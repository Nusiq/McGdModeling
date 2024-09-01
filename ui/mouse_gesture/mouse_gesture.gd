extends Control

class_name MouseGesture

enum Gesture {
	ROTATING,
	PANNING,
	ZOOMING,
	NONE
}
var current_gesture := Gesture.NONE
var gestrue_start_position := Vector2.ZERO


signal rotate_gesture(delta_poz: Vector2)
signal pan_gesture(delta_poz: Vector2)
signal zoom_gesture(delta_poz: Vector2)
signal reset_gesture()

## Called every frame automatically.
## Checks if the mouse gestures have been released and calls the event handlers
## for the gestures if they're active.
## 
## @param delta The elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_released("gesture.rotate_view", false):
		current_gesture = Gesture.NONE
	if Input.is_action_just_released("gesture.pan_view", false):
		current_gesture = Gesture.NONE
	if Input.is_action_just_released("gesture.zoom_view", false):
		current_gesture = Gesture.NONE

	if current_gesture != Gesture.NONE:
		var delta_pos := (
			get_global_mouse_position() - gestrue_start_position
		) / size
		match current_gesture:
			Gesture.ROTATING:
				rotate_gesture.emit(delta_pos)
			Gesture.PANNING:
				pan_gesture.emit(delta_pos)
			Gesture.ZOOMING:
				zoom_gesture.emit(delta_pos)
	else:
		reset_gesture.emit()

## Called automatically on GUI inputs.
## Starts the mouse gestures tracking when the proper key combination is
## pressed.
##
## @param event The GUI input event.
func _gui_input(event: InputEvent) -> void:
	# Detect the start of the gesture and save the starting point
	if event.is_action_pressed("gesture.rotate_view", false, true):
		current_gesture = Gesture.ROTATING
		gestrue_start_position = get_global_mouse_position()
	elif event.is_action_pressed("gesture.pan_view", false, true):
		current_gesture = Gesture.PANNING
		gestrue_start_position = get_global_mouse_position()
	elif event.is_action_pressed("gesture.zoom_view", false, true):
		current_gesture = Gesture.ZOOMING
		gestrue_start_position = get_global_mouse_position()
