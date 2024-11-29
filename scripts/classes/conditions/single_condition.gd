class_name SingleCondition
extends ConditionComponent

var _description: String
var _predicate: Callable


func _init(description: String, predicate: Callable) -> void:
	_description = description
	_predicate = predicate


func is_satisfied() -> bool:
	return _predicate.call()


func get_description() -> String:
	return _description
