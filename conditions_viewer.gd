class_name ConditionsViewer
extends Control

@export var tree: Tree

var root: TreeItem


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for region: Region in get_tree().get_nodes_in_group(Constants.GROUP.REGIONS):
		region.region_hovered.connect(on_region_hovered)


func on_region_hovered(region: Region) -> void:
	if region == null || region.entry_conditions == null:
		return

	tree.clear()
	#tree.hide_root = true
	root = generate_tree(region.entry_conditions, null)


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
		new_item.set_custom_color(0, Color.LIGHT_BLUE)
	else:
		#new_item.collapsed = false
		new_item.set_custom_color(0, Color.RED)

	return new_item

	#ready_3 = tree.create_item(root)
	#ready_3.set_text(0, "III")
	#ready_2 = tree.create_item(root)
	#ready_2.set_text(0, "II")
	#ready_1 = tree.create_item(root)
	#ready_1.set_text(0, "I")
	#ready_0 = tree.create_item(root)
	#ready_0.set_text(0, "At War")
