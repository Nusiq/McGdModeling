extends Node3D

## Represents a bone in a Minecraft model.
class_name Bone

## Represents the pivot of the bone
@onready var pivot: Node3D = $Pivot

## A node that always positions itself to counter the positoin change of the
## pivot. This way moving pivot doesn't move the children of the bone but
## changes how the rotation affects them.
@onready var counter_pivot: Node3D = $Pivot/CounterPivot

## Translates directly to the rotation property of the bone in Minecraft model.
@export var mc_rotation: Vector3 = Vector3.ZERO:
	set(value):
		mc_rotation = value
		if pivot == null:
			return
		pivot.rotation = value * PI/180 * Convertions.MC_GD_ROT
	get:
		return mc_rotation

## Translates directly to the pivot property of the bone in Minecraft model.
@export var mc_pivot: Vector3 = Vector3.ZERO:
	set(value):
		mc_pivot = value
		if pivot == null:
			return
		pivot.position = value * Convertions.MC_GD_LOC
		counter_pivot.position = -value * Convertions.MC_GD_LOC
	get:
		return mc_pivot

## The scene that coresponds to the Bone object
const this_scene = "res://3d/bone/bone.tscn"

## Create the Bone object with its coresponding scene
static func new_scene() -> Bone:
	return preload(this_scene).instantiate()

func _ready() -> void:
	# This seemingly useless piece of code updates the internal properties of
	# this node's child nodes, triggering updates via their setters. It also
	# redraws the mesh.
	mc_rotation = mc_rotation
	mc_pivot = mc_pivot

func _process(_delta: float) -> void:
	pass

## Adds new cube to the bone. Returns a handle for the newly created object.
func add_cube() -> Cube:
	var cube := Cube.new_scene()
	counter_pivot.add_child(cube)
	return cube

## Adds new child bone to this bone. Returns a handle for the newly created
## object.
func add_bone() -> Bone:
	var bone := Bone.new_scene()
	counter_pivot.add_child(bone)
	return bone

