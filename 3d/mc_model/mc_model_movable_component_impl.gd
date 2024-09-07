extends MovableComponent

class_name McModelMovableComponentImpl

var owner: McModel = null

func _init(_owner: McModel) -> void:
	owner = _owner

# IMPLEMENTATION OF THE MOVABLE COMPONENT INTERFACE

func get_position() -> Vector3:
	return owner.global_position

func move(delta: Vector3) -> void:
	var target := _movement_start + delta
	owner.global_position = target

func reset() -> void:
	owner.global_position = _movement_start

func stop_moving() -> void:
	pass # Nothing to do. The models don't need to update anything.