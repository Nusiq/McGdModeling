extends Control

class_name MouseGesture

## Implements the conditions for triggering the mouse gestures.
class Condition:
	func rotate_gesture_condition() -> bool: return true
	func pan_gesture_condition() -> bool: return true
	func zoom_gesture_condition() -> bool: return true
	func move_object_gesture_condition() -> bool: return true

## Possible types of gestures handled by MouseGesture.
enum Gesture {
	## Rotating the view
	ROTATING,
	## Panning the view
	PANNING,
	## Zooming the view
	ZOOMING,
	## Moving an object
	MOVING_OBJECT,
	## No gesture
	NONE,
}
## The currently performed gesture.
var current_gesture := Gesture.NONE
## The starting position of the gesture.
var gestrue_start_position := Vector2.ZERO

## Used in signals emitted by MouseGesture to indicate the stage of the gesture.
enum GestureStage {
	## The gesture has just started.
	JUST_STARTED,
	## The gesture ended successfully.
	SUCCESSFUL_END,
	## The gesture was cancelled.
	CANCELLED,
	## The gesture is still ongoing.
	UPDATE,
	## User pressed the gesture key again (used for object gestures).
	RETAPPED
}

## Emits the gesture signal based on the current gesture type.
func _emit_gesture_signal(gesture_stage: GestureStage) -> void:
	var delta_pos := (
		get_global_mouse_position() - gestrue_start_position)
	match current_gesture:
		Gesture.ROTATING:
			rotate_gesture.emit(delta_pos, gesture_stage)
		Gesture.PANNING:
			pan_gesture.emit(delta_pos, gesture_stage)
		Gesture.ZOOMING:
			zoom_gesture.emit(delta_pos, gesture_stage)
		Gesture.MOVING_OBJECT:
			move_object_gesture.emit(delta_pos, gesture_stage)

## Rotating the view gesture signal.
signal rotate_gesture(
	delta_pos: Vector2, gesture_stage: GestureStage)
## Panning the view gesture signal.
signal pan_gesture(
	delta_pos: Vector2, gesture_stage: GestureStage)
## Zooming the view gesture signal.
signal zoom_gesture(
	delta_pos: Vector2, gesture_stage: GestureStage)
## Moving an object gesture signal.
signal move_object_gesture(
	delta_pos: Vector2, gesture_stage: GestureStage)


## The conditions for triggering the mouse gestures, can be overridden to limit
## when the gestures are triggered.
var condition := Condition.new()

## Called every frame automatically.
## Checks if the mouse gestures have been released and calls the event handlers
## for the gestures if they're active.
## 
## @param delta The elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if current_gesture == Gesture.NONE:
		return
	_emit_gesture_signal(GestureStage.UPDATE)

## Starts the mouse gestures tracking when the proper key combination is
## pressed.
func _input(event: InputEvent) -> void:
	if current_gesture == Gesture.NONE:
		# Detect the start of the gesture and save the starting point
		if (
				event.is_action_pressed("gesture.rotate_view", false, true)
				and condition.rotate_gesture_condition()):
			current_gesture = Gesture.ROTATING
			gestrue_start_position = get_global_mouse_position()
			rotate_gesture.emit(
				Vector2.ZERO, GestureStage.JUST_STARTED)
		elif (
				event.is_action_pressed("gesture.pan_view", false, true)
				and condition.pan_gesture_condition()):
			current_gesture = Gesture.PANNING
			gestrue_start_position = get_global_mouse_position()
			pan_gesture.emit(
				Vector2.ZERO, GestureStage.JUST_STARTED)
		elif (
				event.is_action_pressed("gesture.zoom_view", false, true)
				and condition.zoom_gesture_condition()):
			current_gesture = Gesture.ZOOMING
			gestrue_start_position = get_global_mouse_position()
			zoom_gesture.emit(
				Vector2.ZERO, GestureStage.JUST_STARTED)
		elif (
				event.is_action_pressed("shortcut.move_object", false, true)
				and condition.move_object_gesture_condition()):
			current_gesture = Gesture.MOVING_OBJECT
			gestrue_start_position = get_global_mouse_position()
			move_object_gesture.emit(
				Vector2.ZERO, GestureStage.JUST_STARTED)
	elif (
		# Detect the successful end of the gesture
		(
			current_gesture == Gesture.ROTATING
			and event.is_action_released("gesture.rotate_view", false)
		) or (
			current_gesture == Gesture.PANNING
			and event.is_action_released("gesture.pan_view", false)
		) or (
			current_gesture == Gesture.ZOOMING
			and event.is_action_released("gesture.zoom_view", false)
		) or (
			current_gesture == Gesture.MOVING_OBJECT
			and event.is_action_released("shortcut.viewport_click", false)
		)
	):
		
		_emit_gesture_signal(GestureStage.SUCCESSFUL_END)
		current_gesture = Gesture.NONE
	elif event.is_action_released("shortcut.cancel", false):
		# Detect the cancellation of the gesture
		_emit_gesture_signal(GestureStage.CANCELLED)
		current_gesture = Gesture.NONE
	elif (
		current_gesture == Gesture.MOVING_OBJECT
		and event.is_action_pressed("shortcut.move_object", false, true)
	):
		# Detect the retapping of the gesture
		_emit_gesture_signal(GestureStage.RETAPPED)
