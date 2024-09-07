extends Node3D

class_name EditorViewport

class MouseGesterConditionImpl extends MouseGesture.Condition:
	func move_object_gesture_condition() -> bool:
		return ModeManager.count_selected_objects() > 0

@onready var camera_target: Node3D = $CameraTarget
@onready var camera_yaw: Node3D = $CameraTarget/CameraYaw
@onready var camera_pitch: Node3D = $CameraTarget/CameraYaw/CameraPitch
@onready var camera: Camera3D = $CameraTarget/CameraYaw/CameraPitch/Camera3D
@onready var mouse_gesture: MouseGesture = $MouseGesture

@onready var global_axes: AxesShader = $CameraTarget/CameraYaw/CameraPitch/Camera3D/AxesShader

## Axes displayed during performing operations on objects (like moving)
@onready var operation_axes: AxesShader = $CameraTarget/CameraYaw/CameraPitch/Camera3D/AxesShader2

## Staring zoom value for zoom mouse gesture
var gesture_zoom_start := 0.0
## Starting rotation value for rotation mouse gesture
var gesture_rotate_start := Vector3.ZERO
## Starting position for pan mouse gesture
var gesture_pan_start := Vector3.ZERO

# Gestures configuration
@onready var rotation_sensitivity := UserConfig.load_float(
	"editor_viewport.rotation_sensitivity", 5.0, 0.5, 100.0)
@onready var zoom_sensitivity := UserConfig.load_float(
	"editor_viewport.zoom_sensitivity", 2.0, 0.5, 100.0)
@onready var zoom_sensitivity_scrolling := UserConfig.load_float(
	"editor_viewport.zoom_sensitivity_scrolling", 0.08, 0.01, 0.5)
@onready var pan_sensitivity := UserConfig.load_float(
	"editor_viewport.pan_sensitivity", 2.0, 0.5, 100.0)
@onready var min_view_distance := UserConfig.load_float(
	"editor_viewport.min_view_distance", 0.1, 0.02, 2.0)
@onready var max_view_distance := UserConfig.load_float(
	"editor_viewport.max_view_distance", 1000, 100, 10_000.0)

# Tmp variables to track various states
@onready var _prev_global_camera_transform: Transform3D = \
	get_global_camera_transform()
@onready var _prev_global_camera_target_transform: Transform3D = \
	get_global_camera_target_transform()
var _move_gesture_start_world_space: Vector3 = Vector3.ZERO
var _move_gesture_start_camera_space: Vector2 = Vector2.ZERO
var _move_gesture_plane: Plane = Plane(Vector3.UP, Vector3.ZERO)
var _move_gesture_line: Vector3Option = null
var _move_gesture_affected_objects: Array[MovableComponent] = []
enum MoveGestureSpace {
	CAMERA_NEAR_1,
	CAMERA_NEAR_2,
	CAMERA_NEAR_3,
	CAMERA_ALIGNED,
	X,
	Y,
	Z,
	YZ,
	XZ,
	XY
}
var _move_gesture_space := MoveGestureSpace.CAMERA_ALIGNED

## Emitted when the camera global transform changes. Useful for tracking the
## camera position to handle the 3D gui element changes.
signal camera_transform_changed(global_camera_transform: Transform3D)

## Emitted when the camera target global transform changes. Useful for tracking
## the camera target position to handle the 3D gui element changes.
signal camera_target_transform_changed(global_camera_transform: Transform3D)

func get_global_camera_transform() -> Transform3D:
	return camera.global_transform

func get_global_camera_target_transform() -> Transform3D:
	return camera_target.global_transform

# Gesture handlers
## Called from the child node $MouseGesture. Handles the mouse gesture
## of rotateing the camera. 
func _on_rotate_gesture(
		delta_pos: Vector2, gesture_stage: MouseGesture.GestureStage) -> void:
	delta_pos = delta_pos / mouse_gesture.size
	if gesture_stage == MouseGesture.GestureStage.JUST_STARTED:
		gesture_rotate_start = Vector3(
			camera_pitch.rotation.x, camera_yaw.rotation.y, 0.0)
	camera_pitch.rotation.x = fposmod(
		gesture_rotate_start.x - delta_pos.y * rotation_sensitivity, TAU)
	# Reverse yaw if upside down
	var r := (
		1
		if gesture_rotate_start.x > 3.0 / 2.0 * PI
		|| gesture_rotate_start.x < PI / 2
		else -1)
	camera_yaw.rotation.y = fposmod(
		gesture_rotate_start.y - r * delta_pos.x * rotation_sensitivity, TAU)

