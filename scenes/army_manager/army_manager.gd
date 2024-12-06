class_name ArmyManager
extends Node3D

signal selected_army_changed(emmiter: Army)
signal hovered_army_changed(emmiter: Army)
signal focused_army_changed(emmiter: Army)

const UNIT_TYPE := Constants.UNIT_TYPE

var selected_army: Army:
	set(value):
		selected_army = value
		selected_army_changed.emit(value)
var hovered_army: Army:
	set(value):
		if hovered_army == value:
			hovered_army = null
		else:
			hovered_army = value

		hovered_army_changed.emit(hovered_army)
var focused_army: Army:
	set(value):
		focused_army_changed.emit(value)
		focused_army = value


# Called when the script is executed (using File -> Run in Script Editor).
func _ready() -> void:
	hovered_army_changed.connect(_on_focus_armies_changed)
	selected_army_changed.connect(_on_focus_armies_changed)

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
			nation = load("res://scripts/resources/nations/gondor.tres")

		army_data.erase("region_id")
		new_army_builder().region(region).nation(nation).units(army_data).build_and_assign_to_region()


func split_army_by_selected_units(army: Army) -> Army:
	var selected_units: Array[Unit] = army.get_selected_units()
	if selected_units == army.units:
		return army

	for unit in selected_units:
		army.units.erase(unit)
		unit.selected = false

	var new_army: Army = new_army_builder().nation(army.region.nation).build()
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
