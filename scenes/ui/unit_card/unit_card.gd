class_name UnitCard
extends Control

signal selected_changed(unit: UnitCard)

@export var unit_data: UnitData
@export var selected: bool:
	set(value):
		var old_value := selected
		selected = value
		_on_selected_changed(value)
		if old_value != selected:
			selected_changed.emit(self)

var select_color: Color = Color.AQUA
var basic_color: Color = Color.DIM_GRAY

@onready var _unit_image: TextureRect = %TextureRect
@onready var _nation_label: Label = %Nation
@onready var _type_label: Label = %Type
@onready var _color_rect: ColorRect = %ColorRect


func _ready() -> void:
	_nation_label.text = unit_data.nation.title_short
	_type_label.text = unit_data.type
	_unit_image.texture = unit_data.texture
	self.tooltip_text = "Weight %s" % [unit_data.weight,]
	_on_selected_changed(selected)


func _on_gui_input(event: InputEvent) -> void:
	if !(event is InputEventMouseButton) || !event.is_pressed():
		return

	match event.button_index:
		MOUSE_BUTTON_LEFT:
			selected = true
		MOUSE_BUTTON_RIGHT:
			selected = false


func _on_selected_changed(p_selected: bool) -> void:
	if !_color_rect:
		return

	if p_selected:
		_color_rect.color = select_color
	else:
		_color_rect.color = basic_color
