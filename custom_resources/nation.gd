class_name Nation
extends Resource

signal readyness_changed(nation: Nation, value: int)
signal activated(nation: Nation)

@export var id: StringName
@export var title: StringName
@export var faction: Faction
@export_category("Politics")
@export var active: bool = false:
	set(value):
		active = value
		activated.emit(self)
@export var readyness: int = 3
@export var at_war: bool = false
@export_category("Reserves")
@export var regulars: int
@export var elites: int
@export var leaders: int

static func get_all_nations()-> Array[Nation]:
	return [
		load("res://data/nations/dwarves.tres"),
		load("res://data/nations/elves.tres"),
		load("res://data/nations/gondor.tres"),
		load("res://data/nations/isengard.tres"),
		load("res://data/nations/rohan.tres"),
		load("res://data/nations/sauron.tres"),
		load("res://data/nations/southrons_easterlings.tres"),
		load("res://data/nations/the_north.tres"),
		load("res://data/nations/unaligned.tres")
	]


static func get_valid_nations()-> Array[Nation]:
	return [
		load("res://data/nations/dwarves.tres"),
		load("res://data/nations/elves.tres"),
		load("res://data/nations/gondor.tres"),
		load("res://data/nations/isengard.tres"),
		load("res://data/nations/rohan.tres"),
		load("res://data/nations/sauron.tres"),
		load("res://data/nations/southrons_easterlings.tres"),
		load("res://data/nations/the_north.tres")
	]


func closer_to_war() -> void:
	match readyness:
		1 when !active:
			push_warning("no active, cannot go to war")
		1:
			readyness -= 1
			readyness_changed.emit(self, readyness)
			at_war = true
		0:
			push_warning("alread at war")
		_:
			readyness -= 1
			readyness_changed.emit(self, readyness)
