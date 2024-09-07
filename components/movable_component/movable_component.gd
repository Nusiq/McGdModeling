## A component that can be added to a node to make it movable.
class_name MovableComponent

var _movement_start: Vector3 = Vector3.ZERO

## Returns the position of the movable node. Used in the `start_moving` method
## to get the starting position of the move operation.
func get_position() -> Vector3:
	assert(false, "Not implemented")
	return Vector3.ZERO

## Starts the move operation. Saves the current position to be used during the
## operation in `move` method.
func start_moving() -> Vector3:
	_movement_start = get_position()
	return _movement_start

## Moves the node by the given delta. Should be called as an update during the
## move operation.
func move(_delta: Vector3) -> void:
	assert(false, "Not implemented")

## Resets the move operation. Should be called when the move operation is
## canceled.
func reset() -> void:
	assert(false, "Not implemented")

## Stops the move operation. Should be called when the move operation is
## finished successfully. This method should apply the movement to the node.
func stop_moving() -> void:
	assert(false, "Not implemented")
