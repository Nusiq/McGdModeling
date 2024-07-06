extends FileDialog

class_name CachedFileDialog

## The name that identifies the storage used for saving and loading the
## most recent settings provided by the user in the file dialog. The
## [CachedFileDialog]s with the same memory_group, will share the same
## settings when they're opened again.
@export var memory_group: String = "default"

#region Caching
## Saves the data provided from the dialog form filled by the user into the
## application cache.

enum FileType {
	# DON'T CHANGE THE ENUM VALUES (for future backwards compatibility reasons)
	FILE=0,
	DIR=1
}

## Returns the CachedFileDialog's cache from the AppData cache. If it doesn't
## exist, makes sure to add it.
func get_cache() -> Dictionary:
	var full_cache := AppData.get_cache()
	var dialog_cache: Variant = full_cache.get("cached_file_dialog")
	if dialog_cache is Dictionary:
		return dialog_cache
	dialog_cache = {}
	full_cache["cached_file_dialog"] = dialog_cache
	return dialog_cache

func save_cache(path: String, type: FileType) -> void:
	get_cache()[memory_group] = {
		"format_version": 1,
		"path": path,
		"type": type
	}

## Loads the previously saved data from the cache into the file dialog
## settiings if it exists.
func load_cache() -> bool:
	var memory_group_cache: Dictionary = get_cache().get(memory_group)
	# WARNING! Don't change the way the 'format_version' is checked. Match
	# pattern is very strict about floats and integers and 1.0 != 1 for it.
	# when the data is loaded from JSON file all numbers are saved as float.
	# Using "when" and "==" is a workaround for more sane matching behavior.
	match memory_group_cache:
		{"format_version": var format, "path": var path, "type": var type}\
		when format == 1:
			return load_cache_v1(path, type)
	return false

## Loads file dialog cache saved using format version 1.
func load_cache_v1(path: Variant, type: Variant) -> bool:
	# Check if valid type of path
	if not path is String: return false
	path = path as String
	# Check if valid file path
	if not (path.is_absolute_path() or path.is_relative_path()): return false
	
	# Make sure that the type is an integer. When it's loaded from JSON it's
	# stored as float which wouldn't work with 'match' expression
	if type is float:
		type = int(type)
	
	# Load
	match type:
		FileType.DIR:
			current_dir = path
		FileType.FILE:
			current_dir = path.get_base_dir()
		_:
			return false
	return true

#endregion

#region Event Handlers
func _on_dir_selected(dir: String) -> void:
	save_cache(dir, FileType.DIR)

func _on_file_selected(path: String) -> void:
	save_cache(path, FileType.FILE)

func _on_about_to_popup() -> void:
	load_cache()
#endregion

