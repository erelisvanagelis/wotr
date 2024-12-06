class_name Army
extends CharacterBody3D

signal selected(army: Army)
signal deselected
signal hovered(emmiter: Army)
signal unhovered(emmiter: Army)

@export var speed: int = 10
@export var faction: Faction
@export var region: Region

var units: Array[Unit]
var target_position: Vector3


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	velocity.x = (target_position.x - position.x) * speed
	velocity.z = (target_position.z - position.z) * speed
	velocity.y = (target_position.y - position.y) * speed
	move_and_slide()


func move_to_parent_center(new_position: Vector3) -> void:
	target_position = new_position


func _on_input_event(_camera: Node, _event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if !(_event is InputEventMouseButton) || !_event.is_pressed():
		return

	var event := _event as InputEventMouseButton
	match event.button_index:
		MOUSE_BUTTON_LEFT:
			for unit: Unit in units:
				unit.selected = true
			print("Army clicked")
			selected.emit(self)


func deselect() -> void:
	deselected.emit()


func get_selected_units() -> Array[Unit]:
	return units.filter(func(unit: Unit) -> bool: return unit.selected)


func are_units_selected() -> bool:
	return get_selected_units().size() > 0


func _on_mouse_entered() -> void:
	hovered.emit(self)


func _on_mouse_exited() -> void:
	unhovered.emit(self)
