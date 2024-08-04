extends Node
## Handling everything related to the applications data, The AppData class
## provides static functions for handing the application data. It is also
## instantiated as a singleton, which handles saving the app data when
## application is closed (singletons are handled in Project->Auto load).
class_name AppData

## Path to the applications data folder
static var PATH := "{cache_dir}/{project_name}".format({
	"cache_dir": OS.get_data_dir(),
	"project_name": ProjectSettings.get_setting("application/config/name")
})
static var CACHE_FILE_PATH := PATH + "/cache.json"
static var USER_CONFIG_FILE_PATH := PATH + "/user_config.json"

#region Lazy Evaluation Variables
## (private) value for caching the applications cache
static var _CACHE: Variant = null
## (private) value for caching the user config
static var _USER_CONFIG: Variant = null
#endregion

#region Accessing Files

## Used internally for get_<file> functions
static func _get_app_data_file(path: String) -> Dictionary:
	var cache: Variant = XJSON.read_file(path)
	if cache is Dictionary:
		return cache
	return {}

## Returns the application cache dictionary
static func get_cache() -> Dictionary:
	if _CACHE is Dictionary: return _CACHE
	_CACHE = _get_app_data_file(CACHE_FILE_PATH)
	return _CACHE

static func save_cache() -> void:
	DirAccess.make_dir_recursive_absolute(PATH)
	XJSON.save_file(CACHE_FILE_PATH, get_cache())

## Returns the application user_config dictionary
static func get_user_config() -> Dictionary:
	if _USER_CONFIG is Dictionary: return _USER_CONFIG
	_USER_CONFIG = _get_app_data_file(USER_CONFIG_FILE_PATH)
	return _USER_CONFIG

static func save_user_config() -> void:
	DirAccess.make_dir_recursive_absolute(PATH)
	XJSON.save_file(USER_CONFIG_FILE_PATH, get_user_config())
#endregion
