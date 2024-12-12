class_name ArmyManager
extends Node

signal selected_army_changed(emmiter: Army)
signal hovered_army_changed(emmiter: Army)
signal focused_army_changed(emmiter: Army)

const UNIT_TYPE := Constants.UNIT_TYPE
const ArmyActionType := Constants.ArmyActionType

var selected_army: Army:
	set(value):
		var old_value := selected_army
		selected_army = value
		if selected_army != old_value && selected_army:
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
var _free_regions: Nation = load("res://scripts/resources/nations/unaligned.tres")


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
						"Army weight is less <= 10",
						func() -> bool: return region.army == null || region.army.get_army_weight() < 10
					),
					SingleCondition.new(
						"Has recruitable units with 0 weight", func() -> bool: return any_weigtless_units(region)
					),
				]
			)
		]
	)


func any_weigtless_units(region: Region) -> bool:
	return get_rectuitable_units(region).any(func(unit: UnitData) -> bool: return unit.weight == 0)


func get_rectuitable_units(region: Region) -> Array[UnitData]:
	var base_path: String = "res://scripts/resources/units/%s_%s.tres"

	var units: Array[UnitData] = []
	for unit_type: StringName in Constants.UNIT_TYPE.values():
		var actual_path: String = (base_path % [region.nation.title.replace(" ", "_"), unit_type]).to_lower()
		if ResourceLoader.exists(actual_path) && can_unit_be_recruited(unit_type, region.nation):
			var unit: UnitData = load(actual_path)
			var current_army_size: int = 0 if !region.army else region.army.get_army_weight()
			if current_army_size + unit.weight <= 10:
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


func update_nation_reserves(unit_type: StringName, nation: Nation, unit_count: int) -> void:
	match unit_type:
		Constants.UNIT_TYPE.LEADER:
			nation.leaders += unit_count
		Constants.UNIT_TYPE.ELITE:
			nation.elites += unit_count
		Constants.UNIT_TYPE.NAZGUL:
			nation.nazguls += unit_count
		Constants.UNIT_TYPE.REGULAR:
			nation.regulars += unit_count
		_:
			assert(false, "update_nation_reserves, failed match failed")


func find_army_action_type(incoming_army: Army, target_region: Region) -> ArmyActionType:
	if !target_region.army || incoming_army.faction == target_region.army.faction:
		return ArmyActionType.MOVE

	return ArmyActionType.ATTACK


func can_army_attack(incoming_army: Army, target_region: Region) -> bool:
	return build_army_attack_conditions(incoming_army, target_region).is_satisfied()


func can_army_move(incoming_army: Army, target_region: Region) -> bool:
	return build_army_movement_conditions(incoming_army, target_region).is_satisfied()


func can_army_perform_any_action(incoming_army: Army, target_region: Region) -> bool:
	return can_army_attack(incoming_army, target_region) || can_army_move(incoming_army, target_region)


func build_army_movement_conditions(incoming_army: Army, target_region: Region) -> ConditionComponent:
	if !incoming_army.get_selected_units():
		return SingleCondition.new("Units Selected", func() -> bool: return false)
	var distict_unit_types: Dictionary = {}
	for unit in incoming_army.get_selected_units():
		distict_unit_types[unit.data] = unit

	var unit_conditions: Array[ConditionComponent] = []
	for unit_data: UnitData in distict_unit_types.keys():
		var units: Array[Unit] = [distict_unit_types[unit_data]]
		unit_conditions.append(
			CompositeCondition.any(
				"%s %s - can enter:" % [unit_data.nation.title, unit_data.type],
				[
					SingleCondition.new(
						"Unit belongs to the nation",
						func() -> bool: return are_units_from_the_same_nation(units, target_region.nation)
					),
					SingleCondition.new("Unit nation is at war", func() -> bool: return are_units_at_war(units)),
				]
			)
		)

	return CompositeCondition.all(
		"All need to be true:",
		[
			SingleCondition.new(
				"Not a mountainous border",
				func() -> bool: return target_region.reachable_neighbours.has(incoming_army.region)
			),
			SingleCondition.new(
				"Not attacking another army", func() -> bool: return !target_region.army || target_region.army.faction == incoming_army.faction
			),
			SingleCondition.new(
				"Merge army weight <= 10", func() -> bool: return can_armies_fit(incoming_army, target_region.army)
			),
			SingleCondition.new( "Leader units remain with an army", func() -> bool: return !any_solo_leaders_after_move(incoming_army, target_region)
			),
			CompositeCondition.any(
				"Any must be true:",
				[
					SingleCondition.new(
						"Region is unaligned", func() -> bool: return target_region.nation == _free_regions
					),
					CompositeCondition.all("All must be true:", unit_conditions),
				]
			)
		]
	)


