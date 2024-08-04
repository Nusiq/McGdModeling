extends Node

class_name UserConfig

## Gests settings from the user config file.
static func get_settings() -> Dictionary:
	var config := AppData.get_user_config()
	if not config.get("settings", null) is Dictionary:
		config["settings"] = {}
	return config["settings"]

## Loads a float variable from the user configuration
## Loads a float variable from the user configuration
static func load_float(
		id: String,
		default: float,
		min_: Variant = null, max_: Variant = null) -> float:
	var settings := UserConfig.get_settings()
	if not settings.has(id) or settings[id] == null:
		settings[id] = null # Set to null to make finding settings easier
		return default
	if not settings[id] is float:
		Logging.warning(
			TranslationServer.tr("user_config.setting_type_incorrect").format(
				{"id": id, "expected_type": "float", "default": default}))
		settings[id] = default
		return settings[id]
	if min_ is float and settings[id] < min_:
		Logging.warning(
			TranslationServer.tr("user_config.setting_value_too_small").format(
				{"id": id, "min": min_}))
		settings[id] = min_
	elif max_ is float and settings[id] > max_:
		Logging.warning(
			TranslationServer.tr("user_config.setting_value_too_big").format(
				{"id": id, "max": max_}))
		settings[id] = max_
	return settings[id]

static func load_string(
		id: String, default: String, allowed_values: Variant = null) -> String:
	var settings := UserConfig.get_settings()
	if not settings.has(id) or settings[id] == null:
		settings[id] = null # Set to null to make finding settings easier
		return default
	if not settings[id] is String:
		Logging.warning(
			TranslationServer.tr("user_config.setting_type_incorrect").format(
				{"id": id, "expected_type": "string", "default": default}))
		settings[id] = default
		return settings[id]
	if allowed_values is Array and settings[id] not in allowed_values:
		Logging.warning(
			TranslationServer.tr("user_config.setting_value_not_on_the_list")
			.format({
				"id": id, "allowed_values": allowed_values, "default": default
			}))
		settings[id] = default
	return settings[id]
