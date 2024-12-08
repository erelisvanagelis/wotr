class_name RecruitUnitCard
extends VBoxContainer

@export var card: UnitCard
@export var count: int

@onready var _reserve_label := %Reserve


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_child(card)
	move_child(card, 0)
	_reserve_label.text = str(count)
