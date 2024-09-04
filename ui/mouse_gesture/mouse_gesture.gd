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


signal rotate_gesture(delta_poz: Vector2, just_started: bool)
signal pan_gesture(delta_poz: Vector2, just_started: bool)
signal zoom_gesture(delta_poz: Vector2, just_started: bool)
signal reset_gesture()

## Implements the conditions for triggering the mouse gestures.
class Condition:
	func rotate_gesture_condition() -> bool: return true
	func pan_gesture_condition() -> bool: return true
	func zoom_gesture_condition() -> bool: return true

var condition := Condition.new()

## Called every frame automatically.
## Checks if the mouse gestures have been released and calls the event handlers
## for the gestures if they're active.
## 
## @param delta The elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if (
		(
			current_gesture == Gesture.ROTATING
			and Input.is_action_just_released("gesture.rotate_view", false)
		) or (
			current_gesture == Gesture.PANNING
			and Input.is_action_just_released("gesture.pan_view", false)
		) or (
			current_gesture == Gesture.ZOOMING
			and Input.is_action_just_released("gesture.zoom_view", false)
		)
	):
		current_gesture = Gesture.NONE
		reset_gesture.emit()
	elif current_gesture != Gesture.NONE:
		var delta_pos := (
			get_global_mouse_position() - gestrue_start_position
		) / size
		match current_gesture:
			Gesture.ROTATING:
				rotate_gesture.emit(delta_pos, false)
			Gesture.PANNING:
				pan_gesture.emit(delta_pos, false)
			Gesture.ZOOMING:
				zoom_gesture.emit(delta_pos, false)


## Called automatically on GUI inputs.
## Starts the mouse gestures tracking when the proper key combination is
## pressed.
func _input(event: InputEvent) -> void:
	if current_gesture != Gesture.NONE:
		return
	# Detect the start of the gesture and save the starting point
	if (
			event.is_action_pressed("gesture.rotate_view", false, true)
			and condition.rotate_gesture_condition()):
		current_gesture = Gesture.ROTATING
		gestrue_start_position = get_global_mouse_position()
		rotate_gesture.emit(Vector2.ZERO, true)
	elif (
			event.is_action_pressed("gesture.pan_view", false, true)
			and condition.pan_gesture_condition()):
		current_gesture = Gesture.PANNING
		gestrue_start_position = get_global_mouse_position()
		pan_gesture.emit(Vector2.ZERO, true)
	elif (
			event.is_action_pressed("gesture.zoom_view", false, true)
			and condition.zoom_gesture_condition()):
		current_gesture = Gesture.ZOOMING
		gestrue_start_position = get_global_mouse_position()
		zoom_gesture.emit(Vector2.ZERO, true)

