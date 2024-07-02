extends Node3D

class_name EditorViewport


## Called from the child node $MouseGesture. Handles the mouse gesture
## of rotateing the camera. 
func on_rotate(delta_poz: Vector2):
	print("Hello from MouseGesture.on_rotate")

## Called from the child node $MouseGesture. Handles the mouse gesture
## of panning the camera. 
func on_pan(delta_poz: Vector2):
	print("Hello from MouseGesture.on_pan")

## Called from the child node $MouseGesture. Handles the mouse gesture
## of zooming the camera. 
func on_zoom(delta_poz: Vector2):
	print("Hello from MouseGesture.on_zoom")


# Called when the node enters the scene tree for the first time.
func _ready():
	draw_axes()

func draw_axes():
	var mesh: ImmediateMesh = ImmediateMesh.new()

	mesh.clear_surfaces()
	mesh.surface_begin(Mesh.PRIMITIVE_LINES)

	# X axis (red)
	mesh.surface_set_color(Color.RED)
	mesh.surface_add_vertex(Vector3.ZERO)
	mesh.surface_add_vertex(Vector3(1, 0, 0))

	# Y axis (green) 
	mesh.surface_set_color(Color.GREEN)
	mesh.surface_add_vertex(Vector3.ZERO)
	mesh.surface_add_vertex(Vector3(0, 1, 0))

	# Z axis (blue)
	mesh.surface_set_color(Color.BLUE) 
	mesh.surface_add_vertex(Vector3.ZERO)
	mesh.surface_add_vertex(Vector3(0, 0, 1))
	mesh.surface_end()

	var material = StandardMaterial3D.new()
	material.vertex_color_use_as_albedo = true

	var mesh_instance := MeshInstance3D.new()
	mesh_instance.mesh = mesh
	mesh_instance.set_surface_override_material(0, material)

	add_child(mesh_instance)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
