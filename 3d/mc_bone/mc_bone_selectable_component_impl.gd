## Implements missing methods for the SelectableComponent interface.
extends SelectableComponent

class_name McBoneSelectableNodeComponentImpl

var owner: McBone = null

func _init(_owner: McBone) -> void:
	owner = _owner

func get_active_sibling() -> SelectableComponent:
	if owner.owning_model.active_bone == null:
		return null
	return owner.owning_model.active_bone.selection

func set_self_as_active() -> void:
	owner.owning_model.active_bone = owner

func reset_active_sibling() -> void:
	owner.owning_model.active_bone = null

func view_active() -> void:
	owner.view_active()

func view_selected() -> void:
	owner.view_selected()

func view_deselected() -> void:
	owner.view_deselected()
