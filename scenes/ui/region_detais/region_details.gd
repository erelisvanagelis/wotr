extends GridContainer

@export var army_manager: ArmyManager
@export var region: Region

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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for region: Region in get_tree().get_nodes_in_group(Constants.GROUP.REGIONS):
		region.region_hovered.connect(on_region_hovered)


func on_region_hovered(region_hovered: Region) -> void:
	region = region_hovered
	region_label.text = region.title

	var type := region.type
	if type:
		type_label.text = type.title
		capture_points_label.text = str(type.victory_points)
		defensive_bonus_label.text = str(type.defensive_bonus)
		allows_recruitment_label.text = str(type.allows_recruitment)

	var nation := region.nation
	nation_label.text = nation.title
	leader_count_label.text = str(nation.leaders)
	elite_count_label.text = str(nation.elites)
	regular_count_label.text = str(nation.regulars)

	faction_label.text = nation.faction.title


func _on_leader_recruit_pressed() -> void:
	var army := army_manager.create_army(region.nation, 0, 0, 1, 0)
	army.region = region
	region.army = army
