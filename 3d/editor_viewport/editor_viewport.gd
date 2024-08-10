extends Node3D

class_name EditorViewport

#region Node Handles
@onready var camera_target: Node3D = $CameraTarget
@onready var camera_yaw: Node3D = $CameraTarget/CameraYaw
@onready var camera_pitch: Node3D = $CameraTarget/CameraYaw/CameraPitch
@onready var camera: Camera3D = $CameraTarget/CameraYaw/CameraPitch/Camera3D
@onready var mouse_gesture: MouseGesture = $MouseGesture
#endregion


## Controls the state of performing mouse gestures
var is_mouse_gesture := false
## Staring zoom value for zoom mouse gesture
var gesture_zoom_start := 0.0
## Starting rotation value for rotation mouse gesture
var gesture_rotate_start := Vector3.ZERO
## Starting position for pan mouse gesture
var gesture_pan_start := Vector3.ZERO
 

#region Gesture Interface Config
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
#endregion


## Emitted when the camera global transform changes. Useful for tracking the
## camera position to handle the 3D gui element changes.
signal camera_transform_changed(global_camera_transform: Transform3D)
@onready var _prev_global_camera_transform: Transform3D = get_global_camera_transform()

## Emitted when the camera target global transform changes. Useful for tracking
## the camera target position to handle the 3D gui element changes.
signal camera_target_transform_changed(global_camera_transform: Transform3D)
@onready var _prev_global_camera_target_transform: Transform3D = \
	get_global_camera_target_transform()

func get_global_camera_transform() -> Transform3D:
	return camera.global_transform

func get_global_camera_target_transform() -> Transform3D:
	return camera_target.global_transform

#region Gesture Interface
## Called from the child node $MouseGesture. Handles the mouse gesture
## of rotateing the camera. 
func _on_rotate_gesture(delta_poz: Vector2) -> void:
	if not is_mouse_gesture:
		gesture_rotate_start = Vector3(
			camera_pitch.rotation.x, camera_yaw.rotation.y, 0.0)
		is_mouse_gesture = true
	camera_pitch.rotation.x = fposmod(
		gesture_rotate_start.x - delta_poz.y * rotation_sensitivity, TAU)
	# Reverse yaw if upside down
	var r := (
		1
		if gesture_rotate_start.x > 3.0 / 2.0 * PI
		|| gesture_rotate_start.x < PI / 2
		else -1)
	camera_yaw.rotation.y = fposmod(
		gesture_rotate_start.y - r * delta_poz.x * rotation_sensitivity, TAU)

## Called from the child node $MouseGesture. Handles the mouse gesture
## of panning the camera. 
func _on_pan_gesture(delta_poz: Vector2) -> void:
	if not is_mouse_gesture:
		gesture_zoom_start = camera.position.z # Zoom affects sensitivity
		gesture_pan_start = camera_target.position
		gesture_rotate_start = Vector3(
			camera_pitch.rotation.x, camera_yaw.rotation.y, 0.0)
		is_mouse_gesture = true
	
	var right_left := Vector3.RIGHT.rotated(Vector3.UP, gesture_rotate_start.y)
	var up_down := Vector3.UP.rotated(
		Vector3.LEFT, gesture_rotate_start.x
	).rotated(Vector3.UP, gesture_rotate_start.y)
	camera_target.position = (
		gesture_pan_start +
		up_down * delta_poz.y * gesture_zoom_start * pan_sensitivity +
		right_left * delta_poz.x * gesture_zoom_start * pan_sensitivity
	)

## Called from the child node $MouseGesture. Handles the mouse gesture
## of zooming the camera. 
func _on_zoom_gesture(delta_poz: Vector2) -> void:
	if not is_mouse_gesture:
		gesture_zoom_start = camera.position.z
		is_mouse_gesture = true
	camera.position.z = (
		gesture_zoom_start
		+ gesture_zoom_start * delta_poz.y * zoom_sensitivity)
	if camera.position.z < min_view_distance:
		camera.position.z = min_view_distance
	elif camera.position.z > max_view_distance:
		camera.position.z = max_view_distance

## Called from the child node $MouseGesture when no mouse gesture is
## being performed.
func _on_reset_gesture() -> void:
	if is_mouse_gesture:
		gesture_zoom_start = 0.0
		gesture_rotate_start = Vector3.ZERO
		gesture_pan_start = Vector3.ZERO
		is_mouse_gesture = false
#endregion

## Moves the camera target to the location clicked by the user.
func center_view_to_mouse(mouse_pos: Vector2) -> void:
	var ray_length := 10000.0
	var origin := camera.project_ray_origin(mouse_pos)
	var target := origin + camera.project_ray_normal(mouse_pos) * ray_length
	var space_state := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(origin, target)
	var result := space_state.intersect_ray(query)

	if result:
		camera_target.position = result.position
	else:
		Logging.info(tr("editor_viewport.center_view_to_mouse.no_target"))

func _ready() -> void:
	mouse_gesture.connect("rotate_gesture", _on_rotate_gesture)
	mouse_gesture.connect("pan_gesture", _on_pan_gesture)
	mouse_gesture.connect("zoom_gesture", _on_zoom_gesture)
	mouse_gesture.connect("reset_gesture", _on_reset_gesture)

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
		if is_mouse_gesture:
			return
		_on_zoom_gesture(Vector2.UP * zoom_sensitivity_scrolling)
	elif event.is_action_pressed("shortcut.zoom_out_view", false, true):
		if is_mouse_gesture:
			return
		_on_zoom_gesture(Vector2.DOWN * zoom_sensitivity_scrolling)
	elif event.is_action_pressed("shortcut.center_view_to_mouse", false, true):
		center_view_to_mouse(
			# Using position from mouse_gesture object and not from the event
			# because the user could rebind the shortcut to a keyboard event
			mouse_gesture.get_local_mouse_position())
