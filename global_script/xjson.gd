extends Node

## Extra functions for handling JSON.

## Opens a file and returns a [Variant]. If reading fails returns null.
func read_file(path: String) -> Variant:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null: return null
	var file_text := file.get_as_text()
	file.close() # GDScript would close it on its onw when out of scope.
	return JSON.parse_string(file_text)

## Saves the data into a file in provided path. Returns the success value.
func save_file(path: String, data: Variant) -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null: return false
	file.store_string(JSON.stringify(data, "\t"))
	return true

# Conviniency functions for getting values of expected types from JSON objects.
# Oh god, lack of generics in GDScript suuuucks!

func format_json_path(json_path: Array) -> String:
	var result_array := []
	for item: Variant in json_path:
		if item is String:
			result_array.append('"%s"' % [item])
		else:
			# Should be an integer, if it's wrong there is a serious problem,
			# somewhere in the code but this is not the place to handle it.
			result_array.append(str(item))
	return "->".join(result_array)

## Used internally to add a path info to the error message.
func json_path_info(json_path: Array) -> String:
	if json_path.size() == 0:
		return ""
	var path := format_json_path(json_path)
	return "\n" + tr("xjson.json_path").format({"path": path})

## Results from functions that should return an object but can fail.
class ObjectResult:
	var value: Dictionary
	var error: WrappedError

	func _init(value_: Dictionary, error_: WrappedError = null) -> void:
		value = value_
		error = error_

	func get_or_warn(default_value: Dictionary = {}) -> Dictionary:
		if error:
			Logging.warning(str(error))
			return default_value
		return value

## Tries to get a value of specified type from a dictionary using a key.
## Returns a result object.
## The error message strings can be customized. They should contain a {key}
## placeholder for the key name.
func get_object_from_object(
	root: Dictionary,
	key: String,
	json_path: Array = [],
	key_missing_error: String = \
		tr("error.xjson.something_from_object.key_missing"),
	wrong_type_error: String = tr("error.xjson.obj_from_object.wrong_type"),
) -> ObjectResult:
	if not root.has(key):
		return ObjectResult.new(
			{}, WrappedError.new(
				key_missing_error.format({"key": key})
				+ json_path_info(json_path)))
	var val: Variant = root[key]
	if not val is Dictionary:
		return ObjectResult.new(
			{}, WrappedError.new(
				wrong_type_error.format({"key": key})
				+ json_path_info(json_path)))
	return ObjectResult.new(val)

## Tries to get a value of specified type from an array using an index. Returns
## a result object.
## The error message strings can be customized. They should contain a {index}
## placeholder for the index number.
func get_object_from_array(
	root: Array,
	index: int,
	json_path: Array = [],
	index_out_of_bounds_error: String =
		tr("error.xjson.something_from_array.index_out_of_bounds"),
	wrong_type_error: String = tr("error.xjson.obj_from_array.wrong_type"),
) -> ObjectResult:
	if index < 0 or index >= root.size():
		return ObjectResult.new(
			{}, WrappedError.new(
				index_out_of_bounds_error.format({"index": index})
				+ json_path_info(json_path)))
	var val: Variant = root[index]
	if not val is Dictionary:
		return ObjectResult.new(
			{}, WrappedError.new(
				wrong_type_error.format({"index": index})
				+ json_path_info(json_path)))
	return ObjectResult.new(val)

## Results from functions that should return an array but can fail.
class ArrayResult:
	var value: Array
	var error: WrappedError

	func _init(value_: Array, error_: WrappedError = null) -> void:
		value = value_
		error = error_
	
	func get_or_warn(default_value: Array = []) -> Array:
		if error:
			Logging.warning(str(error))
			return default_value
		return value

## Tries to get a value of specified type from a dictionary using a key.
## Returns a result object.
## The error message strings can be customized. They should contain a {key}
## placeholder for the key name.
func get_array_from_object(
	root: Dictionary,
	key: String,
	json_path: Array = [],
	key_missing_error: String = \
		tr("error.xjson.something_from_object.key_missing"),
	wrong_type_error: String = tr("error.xjson.array_from_object.wrong_type")
) -> ArrayResult:
	if not root.has(key):
		return ArrayResult.new(
			[], WrappedError.new(
				key_missing_error.format({"key": key})
				+ json_path_info(json_path)))
	var val: Variant = root[key]
	if not val is Array:
		return ArrayResult.new(
			[], WrappedError.new(
				wrong_type_error.format({"key": key})
				+ json_path_info(json_path)))
	return ArrayResult.new(val)

