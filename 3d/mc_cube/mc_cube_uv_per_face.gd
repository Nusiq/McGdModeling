extends McCubeUv

## Represents the per-face way of UV mapping for a Minecraft cube.
class_name McCubeUVPerFace

class UvSide:
	var uv: Vector2
	var uv_size: Vector2
	var material_instance: StringOption

	func _init(
			uv_: Vector2, uv_size_: Vector2,
			material_instance_: StringOption) -> void:
		uv = uv_
		uv_size = uv_size_
		material_instance = material_instance_

# Up; +y
var up: UvSide = null

# Down; -y
var down: UvSide = null

# Front; North; -z
var north: UvSide = null

# Back; South; +z
var south: UvSide = null

# Right; East; +x
var east: UvSide = null

# Left; West; -x
var west: UvSide = null

func load_from_object(obj: Dictionary, path_so_far: Array = []) -> void:
	# Loop through all of the side names and setter functions for them.
	var side_names: Array[String] = [
		"up", "down", "north", "south", "east", "west"]
	var side_setters: Array[Callable] = [
		func(val: UvSide) -> void: up = val,
		func(val: UvSide) -> void: down = val,
		func(val: UvSide) -> void: north = val,
		func(val: UvSide) -> void: south = val,
		func(val: UvSide) -> void: east = val,
		func(val: UvSide) -> void: west = val
	]
	for i in range(side_names.size()):
		var side_name := side_names[i]
		var side_setter := side_setters[i]
		var side_val := XJSON.get_object_from_object(
			obj, side_name, path_so_far)
		if side_val.error:
			Logging.warning(str(side_val.error.pass_()))
			continue
		var side_path := path_so_far + [side_name]
		# UV
		var uv_val := XJSON.get_vector2_from_object(
			side_val.value, "uv", side_path)
		if uv_val.error:
			Logging.warning(str(uv_val.error.pass_()))
			continue
		var uv := uv_val.value
		# UV size
		var uv_size_val := XJSON.get_vector2_from_object(
			side_val.value, "uv_size", side_path)
		if uv_size_val.error:
			Logging.warning(str(uv_size_val.error.pass_()))
			continue
		var uv_size := uv_size_val.value
		# Material instance (optional)
		var material_instance_val := XJSON.get_string_from_object(
			side_val.value, "material_instance", side_path)
		var material_instance: StringOption = null
		if material_instance_val.error:
			Logging.warning(str(material_instance_val.error.pass_()))
		else:
			material_instance = StringOption.new(material_instance_val.value)
		side_setter.call(UvSide.new(uv, uv_size, material_instance))

# ACCESSING MATERIAL INSTANCES

## Returns the material instance of the front face.
func get_front_material_instance() -> StringOption:
	if north == null:
		return null
	return north.material_instance
## Returns the material instance of the back face.
func get_back_material_instance() -> StringOption:
	if south == null:
		return null
	return south.material_instance

## Returns the material instance of the right face.
func get_right_material_instance() -> StringOption:
	if east == null:
		return null
	return east.material_instance
## Returns the material instance of the left face.
func get_left_material_instance() -> StringOption:
	if west == null:
		return null
	return west.material_instance

## Returns the material instance of the up face.
func get_up_material_instance() -> StringOption:
	if up == null:
		return null
	return up.material_instance
## Returns the material instance of the down face.
func get_down_material_instance() -> StringOption:
	if down == null:
		return null
	return down.material_instance

# ACCESSING THE UV COORDINATES

## Return the unnormalized UV coordinate for the front/right/up (-z/+x/+y)
## vertex of the front face.
func get_front_right_up_uv_1(_cube_size: Vector3) -> Vector2:
	if north == null: return -Vector2.ONE
	return north.uv
## Return the unnormalized UV coordinate for the front/right/up (-z/+x/+y)
## vertex of the right face.
func get_front_right_up_uv_2(_cube_size: Vector3) -> Vector2:
	if east == null: return -Vector2.ONE
	return east.uv + Vector2(east.uv_size.x, 0)
## Return the unnormalized UV coordinate for the front/right/up (-z/+x/+y)
## vertex of the up face.
func get_front_right_up_uv_3(_cube_size: Vector3) -> Vector2:
	if up == null: return -Vector2.ONE
	return up.uv + Vector2(0, up.uv_size.y)

## Return the unnormalized UV coordinate for the front/right/down (-z/+x/-y)
## vertex of the front face.
func get_front_right_down_uv_1(_cube_size: Vector3) -> Vector2:
	if north == null: return -Vector2.ONE
	return north.uv + Vector2(0, north.uv_size.y)
## Return the unnormalized UV coordinate for the front/right/down (-z/+x/-y)
## vertex of the right face.
func get_front_right_down_uv_2(_cube_size: Vector3) -> Vector2:
	if east == null: return -Vector2.ONE
	return east.uv + east.uv_size
## Return the unnormalized UV coordinate for the front/right/down (-z/+x/-y)
## vertex of the down face.
func get_front_right_down_uv_3(_cube_size: Vector3) -> Vector2:
	if down == null: return -Vector2.ONE
	return down.uv + Vector2(0, down.uv_size.y)

