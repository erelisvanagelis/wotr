extends GridContainer

@export var army_manager: ArmyManager
@export var map: Map

@onready var region_label := %region
@onready var nation_label := %nation
@onready var faction_label := %faction
@onready var type_label := %type
@onready var capture_points_label := %capture_points
@onready var defensive_bonus_label := %defensive_bonus


func _on_map_focused_region_changed(focused_region: Region) -> void:
	is_node_ready()
	if focused_region == null || not is_node_ready():
		return

	nation_label.text = focused_region.nation.title
	faction_label.text = focused_region.nation.faction.title
	region_label.text = focused_region.title

	type_label.text = focused_region.type.title
	capture_points_label.text = str(focused_region.type.victory_points)
	defensive_bonus_label.text = str(focused_region.type.defensive_bonus)


func _on_leader_recruit_pressed() -> void:
	army_manager.new_army_builder().region(map.focused_region).leader(1).build_and_assign_to_region()
