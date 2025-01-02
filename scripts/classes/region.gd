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
		army.target_position = position
@export var secondary_armies: Array[Army]

var free_regions: Nation = load("res://scripts/resources/nations/unaligned.tres")
var neighbours: Array[Region] = []
var movement_condition: ConditionComponent


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	neighbours.append_array(reachable_neighbours)
	neighbours.append_array(unreachable_neighbours)

	#var title_label := Label3D.new()
	#title_label.text = title
	#title_label.position += Vector3(0, 0.001, 0)
	#title_label.rotation = Vector3(-1.5708, 0, 0)
	#title_label.pixel_size = 0.0005
	#add_child(title_label)

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
	higlight_region()
	region_hovered.emit(self)


func higlight_region() -> void:
	var current_collor: StandardMaterial3D = self.get_surface_override_material(0)
	if !current_collor:
		return

	var modified_collor := current_collor.duplicate(true)
	modified_collor.emission_enabled = true
	modified_collor.emission_energy_multiplier = 0.4
	modified_collor.emission = Color.GHOST_WHITE
	self.set_surface_override_material(0, modified_collor)


func _on_mouse_exited() -> void:
	var current_collor: StandardMaterial3D = self.get_surface_override_material(0)
	if !current_collor:
		return

	var modified_collor := current_collor.duplicate(true)
	modified_collor.emission_enabled = false
	self.set_surface_override_material(0, modified_collor)

	region_unhovered.emit(self)


func reset() -> void:
	self.set_surface_override_material(0, default_material)


func reset_neighbours() -> void:
	for neighbour in neighbours:
		neighbour.reset()
