extends Node3D

## Represents a Minecraft model.
class_name McModel

var identifier := ""
var texture_width := 64
var texture_height := 64
var visible_bounds_width := 1.0
var visible_bounds_height := 1.0
var visible_bounds_offset := Vector3(0, 0, 0)

var material_provider: McMaterialProvider = null

## The currently active cube.
var active_cube: McCube = null:
	get:
		return active_cube
	set(value):
		# Update the visibility of the previous active object.
		if active_cube != null:
			if active_cube.selection.is_selected:
				active_cube.view_selected()
			else:
				active_cube.view_deselected()
		# Update the visibility of the new active object.
		if value != null:
			value.view_active()
		# Set the new active object
		active_cube = value

## The currently active bone.
var active_bone: McBone = null:
	get:
		return active_bone
	set(value):
		# Update the visibility of the previous active object.
		if active_bone != null:
			if active_bone.selection.is_selected:
				active_bone.view_selected()
			else:
				active_bone.view_deselected()
		# Update the visibility of the new active object.
		if value != null:
			value.view_active()
		# Set the new active object
		active_bone = value

## Component that expands the functionality of the model to enable it to be
## selected and deselected in the editor.
var selection := SelectableNode.new()

## Implements missing methods for the SelectableNode interface.
class SelectableNodeImpl extends SelectableNode.Interface:
	var owner: McModel = null
	func _init(_owner: McModel) -> void:
		owner = _owner
	func get_active_sibling() -> SelectableNode:
		if ModeManager.active_object == null:
			return null
		return ModeManager.active_object.selection
	func set_self_as_active() -> void:
		ModeManager.active_object = owner
	func reset_active_sibling() -> void:
		ModeManager.active_object = null
	func view_active() -> void: owner.view_active()
	func view_selected() -> void: owner.view_selected()
	func view_deselected() -> void: owner.view_deselected()

## Adds new child bone to this model. Returns a handle for the newly created
## object. Optionally, a McBone object can be passed, in which case no new
## object is created and the passed object is added as a child.
func add_bone(child: McBone = null) -> McBone:
	if child == null:
		child = McBone.new_scene(self)
	elif child.get_parent() != null:
		child.get_parent().remove_child(child)
	add_child(child)
	child.owning_model = self
	return child

## Returns all of the bones that are children of this model.
func get_root_bones() -> Array[McBone]:
	var result: Array[McBone] = []
	for child in get_children():
		if child is McBone:
			result.append(child)
	return result

## Returns all of the bones that are children of this model recursively.
func get_all_bones() -> Array[McBone]:
	var result: Array[McBone] = []
	var bones_to_check := get_root_bones()
	while bones_to_check.size() > 0:
		# "as McBone" is safe a cast becayse size() > 0
		var bone := bones_to_check.pop_front() as McBone
		# Append the bone and add its children to check.
		result.append(bone)
		bones_to_check.append_array(bone.get_bones())
	return result


func load_from_string(json: String, model_index := 0) -> WrappedError:
	var obj: Variant = JSON.parse_string(json)
	if not obj is Dictionary:
		return WrappedError.new(tr("error.mc_model.invalid_root_type"))
	return load_from_object(obj as Dictionary, model_index)

func load_from_file(path: String, model_index := 0) -> WrappedError:
	var obj: Variant = XJSON.read_file(path)
	if not obj is Dictionary:
		return WrappedError.new(tr("error.mc_model.invalid_root_type"))
	return load_from_object(obj as Dictionary, model_index)

