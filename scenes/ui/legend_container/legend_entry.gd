class_name LegendEntry
extends Control

@export var entry: Legend

@onready var color_rect := %ColorRect
@onready var label := %Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	color_rect.color = entry.color.color
	label.text = entry.title
	self.tooltip_text = entry.description
