class_name Army
extends CharacterBody3D

signal selected(army: Army)
signal deselected

@export var speed: int = 10
@export var faction: Faction
@export var region: Region

var units: Array[Unit]
var target_position: Vector3
var _army_scene: PackedScene = preload("res://scenes/army/army.tscn")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	velocity.x = (target_position.x - position.x) * speed
	velocity.z = (target_position.z - position.z) * speed
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
	var units_diff: Array[Unit] = units.filter(func(unit: Unit) -> bool: return unit.selected)
	var empty: Array[Unit] = []

	return units_diff if units_diff else empty


func are_units_selected() -> bool:
	return get_selected_units().size() > 0


func split_off_selected_units() -> Army:
	return split_army(get_selected_units())


func split_army(split_off_units: Array[Unit]) -> Army:
	var army: Army = _army_scene.instantiate()
	army.faction = self.faction
	army.units = split_off_units
	var offset_position := Vector3(self.position)
	army.position = offset_position
	army.position.x = offset_position.x + 0.05

	for unit in split_off_units:
		self.units.erase(unit)
		unit.selected = false

	return army
