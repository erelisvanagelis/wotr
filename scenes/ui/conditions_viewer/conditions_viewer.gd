class_name ConditionsViewer
extends Control

var root: TreeItem
@onready var tree: Tree = %Tree

func _ready() -> void:
	var preview_condition := CompositeCondition.all("Deskription", [
		SingleCondition.new("I'm a negative", func() -> bool: return false),
		SingleCondition.new("I'm a positive", func() -> bool: return true)
	])
	_on_condition_changed(preview_condition)

func _on_condition_changed(condition: ConditionComponent) -> void:
	tree.clear()
	if !condition:
		visible = false
		return

	visible = true
	root = generate_tree(condition, null)


func generate_tree(condition: ConditionComponent, parent: TreeItem) -> TreeItem:
	if condition is SingleCondition:
		return condition_to_tree_item(condition, parent)

	var new_item := condition_to_tree_item(condition, parent)
	var composite := condition as CompositeCondition
	for condition_component: ConditionComponent in composite._conditions:
		generate_tree(condition_component, new_item)

	return new_item


func condition_to_tree_item(condition: ConditionComponent, parent: TreeItem) -> TreeItem:
	var new_item := tree.create_item(parent)
	new_item.set_text(0, condition._description)
	#new_item.set_text(0, condition._description + " - " + str(condition.is_satisfied()))
	if condition.is_satisfied():
		#new_item.collapsed = true
		new_item.set_custom_color(0, ColorPalette.positive().color)
	else:
		#new_item.collapsed = false
		new_item.set_custom_color(0, ColorPalette.negative().color)

	return new_item