## Tries to get a value of specified type from an array using an index. Returns
## a result object.
## The error message strings can be customized. They should contain a {index}
## placeholder for the index number.
func get_array_from_array(
	root: Array,
	index: int,
	json_path: Array = [],
	index_out_of_bounds_error: String =
		tr("error.xjson.something_from_array.index_out_of_bounds"),
	wrong_type_error: String = tr("error.xjson.array_from_array.wrong_type"),
) -> ArrayResult:
	if index < 0 or index >= root.size():
		return ArrayResult.new(
			[], WrappedError.new(
				index_out_of_bounds_error.format({"index": index})
				+ json_path_info(json_path)))
	var val: Variant = root[index]
	if not val is Array:
		return ArrayResult.new(
			[], WrappedError.new(
				wrong_type_error.format({"index": index})
				+ json_path_info(json_path)))
	return ArrayResult.new(val)

## Results from functions that should return a string but can fail.
class StringResult:
	var value: String
	var error: WrappedError

	func _init(value_: String, error_: WrappedError = null) -> void:
		value = value_
		error = error_
	
	func get_or_warn(default_value: String = "") -> String:
		if error:
			Logging.warning(str(error))
			return default_value
		return value

## Tries to get a value of specified type from a dictionary using a key.
## Returns a result object.
## The error message strings can be customized. They should contain a {key}
## placeholder for the key name.
func get_string_from_object(
	root: Dictionary,
	key: String,
	json_path: Array = [],
	key_missing_error: String = \
		tr("error.xjson.something_from_object.key_missing"),
	wrong_type_error: String = tr("error.xjson.string_from_object.wrong_type")
) -> StringResult:
	if not root.has(key):
		return StringResult.new(
			"", WrappedError.new(
				key_missing_error.format({"key": key})
				+ json_path_info(json_path)))
	var val: Variant = root[key]
	if not val is String:
		return StringResult.new(
			"", WrappedError.new(
				wrong_type_error.format({"key": key})
				+ json_path_info(json_path)))
	return StringResult.new(val)

## Tries to get a value of specified type from an array using an index. Returns
## a result object.
## The error message strings can be customized. They should contain a {index}
## placeholder for the index number.
func get_string_from_array(
	root: Array,
	index: int,
	json_path: Array = [],
	index_out_of_bounds_error: String =
		tr("error.xjson.something_from_array.index_out_of_bounds"),
	wrong_type_error: String = tr("error.xjson.string_from_array.wrong_type"),
) -> StringResult:
	if index < 0 or index >= root.size():
		return StringResult.new(
			"", WrappedError.new(
				index_out_of_bounds_error.format({"index": index})
				+ json_path_info(json_path)))
	var val: Variant = root[index]
	if not val is String:
		return StringResult.new(
			"", WrappedError.new(
				wrong_type_error.format({"index": index})
				+ json_path_info(json_path)))
	return StringResult.new(val)

## Results from functions that should return an integer but can fail.
class FloatResult:
	var value: float
	var error: WrappedError

	func _init(value_: float, error_: WrappedError = null) -> void:
		value = value_
		error = error_
	
	func get_or_warn(default_value: float = 0.0) -> float:
		if error:
			Logging.warning(str(error))
			return default_value
		return value

## Tries to get a value of specified type from a dictionary using a key.
## Returns a result object. Allows integers (they are converted to floats).
## The error message strings can be customized. They should contain a {key}
## placeholder for the key name.
func get_float_from_object(
	root: Dictionary,
	key: String,
	json_path: Array = [],
	key_missing_error: String = \
		tr("error.xjson.something_from_object.key_missing"),
	wrong_type_error: String = tr("error.xjson.float_from_object.wrong_type")
) -> FloatResult:
	if not root.has(key):
		return FloatResult.new(
			0.0, WrappedError.new(
				key_missing_error.format({"key": key})
				+ json_path_info(json_path)))
	var val: Variant = root[key]
	if not val is float and not val is int:
		return FloatResult.new(
			0.0, WrappedError.new(
				wrong_type_error.format({"key": key})
				+ json_path_info(json_path)))
	return FloatResult.new(val)


