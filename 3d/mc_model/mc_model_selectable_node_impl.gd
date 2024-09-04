## Implements missing methods for the SelectableComponent interface.
extends SelectableComponent

class_name McModelSelectableComponentImpl

var owner: McModel = null

func _init(_owner: McModel) -> void:
	owner = _owner

func get_active_sibling() -> SelectableComponent:
	if ModeManager.active_object == null:
		return null
	return ModeManager.active_object.selection

func set_self_as_active() -> void:
	ModeManager.active_object = owner

func reset_active_sibling() -> void:
	ModeManager.active_object = null

func view_active() -> void:
	owner.view_active()

func view_selected() -> void:
	owner.view_selected()

func view_deselected() -> void:
	owner.view_deselected()
