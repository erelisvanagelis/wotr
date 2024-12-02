class_name ConditionsViewer
extends Control


var root: TreeItem

@onready var tree: Tree = %Tree

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for region: Region in get_tree().get_nodes_in_group(Constants.GROUP.REGIONS):
		region.region_hovered.connect(on_region_hovered)


func on_region_hovered(region: Region) -> void:
	tree.clear()
	var condition: ConditionComponent = SingleCondition.new("Region is a not a neighbour", func() -> bool: return false)
	#if region == null || region.entry_conditions == null:
	#root = generate_tree([SingleCondition.new("Region is a neighbour", func() -> bool: return false)], null)
	#return
	if region && region.entry_conditions:
		condition = region.entry_conditions

	root = generate_tree(condition, null)
	TreeItemUtils.adjust_container_size(self, root)


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


func _on_tree_item_collapsed(_item: TreeItem) -> void:
	TreeItemUtils.adjust_container_size(self, root)