## Tries to get a value of specified type from an array using an index. Returns
## a result object. Allows integers (they are converted to floats).
## The error message strings can be customized. They should contain a {index}
## placeholder for the index number.
func get_float_from_array(
	root: Array,
	index: int,
	json_path: Array = [],
	index_out_of_bounds_error: String =
		tr("error.xjson.something_from_array.index_out_of_bounds"),
	wrong_type_error: String = tr("error.xjson.float_from_array.wrong_type"),
) -> FloatResult:
	if index < 0 or index >= root.size():
		return FloatResult.new(
			0.0, WrappedError.new(
				index_out_of_bounds_error.format({"index": index})
				+ json_path_info(json_path)))
	var val: Variant = root[index]
	if not val is float and not val is int:
		return FloatResult.new(
			0.0, WrappedError.new(
				wrong_type_error.format({"index": index})
				+ json_path_info(json_path)))
	return FloatResult.new(float(val))

## Results from functions that should return an integer but can fail.
class IntResult:
	var value: int
	var error: WrappedError

	func _init(value_: int, error_: WrappedError = null) -> void:
		value = value_
		error = error_
	
	func get_or_warn(default_value: int = 0) -> int:
		if error:
			Logging.warning(str(error))
			return default_value
		return value

## Tries to get a value of specified type from a dictionary using a key.
## Returns a result object. Allows floats that contain interger values.
## The error message strings can be customized. They should contain a {key}
## placeholder for the key name.
func get_int_from_object(
	root: Dictionary,
	key: String,
	json_path: Array = [],
	key_missing_error: String = \
		tr("error.xjson.something_from_object.key_missing"),
	wrong_type_error: String = tr("error.xjson.int_from_object.wrong_type")
) -> IntResult:
	if not root.has(key):
		return IntResult.new(
			0, WrappedError.new(
				key_missing_error.format({"key": key})
				+ json_path_info(json_path)))
	var val: Variant = root[key]
	if val is float:
		var val_int := int(val)
		if val_int != val:
			return IntResult.new(
				0, WrappedError.new(
					wrong_type_error.format({"key": key})
					+ json_path_info(json_path)))
		return IntResult.new(val_int)
	if not val is int:
		return IntResult.new(
			0, WrappedError.new(
				wrong_type_error.format({"key": key})
				+ json_path_info(json_path)))
	return IntResult.new(val)

## Tries to get a value of specified type from an array using an index. Returns
## a result object. Allows floats that contain interger values.
## The error message strings can be customized. They should contain a {index}
## placeholder for the index number.
func get_int_from_array(
	root: Array,
	index: int,
	json_path: Array = [],
	index_out_of_bounds_error: String =
		tr("error.xjson.something_from_array.index_out_of_bounds"),
	wrong_type_error: String = tr("error.xjson.int_from_array.wrong_type"),
) -> IntResult:
	if index < 0 or index >= root.size():
		return IntResult.new(
			0, WrappedError.new(
				index_out_of_bounds_error.format({"index": index})
				+ json_path_info(json_path)))
	var val: Variant = root[index]
	if val is float:
		var val_int := int(val)
		if val_int != val:
			return IntResult.new(
				0, WrappedError.new(
					wrong_type_error.format({"index": index})
					+ json_path_info(json_path)))
		return IntResult.new(val_int)
	if not val is int:
		return IntResult.new(
			0, WrappedError.new(
				wrong_type_error.format({"index": index})
				+ json_path_info(json_path)))
	return IntResult.new(val)

## Results from functions that should return a boolean but can fail.
class BoolResult:
	var value: bool
	var error: WrappedError

	func _init(value_: bool, error_: WrappedError = null) -> void:
		value = value_
		error = error_
	
	func get_or_warn(default_value: bool = false) -> bool:
		if error:
			Logging.warning(str(error))
			return default_value
		return value

