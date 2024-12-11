class_name CollapsibleControl
extends PanelContainer

@export var title: StringName = "default name"
@export var initialy_collapsed: bool = true
@export var collapse_char: StringName
@export var expand_char: StringName

@onready var collapsible_container := %Collapsible
@onready var button := %Button

var _updatable_text: String = "":
	set(value):
		_updatable_text = value
		if collapsible_container:
			_update_button_text(!collapsible_container.visible)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var children := self.get_children()
	assert(children.all(func(object: Node) -> bool: return object is Control), "Children must be control type")
	assert(children.size() > 1, "Nothing to collapse")

	for i: int in range(1, children.size()):
		children[i].reparent(collapsible_container)

	_update_button_text(initialy_collapsed)


func _on_button_pressed() -> void:
	_update_button_text(collapsible_container.visible)


func _on_updatable_text_changed(text: String) -> void:
	_updatable_text = text


func _update_button_text(collapse: bool) -> void:
	collapsible_container.visible = !collapse
	for child in collapsible_container.get_children():
		child.visible = collapsible_container.visible

	var required_char := collapse_char if collapsible_container.visible else expand_char
	var button_text: String = "%s %s" % [required_char, title]
	if _updatable_text:
		button_text = "%s %s" % [button_text, _updatable_text]

	button.text = button_text
