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
@export var army: Army:
	set(new_army):
		army = new_army
		if !army:
			return

		army.region = self
		army.move_to_parent_center(position)
@export var secondary_armies: Array[Army]

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

func add_to_secondary_armies(secondary: Army) -> void:
	pass
	#if army && army.faction == secondary.faction:
