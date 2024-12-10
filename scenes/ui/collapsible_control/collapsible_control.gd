class_name CollapsibleControl
extends PanelContainer

@export var title: StringName = "default name"
@export var initialy_visible: bool = true
@export var collapse_char: StringName
@export var expand_char: StringName

@onready var collapsible_container := %Collapsible
@onready var button := %Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var children := self.get_children()
	assert(children.all(func(object: Node) -> bool: return object is Control), "Children must be control type")
	assert(children.size() > 1, "Nothing to collapse")

	for i: int in range(1, children.size()):
		children[i].reparent(collapsible_container)

	collapsible_container.visible = initialy_visible
	for child in collapsible_container.get_children():
		child.visible = collapsible_container.visible
	var required_char := collapse_char if collapsible_container.visible else expand_char
	button.text = "%s %s" % [title, required_char]


func _on_button_pressed() -> void:
	collapsible_container.visible = !collapsible_container.visible
	for child in collapsible_container.get_children():
		child.visible = collapsible_container.visible

	var required_char := collapse_char if collapsible_container.visible else expand_char
	button.text = "%s %s" % [title, required_char]
