## A singleton for managing the current working mode of the application.
extends Node

enum Mode {
	SCENE,
	BONE,
	MESH,
}

signal mode_changed(previous: Mode, current: Mode)

## The current working mode of the application.
var current_mode: Mode = Mode.SCENE:
	get:
		return current_mode
	set(value):
		# If we keep the same mode, do nothing
		if current_mode == value:
			return

		# Visually deselect all of the objects of the previous mode
		match current_mode:
			Mode.SCENE:
				for model: McModel in get_tree().get_nodes_in_group(
						"mc_models"):
					model.view_deselected()
			Mode.BONE:
				for bone: McBone in get_tree().get_nodes_in_group("mc_bones"):
					bone.view_deselected()
			Mode.MESH:
				for cube: McCube in get_tree().get_nodes_in_group("mc_cubes"):
					cube.view_deselected()
		# If there is no active object, cannot switch to the bone or mesh mode
		if active_object == null:
			if value == Mode.BONE:
				Logging.info(tr("info.mode_manager.cannot_switch_to_bone"))
				value = Mode.SCENE
			elif value == Mode.MESH:
				Logging.info(tr("info.mode_manager.cannot_switch_to_mesh"))
				value = Mode.SCENE
		# Update the visibility of the objects of the new mode
		match value:
			Mode.SCENE:
				for model: McModel in get_tree().get_nodes_in_group(
						"mc_models"):
					model.selection.view_sync()
			Mode.BONE:
				if active_object != null:
					for bone: McBone in get_tree().get_nodes_in_group(
							"mc_bones"):
						if bone.owning_model == active_object:
							bone.selection.view_sync()
			Mode.MESH:
				if active_object != null:
					for cube: McCube in get_tree().get_nodes_in_group(
							"mc_cubes"):
						if cube.owning_model == active_object:
							cube.selection.view_sync()
		# Checking again, because invalid mode choices may lead to no changes
		if current_mode != value:
			mode_changed.emit(current_mode, value)
		current_mode = value
		

## The currently active object.
var active_object: McModel = null:
	get:
		return active_object
	set(value):
		# Update the visibility of the previous active object
		if active_object != null:
			if active_object.selection.is_selected:
				active_object.view_selected()
			else:
				active_object.view_deselected()
		# Update the visibility of the new active object
		if value != null:
			value.view_active()
		
		# Set the new active object
		active_object = value

## Deselects all of the objects of specific kind based on the current mode and
## active object.
func deselect_all_in_context() -> void:
	match current_mode:
		Mode.SCENE:
			deselect_all_root_objects()
		Mode.BONE:
			deselect_all_bones(active_object)
		Mode.MESH:
			deselect_all_meshes(active_object)


## Deselects all of the root objects.
func deselect_all_root_objects() -> void:
	active_object = null
	for model: McModel in get_tree().get_nodes_in_group("mc_models"):
		model.selection.is_selected = false

## Deselects all of the bones of the given model.
func deselect_all_bones(active_model: McModel) -> void:
	if active_model == null or not is_instance_valid(active_model):
		return
	active_model.active_bone = null
	for bone in active_model.get_all_bones():
		bone.selection.is_selected = false

## Deselects all of the meshes of the given model.
func deselect_all_meshes(active_model: McModel) -> void:
	if active_model == null or not is_instance_valid(active_model):
		return
	active_model.active_cube = null
	for bone in active_model.get_all_bones():
		for cube in bone.get_cubes():
			cube.selection.is_selected = false


## Selects a root object. See select_object_in_context for more details.
func select_root_object(object: McModel, is_adding: bool) -> void:
	if not is_adding:
		# Overwriting selection
		deselect_all_root_objects()
		object.selection.is_selected = true
		active_object = object
		return
	if object.selection.is_selected:
		if active_object == object:
			# Deselecting active object
			object.selection.is_selected = false
			active_object = null
		else:
			# Reassigning active object
			active_object = object
	else:
		# Selecting new object
		object.selection.is_selected = true
		active_object = object

