extends MeshInstance3D

class_name AxesShader

# Used for masking the visibility of the x y and z axes.
enum Mask {
	X = 1,
	Y = 1 << 1,
	Z = 1 << 2
}

func set_line_width(line_width: float) -> void:
	var material: ShaderMaterial = mesh.surface_get_material(0)
	material["shader_parameter/axis_max_line_width"] = line_width

func set_albedo_x(color: Color) -> void:
	var material: ShaderMaterial = mesh.surface_get_material(0)
	material["shader_parameter/albedo_x"] = Vector3(
		color.r, color.g, color.b)
		
func set_albedo_y(color: Color) -> void:
	var material: ShaderMaterial = mesh.surface_get_material(0)
	material["shader_parameter/albedo_y"] = Vector3(
		color.r, color.g, color.b)

func set_albedo_z(color: Color) -> void:
	var material: ShaderMaterial = mesh.surface_get_material(0)
	material["shader_parameter/albedo_z"] = Vector3(
		color.r, color.g, color.b)

func set_max_line_alpha(line_alpha: float) -> void:
	var material: ShaderMaterial = mesh.surface_get_material(0)
	material["shader_parameter/axis_max_line_alpha"] = line_alpha

func set_axis_rotation(axis_rotation: Vector3) -> void:
	var material: ShaderMaterial = mesh.surface_get_material(0)
	material["shader_parameter/axis_rotation"] = axis_rotation

func set_axis_origin(origin: Vector3) -> void:
	var material: ShaderMaterial = mesh.surface_get_material(0)
	material["shader_parameter/axis_origin"] = origin

func set_axes_mask(mask: int) -> void:
	if mask == 0:
		visible = false
		return
	var material: ShaderMaterial = mesh.surface_get_material(0)
	material["shader_parameter/axes_mask"] = mask
	visible = true
