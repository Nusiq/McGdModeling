extends ModelNode

class_name McBone

## The scene that coresponds to the Bone object
const this_scene = "res://3d/mc_bone/mc_bone.tscn"

## Create the Bone object with its coresponding scene
static func new_scene() -> McBone:
	return preload(this_scene).instantiate()

func _ready() -> void:
	super._ready()

## Adds new cube to the bone. Returns a handle for the newly created object.
func add_cube() -> McCube:
	var cube := McCube.new_scene()
	counter_pivot.add_child(cube)
	return cube

## Adds new child bone to this bone. Returns a handle for the newly created
## object.
func add_bone() -> McBone:
	var bone := McBone.new_scene()
	counter_pivot.add_child(bone)
	return bone

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