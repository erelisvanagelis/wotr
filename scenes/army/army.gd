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

@onready var _shape := %Shape


func _ready() -> void:
	var material := StandardMaterial3D.new()
	material.albedo_color = faction.color.color
	_shape.material = material

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	velocity.x = (target_position.x - position.x) * speed
	velocity.z = (target_position.z - position.z) * speed
	velocity.y = (target_position.y - position.y) * speed
	move_and_slide()


func move_to_parent_center(new_position: Vector3) -> void:
	target_position = new_position


func _on_input_event(
	_camera: Node, _event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int
) -> void:
	if !(_event is InputEventMouseButton) || !_event.is_pressed():
		return

	var event := _event as InputEventMouseButton
	match event.button_index:
		MOUSE_BUTTON_LEFT:
			selected.emit(self)


func deselect() -> void:
	deselected.emit()


func get_selected_units() -> Array[Unit]:
	return units.filter(func(unit: Unit) -> bool: return unit.selected)


func get_not_selected_units() -> Array[Unit]:
	return units.filter(func(unit: Unit) -> bool: return !unit.selected)


func are_units_selected() -> bool:
	return get_selected_units().size() > 0


func _on_mouse_entered() -> void:
	hovered.emit(self)


func _on_mouse_exited() -> void:
	unhovered.emit(self)


func merge_armies(army: Army) -> Army:
	if self == army:
		return army

	assert(army, "Another army cannot be null")
	assert(faction == army.faction, "Armies belong to different factions")

	units.append_array(army.units)
	for unit: Unit in units:
		unit.selected = true

	army.remove_self()

	return self


func remove_self() -> void:
	if region.army == self:
		region.army = null
	self.queue_free()



func get_army_weight() -> int:
	return units.reduce(func(accum: int, unit: Unit) -> int: return accum + unit.data.weight, 0)
