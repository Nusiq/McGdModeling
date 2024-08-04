## Simple material provider capable of creating and providing Minecraft
## materials based on textures from the file system.
class_name McMaterialProvider

enum MaterialType {
	ENTITY_ALPHATEST,
	ENTITY,
	ENTITY_ALPHABLEND
	# TODO - add more
}

## The dictionary that maps the short names of the materials to the
## StandardMaterial3D objects.
var _materials: Dictionary = {}

## The key of the default material. It's used as a fallback when the material
## requested by the query_material method is not found.
var default_material_key: StringOption = null

## Returns the material based on the provided bone name and mesh instance name.
## NOTE: This implementation of McMaterialProvider always returns the default
## material. The default material key can be changed by changing the
## default_material_key variable.
func query_material(
		_bone: String,
		_mesh_instance: StringOption) -> StandardMaterial3D:
	if default_material_key != null:
		return _materials.get(default_material_key.value, null)
	return null

## Adds the material to the internal dictionary with the provided key.
func add_material(key: String, material: StandardMaterial3D) -> void:
	_materials[key] = material

## Removes the material from the internal dictionary.
func del_material(key: String) -> void:
	_materials.erase(key)

## Creates new material from the provided texture file and adds it to the
## internal dictionary.
func add_material_from_texture_file(
		key: String, path: String,
		type: MaterialType = MaterialType.ENTITY_ALPHATEST) -> WrappedError:
	var image := Image.load_from_file(path)
	if image == null or image.is_empty():
		return WrappedError.new(
			tr("error.mc_material_provider.unable_to_load_image".format(
				{"path": path})))
	var material := StandardMaterial3D.new()
	var texture := ImageTexture.create_from_image(image)
	if texture.get_width() == 0 or texture.get_height() == 0:
		return WrappedError.new(
			tr("error.mc_material_provider.texture_is_empty".format(
				{"path": path})))
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	material.albedo_texture = texture
	match type:
		MaterialType.ENTITY_ALPHATEST:
			material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
		MaterialType.ENTITY:
			material.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
		MaterialType.ENTITY_ALPHABLEND:
			material.transparency = \
				BaseMaterial3D.TRANSPARENCY_ALPHA_DEPTH_PRE_PASS
		_:
			assert(false, "Unknown material type.")
	_materials[key] = material
	return null