## Tries to get a value of specified type from a dictionary using a key.
## Returns a result object.
## The error message strings can be customized. They should contain a {key}
## placeholder for the key name.
func get_bool_from_object(
	root: Dictionary,
	key: String,
	json_path: Array = [],
	key_missing_error: String = \
		tr("error.xjson.something_from_object.key_missing"),
	wrong_type_error: String = tr("error.xjson.bool_from_object.wrong_type")
) -> BoolResult:
	if not root.has(key):
		return BoolResult.new(
			false, WrappedError.new(
				key_missing_error.format({"key": key})
				+ json_path_info(json_path)))
	var val: Variant = root[key]
	if not val is bool:
		return BoolResult.new(
			false, WrappedError.new(
				wrong_type_error.format({"key": key})
				+ json_path_info(json_path)))
	return BoolResult.new(val)

## Tries to get a value of specified type from an array using an index. Returns
## a result object.
## The error message strings can be customized. They should contain a {index}
## placeholder for the index number.
func get_bool_from_array(
	root: Array,
	index: int,
	json_path: Array = [],
	index_out_of_bounds_error: String =
		tr("error.xjson.something_from_array.index_out_of_bounds"),
	wrong_type_error: String = tr("error.xjson.bool_from_array.wrong_type"),
) -> BoolResult:
	if index < 0 or index >= root.size():
		return BoolResult.new(
			false, WrappedError.new(
				index_out_of_bounds_error.format({"index": index})
				+ json_path_info(json_path)))
	var val: Variant = root[index]
	if not val is bool:
		return BoolResult.new(
			false, WrappedError.new(
				wrong_type_error.format({"index": index})
				+ json_path_info(json_path)))
	return BoolResult.new(val)


class Vector2Result:
	var value: Vector2
	var error: WrappedError

	func _init(value_: Vector2, error_: WrappedError = null) -> void:
		value = value_
		error = error_
	
	func get_or_warn(default_value: Vector2 = Vector2.ZERO) -> Vector2:
		if error:
			Logging.warning(str(error))
			return default_value
		return value

## Alternative constructor for Vector2Result, can't be a static method because
## using tr() in static methods is not allowed.
func init_vector2_result_from_array(
		array: Array, json_path: Array) -> Vector2Result:
	if array.size() != 2:
		return Vector2Result.new(
			Vector2.ZERO, WrappedError.new(
				tr("error.xjson.init_vector2_result_from_array.wrong_size")
				+ json_path_info(json_path)))
	var x := XJSON.get_float_from_array(array, 0, json_path + [0])
	if x.error:
		return Vector2Result.new(Vector2.ZERO, x.error.pass_())
	var y := XJSON.get_float_from_array(array, 1, json_path + [1])
	if y.error:
		return Vector2Result.new(Vector2.ZERO, y.error.pass_())
	return Vector2Result.new(Vector2(x.value, y.value))

func get_vector2_from_object(
	root: Dictionary,
	key: String,
	json_path: Array = [],
	key_missing_error: String = \
		tr("error.xjson.something_from_object.key_missing"),
	wrong_type_error: String = tr("error.xjson.array_from_object.wrong_type")
) -> Vector2Result:
	# Check for the key
	if not root.has(key):
		return Vector2Result.new(
			Vector2.ZERO, WrappedError.new(
				key_missing_error.format({"key": key})
				+ json_path_info(json_path)))
	var val: Variant = root[key]
	if not val is Array:
		return Vector2Result.new(
			Vector2.ZERO, WrappedError.new(
				wrong_type_error.format({"key": key})
				+ json_path_info(json_path)))
	return init_vector2_result_from_array(val, json_path)

func get_vector2_from_array(
	root: Array,
	index: int,
	json_path: Array = [],
	index_out_of_bounds_error: String =
		tr("error.xjson.something_from_array.index_out_of_bounds"),
	wrong_type_error: String = tr("error.xjson.array_from_array.wrong_type"),
) -> Vector2Result:
	# Check for the index
	if index < 0 or index >= root.size():
		return Vector2Result.new(
			Vector2.ZERO, WrappedError.new(
				index_out_of_bounds_error.format({"index": index})
				+ json_path_info(json_path)))
	var val: Variant = root[index]
	if not val is Array:
		return Vector2Result.new(
			Vector2.ZERO, WrappedError.new(
				wrong_type_error.format({"index": index})
				+ json_path_info(json_path)))
	return init_vector2_result_from_array(val, json_path)

class Vector3Result:
	var value: Vector3
	var error: WrappedError

	func _init(value_: Vector3, error_: WrappedError = null) -> void:
		value = value_
		error = error_
	
	func get_or_warn(default_value: Vector3 = Vector3.ZERO) -> Vector3:
		if error:
			Logging.warning(str(error))
			return default_value
		return value

