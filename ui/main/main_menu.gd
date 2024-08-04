extends Control


@onready var file_dialog := $CachedFileDialog

#region PROCESSING
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
#endregion

#region EVENT HANDLERS
func _on_open_file_dialog_pressed() -> void:
	#file_dialog.current_dir = "/some/path"  <- this is how you set defaults
	file_dialog.popup()

func _on_cached_file_dialog_file_selected(path: String) -> void:
	print(XJSON.read_file(path))

#endregion
