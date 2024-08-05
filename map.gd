class_name Map
extends Node3D

@export
var cyl: CharacterBody3D

var selected_neigboars: Array[Region] = []
var selected_region: Region
var selected_region_material := StandardMaterial3D.new()
var selected_neigbour_material := StandardMaterial3D.new()
var selected_army: Army
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	selected_region_material.albedo_color = Color.from_string("FF3131", "ffffff")
	selected_neigbour_material.albedo_color = Color.from_string("fe019a", "ffffff")
	for region: Region in get_tree().get_nodes_in_group(Constants.GROUP.REGIONS):
		region.region_selected.connect(on_region_selected)
		region.region_targeted.connect(_on_region_targeted)
		region.army_selected.connect(_on_army_selected)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func on_region_selected(region: Region) -> void:
	#print("Faction: %s, Nation: %s, region: %s, ID: %s" % [region.faction, region.nation, region.title, region.region_id])
	clear_selections()

	selected_region = region

	region.set_surface_override_material(0, selected_region_material)

func highlight_neighbours(region: Region, army: Army) -> void:
	selected_neigboars.append_array(region.neighbours)
	for neighbour in region.neighbours:
		if neighbour.can_army_enter(army):
			neighbour.set_surface_override_material(0, selected_neigbour_material)

func clear_selections() -> void:
	for _region in selected_neigboars:
		_region.reset_material()
	if selected_region != null:
		selected_region.reset_material()

	selected_neigboars.clear()
	selected_region = null
	selected_army = null

func _on_region_targeted(target_region: Region) -> void:
	if !selected_neigboars.has(target_region):
		print("not a neighbour")
		return
	if selected_army == null:
		print("no army selected")
		return
	if !target_region.can_army_enter(selected_army):
		print("not valid region")
		return
	
	selected_region.army = null
	target_region.army = selected_army
	clear_selections()

func _on_army_selected(region: Region, army: Army) -> void:
	on_region_selected(region)
	highlight_neighbours(region, army)
	selected_army = army
