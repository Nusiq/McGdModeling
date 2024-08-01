extends ModelNode

class_name McBone

## The scene that coresponds to the Bone object
const this_scene = preload("res://3d/mc_bone/mc_bone.tscn")

## The value of the parent property of the bone. Used for syncing with the
## actual bone hierarchy, but can point to a non-existing bone and still be
## exported when saving the model. The model object is responsible for
## maintaining the correct structure.
var mc_parent: StringOption = null

## The value of the name property of the bone. Can be different fron the node
## name. The model object is responsible for maintaining the correct structure.
var mc_name: String = ""

## Create the Bone object with its coresponding scene
static func new_scene() -> McBone:
	var result: McBone = this_scene.instantiate()
	result.connect_child_references()
	return result

func _ready() -> void:
	super._ready()

## Adds new cube to the bone. Returns a handle for the newly created object.
## Optionally, a McCube object can be passed, in which case no new object is
## created and the passed object is added as a child.
func add_cube(child: McCube=null) -> McCube:
	if child == null:
		child = McCube.new_scene()
	elif child.get_parent() != null:
		child.get_parent().remove_child(child)
	counter_pivot.add_child(child)
	return child

## Adds new child bone to this bone. Returns a handle for the newly created
## object. Optionally, a McBone object can be passed, in which case no new
## object is created and the passed object is added as a child.
func add_bone(child: McBone=null) -> McBone:
	if child == null:
		child = McBone.new_scene()
	elif child.get_parent() != null:
		child.get_parent().remove_child(child)
	counter_pivot.add_child(child)
	return child

## Returns all the bones that are children of this bone.
func get_bones() -> Array[McBone]:
	var bones: Array[McBone] = []
	for child in counter_pivot.get_children():
		if child is McBone:
			bones.append(child)
	return bones

## Returns all the cubes that are children of this bone.
func get_cubes() -> Array[McCube]:
	var cubes: Array[McCube] = []
	for child in counter_pivot.get_children():
		if child is McCube:
			cubes.append(child)
	return cubes

## Loads the JSON object data into the bone. Optionally, the path_so_far
## parameter can be specified for error reporting. This property defines
## the path in the JSON file.
func load_from_object(obj: Dictionary, path_so_far: Array=[]) -> WrappedError:
	# Name (required)
	var name_str := XJSON.get_string_from_object(obj, "name", path_so_far)
	if name_str.error:
		return name_str.error.pass_()
	# Parent (optional, but if exists must be valid)
	mc_name = name_str.value
	if "parent" in obj:  # If the parent property exists it must be a string.
		var parent_str := XJSON.get_string_from_object(
			obj, "parent", path_so_far)
		if parent_str.error:  # Has parent but it's not a string!
			return parent_str.error.pass_()
		else:
			mc_parent = StringOption.new(parent_str.value)
	else:
		mc_parent = null
	# Pivot (optional)
	var pivot_arr := XJSON.get_vector3_from_object(obj, "pivot", path_so_far)
	if pivot_arr.error:
		Logging.warning(str(pivot_arr.error.pass_()))
	else:
		mc_pivot = pivot_arr.value
	# Rotation (optional, can be missing)
	if "rotation" in obj:
		var rotation_arr := XJSON.get_vector3_from_object(
			obj, "rotation", path_so_far)
		if rotation_arr.error:
			Logging.warning(str(rotation_arr.error.pass_()))
		else:
			mc_rotation = rotation_arr.value
	# Cubes (optional, can be missing)
	if "cubes" in obj:
		var cubes := XJSON.get_array_from_object(obj, "cubes", path_so_far)
		if cubes.error:
			Logging.warning(str(cubes.error.pass_()))
		else:
			for cube_i in range(cubes.value.size()):
				var cube_path := path_so_far + ["cubes", cube_i]
				var cube := XJSON.get_object_from_array(
					cubes.value, cube_i, cube_path)
				if cube.error:
					Logging.warning(str(cube.error.pass_()))
					continue
				var cube_node := McCube.new_scene()
				var err := cube_node.load_from_object(cube.value, cube_path)
				if err:
					cube_node.queue_free()
					Logging.warning(str(err.pass_()))
				else:
					add_cube(cube_node)
	return null
