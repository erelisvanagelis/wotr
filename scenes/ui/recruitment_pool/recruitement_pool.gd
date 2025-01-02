extends MarginContainer

@export var _army_manager: ArmyManager
@export var _map: Map

var recruitement_unit_card_scene: PackedScene = load(
	"res://scenes/ui/recruitment_unit_card/rectuitment_unit_card.tscn"
)
var unit_card_scene: PackedScene = load("res://scenes/ui/unit_card/unit_card.tscn")

@onready var container: HBoxContainer = %HBoxContainer
@onready var conditions_viewer: ConditionsViewer = %ConditionsViewer
@onready var conditions_not_met: CenterContainer = %ConditionsNotMet


func _ready() -> void:
	_map.focused_region_changed.connect(_on_focused_region_changed)
	_army_manager.focused_army_changed.connect(_on_focused_army_changed)


func _on_focused_army_changed(_army: Army) -> void:
	pass
	#var region: Region = null if !army else army.region
	#_on_focused_region_changed(region)


func _on_focused_region_changed(region: Region) -> void:
	for child in container.get_children():
		child.queue_free()
	conditions_viewer._on_condition_changed(null)

	if !region:
		return

	var conditions := _army_manager.can_region_recruit_conditions(region)
	conditions_viewer._on_condition_changed(conditions)

	var conditions_met := conditions.is_satisfied()
	conditions_not_met.visible = !conditions_met
	container.visible = conditions_met
	if !conditions_met:
		return

	for unit_data: UnitData in _army_manager.get_rectuitable_units(region):
		var unit_card: UnitCard = unit_card_scene.instantiate()
		unit_card.unit_data = unit_data
		unit_card.selected_changed.connect(_on_card_selected_changed)

		var recruit_card: RecruitUnitCard = recruitement_unit_card_scene.instantiate()
		recruit_card.card = unit_card
		var reserve_count: int = _army_manager.get_reserve_count(unit_data.type, region.nation)
		recruit_card.count = reserve_count

		container.add_child(recruit_card)


func _on_card_selected_changed(unit_card: UnitCard) -> void:
	if (
		!unit_card.selected
		|| !_army_manager.can_unit_be_recruited(
			unit_card.unit_data.type, unit_card.unit_data.nation
		)
	):
		return

	var army := (
		_army_manager
		. new_army_builder()
		. units({unit_card.unit_data.type: 1})
		. region(_map.focused_region)
		. build_and_assign_to_region()
	)
	_army_manager.selected_army = army
	unit_card.selected = false
	_on_focused_region_changed(army.region)
