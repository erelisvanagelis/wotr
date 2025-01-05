class_name Map
extends Node3D

signal selected_region_changed(emmiter: Region)
signal targeted_region_changed(emmiter: Region)
signal hovered_region_changed(emmiter: Region)
signal focused_region_changed(emmiter: Region)
signal movemenet_condition_changed(condition: ConditionComponent)
signal consequence_changed(nation_advancement: Dictionary)

@export var army_manager: ArmyManager
@export var army_selector: ArmySelector
@export var search_options: SearchOptions

var selected_region_material := StandardMaterial3D.new()
var move_neigbour_material := StandardMaterial3D.new()
var attack_neigbour_material := StandardMaterial3D.new()
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
	var search_options_dictionary := {}
	for region: Region in get_tree().get_nodes_in_group(Constants.GROUP.REGIONS):
		search_options_dictionary[region.title] = region
		region.region_selected.connect(func(value: Region) -> void: selected_region = value)
		region.region_targeted.connect(func(value: Region) -> void: targeted_region = value)
		region.region_hovered.connect(func(value: Region) -> void: hovered_region = value)
		region.region_unhovered.connect(func(value: Region) -> void: hovered_region = value)

	search_options.color_extraction = func(region: Region) -> Color: return Color.from_string(region.nation.id, Color.GRAY)
	search_options.filter_value_extraction = func(region: Region) -> StringName: return " ".join([region.title, region.nation.title, region.nation.faction.title])
	search_options.option_dictionary = search_options_dictionary

	selected_region_changed.connect(_on_region_selected)
	targeted_region_changed.connect(_on_region_targeted)
	hovered_region_changed.connect(_on_focus_regions_changed)
	selected_region_changed.connect(_on_focus_regions_changed)
	focused_region_changed.connect(_on_focused_region_changed)

	selected_region_material.albedo_color = ColorPalette.selected_region().color
	move_neigbour_material.albedo_color = ColorPalette.move_region().color
	attack_neigbour_material.albedo_color = ColorPalette.attack_region().color


func _on_region_selected(region: Region) -> void:
	clear_selections()
	if region == null:
		return

	region.set_surface_override_material(0, selected_region_material)


func _on_region_targeted(target_region: Region) -> void:
	var selected_army := army_manager.selected_army
	if !selected_army || !army_manager.can_army_perform_any_action(selected_army, target_region):
		return

	if selected_army.are_units_selected():
		selected_army = army_manager.split_army_by_selected_units(selected_army)

	army_manager.move_army_into_region(selected_army, target_region)
	army_manager.selected_army = selected_army


func _on_focus_regions_changed(_region: Region) -> void:
	focused_region = selected_region if hovered_region == null else hovered_region


func highlight_neighbours(region: Region, army: Army) -> void:
	if !region || !army:
		return

	region.reset_neighbours()
	for neighbour in region.neighbours:
		if army_manager.can_army_attack(army, neighbour):
			neighbour.set_surface_override_material(0, attack_neigbour_material)
		elif army_manager.can_army_move(army, neighbour):
			neighbour.set_surface_override_material(0, move_neigbour_material)


func clear_selections() -> void:
	get_tree().call_group(Constants.GROUP.REGIONS, "reset")


func _on_army_manager_selected_army_changed(army: Army) -> void:
	if !army:
		return

	selected_region = army.region
	highlight_neighbours(army.region, army)


func _on_focused_region_changed(region: Region) -> void:
	if army_manager.focused_army != null:
		var action := army_manager.find_army_action_type(army_manager.focused_army, region)
		if action == Constants.ArmyActionType.MOVE:
			movemenet_condition_changed.emit(army_manager.build_army_movement_conditions(army_manager.focused_army, region))
		elif action == Constants.ArmyActionType.ATTACK:
			movemenet_condition_changed.emit(army_manager.build_army_attack_conditions(army_manager.focused_army, region))

		consequence_changed.emit(army_manager.get_nations_affected_by_move(army_manager.focused_army, region))
	else:
		movemenet_condition_changed.emit(null)


func _on_search_bar_list_item_changed(item: StringName) -> void:
	selected_region = search_options.option_dictionary[item]

func find_region(title: StringName) -> Region:
	return search_options.option_dictionary[title]


#func highlight_region(title: String) -> void:
	#var region: Region = search_options.option_dictionary[title]
	#region.higlight_region()
