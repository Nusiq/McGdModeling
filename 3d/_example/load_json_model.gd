extends Node3D

@onready var file_dialog := $CachedFileDialog

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	file_dialog.popup()

func _on_cached_file_dialog_file_selected(path: String) -> void:
	var mc_model := McModel.new()
	add_child(mc_model)
	var err := mc_model.load_from_file(path)
	if err != null:
		Logging.error(str(err))
		return
	file_dialog.hide()

