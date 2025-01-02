extends Control

@export var _map: Map
@export var _army_manager: ArmyManager

var selected_card: EventCard
var icons: Dictionary = {
	free_people_character = load("res://assets/images/card/FP_Character.png"),
	free_people_army = load("res://assets/images/card/FP_Army.png"),
	free_people_muster = load("res://assets/images/card/FP_Muster.png"),
	shadow_character = load("res://assets/images/card/S_Character.png"),
	shadow_army = load("res://assets/images/card/S_Army.png"),
	shadow_muster = load("res://assets/images/card/S_Muster.png"),
}

@onready var card_loader: CardLoader = %CardLoader
@onready var search_options: SearchOptions = %SearchOptions
@onready var title_label: RichTextLabel = %TitleLabel
@onready var number_label: Label = %NumberLabel
@onready var pre_condition_label: RichTextLabel = %PreConditionLabel
@onready var action_label: RichTextLabel = %ActionLabel
@onready var discard_label: RichTextLabel = %DiscardLabel
@onready var faction_label: Label = %FactionLabel
@onready var deck_label: Label = %DeckLabel
@onready var type_texture_rect: TextureRect = %TypeTextureRect
@onready var activate_button: Button = %ActivateButton


func _ready() -> void:
	var search_option_dictionary := {}
	for event_card: EventCard in card_loader.cards.values():
		search_option_dictionary[event_card.card_name] = event_card

	search_options.option_dictionary = search_option_dictionary
	search_options.color_extraction = func(card: EventCard) -> Color:
		return card.faction.color.color
	search_options.filter_value_extraction = func(card: EventCard) -> String:
		return card.search_string


func _on_search_bar_list_item_changed(item: StringName) -> void:
	var card: EventCard = search_options.option_dictionary[item]
	selected_card = card
	title_label.text = "[center][b]%s[/b][/center]" % card.card_name
	number_label.text = "%s/24" % card.number
	pre_condition_label.text = "[b]%s[/b]" % card.pre_condition
	action_label.text = card.action
	discard_label.text = "[i]%s[/i]" % card.discard_condition
	faction_label.text = card.faction.title
	deck_label.text = card.deck
	var icon_name: String = (card.faction.title + " " + card.type).to_lower().replace(" ", "_")
	type_texture_rect.texture = icons[icon_name]
	type_texture_rect.tooltip_text = "%s type event card" % card.type

	var is_card_implemented := _higlight_card_effects(card.id)
	if is_card_implemented:
		activate_button.disabled = false
		activate_button.text = "Activate"
	else:
		activate_button.disabled = true
		activate_button.text = "Not Implemented"


func _higlight_card_effects(id: Constants.EventCardName) -> bool:
	_map.clear_selections()
	match id:
		Constants.EventCardName.DAIN_IRONFOOTS_GUARD:
			_map.find_region("Erebor").higlight_region()
		Constants.EventCardName.ORCS_MULTIPLYING_AGAIN:
			var guldur := _map.find_region("Dol Guldur")
			var mount := _map.find_region("Mount Gundabad")
			guldur.higlight_region()
			mount.higlight_region()
		_:
			return false
	return true


func _activate_card_effects(id: Constants.EventCardName) -> void:
	_map.clear_selections()
	match id:
		Constants.EventCardName.ORCS_MULTIPLYING_AGAIN:
			var guldur := _map.find_region("Dol Guldur")
			var mount := _map.find_region("Mount Gundabad")
			(
				_army_manager
				. new_army_builder()
				. regular(3)
				. region(guldur)
				. ignored_reserves(false)
				. build_and_assign_to_region()
			)
			(
				_army_manager
				. new_army_builder()
				. regular(3)
				. region(mount)
				. ignored_reserves(false)
				. build_and_assign_to_region()
			)


func _on_button_pressed() -> void:
	_activate_card_effects(selected_card.id)
