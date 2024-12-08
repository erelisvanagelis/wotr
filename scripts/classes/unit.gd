class_name Unit
extends RefCounted

const UNIT_CARD: PackedScene = preload("res://scenes/ui/unit_card/unit_card.tscn")
var data: UnitData
var selected: bool = false


static func select_unit(unit_nation: Nation, unit_type: String) -> Unit:
	return select_unit_by_string(unit_nation.title, unit_type)


static func select_units(unit_nation: Nation, unit_type: String, count: int) -> Array[Unit]:
	var units: Array[Unit] = []
	for i: int in range(0, count):
		units.append(select_unit_by_string(unit_nation.title, unit_type))

	return units


static func select_unit_by_string(unit_nation_title: String, unit_type: String) -> Unit:
	var unit := Unit.new()
	var base_path: String = "res://scripts/resources/units/%s_%s.tres"
	var actual: String = (base_path % [unit_nation_title.replace(" ", "_"), unit_type]).to_lower()

	assert(ResourceLoader.exists(actual), "Cannot find Unit Data resource, with path: %s" % actual)
	unit.data = load(actual)

	return unit


func instantiate_unit_card() -> UnitCard:
	var card_scene: UnitCard = UNIT_CARD.instantiate()
	card_scene.unit_data = data
	card_scene.selected = selected
	card_scene.selected_changed.connect(func(card: UnitCard) -> void: selected = card.selected)

	return card_scene
