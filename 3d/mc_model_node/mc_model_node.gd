extends Node3D

## A base class of of the 3D components of the Minecraft model like
## cubes and bones.
class_name ModelNode

## Represents a pivot for applying the rotation.
@onready var pivot: Node3D = $Pivot

## A node that always positions itself to counter the positoin change of the
## pivot. This way moving pivot doesn't move the children of the object but
## changes how the rotation affects them.
@onready var counter_pivot: Node3D = $Pivot/CounterPivot

## Translates directly to the rotation property of the node in Minecraft model.
@export var mc_rotation: Vector3 = Vector3.ZERO:
	set(value):
		mc_rotation = value
		if pivot == null:
			return
		pivot.rotation = value * PI/180 * Convertions.MC_GD_ROT
	get:
		return mc_rotation

## Translates directly to the pivot property of the node in Minecraft model.
@export var mc_pivot: Vector3 = Vector3.ZERO:
	set(value):
		mc_pivot = value
		if pivot == null:
			return
		pivot.position = value * Convertions.MC_GD_LOC
		counter_pivot.position = -value * Convertions.MC_GD_LOC
	get:
		return mc_pivot

func _ready() -> void:
	# This seemingly useless piece of code updates the internal properties of
	# this node's child nodes, triggering updates via their setters. It also
	# redraws the mesh.
	mc_rotation = mc_rotation
	mc_pivot = mc_pivot