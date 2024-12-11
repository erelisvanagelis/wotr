class_name ArmySelector
extends Control

signal composition_changed(composition_summary: String)
signal unit_selection_changed

@export var container: Container
@export var army_manager: ArmyManager

var selected_units: Array[UnitCard] = []
var units: Array[Unit]:
	set(value):
		selected_units = []
		value.sort_custom(func(a: Unit, b: Unit) -> bool: return unit_name(a) < unit_name(b))
		units = value
		composition_changed.emit(unit_composition_summary(value))
		update_ui(value)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	units = units


func _on_army_manager_focused_army_changed(army: Army) -> void:
	var test: Array[Unit] = []
	units = army.units if army else test


func update_ui(p_units: Array[Unit]) -> void:
	if !container:
		return
	for node: Node in container.get_children():
		node.queue_free()

	for unit: Unit in p_units:
		if !unit:
			print("unit is null")
			continue

		var unit_card: UnitCard = unit.instantiate_unit_card()

		unit_card.selected_changed.connect(on_unit_selected_deselected)

		container.add_child(unit_card)


func on_unit_selected_deselected(_unit_card: UnitCard) -> void:
	unit_selection_changed.emit()
	army_manager.selected_army = army_manager.selected_army



func unit_name(unit: Unit) -> String:
	return "%s %s" %[unit.data.type, unit.data.nation.title]

func unit_composition_summary(p_units: Array[Unit]) -> String:
	var composition := {}
	var weight := 0
	for unit: Unit in p_units:
		weight += unit.data.weight
		var type: StringName = unit.data.type
		if composition.has(type):
			composition[type] = composition[type] + 1
		else:
			composition[type] = 1

	var entries := PackedStringArray()
	for type: StringName in composition.keys():
		entries.append("%s - %s" % [type.capitalize(), str(composition[type])])

	if entries:
		return "(Weight: %s | %s)" % [weight, ", ".join(entries)]
	return ""
