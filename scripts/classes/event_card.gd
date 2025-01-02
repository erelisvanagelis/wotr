class_name EventCard
extends RefCounted

# Card Properties
var id: Constants.EventCardName
var card_name: String
var type: String
var number: int
var faction: Faction
var deck: String
var search_string: String
var pre_condition: String
var action: String
var discard_condition: String
var play_on_table: bool

func _init(data: Dictionary) -> void:
	id = Constants.EventCardName.get(data.get("id", ""))
	card_name = data.get("name", "")
	type = data.get("type", "")
	number = data.get("number", 0)
	var faction_name: String = data.get("faction", "")
	faction = Faction.free_people() if faction_name == Faction.free_people().title else Faction.shadow()
	deck = data.get("deck", "")
	search_string = data.get("search_string", "")
	pre_condition = data.get("pre_condition", "")
	action = data.get("action", "")
	discard_condition = data.get("discard_condition", "")
	play_on_table = data.get("play_on_table", false)
