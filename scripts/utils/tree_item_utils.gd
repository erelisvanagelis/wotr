class_name TreeItemUtils
extends Node

const MinSize := 23
const TreeItemSize := 38


static func get_recursive_child_count(item: TreeItem) -> int:
	var children: Array[TreeItem] = item.get_children()

	if item.collapsed || children.is_empty():
		return 1

	var count := 1
	for child in children:
		count += get_recursive_child_count(child)

	return count


static func adjust_container_size(container: Control, root: TreeItem, count_root: bool = false) -> void:
	var child_count := get_recursive_child_count(root) - 1
	var root_excluded_count := child_count if count_root else child_count - 1
	root_excluded_count = 0 if root_excluded_count < 0 else root_excluded_count
	container.custom_minimum_size = Vector2(0, MinSize + root_excluded_count * TreeItemSize)
