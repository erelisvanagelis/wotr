extends Control

@export var container: HBoxContainer
@export var army_manager: ArmyManager
var units: Array[Unit]:
	set(value):
		for unit in units:
			unit.selected = false
		selected_units = []
		units = value
		update_ui(value)

@onready var selected_units: Array[UnitCard] = []

var unit_card_scene := preload("res://unit_card.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	units = units
	army_manager.army_selected.connect(army_selected)
	army_manager.army_deselected.connect(army_deselected)


func army_selected(army: Army) -> void:
	print("army_selected")
	print(army.units.size())
	units = army.units


func army_deselected() -> void:
	print("deselected")
	#for unit: Unit in units
	units = []


func update_ui(selected_units: Array[Unit]) -> void:
	print("called update ui")
	if !container:
		return
	for node: Node in container.get_children():
		node.queue_free()

	for unit: Unit in selected_units:
		if !unit:
			print("unit is null")
			continue

		var unit_card: UnitCard = unit.instantiate_unit_card()
		unit_card.on_select()

		container.add_child(unit_card)

	print("Selected Units Count: ", selected_units.size())
	visible = !selected_units.is_empty()
	print(visible)

#var selected