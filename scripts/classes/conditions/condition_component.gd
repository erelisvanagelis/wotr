class_name ConditionComponent
extends Node


func _init() -> void:
	assert(get_script() != ConditionComponent, "ConditionComponent is an abstract class and cannot be instantiated directly")


func is_satisfied() -> bool:
	assert(false, "not implemented")
	return false


func get_description() -> String:
	assert(false, "not implemented")
	return ""
