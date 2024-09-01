## A component that can be added to a node to make it selectable. The node must
## implement the Interface subclass to provide the missing methods.
class_name SelectableNode

## A class that provides an interface for suplying the missing methods of the
## selectable node.
class Interface:
	## Returns the active sibling of the node. E.g. the SelectableNode of the
	## active bone of the model if this SelectableNode belongs to a bone.
	func get_active_sibling() -> SelectableNode:
		assert(false, "Not implemented.")
		return null
	## Sets this node as active. E.g. sets the bone that owns this
	## SelectableNode as active in a model.
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

var methods: Interface = null

## Whether the node is selected or not.
var is_selected := false:
	get:
		return is_selected
	set(value):
		is_selected = value
		if is_selected:
			methods.view_selected()
		else:
			is_active = false
			methods.view_deselected()

# Whether the node is active or not.
var is_active: bool:
	get:
		return methods.get_active_sibling() == self
	set(value):
		# The visibility is updated in the ModeManager
		if value:
			methods.set_self_as_active()
		else:
			if methods.get_active_sibling() == self:
				methods.reset_active_sibling()


## Synchs the view state with the actual selection state of the model.
func view_sync() -> void:
	if is_active:
		# If it's active it's also selected but active has priority
		methods.view_active()
	elif is_selected:
		methods.view_selected()
	else:
		methods.view_deselected()
