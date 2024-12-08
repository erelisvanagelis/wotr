class_name Nation
extends Resource

signal readyness_changed(nation: Nation, value: int)
signal activated(nation: Nation)

@export var id: StringName
@export var title: StringName
@export var title_short: StringName
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
@export var nazguls: int
#@export var available_units: Array[UnitData]


static func get_all_nations() -> Array[Nation]:
	var all_nations := get_valid_nations()
	all_nations.append(load("res://scripts/resources/nations/unaligned.tres"))

	return all_nations


static func get_valid_nations() -> Array[Nation]:
	return [
		load("res://scripts/resources/nations/dwarves.tres"),
		load("res://scripts/resources/nations/elves.tres"),
		load("res://scripts/resources/nations/gondor.tres"),
		load("res://scripts/resources/nations/isengard.tres"),
		load("res://scripts/resources/nations/rohan.tres"),
		load("res://scripts/resources/nations/sauron.tres"),
		load("res://scripts/resources/nations/southrons_&_easterlings.tres"),
		load("res://scripts/resources/nations/the_north.tres")
	]


func closer_to_war() -> void:
	match readyness:
		1 when !active:
			push_warning("not active, cannot go to war")
		1:
			readyness -= 1
			readyness_changed.emit(self, readyness)
			at_war = true
		0:
			push_warning("alread at war")
		_:
			readyness -= 1
			readyness_changed.emit(self, readyness)
