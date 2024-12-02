@tool  # Needed so it runs in editor.
extends EditorScenePostImport

const REGION_DATA_PATH: String = "res://assets/map/regions.json"
const MAP_DATA = Constants.MAP_DATA


# Called right after the scene is imported and gets the root node.
func _post_import(scene: Node) -> Object:
	var color_map: Image = Image.load_from_file("res://assets/map/map_mask.png")

	var nations_map := get_nation_map()
	var regions_data := get_region_data(REGION_DATA_PATH)
	var bounds := get_offset_bounds(scene)

	var regions := get_regions(scene)
	for region: Region in regions:
		region.add_to_group(Constants.GROUP.REGIONS, true)
		region.id = find_region_id(color_map, region.position, bounds[1], bounds[2])
		region = apply_region_data(region, regions_data, nations_map)

	var region_map := {}
	for region: Region in regions:
		region_map[region.id] = region
#
	for region: Region in regions:
		if !regions_data.has(region.id):
			continue
		var bours: Array[Region] = []
		for neighbour: String in regions_data[region.id][MAP_DATA.NEIGHBOURS]:
			bours.append(region_map[neighbour])

		var unreachable_neighbours: Array[Region] = []
		for neighbour: String in regions_data[region.id][MAP_DATA.UNREACHABLE_NEIGHBOURS]:
			unreachable_neighbours.append(region_map[neighbour])

		region.reachable_neighbours = bours
		region.unreachable_neighbours = unreachable_neighbours

	return scene


func get_nation_map() -> Dictionary:
	var nations_map := {}
	for nation: Nation in Nation.get_all_nations():
		print(nation)
		nations_map[nation.id] = nation

	return nations_map


func get_faction_data(path: String) -> Dictionary:
	var factions_json: Array = JSON.parse_string(FileAccess.open(path, FileAccess.READ).get_as_text())
	var factions: Dictionary = {}
	for faction: Dictionary in factions_json:
		factions[faction[MAP_DATA.ID]] = faction

	return factions


func get_regions_data_from_factions_data(factions: Dictionary) -> Dictionary:
	var regions: Dictionary = {}
	for faction: Dictionary in factions.values():
		for region: Dictionary in faction[MAP_DATA.REGIONS]:
			regions[region[MAP_DATA.ID]] = region

	return regions


func get_region_data(path: String) -> Dictionary:
	var regions_json: Array = JSON.parse_string(FileAccess.open(path, FileAccess.READ).get_as_text())
	var regions: Dictionary = {}
	for region: Dictionary in regions_json:
		regions[region[MAP_DATA.ID]] = region

	return regions


func get_offset_bounds(scene: Node) -> Array[Vector2]:
	var bounds := (scene.get_node(MAP_DATA.BOUNDS) as MeshInstance3D).get_aabb()
	var min_bound: Vector2 = Vector2(bounds.position.x, bounds.end.z)
	var max_bound: Vector2 = Vector2(bounds.end.x, bounds.end.z)
	var offset := Vector2(abs(0 - min_bound.x), abs(0 - min_bound.y))
	min_bound = min_bound + offset
	max_bound = max_bound + offset

	return [min_bound, max_bound, offset]


func get_regions(scene: Node) -> Array[Region]:
	var region_script: Resource = load("res://scripts/classes/region.gd")
	var regions: Array[Region] = []

	for node: Node in scene.get_children().filter(region_filter):
		node.set_script(region_script)
		var region := node as Region
		region.position.y = 0
		regions.append(region)

	return regions


func region_filter(node: Node) -> bool:
	return node.name.begins_with(MAP_DATA.REGION) && node is MeshInstance3D


func find_region_id(color_map: Image, position: Vector3, max_bound: Vector2, offset: Vector2) -> StringName:
	@warning_ignore("narrowing_conversion")
	var x: int = (position.x + offset.x) * color_map.get_size().x / max_bound.x
	@warning_ignore("narrowing_conversion")
	var y: int = (position.z + offset.y) * color_map.get_size().y / max_bound.y

	return color_map.get_pixel(x, y).to_html(false)


func apply_region_data(region: Region, regions_data: Dictionary, nations_data: Dictionary) -> Region:
	if !regions_data.has(region.id):
		print("Region has no data - ", region.id)
		return region

	var region_data: Dictionary = regions_data[region.id]
	var nation: Nation = nations_data[region_data[MAP_DATA.PARENT_ID]]

	var city := load("res://scripts/resources/region_types/city.tres")
	var fortification := load("res://scripts/resources/region_types/fortification.tres")
	var stronghold := load("res://scripts/resources/region_types/stronghold.tres")
	var town := load("res://scripts/resources/region_types/town.tres")
	var settlement := load("res://scripts/resources/region_types/settlement.tres")

	region.title = region_data[MAP_DATA.NAME]
	region.nation = nation
	if region_data[MAP_DATA.FORTIFICATION]:
		region.type = fortification
	elif region_data[MAP_DATA.CITY]:
		region.type = city
	elif region_data[MAP_DATA.TOWN]:
		region.type = town
	elif region_data[MAP_DATA.STRONGHOLD]:
		region.type = stronghold
	else:
		region.type = settlement

	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = Color.from_string(nation.id, "ffffff")
	region.default_material = material
	region.set_surface_override_material(0, region.default_material)

	return region
