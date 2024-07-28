class_name Army
extends CharacterBody3D

@export var speed: int = 10
@export var faction: StringName
@export var nation: StringName

@onready var target_position: Vector3 = position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	velocity.x = (target_position.x - position.x) * speed;
	velocity.z = (target_position.z - position.z) * speed;
	move_and_slide()

func _move_to_parent_center(new_position: Vector3) -> void:
	target_position = new_position
