extends ModelNode

class_name McCube

@onready var mesh_instance: MeshInstance3D = $Pivot/CounterPivot/Mesh
@onready var mesh_collision: CollisionShape3D = $Pivot/CounterPivot/Mesh/StaticBody3D/CollisionShape3D

# 0 - front/right/down
# 1 - front/left/down
# 2 - front/left/top
# 3 - front/right/top
# 4 - back/right/down
# 5 - back/left/down
# 6 - back/left/top
# 7 - back/right/top
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

var mc_uv: McCubeUv = null

## A refernece to the bone that owns this node. This should be memory safe
## because for Nodes, Godot uses the tree structure to manage memory.
var owning_bone: McBone = null

func redraw_mesh() -> void:
	# Update collision
	mesh_collision.shape.size = abs(mc_size)
	mesh_collision.position = mc_size / 2 * Convertions.MC_GD_LOC
	

	# Update the actual mesh
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	# The set_smooth_group(-1) makes the model use flat shading when
	# the generate_normals() is applied
	st.set_smooth_group(-1)
	var vertices: Array[Vector3] = [
		# 0 - front/right/down
		Vector3(0, 0, 0),
		# 1 - front/left/down
		Convertions.MC_GD_LOC * Vector3(mc_size.x, 0, 0),
		# 2 - front/left/top
		Convertions.MC_GD_LOC * Vector3(mc_size.x, mc_size.y, 0),
		# 3 - front/right/top
		Vector3(0, mc_size.y, 0),
		# 4 - back/right/down
		Vector3(0, 0, mc_size.z),
		# 5 - back/left/down
		Convertions.MC_GD_LOC * Vector3(mc_size.x, 0, mc_size.z),
		# 6 - back/left/top
		Convertions.MC_GD_LOC * Vector3(mc_size.x, mc_size.y, mc_size.z),
		# 7 - back/right/top
		Vector3(0, mc_size.y, mc_size.z)
	]
	for i in range(len(faces)):
		# Set variable that determines whether we are on front/back,
		# right/left, or top/bottom axis
		var axis: int
		if i < 6: axis = 0 # Front
		elif i < 12: axis = 1 # Right
		elif i < 18: axis = 0 # Back
		elif i < 24: axis = 1 # Left
		elif i < 30: axis = 2 # Top
		else: axis = 2 # Bottom
		var index := faces[i]
		if mc_uv != null and owning_model != null:
			# Prepare function for setting the material, based on the existence
			# of the material provider
			var set_material := func(
				_material_instance: StringOption) -> void: st.set_material(null)
			if owning_model.material_provider != null:
				assert(
					owning_bone != null,
					"Invalid state - cube belongs to a model but doesn't "
					+"belong to a bone.")
				set_material = func(material_instance: StringOption) -> void:
					st.set_material(
						owning_model.material_provider.query_material(
							owning_bone.mc_name, material_instance))
			var uv_coords: Vector2
			# This should cover all posibilities. If not, that's a bug.
			match index:
				0:
					match axis:
						0:
							uv_coords = mc_uv.get_front_right_down_uv_1(mc_size)
							set_material.call(mc_uv.get_front_material_instance())
						1:
							uv_coords = mc_uv.get_front_right_down_uv_2(mc_size)
							set_material.call(mc_uv.get_right_material_instance())
						2:
							uv_coords = mc_uv.get_front_right_down_uv_3(mc_size)
							set_material.call(mc_uv.get_down_material_instance())
				1:
					match axis:
						0:
							uv_coords = mc_uv.get_front_left_down_uv_1(mc_size)
							set_material.call(mc_uv.get_front_material_instance())
						1:
							uv_coords = mc_uv.get_front_left_down_uv_2(mc_size)
							set_material.call(mc_uv.get_left_material_instance())
						2:
							uv_coords = mc_uv.get_front_left_down_uv_3(mc_size)
							set_material.call(mc_uv.get_down_material_instance())
				2:
					match axis:
						0:
							uv_coords = mc_uv.get_front_left_up_uv_1(mc_size)
							set_material.call(mc_uv.get_front_material_instance())
						1:
							uv_coords = mc_uv.get_front_left_up_uv_2(mc_size)
							set_material.call(mc_uv.get_left_material_instance())
						2:
							uv_coords = mc_uv.get_front_left_up_uv_3(mc_size)
							set_material.call(mc_uv.get_up_material_instance())
				3:
					match axis:
						0:
							uv_coords = mc_uv.get_front_right_up_uv_1(mc_size)
							set_material.call(mc_uv.get_front_material_instance())
						1:
							uv_coords = mc_uv.get_front_right_up_uv_2(mc_size)
							set_material.call(mc_uv.get_right_material_instance())
						2:
							uv_coords = mc_uv.get_front_right_up_uv_3(mc_size)
							set_material.call(mc_uv.get_up_material_instance())
				4:
					match axis:
						0:
							uv_coords = mc_uv.get_back_right_down_uv_1(mc_size)
							set_material.call(mc_uv.get_back_material_instance())
						1:
							uv_coords = mc_uv.get_back_right_down_uv_2(mc_size)
							set_material.call(mc_uv.get_right_material_instance())
						2:
							uv_coords = mc_uv.get_back_right_down_uv_3(mc_size)
							set_material.call(mc_uv.get_down_material_instance())
				5:
					match axis:
						0:
							uv_coords = mc_uv.get_back_left_down_uv_1(mc_size)
							set_material.call(mc_uv.get_back_material_instance())
						1:
							uv_coords = mc_uv.get_back_left_down_uv_2(mc_size)
							set_material.call(mc_uv.get_left_material_instance())
						2:
							uv_coords = mc_uv.get_back_left_down_uv_3(mc_size)
							set_material.call(mc_uv.get_down_material_instance())
				6:
					match axis:
						0:
							uv_coords = mc_uv.get_back_left_up_uv_1(mc_size)
							set_material.call(mc_uv.get_back_material_instance())
						1:
							uv_coords = mc_uv.get_back_left_up_uv_2(mc_size)
							set_material.call(mc_uv.get_left_material_instance())
						2:
							uv_coords = mc_uv.get_back_left_up_uv_3(mc_size)
							set_material.call(mc_uv.get_up_material_instance())
				7:
					match axis:
						0:
							uv_coords = mc_uv.get_back_right_up_uv_1(mc_size)
							set_material.call(mc_uv.get_back_material_instance())
						1:
							uv_coords = mc_uv.get_back_right_up_uv_2(mc_size)
							set_material.call(mc_uv.get_right_material_instance())
						2:
							uv_coords = mc_uv.get_back_right_up_uv_3(mc_size)
							set_material.call(mc_uv.get_up_material_instance())
				_:
					assert(false, "Invalid state - face index out of bounds.")
			st.set_uv(
				uv_coords /
				Vector2( # Element-wise division
					owning_model.texture_width,
					owning_model.texture_height))
		st.add_vertex(vertices[index])
	st.generate_normals()
	var mesh_data := st.commit()
	mesh_instance.mesh = mesh_data

## The scene that coresponds to the Cube object
const this_scene = preload("res://3d/mc_cube/mc_cube.tscn")

## Create the Cube object with its coresponding scene
static func new_scene(owning_model_: McModel, owning_bone_: McBone) -> McCube:
	var result := this_scene.instantiate()
	result.owning_model = owning_model_
	result.owning_bone = owning_bone_
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
	# UV (optional, will be replaced with [0,0] if not present)
	if "uv" in obj:
		if obj["uv"] is Array:
			var uv_val := XJSON.get_vector2_from_object(obj, "uv", path_so_far)
			if uv_val.error:
				Logging.warning(str(uv_val.error.pass_()))
				mc_uv = McCubeUVStandard.new()
			else:
				mc_uv = McCubeUVStandard.new()
				mc_uv.uv = uv_val.value
		elif obj["uv"] is Dictionary:
			mc_uv = McCubeUVPerFace.new()
			mc_uv.load_from_object(obj["uv"], path_so_far + ["uv"])
		else:
			Logging.warning(
				WrappedError.new(
					tr("error.mc_cube.load_from_object.uv_wrong_type")
					+ XJSON.json_path_info(path_so_far)
				).to_string()
			)
			mc_uv = McCubeUVStandard.new()
	return null
