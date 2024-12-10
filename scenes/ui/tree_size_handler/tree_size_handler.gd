extends Control

var _tree: Tree
var _tree_scrollbar: VScrollBar
var _is_ready: bool = false
var _parent: Control
var _other_children: Array[Control] = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_parent = self.get_parent()
	_tree = get_child(0)
	_tree_scrollbar = _tree.find_child("*VScrollBar*", false, false)
	for child: Control in _parent.get_children():
		if child != self:
			_other_children.append(child)

	_tree.item_collapsed.connect(_on_tree_item_collapsed)

	_is_ready = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if !_is_ready || !_parent.visible || !_tree_scrollbar.visible:
		return

	var size_of_others: int = _other_children.reduce(
		func(accum: float, control: Control) -> float: return accum + control.size.y, 0
	)

	_tree.size = Vector2(_tree.size.x, _tree_scrollbar.max_value + 9)
	_parent.custom_minimum_size = Vector2(0, _tree.size.y + size_of_others)


func _on_tree_item_collapsed(_item: TreeItem) -> void:
	_tree.custom_minimum_size = Vector2(_tree.size.x, 0)
	_tree.size = Vector2(_tree.size.x, 0)
