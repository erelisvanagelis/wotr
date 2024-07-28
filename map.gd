extends Node3D

@export
var cyl: CharacterBody3D

var selected_regions: Array[Region] = []
var selected: bool = false;
var selected_region_material: StandardMaterial3D
var selected_neigbour_material: StandardMaterial3D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	selected_region_material = StandardMaterial3D.new()
	selected_region_material.albedo_color = Color.from_string("E4F230", "ffffff")

	selected_neigbour_material = StandardMaterial3D.new()
	selected_neigbour_material.albedo_color = Color.from_string("fe019a", "ffffff")
	for region: Region in get_tree().get_nodes_in_group(Constants.GROUP.REGIONS):
		region.region_selected.connect(_on_static_body_3d_input_event_connector)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_static_body_3d_input_event_connector(region: Region) -> void:
	for _region in selected_regions:
		if _region != null:
			_region.reset_material()
	selected_regions.clear()

	print("Faction: %s, Nation: %s, region: %s" % [region.faction, region.nation, region.title])
	#cyl._move_to_parent_center(region.global_position)
	selected_regions.append_array(region.neighbours)
	selected_regions.append(region)

	for neighbour in region.neighbours:
		if neighbour != null:
			neighbour.set_surface_override_material(0, selected_neigbour_material)

	region.set_surface_override_material(0, selected_region_material)
