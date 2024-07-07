extends Node

class_name UserConfig

const _INCORRECT_SETTING_TYPE = (
	"The value of the \"{id}\" setting in the user config is not a "+
	"{expected_type}. Changing the value to default value: {default}")
const _SETTING_VALUE_TOO_SMALL = (
	"The value of the \"{id}\" setting in the user config is too small. "+
	"Changing the value to allowed minimum: {min}")
const _SETTING_VALUE_TOO_BIG = (
	"The value of the \"{id}\" setting in the user config is too big. "+
	"Changing the value to allowed maximum: {max}")

## Gests settings from the user config file.
static func get_settings() -> Dictionary:
	var config := AppData.get_user_config()
	if not config.get("settings", null) is Dictionary:
		config["settings"] = {}
	return config["settings"]

## Loads a float variable from the user configuration
static func load_float(
		id: String,
		default: float,
		min_: Variant=null, max_: Variant=null) -> float:
	var settings := UserConfig.get_settings()
	if not settings.has(id) or settings[id] == null:
		settings[id] = null  # Set to null to make finding settings easier
		return default
	if not settings[id] is float:
		Logging.error(_INCORRECT_SETTING_TYPE.format(
			{"id":id, "expected_type": "float", "default": default}))
		settings[id] = default
		return settings[id]
	if min_ is float and settings[id] < min_:
		Logging.error(_SETTING_VALUE_TOO_SMALL.format(
			{"id":id, "min": min_}))
		settings[id] = min_
	elif max_ is float and settings[id] > max_:
		Logging.error(_SETTING_VALUE_TOO_BIG.format(
			{"id":id, "max": max_}))
		settings[id] = max_
	return settings[id]
		
	
