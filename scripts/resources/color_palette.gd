class_name ColorPalette
extends Resource

static var _loader := CachedResourceLoader.new("res://scripts/resources/color_pallete/%s.tres")
@export var color: Color


static func negative() -> ColorPalette:
	return _loader.get_cached("negative")


static func positive() -> ColorPalette:
	return _loader.get_cached("positive")


static func neutral() -> ColorPalette:
	return _loader.get_cached("neutral")


static func active() -> ColorPalette:
	return _loader.get_cached("active")


static func inactive() -> ColorPalette:
	return _loader.get_cached("inactive")


static func free_people() -> ColorPalette:
	return _loader.get_cached("free_people")


static func shadow() -> ColorPalette:
	return _loader.get_cached("shadow")


static func unaligned() -> ColorPalette:
	return _loader.get_cached("unaligned")
