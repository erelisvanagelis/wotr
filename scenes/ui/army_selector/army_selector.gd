class_name ArmySelector
extends Control

signal unit_selection_changed

@export var container: Container
@export var army_manager: ArmyManager


var units: Array[Unit]:
	set(value):
		for unit in units:
			unit.selected = false

		selected_units = []
		units = value
		update_ui(value)

@onready var selected_units: Array[UnitCard] = []


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
	units = []


func update_ui(p_units: Array[Unit]) -> void:
	print("called update ui")
	if !container:
		return
	for node: Node in container.get_children():
		node.queue_free()

	for unit: Unit in p_units:
		if !unit:
			print("unit is null")
			continue

		var unit_card: UnitCard = unit.instantiate_unit_card()
		unit_card.on_select()
		unit_card.selected.connect(on_unit_selected_deselected)
		unit_card.deselected.connect(on_unit_selected_deselected)

		container.add_child(unit_card)

	print("Selected Units Count: ", selected_units.size())
	#visible = !selected_units.is_empty()
	print(visible)


func on_unit_selected_deselected(_unit_card: UnitCard) -> void:
	unit_selection_changed.emit()
