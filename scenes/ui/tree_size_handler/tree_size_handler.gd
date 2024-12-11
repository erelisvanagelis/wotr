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

	var size_of_others: Vector2 = _other_children.reduce(
		func(accum: Vector2, control: Control) -> Vector2: return accum + control.size, Vector2.ZERO
	)

	_tree.position = Vector2.ZERO
	_tree.size = Vector2(size_of_others.x, _tree_scrollbar.max_value + 9)
	_parent.custom_minimum_size = Vector2(0, _tree.size.y + size_of_others.y)


func _on_tree_item_collapsed(_item: TreeItem) -> void:
	_tree.custom_minimum_size = Vector2.ZERO
	_tree.set_deferred("size", Vector2.ZERO)