## Called from the child node $MouseGesture. Handles the mouse gesture
## of panning the camera. 
func _on_pan_gesture(
		delta_pos: Vector2, gesture_stage: MouseGesture.GestureStage) -> void:
	delta_pos = delta_pos / mouse_gesture.size
	if gesture_stage == MouseGesture.GestureStage.JUST_STARTED:
		gesture_zoom_start = camera.position.z # Zoom affects sensitivity
		gesture_pan_start = camera_target.position
		gesture_rotate_start = Vector3(
			camera_pitch.rotation.x, camera_yaw.rotation.y, 0.0)
	
	var right_left := Vector3.RIGHT.rotated(Vector3.UP, gesture_rotate_start.y)
	var up_down := Vector3.UP.rotated(
		Vector3.LEFT, gesture_rotate_start.x
	).rotated(Vector3.UP, gesture_rotate_start.y)
	camera_target.position = (
		gesture_pan_start +
		up_down * delta_pos.y * gesture_zoom_start * pan_sensitivity +
		right_left * delta_pos.x * gesture_zoom_start * pan_sensitivity
	)

## Called from the child node $MouseGesture. Handles the mouse gesture
## of zooming the camera. 
func _on_zoom_gesture(
		delta_pos: Vector2, gesture_stage: MouseGesture.GestureStage) -> void:
	delta_pos = delta_pos / mouse_gesture.size
	if gesture_stage == MouseGesture.GestureStage.JUST_STARTED:
		gesture_zoom_start = camera.position.z
	change_zoom(gesture_zoom_start, delta_pos.y)

## Changes the zoom of the camera assuming that the camera's original position
## is starting_camera_position_z and the delta is the change in the zoom.
func change_zoom(starting_camera_position_z: float, delta: float) -> void:
	camera.position.z = (
		starting_camera_position_z
		+ starting_camera_position_z * delta * zoom_sensitivity)
	if camera.position.z < min_view_distance:
		camera.position.z = min_view_distance
	elif camera.position.z > max_view_distance:
		camera.position.z = max_view_distance


class _CosIndexPair:
	var cosine: float
	var index: int
	func _init(_cosine: float, _index: int) -> void:
		cosine = _cosine
		index = _index

func _sort_normals_by_camera_alignment(
		normals: Array[Vector3]) -> Array[Vector3]:
	# Array of pairs (cosine, index)
	var cosines: Array[_CosIndexPair] = []
	for i in range(normals.size()):
		cosines.append(_CosIndexPair.new(
			normals[i].dot(camera.global_transform.basis.z),
			i))
	cosines.sort_custom(
		func(a: _CosIndexPair, b: _CosIndexPair) -> bool:
			return a.cosine > b.cosine)
	var sorted_normals: Array[Vector3] = []
	for cosine in cosines:
		sorted_normals.append(normals[cosine.index])
	return sorted_normals

