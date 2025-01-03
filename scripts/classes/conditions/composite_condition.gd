class_name CompositeCondition
extends ConditionComponent

enum MatchType { ANY, ALL }

var _description: String
var _match_type: MatchType
var _conditions: Array[ConditionComponent]


# Private base constructor
func _init(description: String, match_type: MatchType, conditions: Array[ConditionComponent]) -> void:
	_description = description
	_match_type = match_type
	_conditions = conditions


static func any(description: String, conditions: Array[ConditionComponent]) -> CompositeCondition:
	return CompositeCondition.new(description, MatchType.ANY, conditions)


static func all(description: String, conditions: Array[ConditionComponent]) -> CompositeCondition:
	return CompositeCondition.new(description, MatchType.ALL, conditions)


func is_satisfied() -> bool:
	var check: Callable = func(condition: ConditionComponent) -> bool: return condition.is_satisfied()

	return _conditions.all(check) if _match_type == MatchType.ALL else _conditions.any(check)


func get_description() -> String:
	return _description