## Selects a bone object. See select_object_in_context for more details.
func select_bone(active_model: McModel, object: McBone, is_adding: bool) -> void:
	if active_model == null or not is_instance_valid(active_model):
		return
	if object.owning_model != active_model:
		return
	if not is_adding:
		# Overwriting selection
		deselect_all_bones(active_model)
		object.selection.is_selected = true
		active_model.active_bone = object
		return
	if object.selection.is_selected:
		if active_model.active_bone == object:
			# Deselecting active object
			object.selection.is_selected = false
			active_model.active_bone = null
		else:
			# Reassigning active object
			active_model.active_bone = object
	else:
		# Selecting new object
		object.selection.is_selected = true
		active_model.active_bone = object

## Selects a mesh object. See select_object_in_context for more details.
func select_mesh(active_model: McModel, object: McCube, is_adding: bool) -> void:
	if active_model == null or not is_instance_valid(active_model):
		return
	if object.owning_model != active_model:
		return
	if not is_adding:
		# Overwriting selection
		deselect_all_meshes(active_model)
		object.selection.is_selected = true
		active_model.active_cube = object
		return
	if object.selection.is_selected:
		if active_model.active_cube == object:
			# Deselecting active object
			object.selection.is_selected = false
			active_model.active_cube = null
		else:
			# Reassigning active object
			active_model.active_cube = object
	else:
		# Selecting new object
		object.selection.is_selected = true
		active_model.active_cube = object

## Selects an object (different kind based no the current mode) based on the
## clicked McCubeStaticBody3D object (that represents a hitbox of a cube).
## The is_adding parameter determines the behavior of the selection. If true,
## the object is added to the selection, otherwise the selection is overwritten.
## In if the object is already selected and is_adding is true clicking on it
## will deselect it.
func select_object_in_context(object: McCubeStaticBody3D, is_adding: bool) -> void:
	match current_mode:
		Mode.SCENE:
			select_root_object(object.owning_cube.owning_model, is_adding)
		Mode.BONE:
			select_bone(active_object, object.owning_cube.owning_bone, is_adding)
		Mode.MESH:
			select_mesh(active_object, object.owning_cube, is_adding)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("shortcut.activate_scene_mode", false, true):
		current_mode = Mode.SCENE
	elif event.is_action_pressed("shortcut.activate_bone_mode", false, true):
		current_mode = Mode.BONE
	elif event.is_action_pressed("shortcut.activate_mesh_mode", false, true):
		current_mode = Mode.MESH

func count_selected_objects() -> int:
	var count := 0
	match current_mode:
		Mode.SCENE:
			for model: McModel in get_tree().get_nodes_in_group("mc_models"):
				if model.selection.is_selected:
					count += 1
		Mode.BONE:
			if active_object == null:
				return 0
			for bone: McBone in active_object.get_all_bones():
				if bone.selection.is_selected:
					count += 1
		Mode.MESH:
			if active_object == null:
				return 0
			for bone: McBone in active_object.get_all_bones():
				for cube: McCube in bone.get_cubes():
					if cube.selection.is_selected:
						count += 1
	return count

func get_selected_movable_objects() -> Array[MovableComponent]:
	var result: Array[MovableComponent] = []
	match current_mode:
		Mode.SCENE:
			for model: McModel in get_tree().get_nodes_in_group("mc_models"):
				if model.selection.is_selected:
					result.append(model.movable)
		Mode.BONE:
			if active_object == null:
				return result
			for bone: McBone in active_object.get_all_bones():
				if bone.selection.is_selected:
					result.append(bone.movable)
		Mode.MESH:
			if active_object == null:
				return result
			for bone: McBone in active_object.get_all_bones():
				for cube: McCube in bone.get_cubes():
					if cube.selection.is_selected:
						result.append(cube.movable)
	return result