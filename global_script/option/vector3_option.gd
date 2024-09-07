## A wrapper for Vector3 to allow null values.
class_name Vector3Option

var value: Vector3 = Vector3.ZERO

func _init(value_: Vector3) -> void:
	value = value_
