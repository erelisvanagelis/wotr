@tool
extends EditorScript
const UNIT_TYPE := Constants.UNIT_TYPE

# Called when the script is executed (using File -> Run in Script Editor).
func _run() -> void:
	var scene := get_scene()
	if !(scene is Map) || !Engine.is_editor_hint():
		print('cant run, legs broken')
		return
	
	scene.get_tree().call_group(Constants.GROUP.ARMIES, "queue_free")
	var region_map: Dictionary = {}
	for region: Region in get_scene().get_tree().get_nodes_in_group(Constants.GROUP.REGIONS):
		region_map[region.id] = region
		
	for army_data: Dictionary in JSON.parse_string(FileAccess.open("res://import_data/army/armies.json", FileAccess.READ).get_as_text()):
		var region: Region = region_map[army_data['region_id']]
		var nation := region.nation;
		if army_data['region_id'] == "02feea":
			nation = load("res://data/nations/gondor.tres") as Nation
			
		var army := Army.new_army(nation, army_data[UNIT_TYPE.REGULAR], army_data[UNIT_TYPE.ELITE], army_data[UNIT_TYPE.LEADER])
		army.add_to_group(Constants.GROUP.ARMIES, true)
		scene.add_child(army, true)
		army.owner = scene
		for unit in army.units:
			army.add_child(unit, true)
			unit.owner = scene
		
		army.position = region.position
		army.position.y = army.position.y + 0.05
		region.army = army
		
		
func get_army_data(path: String) -> Dictionary:
	var armies_json: Array = JSON.parse_string(FileAccess.open(path, FileAccess.READ).get_as_text())
	var armies: Dictionary = {}
	for army: Dictionary in armies_json:
		armies[army['region_id']] = army

	return armies
