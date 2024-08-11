@tool
extends Node3D

## Draws a simple line. The line is always drawn upwards (Y+ direction).
## If you want to draw it pointing in a different direction, you can rotate the
## node.
class_name AxisLine

## Whether the line should be drawn both ways or only in positive direction. If
## double_sided is true, the line will be drawn in both directions. The length
## of the line will be doubled.
@export var double_sided: bool = true:
	get:
		return double_sided
	set(value):
		double_sided = value
		if not is_node_ready(): await ready
		redraw()

## Whether the line should have a fixed size in the screen. If fixed_size is
## true, the line will always have the same size in the screen, regardless of
## the distance to the camera. Useful for drawing axes.
@export var fixed_size: bool = true:
	get:
		return fixed_size
	set(value):
		if material != null:
			material.fixed_size = value
		fixed_size = value

## The length of the line.
@export var length: float = 10.0:
	get:
		return length
	set(value):
		length = value
		if not is_node_ready(): await ready
		redraw()

## The thickness of the line. If thickness is 0.0, the line will be drawn as a
## simple line. If thickness is greater than 0.0, the line will be drawn as a
## cylinder.
@export var thickness: float = 0.0:
	get:
		return thickness
	set(value):
		thickness = value
		if not is_node_ready(): await ready
		redraw()

## The color of the line.
@export var color: Color = Color(1, 1, 1, 1):
	get:
		return color
	set(value):
		if material != null:
			material.albedo_color = color
		color = value

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
var mesh: Mesh = ImmediateMesh.new()
var material: StandardMaterial3D = StandardMaterial3D.new()


func redraw() -> void:
	# Mesh instance might be null before _ready is called
	if mesh_instance == null:
		return
	if thickness <= 0.0:
		if not mesh is ImmediateMesh:
			mesh = ImmediateMesh.new()
		mesh.clear_surfaces()
		mesh.surface_begin(Mesh.PRIMITIVE_LINES)
		if double_sided:
			mesh.surface_add_vertex(Vector3(0, -length, 0))
		else:
			mesh.surface_add_vertex(Vector3(0, 0, 0))
		mesh.surface_add_vertex(Vector3(0, length, 0))
		mesh.surface_end()
		mesh_instance.position = Vector3.ZERO
	else:
		if not mesh is CylinderMesh:
			mesh = CylinderMesh.new()
		mesh.top_radius = thickness
		mesh.bottom_radius = thickness
		if double_sided:
			mesh.height = length * 2
			mesh_instance.position = Vector3.ZERO
		else:
			mesh.height = length
			mesh_instance.position = Vector3(0, length / 2, 0)
	mesh_instance.mesh = mesh

func _ready() -> void:
	# Create the material
	material.shading_mode = StandardMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	material.fixed_size = fixed_size
	# Assign the material to the mesh instance
	mesh_instance.material_override = material
	# Draw the line
	redraw()
