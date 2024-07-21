extends Node3D

class_name Cube

@onready var mesh_instance: MeshInstance3D = $Pivot/Mesh
@onready var pivot: Node3D = $Pivot

const faces: Array[int] = [
	3, 2, 1, 3, 1, 0,  # Front: 3,2,1,0
	0, 4, 7, 0, 7, 3,  # Right: 0,4,7,3
	4, 5, 6, 4, 6, 7,  # Back: 4,5,6,7
	2, 6, 5, 2, 5, 1,  # Left: 2,6,5,1
	2, 3, 7, 2, 7, 6,  # Top: 2,3,7,6
	1, 5, 4, 1, 4, 0]  # Bottom: 1,5,4,0

@export var mc_size: Vector3 = Vector3.ONE:
	set(value):
		mc_size = value
		if mesh_instance != null:
			redraw_mesh()
	get:
		return mc_size

@export var mc_rotation: Vector3 = Vector3.ZERO:
	set(value):
		mc_rotation = value
		if pivot == null:
			return
		pivot.rotation = value * PI/180 * Convertions.MC_GD_ROT
	get:
		return mc_rotation

@export var mc_origin: Vector3 = Vector3.ZERO:
	set(value):
		mc_origin = value
		if mesh_instance == null:
			return
		mesh_instance.position = (
			-pivot.position + mc_origin) * Convertions.MC_GD_LOC
	get:
		return mc_origin

@export var mc_pivot: Vector3 = Vector3.ZERO:
	set(value):
		mc_pivot = value
		if pivot == null:
			return
		pivot.position = value * Convertions.MC_GD_LOC
		mesh_instance.position = (
			-value + mc_origin) * Convertions.MC_GD_LOC
	get:
		return mc_pivot


func redraw_mesh() -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	# The set_smooth_group(-1) makes the model use flat shading when
	# the generate_normals() is applied
	st.set_smooth_group(-1)
	var vertices: Array[Vector3] = [
		Vector3(0, 0, 0),
		Convertions.MC_GD_LOC * Vector3(mc_size.x, 0, 0),
		Convertions.MC_GD_LOC * Vector3(mc_size.x, mc_size.y, 0),
		Vector3(0, mc_size.y, 0),
		Vector3(0, 0, mc_size.z),
		Convertions.MC_GD_LOC * Vector3(mc_size.x, 0, mc_size.z),
		Convertions.MC_GD_LOC * Vector3(mc_size.x, mc_size.y, mc_size.z),
		Vector3(0, mc_size.y, mc_size.z)
	]
	for index in faces:
		st.add_vertex(vertices[index])
	st.generate_normals()
	var mesh_data := st.commit()
	mesh_instance.mesh = mesh_data


## The scene that coresponds to the Cube object
const this_scene = "res://3d/cube/cube.tscn"

## Create the Cube object with its coresponding scene
static func new_scene() -> Cube:
	return preload(this_scene).instantiate()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# This seemingly useless piece of code updates the internal properties of
	# this node's child nodes, triggering updates via their setters. It also
	# redraws the mesh.
	mc_size = mc_size
	mc_rotation = mc_rotation
	mc_origin = mc_origin
	mc_pivot = mc_pivot


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
