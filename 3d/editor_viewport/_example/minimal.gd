extends Node3D


@onready var mesh: MeshInstance3D = $MeshInstance3D


func _on_option_button_item_selected(index: int) -> void:
	match index:
		0:
			mesh.layers = 1
		1:
			mesh.layers = 3
		2:
			mesh.layers = 5
		_:
			pass
