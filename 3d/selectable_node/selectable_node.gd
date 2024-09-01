extends Node

class_name SelectableNode

## Whether the node is selected or not.
var is_selected := false:
	get:
		return is_selected
	set(value):
		is_selected = value
		if is_selected:
			view_selected()
		else:
			is_active = false
			view_deselected()

# Whether the node is active or not.
var is_active: bool:
	get:
		return _get_active_sibling() == self
	set(value):
		# The visibility is updated in the ModeManager
		if value:
			_set_active_sibling(self)
		else:
			if _get_active_sibling() == self:
				_set_active_sibling(null)


## Makes the bone appear as active in the editor.
func view_active() -> void: assert(false, "Not implemented.")

## Makes the bone appear as selected in the editor.
func view_selected() -> void: assert(false, "Not implemented.")

## Makes the bone appear as deselected in the editor.
func view_deselected() -> void: assert(false, "Not implemented.")

## Synchs the view state with the actual selection state of the model.
func view_sync() -> void:
	if is_active:
		# If it's active it's also selected but active has priority
		view_active()
	elif is_selected:
		view_selected()
	else:
		view_deselected()

## Returns the active object of the same kind as this node. This is used to
## fully implement the "is_active" property and should not be used directly
## except from implementing it.
func _get_active_sibling() -> SelectableNode:
	assert(false, "Not implemented.")
	return null

## Sets the active object of the same kind as this node. This is used to
## fully implement the "is_active" property and should not be used directly
## except from implementing it.
func _set_active_sibling(_value: SelectableNode) -> void:
	assert(false, "Not implemented.")