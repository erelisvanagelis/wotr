class_name CollapsibleControl
extends Control

@export var title: String = "default name"
@export var initialy_visible: bool = true

@onready var collapsible_container := %Collapsible
@onready var button := %Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var children := self.get_children()
	assert(children.all(func(object: Node) -> bool: return object is Control), "Children must be control type")
	assert(children.size() > 1, "Nothing to collapse")

	for i: int in range(1, children.size()):
		children[i].reparent(collapsible_container)

	button.text = title
	collapsible_container.visible = initialy_visible


func _on_button_pressed() -> void:
	collapsible_container.visible = !collapsible_container.visible
