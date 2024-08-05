class_name Army
extends CharacterBody3D

signal army_selected()

@export var speed: int = 10
@export var units: Array[Unit]
@export var faction: Faction

var target_position: Vector3

static func new_army(nation: Nation, regular: int, elite: int, leader: int) -> Army:
	var army: Army = load("res://army.tscn").instantiate()
	army.faction = nation.faction
	var new_units: Array[Unit] = []
	for _i in regular:
		var unit: Unit = load("res://unit.tscn").instantiate()
		unit.type = Constants.UNIT_TYPE.REGULAR
		unit.nation = nation
		new_units.append(unit)
	for _i in elite:
		var unit: Unit = load("res://unit.tscn").instantiate()
		unit.type = Constants.UNIT_TYPE.ELITE
		unit.nation = nation
		new_units.append(unit)
	for _i in leader:
		var unit: Unit = load("res://unit.tscn").instantiate()
		unit.type = Constants.UNIT_TYPE.LEADER
		unit.nation = nation
		new_units.append(unit)
	army.units = new_units

	return army

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	velocity.x = (target_position.x - position.x) * speed;
	velocity.z = (target_position.z - position.z) * speed;
	move_and_slide()

func move_to_parent_center(new_position: Vector3) -> void:
	target_position = new_position


func _on_input_event(_camera: Node, _event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if !(_event is InputEventMouseButton) || !_event.is_pressed():
		return

	var event := _event as InputEventMouseButton
	match event.button_index:
		MOUSE_BUTTON_LEFT:
			army_selected.emit()

