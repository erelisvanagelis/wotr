class_name Map
extends Node3D

@export var army_manager: ArmyManager
@export var army_selector: ArmySelector

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

	army_manager.army_selected.connect(_on_army_selected)
	army_selector.unit_selection_changed.connect(on_unit_selected)
	print("nonsence")


func on_unit_selected() -> void:
	if !selected_region || !selected_army:
		return

	selected_region.reset_neigbour_materials()
	highlight_neighbours(selected_region, selected_army)


func on_region_selected(region: Region) -> void:
	clear_selections()

	selected_region = region

	region.set_surface_override_material(0, selected_region_material)

func highlight_neighbours(region: Region, army: Army) -> void:
	if !region || !army:
		return

	selected_neigboars.append_array(region.neighbours)
	for neighbour in region.neighbours:
		if neighbour.can_army_enter(army):
			neighbour.set_surface_override_material(0, selected_neigbour_material)

func clear_selections() -> void:
	for _region in selected_neigboars:
		_region.reset_material()
	if selected_region:
		selected_region.reset_material()
	if selected_army:
		selected_army.deselect()

	selected_neigboars.clear()
	selected_region = null
	selected_army = null

func _on_region_targeted(target_region: Region) -> void:
	if !selected_army:
		return

	if selected_army.are_units_selected():
		print("units are selected")
		selected_army = army_manager.split_army_by_selected_units(selected_army)
	else:
		selected_region.army = null

	if !selected_neigboars.has(target_region):
		print("not a neighbour")
		return
	elif selected_army == null:
		print("no army selected")
		return
	elif !target_region.can_army_enter(selected_army):
		print("not valid region")
		return


	selected_region.army = null
	target_region.army = selected_army
	selected_army.region = target_region
	clear_selections()

func _on_army_selected(army: Army) -> void:
	print("army selected in map")
	on_region_selected(army.region)
	selected_army = army
	highlight_neighbours(selected_region, army)
