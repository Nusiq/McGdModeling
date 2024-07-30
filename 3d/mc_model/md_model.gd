extends Node3D

## Represents a Minecraft model.
class_name McModel

var identifier := ""
var texture_width := 64
var texture_height := 64
var visible_bounds_width := 1
var visible_bounds_height := 1
var visible_bounds_offset_x := Vector3(0, 0, 0)

## Adds new bone to the model. Returns a handle for the newly created object.
func add_bone() -> McBone:
	var bone := McBone.new_scene()
	add_child(bone)
	return bone


## Returns all of the bones that are children of this model.
func get_root_bones() -> Array[McBone]:
	var result: Array[McBone] = []
	for child in get_children():
		if child is McBone:
			result.append(child)
	return result

## Returns all of the bones that are children of this model.
func get_all_bones() -> Array[McBone]:
	var result: Array[McBone] = []
	var bones_to_check := get_root_bones()
	while bones_to_check.size() > 0:
		# "as McBone" is safe a cast becayse size() > 0
		var bone := bones_to_check.pop_front() as McBone
		# Append the bone and add its children to check.
		result.append(bone)
		bones_to_check.append_array(bone.get_bones())
	return result
