class_name SearchOptions
extends Node

@export var option_dictionary: Dictionary = {}:
	set(dict):
		option_list.assign(dict.keys())
		option_list.sort_custom(sort_predicate)
		option_dictionary = dict
@export var color_extraction: Callable
@export var filter_value_extraction: Callable
var option_list: Array[StringName] = []:
	set(list):
		option_list = list
		print("what is going on")

func sort_predicate(a: StringName, b: StringName) -> bool:
	return String(a) < String(b)


func filter_predicate() -> bool:

	return true