func update_move_gesture_space() -> void:
	# Assume no line lock (which is true for most of the cases)
	_move_gesture_line = null

	if _move_gesture_space == MoveGestureSpace.CAMERA_ALIGNED:
		_move_gesture_plane = Plane(
			camera.global_transform.basis.z, # Normal
			_move_gesture_start_world_space) # Point
	elif _move_gesture_space in [
			MoveGestureSpace.CAMERA_NEAR_1,
			MoveGestureSpace.CAMERA_NEAR_2,
			MoveGestureSpace.CAMERA_NEAR_3,
			MoveGestureSpace.X, MoveGestureSpace.Y, MoveGestureSpace.Z]:
		# The single axis aligned movemend is handled a little bit differently
		# but we still project to a plane.
		var normals: Array[Vector3] = []
		# Moving along line X - set line to X, else add left/right
		if _move_gesture_space == MoveGestureSpace.X:
			_move_gesture_line = Vector3Option.new(Vector3.RIGHT)
		else:
			normals.append_array([Vector3.LEFT, Vector3.RIGHT])
		# Moving along line Y - set line to Y, else add up/down
		if _move_gesture_space == MoveGestureSpace.Y:
			_move_gesture_line = Vector3Option.new(Vector3.UP)
		else:
			normals.append_array([Vector3.UP, Vector3.DOWN])
		# Moving along line Z - set line to Z, else add forward/back
		if _move_gesture_space == MoveGestureSpace.Z:
			_move_gesture_line = Vector3Option.new(Vector3.FORWARD)
		else:
			normals.append_array([Vector3.FORWARD, Vector3.BACK])

		# If it's the CAMERA_NEAR_1 all normals are valid.
		normals = _sort_normals_by_camera_alignment(normals)
		var index := 0
		match _move_gesture_space:
			MoveGestureSpace.CAMERA_NEAR_2:
				index = 1
			MoveGestureSpace.CAMERA_NEAR_3:
				index = 2
		_move_gesture_plane = Plane(
			normals[index], # Normal
			_move_gesture_start_world_space) # Point
	elif _move_gesture_space == MoveGestureSpace.XY:
		_move_gesture_plane = Plane(
			Vector3.FORWARD, _move_gesture_start_world_space)
	elif _move_gesture_space == MoveGestureSpace.XZ:
		_move_gesture_plane = Plane(
			Vector3.UP, _move_gesture_start_world_space)
	elif _move_gesture_space == MoveGestureSpace.YZ:
		_move_gesture_plane = Plane(
			Vector3.RIGHT, _move_gesture_start_world_space)

	operation_axes.set_axis_origin(_move_gesture_start_world_space)
	# The operation_axes represent a plane. We're moving the object along the
	# X and Y axes (the plane's surface), unless it's locked to a single axis.
	match _move_gesture_space:
		MoveGestureSpace.X:
			operation_axes.set_axis_rotation(Vector3.ZERO)
			operation_axes.set_axes_mask(AxesShader.Mask.X)
		MoveGestureSpace.Y:
			operation_axes.set_axis_rotation(Vector3.ZERO)
			operation_axes.set_axes_mask(AxesShader.Mask.Y)
		MoveGestureSpace.Z:
			operation_axes.set_axis_rotation(Vector3.ZERO)
			operation_axes.set_axes_mask(AxesShader.Mask.Z)
		_:
			# Get Euler angles from the plane normal. It's basically like the spherical
			# coordinates, but we don't care about the radius. We need 2 angles to
			# represent our desired rotation
			var euler := Vector3(
				0.0,
				atan2(_move_gesture_plane.normal.x, -_move_gesture_plane.normal.z),
				atan2(_move_gesture_plane.normal.y, _move_gesture_plane.normal.z)
			) / PI * 180.0 # We need to convert to degrees
			operation_axes.set_axis_rotation(euler)
			operation_axes.set_axes_mask(AxesShader.Mask.X | AxesShader.Mask.Y)
	

## Called from the child node $MouseGesture. Handles the mouse gesture
## of moving an object.
func _on_move_object_gesture(
		delta_pos: Vector2, gesture_stage: MouseGesture.GestureStage) -> void:
	if gesture_stage == MouseGesture.GestureStage.JUST_STARTED:
		_move_gesture_affected_objects = ModeManager.get_selected_movable_objects()
		# Calculate the average position of the selected objects
		_move_gesture_start_world_space = Vector3.ZERO
		for movable in _move_gesture_affected_objects:
			_move_gesture_start_world_space += movable.start_moving()
		_move_gesture_start_world_space /= _move_gesture_affected_objects.size()
		_move_gesture_start_camera_space = camera.unproject_position(
			_move_gesture_start_world_space)
		_move_gesture_space = MoveGestureSpace.CAMERA_ALIGNED
		update_move_gesture_space()
	elif gesture_stage == MouseGesture.GestureStage.RETAPPED:
		match _move_gesture_space:
			MoveGestureSpace.CAMERA_ALIGNED:
				_move_gesture_space = MoveGestureSpace.CAMERA_NEAR_1
			MoveGestureSpace.CAMERA_NEAR_1:
				_move_gesture_space = MoveGestureSpace.CAMERA_NEAR_2
			MoveGestureSpace.CAMERA_NEAR_2:
				_move_gesture_space = MoveGestureSpace.CAMERA_NEAR_3
			_:
				_move_gesture_space = MoveGestureSpace.CAMERA_ALIGNED
		update_move_gesture_space()
	elif gesture_stage == MouseGesture.GestureStage.CANCELLED:
		operation_axes.set_axes_mask(0)
		for movable in _move_gesture_affected_objects:
			movable.reset()
		return
	# UPDATE or SUCCESSFUL_END
	var intersection: Variant = _move_gesture_plane.intersects_ray(
		camera.project_ray_origin(_move_gesture_start_camera_space + delta_pos),
		camera.project_ray_normal(_move_gesture_start_camera_space + delta_pos))
	if intersection is Vector3:
		if _move_gesture_line != null:
			# Project the intersection point onto the line
			intersection = (
				intersection - _move_gesture_start_world_space
			).project(_move_gesture_line.value)
			intersection = intersection + _move_gesture_start_world_space
		var delta := (intersection as Vector3) - _move_gesture_start_world_space
		for movable in _move_gesture_affected_objects:
			movable.move(delta)
	else:
		for movable in _move_gesture_affected_objects:
			movable.move(Vector3.ZERO)
	if gesture_stage == MouseGesture.GestureStage.SUCCESSFUL_END:
		operation_axes.set_axes_mask(0)

