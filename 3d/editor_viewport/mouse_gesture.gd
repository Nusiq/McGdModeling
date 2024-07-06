## This class just redirects all of the input handling responsibility
## to it's parent (the viewport).
extends MouseGesture

var viewport: EditorViewport

func _ready() -> void:
	viewport = get_node("..")

func on_rotate(delta_poz: Vector2) -> void:
	viewport.on_rotate(delta_poz)

func on_pan(delta_poz: Vector2) -> void:
	viewport.on_pan(delta_poz)

func on_zoom(delta_poz: Vector2) -> void:
	viewport.on_zoom(delta_poz)

func on_reset_gesture() -> void:
	viewport.on_reset_gesture()
