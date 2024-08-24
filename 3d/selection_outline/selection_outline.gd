extends Node3D

@export var outline_color: Color = Color(1.0, 1.0, 1.0, 1.0):
	get:
		return outline_color
	set(value):
		outline_color = value
		var viewport_container: SubViewportContainer = $SubViewportContainer
		if viewport_container:
			viewport_container.material["shader_parameter/outlineColor"] = value


@export_flags_3d_render var outline_layers: int = 2:
	get:
		return outline_layers
	set(value):
		outline_layers = value
		var posprocessing_mesh: MeshInstance3D = $MeshInstance3D
		var camera: Camera3D = $SubViewportContainer/SubViewport/Camera3D
		if posprocessing_mesh and camera:
			posprocessing_mesh.layers = value
			camera.cull_mask = value
