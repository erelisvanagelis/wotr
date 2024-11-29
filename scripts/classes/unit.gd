class_name Unit
extends RefCounted

const UNIT_CARD: PackedScene = preload("res://scenes/ui/unit_card/unit_card.tscn")
var data: UnitData
var selected: bool = false


static func select_unit(unit_nation: Nation, unit_type: String) -> Unit:
	var unit := Unit.new()
	var base_path: String = "res://scripts/resources/units/%s_%s.tres"
	var actual: String = (base_path % [unit_nation.title.replace(" ", "_"), unit_type]).to_lower()
	if ResourceLoader.exists(actual):
		unit.data = load(actual)

	if unit.data:
		return unit

	if unit_nation.faction.title == "Free People":
		unit.data = load("res://scripts/resources/units/free_unit.tres")
	else:
		unit.data = load("res://scripts/resources/units/shadow_unit.tres")

	return unit


func instantiate_unit_card() -> UnitCard:
	var card_scene: UnitCard = UNIT_CARD.instantiate()
	card_scene.nation_label.text = data.nation.title
	card_scene.type_label.text = data.type
	card_scene.unit_image.texture = data.texture
	card_scene.unit = self
	return card_scene
