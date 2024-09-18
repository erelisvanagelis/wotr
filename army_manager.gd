class_name ArmyManager
extends Node3D

signal army_selected(army: Army)
signal army_deselected()

@onready var army_scene: PackedScene = preload("res://army.tscn")
const UNIT_TYPE := Constants.UNIT_TYPE

func create_army(nation: Nation, regular: int, elite: int, leader: int) -> Army:
	var army: Army = load("res://army.tscn").instantiate()
	army.faction = nation.faction
	var new_units: Array[Unit] = []
	for _i in regular:
		var unit: Unit = Unit.select_unit(nation, Constants.UNIT_TYPE.REGULAR)
		#unit.type = Constants.UNIT_TYPE.REGULAR
		#unit.nation = nation
		new_units.append(unit)
	for _i in elite:
		var unit: Unit = Unit.select_unit(nation, Constants.UNIT_TYPE.ELITE)
		#unit.type = Constants.UNIT_TYPE.ELITE
		#unit.nation = nation
		new_units.append(unit)
	for _i in leader:
		var unit: Unit = Unit.select_unit(nation, Constants.UNIT_TYPE.LEADER)
		#unit.type = Constants.UNIT_TYPE.LEADER
		#unit.nation = nation
		new_units.append(unit)
	army.units = new_units

	army.selected.connect(func(army: Army) -> void: army_selected.emit(army))
	army.deselected.connect(func() -> void: army_deselected.emit())
	add_child(army)
	#army.owner = self

	return army


func split_army_by_selected_units(selected_army: Army) -> Army:
	var new_army: Army = load("res://army.tscn").instantiate()
	var split_off_units: Array[Unit] = selected_army.get_selected_units()
	new_army.faction = selected_army.faction
	new_army.units = split_off_units
	var position:= Vector3(selected_army.position)
	new_army.position = position
	new_army.position.x = position.x + 0.05

	for unit in split_off_units:
		selected_army.units.erase(unit)
		unit.selected = false

	new_army.selected.connect(func(army: Army) -> void: army_selected.emit(army))
	new_army.deselected.connect(func() -> void: army_deselected.emit())
	add_child(new_army)
	return new_army


# Called when the script is executed (using File -> Run in Script Editor).
func _ready() -> void:
	pass # Replace with function body.

	get_tree().call_group(Constants.GROUP.ARMIES, "queue_free")
	get_tree().call_group(Constants.GROUP.UNITS, "queue_free")
	var region_map: Dictionary = {}
	for region: Region in get_tree().get_nodes_in_group(Constants.GROUP.REGIONS):
		region_map[region.id] = region

	for army_data: Dictionary in JSON.parse_string(FileAccess.open("res://import_data/army/armies.json", FileAccess.READ).get_as_text()):
		var region: Region = region_map[army_data['region_id']]
		var nation := region.nation;
		if army_data['region_id'] == "02feea":
			nation = load("res://data/nations/gondor.tres") as Nation

		var army := create_army(nation, army_data[UNIT_TYPE.REGULAR], army_data[UNIT_TYPE.ELITE], army_data[UNIT_TYPE.LEADER])
		print("manager called")
		army.position = region.position
		army.position.y = army.position.y + 0.05
		region.army = army
		army.region = region


func get_army_data(path: String) -> Dictionary:
	var armies_json: Array = JSON.parse_string(FileAccess.open(path, FileAccess.READ).get_as_text())
	var armies: Dictionary = {}
	for army: Dictionary in armies_json:
		armies[army['region_id']] = army

	return armies
