class_name RegionType
extends Resource

@export var title: StringName
@export var victory_points: int
@export var defensive_bonus: int
@export var allows_recruitment: bool


static func get_region_types() -> Array[RegionType]:
	return [
		load("res://scripts/resources/region_types/city.tres"),
		load("res://scripts/resources/region_types/fortification.tres"),
		load("res://scripts/resources/region_types/stronghold.tres"),
		load("res://scripts/resources/region_types/town.tres"),
	]
