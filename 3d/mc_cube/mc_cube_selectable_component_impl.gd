## Implements missing methods for the SelectableComponent interface.
extends SelectableComponent

class_name McCubeSelectableComponentImpl

var owner: McCube = null

func _init(_owner: McCube) -> void:
	owner = _owner

func get_active_sibling() -> SelectableComponent:
	if owner.owning_model.active_cube == null:
		return null
	return owner.owning_model.active_cube.selection

func set_self_as_active() -> void:
	owner.owning_model.active_cube = owner

func reset_active_sibling() -> void:
	owner.owning_model.active_cube = null

func view_active() -> void:
	owner.view_active()

func view_selected() -> void:
	owner.view_selected()

func view_deselected() -> void:
	owner.view_deselected()
