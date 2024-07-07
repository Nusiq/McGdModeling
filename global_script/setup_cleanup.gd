extends Node

## A singleton whose only purpose is to run some scripts on application setup
## and cleanup.

func _ready() -> void:
	var locale := UserConfig.load_string("locale", "en", ["en", "pl"])
	TranslationServer.set_locale(locale)

## Handles saving the data when application is closed.
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		print("Saving application data in: %s" % [AppData.PATH])
		AppData.save_cache()
		AppData.save_user_config()
