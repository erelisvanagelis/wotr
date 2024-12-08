class_name Region
extends MeshInstance3D

signal region_selected(emmiter: Region)
signal region_targeted(emmiter: Region)
signal region_hovered(emmiter: Region)
signal region_unhovered(emmiter: Region)

@export var id: StringName
@export var title: StringName
@export var nation: Nation
@export var type: RegionType
@export var reachable_neighbours: Array[Region] = []
@export var unreachable_neighbours: Array[Region] = []
@export var default_material: StandardMaterial3D = null
#FIXME army split removes ownership
@export var army: Army:
	set(new_army):
		if army && new_army && army.faction == new_army.faction:
			new_army.merge_armies(army)
		elif (army && new_army) && army != new_army:
			army.remove_self()

		army = new_army
		if !army:
			return

		if army.region != null:
			army.region.army = null
		army.region = self
		army.move_to_parent_center(position)

var free_regions: Nation = load("res://scripts/resources/nations/unaligned.tres")
var neighbours: Array[Region] = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	neighbours.append_array(reachable_neighbours)
	neighbours.append_array(unreachable_neighbours)

	var body: StaticBody3D = get_node("StaticBody3D") as StaticBody3D
	body.input_event.connect(_on_static_body_3d_input_event)
	body.mouse_entered.connect(_on_mouse_entered)
	body.mouse_exited.connect(_on_mouse_exited)


func _on_static_body_3d_input_event(
	_camera: Node, _event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int
) -> void:
	if !(_event is InputEventMouseButton) || !_event.is_pressed():
		return

	var event := _event as InputEventMouseButton
	match event.button_index:
		MOUSE_BUTTON_LEFT:
			region_selected.emit(self)
		MOUSE_BUTTON_RIGHT:
			region_targeted.emit(self)


func _on_mouse_entered() -> void:
	var current_collor: StandardMaterial3D = self.get_surface_override_material(0)
	if !current_collor:
		return

	var modified_collor := current_collor.duplicate(true)
	modified_collor.emission_enabled = true
	modified_collor.emission_energy_multiplier = 0.1
	modified_collor.emission = Color.GHOST_WHITE
	self.set_surface_override_material(0, modified_collor)

	region_hovered.emit(self)


func _on_mouse_exited() -> void:
	var current_collor: StandardMaterial3D = self.get_surface_override_material(0)
	if !current_collor:
		return

	var modified_collor := current_collor.duplicate(true)
	modified_collor.emission_enabled = false
	self.set_surface_override_material(0, modified_collor)

	region_unhovered.emit(self)


func reset_material() -> void:
	self.set_surface_override_material(0, default_material)


func reset_neigbour_materials() -> void:
	for neighbour in neighbours:
		neighbour.reset_material()


func can_army_enter(incoming_army: Army) -> bool:
	return army_entry_conditions(incoming_army).is_satisfied()


func army_entry_conditions(incoming_army: Army) -> CompositeCondition:
	return CompositeCondition.all(
		"All need to be met:",
		[
			SingleCondition.new(
				"Not a mountainous border", func() -> bool: return reachable_neighbours.has(incoming_army.region)
			),
			SingleCondition.new(
				"Not attacking another army", func() -> bool: return !army || army.faction == incoming_army.faction
			),
			SingleCondition.new(
				"Number of army units <= 10 after the merge",
				func() -> bool: return can_units_fit(incoming_army.get_selected_units())
			),
			CompositeCondition.any(
				"Any need to be met:",
				[
					SingleCondition.new(
						"Units belong to the target region nation",
						func() -> bool: return are_units_from_the_same_nation(incoming_army.units, nation)
					),
					SingleCondition.new(
						"Units are at war", func() -> bool: return are_units_at_war(incoming_army.units)
					),
					SingleCondition.new("Target region is a free region", func() -> bool: return nation == free_regions)
				]
			)
		]
	)


func can_units_fit(units: Array[Unit]) -> bool:
	if army == null:
		return true

	return army_size(units) + army_size(army.units) <= 10


func army_size(units: Array[Unit]) -> int:
	return units.reduce(func(accum: int, unit: Unit) -> int: return accum + unit.data.weight, 0)


func are_units_at_war(units: Array[Unit]) -> bool:
	return units.filter(func(x: Unit) -> bool: return x.data.nation.at_war).size() == units.size()


func are_units_from_the_same_nation(units: Array[Unit], other_nation: Nation) -> bool:
	return units.filter(func(x: Unit) -> bool: return x.data.nation == other_nation).size() == units.size()