## Alternative constructor for Vector3Result, can't be a static method because
## using tr() in static methods is not allowed.
func init_vector3_result_from_array(
		array: Array, json_path: Array) -> Vector3Result:
	if array.size() != 3:
		return Vector3Result.new(
			Vector3.ZERO, WrappedError.new(
				tr("error.xjson.init_vector3_result_from_array.wrong_size")
				+ json_path_info(json_path)))
	var x := XJSON.get_float_from_array(array, 0, json_path + [0])
	if x.error:
		return Vector3Result.new(Vector3.ZERO, x.error.pass_())
	var y := XJSON.get_float_from_array(array, 1, json_path + [1])
	if y.error:
		return Vector3Result.new(Vector3.ZERO, y.error.pass_())
	var z := XJSON.get_float_from_array(array, 2, json_path + [2])
	if z.error:
		return Vector3Result.new(Vector3.ZERO, z.error.pass_())
	return Vector3Result.new(Vector3(x.value, y.value, z.value))

func get_vector3_from_object(
	root: Dictionary,
	key: String,
	json_path: Array = [],
	key_missing_error: String = \
		tr("error.xjson.something_from_object.key_missing"),
	wrong_type_error: String = tr("error.xjson.array_from_object.wrong_type")
) -> Vector3Result:
	# Check for the key
	if not root.has(key):
		return Vector3Result.new(
			Vector3.ZERO, WrappedError.new(
				key_missing_error.format({"key": key})
				+ json_path_info(json_path)))
	var val: Variant = root[key]
	if not val is Array:
		return Vector3Result.new(
			Vector3.ZERO, WrappedError.new(
				wrong_type_error.format({"key": key})
				+ json_path_info(json_path)))
	return init_vector3_result_from_array(val, json_path)

func get_vector3_from_array(
	root: Array,
	index: int,
	json_path: Array = [],
	index_out_of_bounds_error: String =
		tr("error.xjson.something_from_array.index_out_of_bounds"),
	wrong_type_error: String = tr("error.xjson.array_from_array.wrong_type"),
) -> Vector3Result:
	# Check for the index
	if index < 0 or index >= root.size():
		return Vector3Result.new(
			Vector3.ZERO, WrappedError.new(
				index_out_of_bounds_error.format({"index": index})
				+ json_path_info(json_path)))
	var val: Variant = root[index]
	if not val is Array:
		return Vector3Result.new(
			Vector3.ZERO, WrappedError.new(
				wrong_type_error.format({"index": index})
				+ json_path_info(json_path)))
	return init_vector3_result_from_array(val, json_path)


## Results from functions that should return a variant but can fail. Used for
## getting data from JSON using full JSON paths.
class VariantResult:
	var value: Variant
	var error: WrappedError

	func _init(value_: Variant, error_: WrappedError = null) -> void:
		value = value_
		error = error_

	func get_or_warn(default_value: Variant = null) -> Variant:
		if error:
			Logging.warning(str(error))
			return default_value
		return value

func get_variant_from_json_path(
	root: Variant,
	json_path: Array,
	json_path_until_now: Array = [],
) -> VariantResult:
	if json_path.size() == 0:
		return root
	json_path = json_path.duplicate()
	json_path_until_now = json_path_until_now.duplicate()
	while json_path.size() > 0:
		var key: Variant = json_path.pop_front()
		json_path_until_now.append(key)
		match key:
			var k when k is String:
				if not root is Dictionary:
					return VariantResult.new(
						null, WrappedError.new(
							tr("error.xjson.path_does_not_exist")
							+ json_path_info(json_path_until_now)))
				if not root.has(key):
					return VariantResult.new(
						null, WrappedError.new(
							tr("error.xjson.something_from_object.key_missing")
							+ json_path_info(json_path_until_now)))
				root = root[key]
			var k when k is int:
				if not root is Array:
					return VariantResult.new(
						null, WrappedError.new(
							tr("error.xjson.path_does_not_exist")
							+ json_path_info(json_path_until_now)))
				if k < 0 or k >= root.size():
					return VariantResult.new(
						null, WrappedError.new(
							tr("error.xjson.something_from_array.index_out_of_bounds")
							+ json_path_info(json_path_until_now)))
				root = root[k]
			_:
				return VariantResult.new(
					null, WrappedError.new(
						tr("error.xjson.invalid_json_path")
						+ json_path_info(json_path_until_now)))
	return VariantResult.new(root)

