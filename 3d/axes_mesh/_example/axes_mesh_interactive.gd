extends Node3D


@onready var axes: Axes = $Axes
@onready var node1: Node3D = $Node1
@onready var node2: Node3D = $Node1/Node2

@onready var editor_viewport: EditorViewport = $EditorViewport

@onready var target_dropdown: OptionButton = $Control/VBoxContainer/TargetDropdown
@onready var x_visible_checkbox: CheckBox = $Control/VBoxContainer/XVisibleCheckbox
@onready var y_visible_checkbox: CheckBox = $Control/VBoxContainer/YVisibleCheckbox
@onready var z_visible_checkbox: CheckBox = $Control/VBoxContainer/ZVisibleCheckbox
@onready var infinite_checkbox: CheckBox = $Control/VBoxContainer/InfiniteCheckbox

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	axes.editor_viewport = editor_viewport


func _on_infinite_checkbox_toggled(toggled_on: bool) -> void:
	axes.is_infinite = toggled_on

func _on_z_visible_checkbox_toggled(toggled_on: bool) -> void:
	axes.line_z_visible = toggled_on

func _on_y_visible_checkbox_toggled(toggled_on: bool) -> void:
	axes.line_y_visible = toggled_on


func _on_x_visible_checkbox_toggled(toggled_on: bool) -> void:
	axes.line_x_visible = toggled_on

func _on_target_dropdown_item_selected(index: int) -> void:
	match index:
		0:
			axes.origin_node = null
		1:
			axes.origin_node = node1
		2:
			axes.origin_node = node2
