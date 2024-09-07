## A component that can be added to a node to make it movable.
class_name MovableComponent

var _movement_start: Vector3 = Vector3.ZERO

func get_position() -> Vector3:
	assert(false, "Not implemented")
	return Vector3.ZERO

func start_moving() -> Vector3:
	_movement_start = get_position()
	return _movement_start

func move(_delta: Vector3) -> void:
	assert(false, "Not implemented")

func reset() -> void:
	assert(false, "Not implemented")

func stop_moving() -> void:
	assert(false, "Not implemented")