## Casts a ray from the mouse position to the 3D world.
## See the PhysicsDirectSpaceState3D.intersect_ray() for more information about
## the structure of the returned dictionary.
func cast_ray_from_mouse(mouse_pos: Vector2) -> Dictionary:
	var ray_length := 10000.0
	var origin := camera.project_ray_origin(mouse_pos)
	var target := origin + camera.project_ray_normal(mouse_pos) * ray_length
	var space_state := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(origin, target)
	return space_state.intersect_ray(query)

## Moves the camera target to the location clicked by the user.
func center_view_to_mouse(mouse_pos: Vector2) -> void:
	var result := cast_ray_from_mouse(mouse_pos)
	if result:
		camera_target.position = result.position
	else:
		Logging.info(tr("editor_viewport.center_view_to_mouse.no_target"))

func click_mouse(mouse_pos: Vector2, is_adding: bool) -> void:
	var result := cast_ray_from_mouse(mouse_pos)
	
	if len(result) == 0: # No collision
		if is_adding:
			return
		ModeManager.deselect_all_in_context()
		return
	if not result.collider is McCubeStaticBody3D:
		return
	var collider: McCubeStaticBody3D = result.collider
	ModeManager.select_object_in_context(collider, is_adding)

func _ready() -> void:
	mouse_gesture.rotate_gesture.connect(_on_rotate_gesture)
	mouse_gesture.pan_gesture.connect(_on_pan_gesture)
	mouse_gesture.zoom_gesture.connect(_on_zoom_gesture)
	mouse_gesture.move_object_gesture.connect(_on_move_object_gesture)
	mouse_gesture.condition = MouseGesterConditionImpl.new()

func _process(_delta: float) -> void:
	# Check and notify the changes in the global camera transform
	if camera.global_transform != _prev_global_camera_transform:
		_prev_global_camera_transform = camera.global_transform
		camera_transform_changed.emit(camera.global_transform)
	if camera_target.global_transform != _prev_global_camera_target_transform:
		_prev_global_camera_target_transform = camera_target.global_transform
		camera_target_transform_changed.emit(camera_target.global_transform)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("shortcut.zoom_in_view", false, true):
		change_zoom(camera.position.z, -zoom_sensitivity_scrolling)
	elif event.is_action_pressed("shortcut.zoom_out_view", false, true):
		change_zoom(camera.position.z, zoom_sensitivity_scrolling)
	elif event.is_action_pressed("shortcut.center_view_to_mouse", false, true):
		center_view_to_mouse(
			# Using position from mouse_gesture object and not from the event
			# because the user could rebind the shortcut to a keyboard event
			mouse_gesture.get_local_mouse_position())
	elif (
			mouse_gesture.current_gesture == MouseGesture.Gesture.NONE and
			event.is_action_pressed("shortcut.viewport_click", false, false)):
		click_mouse(
			mouse_gesture.get_local_mouse_position(),
			Input.is_key_pressed(KEY_SHIFT)
		)
	elif mouse_gesture.current_gesture == MouseGesture.Gesture.MOVING_OBJECT:
		if event.is_action_pressed("shortcut.move_object.lock_axis_x", false, true):
			_move_gesture_space = MoveGestureSpace.X
			update_move_gesture_space()
		elif event.is_action_pressed("shortcut.move_object.lock_axis_y", false, true):
			_move_gesture_space = MoveGestureSpace.Y
			update_move_gesture_space()
		elif event.is_action_pressed("shortcut.move_object.lock_axis_z", false, true):
			_move_gesture_space = MoveGestureSpace.Z
			update_move_gesture_space()
		elif event.is_action_pressed("shortcut.move_object.lock_surface_x", false, true):
			_move_gesture_space = MoveGestureSpace.YZ
			update_move_gesture_space()
		elif event.is_action_pressed("shortcut.move_object.lock_surface_y", false, true):
			_move_gesture_space = MoveGestureSpace.XZ
			update_move_gesture_space()
		elif event.is_action_pressed("shortcut.move_object.lock_surface_z", false, true):
			_move_gesture_space = MoveGestureSpace.XY
			update_move_gesture_space()
