class_name UnitData
extends Resource

#signal unit_selected(unit: Unit)
#signal unit_deselected(unit: Unit)

@export var type: StringName
@export var nation: Nation
@export var region_range: int = 1
@export var health: int = 1
@export var texture: Texture
@export var unit_card: PackedScene = preload("res://unit_card.tscn")
var selected: bool = false

static func select_unit(unit_nation: Nation, unit_type: String) -> UnitData:
	var base_path: String = "res://data/units/%s_%s.tres"
	var actual: String = (base_path % [unit_nation.title, unit_type]).to_lower()

	if ResourceLoader.exists(actual):
		return load(actual)

	if unit_nation.faction.title == 'Free People':
		return load("res://data/units/free_unit.tres")
	else:
		return load("res://data/units/shadow_unit.tres")


func instantiate_unit_card() -> UnitCard:
	var card_scene: UnitCard = unit_card.instantiate()
	card_scene.nation_label.text = nation.title
	card_scene.type_label.text = type
	card_scene.unit_image.texture = texture
	#card_scene.selected.connect(func(_unit: UnitCard) -> void: selected = true)
	#card_scene.deselected.connect(func(_unit: UnitCard) -> void: selected = false)
	#card_scene.unit = self
	return card_scene
