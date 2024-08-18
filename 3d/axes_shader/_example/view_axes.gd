extends Node3D

@onready var checkbox_x: CheckBox = $VBoxContainer/HBoxContainer/CheckBoxX
@onready var checkbox_y: CheckBox = $VBoxContainer/HBoxContainer/CheckBoxY
@onready var checkbox_z: CheckBox = $VBoxContainer/HBoxContainer/CheckBoxZ

@onready var rotation_x: Slider = $VBoxContainer/RotationSliderX
@onready var rotation_y: Slider = $VBoxContainer/RotationSliderY
@onready var rotation_z: Slider = $VBoxContainer/RotationSliderZ

@onready var origin_x: Slider = $VBoxContainer/OriginSliderX
@onready var origin_y: Slider = $VBoxContainer/OriginSliderY
@onready var origin_z: Slider = $VBoxContainer/OriginSliderZ

@onready var axes_shader: AxesShader = $Camera3D/Axes

var _axes_mask: int = AxesShader.Mask.X | AxesShader.Mask.Y | AxesShader.Mask.Z


func _on_check_box_x_toggled(toggled_on: bool) -> void:
	if toggled_on:
		_axes_mask = _axes_mask | AxesShader.Mask.X
	else:
		_axes_mask = _axes_mask & ~AxesShader.Mask.X
	print(_axes_mask)
	axes_shader.set_axes_mask(_axes_mask)
	
func _on_check_box_y_toggled(toggled_on: bool) -> void:
	if toggled_on:
		_axes_mask = _axes_mask | AxesShader.Mask.Y
	else:
		_axes_mask = _axes_mask & ~AxesShader.Mask.Y
	print(_axes_mask)
	axes_shader.set_axes_mask(_axes_mask)
	

func _on_check_box_z_toggled(toggled_on: bool) -> void:
	if toggled_on:
		_axes_mask = _axes_mask | AxesShader.Mask.Z
	else:
		_axes_mask = _axes_mask & ~AxesShader.Mask.Z
	print(_axes_mask)
	axes_shader.set_axes_mask(_axes_mask)

func _on_rotation_slider_value_changed(_value: float) -> void:
	axes_shader.set_axis_rotation(Vector3(
		rotation_x.value, rotation_y.value, rotation_z.value))

func _on_origin_slider_value_changed(_value: float) -> void:
	axes_shader.set_axis_origin(Vector3(origin_x.value, origin_y.value, origin_z.value))
