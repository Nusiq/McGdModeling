extends ModelNode

class_name McCube

@onready var mesh_instance: MeshInstance3D = $Pivot/CounterPivot/Mesh

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

@export var mc_origin: Vector3 = Vector3.ZERO:
	set(value):
		mc_origin = value
		if mesh_instance == null:
			return
		mesh_instance.position = mc_origin * Convertions.MC_GD_LOC
	get:
		return mc_origin

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
const this_scene = preload("res://3d/mc_cube/mc_cube.tscn")

## Create the Cube object with its coresponding scene
static func new_scene() -> McCube:
	var result := this_scene.instantiate()
	result.connect_child_references()
	return result


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	mc_size = mc_size
	mc_origin = mc_origin

func load_from_object(obj: Dictionary, path_so_far: Array=[]) -> WrappedError:
	# Size (optional)
	var size := XJSON.get_vector3_from_object(obj, "size", path_so_far)
	if size.error:
		Logging.warning(str(size.error.pass_()))
	else:
		mc_size = size.value
	# Origin (optional)
	var origin := XJSON.get_vector3_from_object(obj, "origin", path_so_far)
	if origin.error:
		Logging.warning(str(origin.error.pass_()))
	else:
		mc_origin = origin.value
	# Rotation (optional, it's ok if not present)
	if "rotation" in obj:
		var rotation_val := XJSON.get_vector3_from_object(
			obj, "rotation", path_so_far)
		if rotation_val.error:
			Logging.warning(str(rotation_val.error.pass_()))
		else:
			mc_rotation = rotation_val.value
	# Pivot (optional, it's ok if not present)
	if "pivot" in obj:
		var pivot_val := XJSON.get_vector3_from_object(
			obj, "pivot", path_so_far)
		if pivot_val.error:
			Logging.warning(str(pivot_val.error.pass_()))
		else:
			mc_pivot = pivot_val.value
	return null