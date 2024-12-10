class_name ArmyManager
extends Node3D

signal selected_army_changed(emmiter: Army)
signal hovered_army_changed(emmiter: Army)
signal focused_army_changed(emmiter: Army)

const UNIT_TYPE := Constants.UNIT_TYPE

var selected_army: Army:
	set(value):
		selected_army = value
		if selected_army:
			for unit: Unit in selected_army.units:
				unit.selected = true
		selected_army_changed.emit(value)
var hovered_army: Army:
	set(value):
		if hovered_army == value:
			hovered_army = null
		else:
			hovered_army = value

		if value && value != selected_army:
			for unit: Unit in value.units:
				unit.selected = false

		hovered_army_changed.emit(hovered_army)
var focused_army: Army:
	set(value):
		focused_army = value
		focused_army_changed.emit(value)

var _nazgul: UnitData = load("res://scripts/resources/units/sauron_nazgûl.tres")


# Called when the script is executed (using File -> Run in Script Editor).
func _ready() -> void:
	hovered_army_changed.connect(_on_focus_armies_changed)
	selected_army_changed.connect(_on_focus_armies_changed)

	get_tree().call_group(Constants.GROUP.ARMIES, "queue_free")
	get_tree().call_group(Constants.GROUP.UNITS, "queue_free")

	var region_map: Dictionary = {}
	for region: Region in get_tree().get_nodes_in_group("regions"):
		region_map[region.id] = region

	var armies_file := FileAccess.open("res://assets/army/armies.json", FileAccess.READ)
	for army_data: Dictionary in JSON.parse_string(armies_file.get_as_text()):
		var region: Region = region_map[army_data["region_id"]]
		var nation := region.nation
		if army_data["region_id"] == "02feea":
			nation = load("res://scripts/resources/nations/gondor.tres")

		army_data.erase("region_id")
		(
			new_army_builder()
			. region(region)
			. nation(nation)
			. units(army_data)
			. ignored_reserves(true)
			. build_and_assign_to_region()
		)


func split_army_by_selected_units(army: Army) -> Army:
	var selected_units: Array[Unit] = army.get_selected_units()
	if selected_units == army.units:
		return army

	for unit in selected_units:
		army.units.erase(unit)

	var new_army: Army = new_army_builder().faction(army.faction).build()
	new_army.units = selected_units
	new_army.position = army.position + Vector3(0.05, 0, 0)
	new_army.region = army.region

	return new_army


func get_army_data(path: String) -> Dictionary:
	var armies_json: Array = JSON.parse_string(FileAccess.open(path, FileAccess.READ).get_as_text())
	var armies: Dictionary = {}
	for army: Dictionary in armies_json:
		armies[army["region_id"]] = army

	return armies


func new_army_builder() -> ArmyBuilder:
	return ArmyBuilder.new(self)


func _on_focus_armies_changed(_army: Army) -> void:
	focused_army = selected_army if hovered_army == null else hovered_army


func can_region_recruit_conditions(region: Region) -> ConditionComponent:
	return CompositeCondition.all(
		"All requirements need to be met:",
		[
			SingleCondition.new(
				"Region is a Town/City/Stronghold", func() -> bool: return region.type.allows_recruitment
			),
			SingleCondition.new("Nation is at War", func() -> bool: return region.nation.at_war),
			CompositeCondition.any(
				"Any condition needs to be met:",
				[
					SingleCondition.new(
						"Army Weight is less <= 10",
						func() -> bool: return region.army == null || region.army.get_army_weight() < 10
					),
					SingleCondition.new(
						"Has recruitable units with 0 weight",
						func() -> bool: return any_weigtless_units(region)
					),
				]
			)
		]
	)

func any_weigtless_units(region: Region) -> bool:
	return get_rectuitable_units(region).any(func (unit: UnitData) -> bool: return unit.weight == 0)

func get_rectuitable_units(region: Region) -> Array[UnitData]:
	var base_path: String = "res://scripts/resources/units/%s_%s.tres"

	var units: Array[UnitData] = []
	for unit_type: StringName in Constants.UNIT_TYPE.values():
		var actual_path: String = (base_path % [region.nation.title.replace(" ", "_"), unit_type]).to_lower()
		if ResourceLoader.exists(actual_path) && can_unit_be_recruited(unit_type, region.nation):
			units.append(load(actual_path))

	if region.nation == Nations.SAURON && region.type != RegionTypes.STRONGHOLD:
		units.erase(_nazgul)

	return units


func can_unit_be_recruited(unit_type: StringName, nation: Nation) -> bool:
	return get_reserve_count(unit_type, nation) > 0


func get_reserve_count(unit_type: StringName, nation: Nation) -> int:
	match unit_type:
		Constants.UNIT_TYPE.LEADER:
			return nation.leaders
		Constants.UNIT_TYPE.ELITE:
			return nation.elites
		Constants.UNIT_TYPE.NAZGUL:
			return nation.nazguls
		Constants.UNIT_TYPE.REGULAR:
			return nation.regulars
		_:
			assert(false, "get_reserve_count, failed match failed")
			return -1


func decrease_nation_reserves(unit_type: StringName, nation: Nation, unit_count: int) -> void:
	match unit_type:
		Constants.UNIT_TYPE.LEADER:
			nation.leaders -= unit_count
		Constants.UNIT_TYPE.ELITE:
			nation.elites -= unit_count
		Constants.UNIT_TYPE.NAZGUL:
			nation.nazguls -= unit_count
		Constants.UNIT_TYPE.REGULAR:
			nation.regulars -= unit_count
		_:
			assert(false, "decrease_nation_reserves, failed match failed")
