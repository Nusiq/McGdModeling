extends MovableComponent

class_name McCubeMovableComponentImpl

var owner: McCube = null

func _init(_owner: McCube) -> void:
	owner = _owner

func get_position() -> Vector3:
	return owner.global_position

func move(delta: Vector3) -> void:
	var target := _movement_start + delta
	owner.global_position = target

func reset() -> void:
	owner.global_position = _movement_start