func load_from_object(obj: Dictionary, model_index := 0) -> WrappedError:
	# minecraft:geometry
	var geo_path := ["minecraft:geometry", model_index]
	var geo := XJSON.get_object_from_json_path(obj, geo_path)
	if geo.error != null:
		return geo.error.pass_()
	# description
	var desc := XJSON.get_object_from_object(
		geo.value, "description", geo_path)
	if desc.error: # We don't care much about it.
		Logging.warning(
			str(desc.error.wrap(tr("mc_model.load.invalid_description"))))
	else:
		# Identifier
		var desc_path := geo_path + ["description"]
		identifier = XJSON.get_string_from_object(
			desc.value, "identifier", desc_path).get_or_warn()
		# Texture Width & Height
		texture_width = XJSON.get_int_from_object(
			desc.value, "texture_width", desc_path) \
			.get_or_warn(texture_width)
		texture_height = XJSON.get_int_from_object(
			desc.value, "texture_height", desc_path) \
			.get_or_warn(texture_height)
		# Visible Bounds
		visible_bounds_width = XJSON.get_float_from_object(
			desc.value, "visible_bounds_width", desc_path) \
			.get_or_warn(visible_bounds_width)
		visible_bounds_height = XJSON.get_float_from_object(
			desc.value, "visible_bounds_height", desc_path) \
			.get_or_warn(visible_bounds_height)
		# Visible Bounds Offset
		var vbo := XJSON.get_array_from_object(
			desc.value, "visible_bounds_offset", desc_path)
		if vbo.error:
			Logging.warning(str(vbo.error.pass_()))
		else:
			var vbo_path := desc_path + ["visible_bounds_offset"]
			visible_bounds_offset = Vector3(
				XJSON.get_float_from_array(vbo.value, 0, vbo_path) \
					.get_or_warn(visible_bounds_offset.x),
				XJSON.get_float_from_array(vbo.value, 1, vbo_path) \
					.get_or_warn(visible_bounds_offset.y),
				XJSON.get_float_from_array(vbo.value, 2, vbo_path) \
					.get_or_warn(visible_bounds_offset.z)
			)
	# Bones
	var bones_path := geo_path + ["bones"]
	var bones := XJSON.get_array_from_object(geo.value, "bones", geo_path)
	if bones.error:
		return bones.error.pass_()
	for bone_i in range(bones.value.size()):
		# Bone
		var bone_path := bones_path + [bone_i]
		var bone := XJSON.get_object_from_array(bones.value, bone_i, bone_path)
		if bone.error:
			Logging.warning(str(bone.error.pass_()))
			continue
		var bone_node := McBone.new_scene(self)
		var err := bone_node.load_from_object(bone.value, bone_path)
		if err:
			bone_node.queue_free()
			Logging.warning(str(err.pass_()))
		else:
			add_bone(bone_node)
	# Update the hierarchy (things that couldn't load in first pass like
	# parents)
	update_bone_hierarchy()
	return null

## Updates the bone hierarchy based on their names and their declared parent
## names.
func update_bone_hierarchy() -> void:
	var all_bones := get_all_bones()
	# Godot doesn't have proper typing for this: Dict[str, Array[McBone]]
	var name_map: Dictionary = {}

	# Pass 1: Create the name map.
	for bone in all_bones:
		if bone.mc_name not in name_map:
			name_map[bone.mc_name] = [bone]
		else:
			name_map[bone.mc_name].append(bone)
	# Pass 2: Set the parents
	for bone in all_bones:
		if bone.mc_parent == null:
			add_bone(bone)
		elif bone.mc_parent.value in name_map:
			var parent: McBone = name_map[bone.mc_parent.value][0]
			parent.add_bone(bone)
	# Pass 3: Rename the nodes. This must be done after setting parents
	# because two children can't have the same name and in intermediate steps
	# this could happen. In minecraft, no two bones can have the same name but
	# nothing stops the user from doing that in the JSON.
	for bone in all_bones:
		bone.name = bone.mc_name

## Removes all bones from this model.
func remove_bones() -> void:
	for bone in get_root_bones():
		bone.free()

func redraw_mesh() -> void:
	for bone in get_all_bones():
		bone.redraw_mesh()

# SelectableNode INTERFACE IMPLEMENTATION
## Makes the model appear as active in the editor.
func view_active() -> void:
	for bone in get_all_bones():
		for cube in bone.get_cubes():
			cube.mesh_instance.layers = 5

## Makes the model appear as selected in the editor.
func view_selected() -> void:
	for bone in get_all_bones():
		for cube in bone.get_cubes():
			cube.mesh_instance.layers = 3

## Makes the model appear as deselected in the editor.
func view_deselected() -> void:
	for bone in get_all_bones():
		for cube in bone.get_cubes():
			cube.mesh_instance.layers = 1


func _ready() -> void:
	# Add selectable node interface
	selection.methods = SelectableNodeImpl.new(self)
