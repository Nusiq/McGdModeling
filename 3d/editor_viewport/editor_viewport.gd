extends Node3D

class_name EditorViewport

#region Node Handles
@onready var camera_target: Node3D = $CameraTarget
@onready var camera_yaw: Node3D = $CameraTarget/CameraYaw
@onready var camera_pitch: Node3D = $CameraTarget/CameraYaw/CameraPitch
@onready var camera: Camera3D = $CameraTarget/CameraYaw/CameraPitch/Camera3D
@onready var mouse_gesture: MouseGesture = $MouseGesture
#endregion

#region Gesture Interface Config
## Controls the state of performing mouse gestures
var is_mouse_gesture := false
## Staring zoom value for zoom mouse gesture
var gesture_zoom_start := 0.0
## Starting rotation value for rotation mouse gesture
var gesture_rotate_start := Vector3.ZERO
## Starting position for pan mouse gesture
var gesture_pan_start := Vector3.ZERO
 
const ROTATION_SENSITIVITY_MULTIPLIER = 5.0

const ZOOM_SENSITIVITY_MULTIPLIER = 2.0
const MIN_VIEW_DISTANCE = 0.02
const MAX_VIEW_DISTANCE = 10_000.0

const PAN_SENSITIVITY_MULTIPLIER = 2.0
#endregion

#region Gesture Interface
## Called from the child node $MouseGesture. Handles the mouse gesture
## of rotateing the camera. 
func on_rotate(delta_poz: Vector2) -> void:
	if not is_mouse_gesture:
		gesture_rotate_start = Vector3(
			camera_pitch.rotation.x, camera_yaw.rotation.y, 0.0)
		is_mouse_gesture = true
	camera_pitch.rotation.x = fposmod(
		gesture_rotate_start.x- delta_poz.y*ROTATION_SENSITIVITY_MULTIPLIER, TAU)
	# Reverse yaw if upside down
	var r := (
		1
		if gesture_rotate_start.x > 3.0/2.0*PI || gesture_rotate_start.x < PI/2
		else -1)
	camera_yaw.rotation.y = fposmod(
		gesture_rotate_start.y-r*delta_poz.x*ROTATION_SENSITIVITY_MULTIPLIER, TAU)

## Called from the child node $MouseGesture. Handles the mouse gesture
## of panning the camera. 
func on_pan(delta_poz: Vector2) -> void:
	if not is_mouse_gesture:
		gesture_zoom_start = camera.position.z
		gesture_pan_start = camera_target.position
		gesture_rotate_start = Vector3(
			camera_pitch.rotation.x, camera_yaw.rotation.y, 0.0)
		is_mouse_gesture = true
	
	var rotate_basis := Basis.from_euler(gesture_rotate_start)
	camera_target.position = (
		gesture_pan_start +
		rotate_basis.y * delta_poz.y*gesture_zoom_start*PAN_SENSITIVITY_MULTIPLIER +
		rotate_basis.x * -delta_poz.x*gesture_zoom_start*PAN_SENSITIVITY_MULTIPLIER
	)

## Called from the child node $MouseGesture. Handles the mouse gesture
## of zooming the camera. 
func on_zoom(delta_poz: Vector2) -> void:
	if not is_mouse_gesture:
		gesture_zoom_start = camera.position.z
		is_mouse_gesture = true
	camera.position.z = (
		gesture_zoom_start + gesture_zoom_start*delta_poz.y*ZOOM_SENSITIVITY_MULTIPLIER)
	if camera.position.z < MIN_VIEW_DISTANCE:
		camera.position.z = MIN_VIEW_DISTANCE
	elif camera.position.z > MAX_VIEW_DISTANCE:
		camera.position.z = MAX_VIEW_DISTANCE

## Called from the child node $MouseGesture when no mouse gesture is
## being performed.
func on_reset_gesture() -> void:
	if is_mouse_gesture:
		gesture_zoom_start = 0.0
		gesture_rotate_start = Vector3.ZERO
		gesture_pan_start = Vector3.ZERO
		is_mouse_gesture = false
#endregion

#region Setup Functions
func draw_axes() -> void:
	var mesh: ImmediateMesh = ImmediateMesh.new()

	mesh.clear_surfaces()
	mesh.surface_begin(Mesh.PRIMITIVE_LINES)

	# X axis (red)
	mesh.surface_set_color(Color.RED)
	mesh.surface_add_vertex(Vector3.ZERO)
	mesh.surface_add_vertex(Vector3(1, 0, 0))

	# Y axis (green) 
	mesh.surface_set_color(Color.GREEN)
	mesh.surface_add_vertex(Vector3.ZERO)
	mesh.surface_add_vertex(Vector3(0, 1, 0))

	# Z axis (blue)
	mesh.surface_set_color(Color.BLUE) 
	mesh.surface_add_vertex(Vector3.ZERO)
	mesh.surface_add_vertex(Vector3(0, 0, 1))
	mesh.surface_end()

	var material := StandardMaterial3D.new()
	material.vertex_color_use_as_albedo = true

	var mesh_instance := MeshInstance3D.new()
	mesh_instance.mesh = mesh
	mesh_instance.set_surface_override_material(0, material)

	add_child(mesh_instance)

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
		print("No object was clicked.")

func _ready() -> void:
	draw_axes()

func _process(_delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("shortcut.zoom_in_view", false, true):
		if is_mouse_gesture:
			return
		on_zoom(Vector2.UP * 0.08)
	elif event.is_action_pressed("shortcut.zoom_out_view", false, true):
		if is_mouse_gesture:
			return
		on_zoom(Vector2.DOWN * 0.08)
	elif event.is_action_pressed("shortcut.center_view_to_mouse", false, true):
		center_view_to_mouse(
			# Using position from mouse_gesture object and not from the event
			# because the user could rebind the shortcut to a keyboard event
			mouse_gesture.get_local_mouse_position())
