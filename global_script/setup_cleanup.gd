extends Node

## A singleton whose only purpose is to run some scripts on application setup
## and cleanup.

func _ready() -> void:
	var locale := UserConfig.load_string("locale", "en", ["en", "pl"])
	TranslationServer.set_locale(locale)

## Handles saving the data when application is closed.
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		Logging.info(
			tr("setup_cleanup.saving_app_data")
			.format({"app_data_path": AppData.PATH}))
		AppData.save_cache()
		AppData.save_user_config()