func build_army_attack_conditions(incoming_army: Army, target_region: Region) -> ConditionComponent:
	if !incoming_army.get_selected_units():
		return SingleCondition.new("Units Selected", func() -> bool: return false)
	var distict_unit_types: Dictionary = {}
	for unit in incoming_army.get_selected_units():
		distict_unit_types[unit.data] = unit

	var unit_conditions: Array[ConditionComponent] = []
	for unit_data: UnitData in distict_unit_types.keys():
		var units: Array[Unit] = [distict_unit_types[unit_data]]
		unit_conditions.append(
			CompositeCondition.any(
				"%s %s - can enter:" % [unit_data.nation.title, unit_data.type],
				[
					SingleCondition.new("Unit nation is at war", func() -> bool: return are_units_at_war(units)),
				]
			)
		)

	return CompositeCondition.all(
		"All need to be true:",
		[
			SingleCondition.new(
				"Neighboaring region",
				func() -> bool: return target_region.reachable_neighbours.has(incoming_army.region)
			),
			SingleCondition.new(
				"Army of opposing faction",
				func() -> bool: return find_army_action_type(incoming_army, target_region) == ArmyActionType.ATTACK
			),
			CompositeCondition.all("All must be true:", unit_conditions),
		]
	)


func build_army_conditions(incoming_army: Army, target_region: Region) -> ConditionComponent:
	match find_army_action_type(incoming_army, target_region):
		ArmyActionType.ATTACK:
			return build_army_attack_conditions(incoming_army, target_region)
		ArmyActionType.MOVE:
			return build_army_movement_conditions(incoming_army, target_region)
		_:
			assert(false, "Should not happen")
			return null


func can_armies_fit(f_army: Army, s_army: Army) -> bool:
	if f_army == null || s_army == null:
		return true

	return army_size(f_army.get_selected_units()) + army_size(s_army.units) <= 10


func army_size(units: Array[Unit]) -> int:
	return units.reduce(func(accum: int, unit: Unit) -> int: return accum + unit.data.weight, 0)


func are_units_at_war(units: Array[Unit]) -> bool:
	return units.filter(func(x: Unit) -> bool: return x.data.nation.at_war).size() == units.size()


func are_units_from_the_same_nation(units: Array[Unit], other_nation: Nation) -> bool:
	return units.filter(func(x: Unit) -> bool: return x.data.nation == other_nation).size() == units.size()


func any_solo_leaders_after_move(army: Army, target_region: Region) -> bool:
	var only_leaders_predicate := func(unit: Unit) -> bool: return unit.data.type == UNIT_TYPE.LEADER
	if army.get_not_selected_units() && army.get_not_selected_units().all(only_leaders_predicate):
		return true

	return army.get_selected_units().all(only_leaders_predicate) && !target_region.army

func _get_leaders(army: Army, selected: bool)-> Array[Unit]:
	return army.units.filter(func(unit: Unit)-> bool: return unit.selected == selected && unit.data.type == UNIT_TYPE.LEADER)

func move_army_into_region(incoming_army: Army, target_region: Region) -> void:
	update_political_track(incoming_army, target_region)
	var present_army: Army = target_region.army
	if incoming_army && present_army && incoming_army.faction == present_army.faction:
		incoming_army.merge_armies(present_army)
	elif (present_army && incoming_army) && present_army != incoming_army:
		if present_army.faction == Faction.shadow():
			for unit: Unit in present_army.units:
				update_nation_reserves(unit.data.type, unit.data.nation, 1)
		present_army.remove_self()

	if incoming_army && incoming_army.region.army == incoming_army:
		incoming_army.region.army = null
	target_region.army = incoming_army



func update_political_track(incoming_army: Army, target_region: Region) -> void:
	if incoming_army.faction != target_region.nation.faction:
		target_region.nation.active = true
		target_region.nation.closer_to_war()
	if target_region.army != null && incoming_army.faction != target_region.army.faction:
		var attacked_nations := {}
		for unit: Unit in target_region.army.units:
			attacked_nations[unit.data.nation] = unit.data.nation

		for nation: Nation in attacked_nations.keys():
			nation.active = true
			nation.closer_to_war()
