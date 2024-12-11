class_name Map
extends Node3D

signal selected_region_changed(emmiter: Region)
signal targeted_region_changed(emmiter: Region)
signal hovered_region_changed(emmiter: Region)
signal focused_region_changed(emmiter: Region)
signal movemenet_condition_changed(condition: ConditionComponent)

@export var army_manager: ArmyManager
@export var army_selector: ArmySelector

var selected_region_material := StandardMaterial3D.new()
var selected_neigbour_material := StandardMaterial3D.new()
var title_to_region_map: Dictionary = {}
var hovered_region: Region:
	set(value):
		if hovered_region == value:
			hovered_region = null
		else:
			hovered_region = value

		hovered_region_changed.emit(hovered_region)
var selected_region: Region:
	set(value):
		var old_value := selected_region
		selected_region = value

		if old_value != value:
			selected_region_changed.emit(value)
			if value:
				army_manager.selected_army = value.army
var targeted_region: Region:
	set(value):
		targeted_region_changed.emit(value)
		targeted_region = value
var focused_region: Region:
	set(value):
		if focused_region != value:
			focused_region_changed.emit(value)
		focused_region = value


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for region: Region in get_tree().get_nodes_in_group(Constants.GROUP.REGIONS):
		title_to_region_map[region.title] = region
		region.region_selected.connect(func(value: Region) -> void: selected_region = value)
		region.region_targeted.connect(func(value: Region) -> void: targeted_region = value)
		region.region_hovered.connect(func(value: Region) -> void: hovered_region = value)
		region.region_unhovered.connect(func(value: Region) -> void: hovered_region = value)

	title_to_region_map.make_read_only()

	selected_region_changed.connect(_on_region_selected)
	targeted_region_changed.connect(_on_region_targeted)
	hovered_region_changed.connect(_on_focus_regions_changed)
	selected_region_changed.connect(_on_focus_regions_changed)
	focused_region_changed.connect(_on_focused_region_changed)

	selected_region_material.albedo_color = Color.from_string("FF3131", "ffffff")
	selected_neigbour_material.albedo_color = Color.from_string("fe019a", "ffffff")


func _on_region_selected(region: Region) -> void:
	clear_selections()
	if region == null:
		return

	region.set_surface_override_material(0, selected_region_material)


func _on_region_targeted(target_region: Region) -> void:
	var selected_army := army_manager.selected_army
	if !selected_army:
		return

	if selected_army.are_units_selected():
		var split_off_army := army_manager.split_army_by_selected_units(selected_army)
		if target_region.can_army_enter(split_off_army):
			selected_army = split_off_army
		else:
			selected_army.merge_armies(split_off_army)

	if target_region.can_army_enter(selected_army):
		target_region.army = selected_army
		army_manager.selected_army = target_region.army


func _on_focus_regions_changed(_region: Region) -> void:
	focused_region = selected_region if hovered_region == null else hovered_region


func highlight_neighbours(region: Region, army: Army) -> void:
	if !region || !army:
		return

	region.reset_neigbour_materials()
	for neighbour in region.neighbours:
		if neighbour.can_army_enter(army):
			neighbour.set_surface_override_material(0, selected_neigbour_material)


func clear_selections() -> void:
	get_tree().call_group(Constants.GROUP.REGIONS, "reset_material")


func _on_army_manager_selected_army_changed(army: Army) -> void:
	if !army:
		return

	selected_region = army.region
	highlight_neighbours(army.region, army)


func _on_focused_region_changed(region: Region) -> void:
	if army_manager.focused_army:
		movemenet_condition_changed.emit(region.army_entry_conditions(army_manager.focused_army))
	else:
		movemenet_condition_changed.emit(null)
