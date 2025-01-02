class_name CardLoader
extends Node

var cards: Dictionary = {}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var file := FileAccess.open("res://assets/cards/cards_enriched.json", FileAccess.READ)
	assert(file, "Could not load card data")

	# Read the JSON content
	var json_text := file.get_as_text()
	file.close()

	for card_data: Dictionary in JSON.parse_string(json_text):
		var event_card := EventCard.new(card_data)
		cards[event_card.id] = event_card
