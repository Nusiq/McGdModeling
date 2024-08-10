@tool
extends Node3D

class_name Axes

@onready var line_x: Line = $LineX
@onready var line_y: Line = $LineY
@onready var line_z: Line = $LineZ

@export var line_x_visible: bool = true:
	get:
		return line_x.visible
	set(value):
		if not is_node_ready(): await ready
		line_x.visible = value

@export var line_y_visible: bool = true:
	get:
		return line_y.visible
	set(value):
		if not is_node_ready(): await ready
		line_y.visible = value

@export var line_z_visible: bool = true:
	get:
		return line_z.visible
	set(value):
		if not is_node_ready(): await ready
		line_z.visible = value

## The thickness of the axes.
@export var thickness: float = 0.0:
	get:
		return thickness
	set(value):
		thickness = value
		if not is_node_ready(): await ready
		line_x.thickness = value
		line_y.thickness = value
		line_z.thickness = value

## The length of the axes.
@export var length: float = 1.0:
	get:
		return length
	set(value):
		length = value
		if not is_node_ready(): await ready
		line_x.length = value
		line_y.length = value
		line_z.length = value

# The length of the axes when they are infinite. Useful for debugging.
# set it to big value like 10000.0. When tesintg you can set it to smaller value
# like 0.5 to see the ends of the axes.
const LENGTH_WHEN_INFINITE: float = 10000.0

@export var is_infinite: bool = false:
	get:
		return is_infinite
	set(value):
		is_infinite = value
		if not is_node_ready(): await ready
		if value: # Set true
			for line: Line in [line_x, line_y, line_z]:
				line.length = LENGTH_WHEN_INFINITE
				line.double_sided = true
				line.fixed_size = true
		else: # Set false
			for line: Line in [line_x, line_y, line_z]:
				line.length = length
				line.double_sided = false
				line.fixed_size = false
		update_axes_positions()

## The editor viewport to track the camera target transform. The tracking is
## used only when the axes are set to be displayed as inifinite. Axes follow
## the camera target to be always visble (if the camera is looking at them).
@export var editor_viewport: EditorViewport = null:
	get:
		return editor_viewport
	set(value):
		# If it's the same viewport do nothing
		if editor_viewport == value:
			return
		
		# If editor_viewport is already assigned, disconnect the signal from
		# the previous viewport
		if editor_viewport != null:
			if editor_viewport.camera_target_transform_changed.is_connected(
					_on_camera_target_transform_changed):
				editor_viewport.camera_target_transform_changed.disconnect(
					_on_camera_target_transform_changed)
		
		# Connect the signal to the viewport
		if value != null:
			value.camera_target_transform_changed.connect(_on_camera_target_transform_changed)

		# Assign the new viewport
		editor_viewport = value
		update_axes_positions()

## The node that defines the origin and rotation of the axes. If not set, the origin and
## rotation is set to the global origin (0, 0, 0) and no rotation.
@export var origin_node: Node3D = null:
	get:
		return origin_node
	set(value):
		origin_node = value
		update_axes_positions()


## Updates the axes positions and rotations. The axes represent the orientations
## of the origin_node. If the axes are set to be is_infinite, they will follow the
## camera target.
func update_axes_positions() -> void:
	if editor_viewport == null:
		_on_camera_target_transform_changed(Transform3D.IDENTITY)
	else:
		_on_camera_target_transform_changed(
			editor_viewport.get_global_camera_target_transform())

func _on_camera_target_transform_changed(
		camera_target_global_transform: Transform3D) -> void:
	# Set origin and rotation to match the origin_node
	if origin_node == null:
		global_position = Vector3.ZERO
		global_rotation = Vector3.ZERO
	else:
		global_position = origin_node.global_position
		global_rotation = origin_node.global_rotation
	
	# If axes are infinite, project the positions of the axes to match the
	# coordinates of the camera target transform
	if is_infinite:
		# Get the Transform3D that represents the transformation of the camera
		# in the space of the axes (in space of the origin_node or global space)
		var camera_transform_in_this_space := \
			global_transform.inverse() * camera_target_global_transform
		# Update the positions of the axes
		line_x.position.x = camera_transform_in_this_space.origin.x
		line_y.position.y = camera_transform_in_this_space.origin.y
		line_z.position.z = camera_transform_in_this_space.origin.z
	else:
		# Set the positions of the axes to the origin
		line_x.position = Vector3.ZERO
		line_y.position = Vector3.ZERO
		line_z.position = Vector3.ZERO
