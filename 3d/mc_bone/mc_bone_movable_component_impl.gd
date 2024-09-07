extends MovableComponent

class_name McBoneMovableComponentImpl

var owner: McBone = null

## Added to the returned global_position to render the  move operation UI
## in the pivot point of the cube.
var _pivot_offset: Vector3 = Vector3.ZERO

func _init(_owner: McBone) -> void:
	owner = _owner

func get_position() -> Vector3:
	_pivot_offset = owner.mc_pivot * Convertions.MC_GD_LOC
	return owner.global_position + _pivot_offset

func move(delta: Vector3) -> void:
	var target := _movement_start + delta
	owner.global_position = target - _pivot_offset

func reset() -> void:
	owner.global_position = _movement_start - _pivot_offset

func stop_moving() -> void:
	owner.transfer_position_to_mc()
