class_name ArmyManager
extends Node3D

signal army_selected(army: Army)
signal army_deselected

const UNIT_TYPE := Constants.UNIT_TYPE


func create_army(nation: Nation, regular: int, elite: int, leader: int, nazgul: int) -> Army:
	var army: Army = load("res://scenes/army/army.tscn").instantiate()
	army.faction = nation.faction
	var new_units: Array[Unit] = []
	for _i in regular:
		var unit: Unit = Unit.select_unit(nation, Constants.UNIT_TYPE.REGULAR)
		new_units.append(unit)
	for _i in elite:
		var unit: Unit = Unit.select_unit(nation, Constants.UNIT_TYPE.ELITE)
		new_units.append(unit)
	for _i in leader:
		var unit: Unit = Unit.select_unit(nation, Constants.UNIT_TYPE.LEADER)
		new_units.append(unit)
	for _i in nazgul:
		var unit: Unit = Unit.select_unit(nation, Constants.UNIT_TYPE.LEADER)
		new_units.append(unit)
	army.units = new_units

	army.selected.connect(func(selected_army: Army) -> void: army_selected.emit(selected_army))
	army.deselected.connect(func() -> void: army_deselected.emit())
	add_child(army)

	return army


func split_army_by_selected_units(selected_army: Army) -> Army:
	var split_off_units: Array[Unit] = selected_army.get_selected_units()
	if split_off_units == selected_army.units:
		return selected_army

	var new_army: Army = load("res://scenes/army/army.tscn").instantiate()
	new_army.faction = selected_army.faction
	new_army.units = split_off_units
	var offset_position := Vector3(selected_army.position)
	new_army.position = offset_position
	new_army.position.x = offset_position.x + 0.05

	for unit in split_off_units:
		selected_army.units.erase(unit)
		unit.selected = false

	new_army.selected.connect(func(army: Army) -> void: army_selected.emit(army))
	new_army.deselected.connect(func() -> void: army_deselected.emit())
	add_child(new_army)
	return new_army


# Called when the script is executed (using File -> Run in Script Editor).
func _ready() -> void:
	get_tree().call_group(Constants.GROUP.ARMIES, "queue_free")
	get_tree().call_group(Constants.GROUP.UNITS, "queue_free")
	var region_map: Dictionary = {}
	for region: Region in get_tree().get_nodes_in_group(Constants.GROUP.REGIONS):
		region_map[region.id] = region

	var armies_file := FileAccess.open("res://assets/army/armies.json", FileAccess.READ)
	for army_data: Dictionary in JSON.parse_string(armies_file.get_as_text()):
		var region: Region = region_map[army_data["region_id"]]
		var nation := region.nation
		if army_data["region_id"] == "02feea":
			nation = load("res://scripts/resources/nations/gondor.tres") as Nation

		var army := create_army(nation, army_data[UNIT_TYPE.REGULAR], army_data[UNIT_TYPE.ELITE], army_data[UNIT_TYPE.LEADER], army_data[UNIT_TYPE.NAZGUL])
		army.position = region.position
		army.position.y = army.position.y + 0.05
		region.army = army
		army.region = region


func get_army_data(path: String) -> Dictionary:
	var armies_json: Array = JSON.parse_string(FileAccess.open(path, FileAccess.READ).get_as_text())
	var armies: Dictionary = {}
	for army: Dictionary in armies_json:
		armies[army["region_id"]] = army

	return armies