## Return the unnormalized UV coordinate for the front/left/up (-z/-x/+y)
## vertex of the front face.
func get_front_left_up_uv_1(_cube_size: Vector3) -> Vector2:
	if north == null: return -Vector2.ONE
	return north.uv + Vector2(north.uv_size.x, 0)
## Return the unnormalized UV coordinate for the front/left/up (-z/-x/+y)
## vertex of the left face.
func get_front_left_up_uv_2(_cube_size: Vector3) -> Vector2:
	if west == null: return -Vector2.ONE
	return west.uv
## Return the unnormalized UV coordinate for the front/left/up (-z/-x/+y)
## vertex of the up face.
func get_front_left_up_uv_3(_cube_size: Vector3) -> Vector2:
	if up == null: return -Vector2.ONE
	return up.uv + up.uv_size

## Return the unnormalized UV coordinate for the front/left/down (-z/-x/-y)
## vertex of the front face.
func get_front_left_down_uv_1(_cube_size: Vector3) -> Vector2:
	if north == null: return -Vector2.ONE
	return north.uv + north.uv_size
## Return the unnormalized UV coordinate for the front/left/down (-z/-x/-y)
## vertex of the left face.
func get_front_left_down_uv_2(_cube_size: Vector3) -> Vector2:
	if west == null: return -Vector2.ONE
	return west.uv + Vector2(0, west.uv_size.y)
## Return the unnormalized UV coordinate for the front/left/down (-z/-x/-y)
## vertex of the down face.
func get_front_left_down_uv_3(_cube_size: Vector3) -> Vector2:
	if down == null: return -Vector2.ONE
	return down.uv + down.uv_size

## Return the unnormalized UV coordinate for the back/right/up (+z/+x/+y)
## vertex of the back face.
func get_back_right_up_uv_1(_cube_size: Vector3) -> Vector2:
	if south == null: return -Vector2.ONE
	return south.uv + Vector2(south.uv_size.x, 0)
## Return the unnormalized UV coordinate for the back/right/up (+z/+x/+y)
## vertex of the right face.
func get_back_right_up_uv_2(_cube_size: Vector3) -> Vector2:
	if east == null: return -Vector2.ONE
	return east.uv
## Return the unnormalized UV coordinate for the back/right/up (+z/+x/+y)
## vertex of the up face.
func get_back_right_up_uv_3(_cube_size: Vector3) -> Vector2:
	if up == null: return -Vector2.ONE
	return up.uv

## Return the unnormalized UV coordinate for the back/right/down (+z/+x/-y)
## vertex of the back face.
func get_back_right_down_uv_1(_cube_size: Vector3) -> Vector2:
	if south == null: return -Vector2.ONE
	return south.uv + south.uv_size
## Return the unnormalized UV coordinate for the back/right/down (+z/+x/-y)
## vertex   of the right face.
func get_back_right_down_uv_2(_cube_size: Vector3) -> Vector2:
	if east == null: return -Vector2.ONE
	return east.uv + Vector2(0, east.uv_size.y)
## Return the unnormalized UV coordinate for the back/right/down (+z/+x/-y)
## vertex of the down face.
func get_back_right_down_uv_3(_cube_size: Vector3) -> Vector2:
	if down == null: return -Vector2.ONE
	return down.uv

## Return the unnormalized UV coordinate for the back/left/up (+z/-x/+y)
## vertex of the back face.
func get_back_left_up_uv_1(_cube_size: Vector3) -> Vector2:
	if south == null: return -Vector2.ONE
	return south.uv
## Return the unnormalized UV coordinate for the back/left/up (+z/-x/+y)
## vertex of the left face.
func get_back_left_up_uv_2(_cube_size: Vector3) -> Vector2:
	if west == null: return -Vector2.ONE
	return west.uv + Vector2(west.uv_size.x, 0)
## Return the unnormalized UV coordinate for the back/left/up (+z/-x/+y)
## vertex of the up face.
func get_back_left_up_uv_3(_cube_size: Vector3) -> Vector2:
	if up == null: return -Vector2.ONE
	return up.uv + Vector2(up.uv_size.x, 0)

## Return the unnormalized UV coordinate for the back/left/down (+z/-x/-y)
## vertex of the back face.
func get_back_left_down_uv_1(_cube_size: Vector3) -> Vector2:
	if south == null: return -Vector2.ONE
	return south.uv + Vector2(0, south.uv_size.y)
## Return the unnormalized UV coordinate for the back/left/down (+z/-x/-y)
## vertex of the left face.
func get_back_left_down_uv_2(_cube_size: Vector3) -> Vector2:
	if west == null: return -Vector2.ONE
	return west.uv + west.uv_size
## Return the unnormalized UV coordinate for the back/left/down (+z/-x/-y)
## vertex of the down face.
func get_back_left_down_uv_3(_cube_size: Vector3) -> Vector2:
	if down == null: return -Vector2.ONE
	return down.uv + Vector2(down.uv_size.x, 0)
