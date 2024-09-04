## A component that can be added to a node to make it selectable. The actual
## class must implement the missing methods.
class_name SelectableComponent


## Returns the active sibling of the node. E.g. the SelectableComponent of the
## active bone of the model if this SelectableComponent belongs to a bone.
func get_active_sibling() -> SelectableComponent:
	assert(false, "Not implemented.")
	return null

## Sets this node as active. E.g. sets the bone that owns this
## SelectableComponent as active in a model.
func set_self_as_active() -> void:
	assert(false, "Not implemented.")

## Resets the active sibling. E.g. sets the active bone of the model to
## null.
func reset_active_sibling() -> void:
	assert(false, "Not implemented.")

## Makes the object appear as active in the editor.
func view_active() -> void:
	assert(false, "Not implemented.")

## Makes the object appear as selected in the editor.
func view_selected() -> void:
	assert(false, "Not implemented.")

## Makes the object appear as deselected in the editor.
func view_deselected() -> void:
	assert(false, "Not implemented.")

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
		return get_active_sibling() == self
	set(value):
		# The visibility is updated in the ModeManager
		if value:
			set_self_as_active()
		else:
			if get_active_sibling() == self:
				reset_active_sibling()


## Synchs the view state with the actual selection state of the model.
func view_sync() -> void:
	if is_active:
		# If it's active it's also selected but active has priority
		view_active()
	elif is_selected:
		view_selected()
	else:
		view_deselected()
