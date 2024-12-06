extends GridContainer

@export var army_manager: ArmyManager
@export var map: Map

@onready var region_label := %region
@onready var nation_label := %nation
@onready var faction_label := %faction
@onready var type_label := %type
@onready var capture_points_label := %capture_points
@onready var defensive_bonus_label := %defensive_bonus
@onready var allows_recruitment_label := %allows_recruitements
@onready var leader_count_label := %leader_count
@onready var elite_count_label := %elite_count
@onready var regular_count_label := %regular_count


func _on_map_focused_region_changed(focused_hovered: Region) -> void:
	if focused_hovered == null:
		visible = false
		return

	visible = true

	region_label.text = focused_hovered.title
	var type := focused_hovered.type
	if type:
		type_label.text = type.title
		capture_points_label.text = str(type.victory_points)
		defensive_bonus_label.text = str(type.defensive_bonus)
		allows_recruitment_label.text = str(type.allows_recruitment)

	var nation := focused_hovered.nation
	nation_label.text = nation.title
	leader_count_label.text = str(nation.leaders)
	elite_count_label.text = str(nation.elites)
	regular_count_label.text = str(nation.regulars)

	faction_label.text = nation.faction.title


func _on_leader_recruit_pressed() -> void:
	army_manager.new_army_builder().region(map.focused_region).leader(1).build_and_assign_to_region()
