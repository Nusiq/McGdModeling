extends Node
## Handling everything related to the applications data, The AppData class
## provides static functions for handing the application data. It is also
## instantiated as a singleton, which handles saving the app data when
## application is closed (singletons are handled in Project->Auto load).
class_name AppData

## Path to the applications data folder
static var PATH = "{cache_dir}/{project_name}".format({
	"cache_dir": OS.get_data_dir(),
	"project_name": ProjectSettings.get_setting("application/config/name")
})

static var CACHE_FILE = PATH + "/cache.json"

#region Application Cache
## (private) value for caching the applications cache
static var _CACHE: Variant = null

## Returns the application cache dictionary
static func get_cache() -> Dictionary:
	if _CACHE is Dictionary: return _CACHE
	match XJSON.read_file(CACHE_FILE):
		var cache when cache is Dictionary:
			_CACHE = cache
		_:
			_CACHE = {}
	return _CACHE

static func save_cache() -> void:
	DirAccess.make_dir_recursive_absolute(PATH)
	XJSON.save_file(CACHE_FILE, get_cache())

#endregion

#region Event Handlers

## Handles saving the data when application is closed.
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_cache()

#endregion
