class_name UnitCard
extends Control

signal selected(unit: UnitCard)
signal deselected(unit: UnitCard)

@export var unit_image: TextureRect
@export var nation_label: Label
@export var type_label: Label
@export var color_rect: ColorRect

var unit: Unit
var select_color: Color = Color.AQUA
var basic_color: Color = Color.DIM_GRAY


func _on_gui_input(event: InputEvent) -> void:
	if !(event is InputEventMouseButton) || !event.is_pressed():
		return

	match event.button_index:
		MOUSE_BUTTON_LEFT:
			on_select()
		MOUSE_BUTTON_RIGHT:
			on_deselect()


func on_select() -> void:
	color_rect.color = select_color
	unit.selected = true
	selected.emit(self)


func on_deselect() -> void:
	color_rect.color = basic_color
	unit.selected = false
	deselected.emit(self)
