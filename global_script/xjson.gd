extends Node
## Extra functions for handling JSON

class_name XJSON

## Opens a file and returns a [Variant]. If reading fails returns null.
static func read_file(path: String) -> Variant:
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null: return null
	var file_text = file.get_as_text()
	file.close()  # GDScript would close it on its onw when out of scope.
	var json = JSON.new()
	return json.parse_string(file_text)

## Saves the data into a file in provided path. Returns the success value.
static func save_file(path: String, data: Variant) -> bool:
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file == null: return false
	file.store_string(JSON.stringify(data, "\t"))
	return true