func get_object_from_json_path(
	root: Variant,
	json_path: Array,
	json_path_until_now: Array = [],
) -> ObjectResult:
	var result := get_variant_from_json_path(
			root, json_path, json_path_until_now)
	if result.error:
		return ObjectResult.new({}, result.error.pass_())
	if not result.value is Dictionary:
		return ObjectResult.new(
			{}, WrappedError.new(
				tr("error.xjson.object_from_json_path.wrong_type")
				+ json_path_info(json_path_until_now)))
	return ObjectResult.new(result.value)

func get_array_from_json_path(
	root: Variant,
	json_path: Array,
	json_path_until_now: Array = [],
) -> ArrayResult:
	var result := get_variant_from_json_path(
		root, json_path, json_path_until_now)
	if result.error:
		return ArrayResult.new([], result.error.pass_())
	if not result.value is Array:
		return ArrayResult.new(
			[], WrappedError.new(
				tr("error.xjson.array_from_json_path.wrong_type")
				+ json_path_info(json_path_until_now)))
	return ArrayResult.new(result.value)

func get_string_from_json_path(
	root: Variant,
	json_path: Array,
	json_path_until_now: Array = [],
) -> StringResult:
	var result := get_variant_from_json_path(
		root, json_path, json_path_until_now)
	if result.error:
		return StringResult.new("", result.error.pass_())
	if not result.value is String:
		return StringResult.new(
			"", WrappedError.new(
				tr("error.xjson.string_from_json_path.wrong_type")
				+ json_path_info(json_path_until_now)))
	return StringResult.new(result.value)

func get_float_from_json_path(
	root: Variant,
	json_path: Array,
	json_path_until_now: Array = [],
) -> FloatResult:
	var result := get_variant_from_json_path(
		root, json_path, json_path_until_now)
	if result.error:
		return FloatResult.new(0.0, result.error.pass_())
	if not result.value is float and not result.value is int:
		return FloatResult.new(
			0.0, WrappedError.new(
				tr("error.xjson.float_from_json_path.wrong_type")
				+ json_path_info(json_path_until_now)))
	return FloatResult.new(float(result.value))

func get_int_from_json_path(
	root: Variant,
	json_path: Array,
	json_path_until_now: Array = [],
) -> IntResult:
	var result := get_variant_from_json_path(
		root, json_path, json_path_until_now)
	if result.error:
		return IntResult.new(0, result.error.pass_())
	if result.value is float:
		var val_int := int(result.value)
		if val_int != result.value:
			return IntResult.new(
				0, WrappedError.new(
					tr("error.xjson.int_from_json_path.wrong_type")
					+ json_path_info(json_path_until_now)))
		return IntResult.new(val_int)
	if not result.value is int:
		return IntResult.new(
			0, WrappedError.new(
				tr("error.xjson.int_from_json_path.wrong_type")
				+ json_path_info(json_path_until_now)))
	return IntResult.new(result.value)

func get_bool_from_json_path(
	root: Variant,
	json_path: Array,
	json_path_until_now: Array = [],
) -> BoolResult:
	var result := get_variant_from_json_path(root, json_path, json_path_until_now)
	if result.error:
		return BoolResult.new(false, result.error.pass_())
	if not result.value is bool:
		return BoolResult.new(
			false, WrappedError.new(
				tr("error.xjson.bool_from_json_path.wrong_type")
				+ json_path_info(json_path_until_now)))
	return BoolResult.new(result.value)

func get_vector3_from_json_path(
	root: Variant,
	json_path: Array,
	json_path_until_now: Array = [],
) -> Vector3Result:
	var result := get_variant_from_json_path(
		root, json_path, json_path_until_now)
	if result.error:
		return Vector3Result.new(Vector3.ZERO, result.error.pass_())
	if not result.value is Array:
		return Vector3Result.new(
			Vector3.ZERO, WrappedError.new(
				tr("error.xjson.vector3_from_json_path.wrong_type")
				+ json_path_info(json_path_until_now)))
	return init_vector3_result_from_array(result.value, json_path_until_now)
