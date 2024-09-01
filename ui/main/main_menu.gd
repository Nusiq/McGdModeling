extends Node3D

@onready var model_file_dialog: CachedFileDialog = $CachedFileDialogModel
@onready var texture_file_dialog: CachedFileDialog = $CachedFileDialogTexture
@onready var mc_model: McModel = $McModel

func _ready() -> void:
	mc_model.is_active = true
	ModeManager.current_mode = ModeManager.Mode.MESH

func _on_cached_file_dialog_model_file_selected(path: String) -> void:
	mc_model.remove_bones()

	# Load the model from the file
	var err := mc_model.load_from_file(path)
	if err != null:
		Logging.error(str(err.pass_()))

func _on_cached_file_dialog_texture_file_selected(path: String) -> void:
	# Add the material provider
	var material_provider := McMaterialProvider.new()
	material_provider.default_material_key = StringOption.new("default")
	material_provider.add_material_from_texture_file("default", path)
	mc_model.material_provider = material_provider
	mc_model.redraw_mesh()

func _on_button_load_model_pressed() -> void:
	model_file_dialog.popup()

func _on_button_load_texture_pressed() -> void:
	texture_file_dialog.popup()
