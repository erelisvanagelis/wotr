class_name Faction
extends Resource

static var _loader := CachedResourceLoader.new("res://scripts/resources/factions/%s.tres")
@export var title: StringName
@export var color: ColorPalette


static func free_people() -> Faction:
	return _loader.get_cached("free_people")


static func shadow() -> Faction:
	return _loader.get_cached("shadow")


static func unaligned() -> Faction:
	return _loader.get_cached("unaligned")
