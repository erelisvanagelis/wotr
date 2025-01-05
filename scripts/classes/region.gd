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

var hover_colors: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	neighbours.append_array(reachable_neighbours)
	neighbours.append_array(unreachable_neighbours)

	var selected_region_material := StandardMaterial3D.new()
	var move_neigbour_material := StandardMaterial3D.new()
	var attack_neigbour_material := StandardMaterial3D.new()
	selected_region_material.albedo_color = ColorPalette.selected_region().color
	move_neigbour_material.albedo_color = ColorPalette.move_region().color
	attack_neigbour_material.albedo_color = ColorPalette.attack_region().color

	hover_colors[default_material] = _set_hover_color(default_material)
	hover_colors[selected_region_material] = _set_hover_color(selected_region_material)
	hover_colors[move_neigbour_material] = _set_hover_color(move_neigbour_material)
	hover_colors[attack_neigbour_material] = _set_hover_color(attack_neigbour_material)
	hover_colors[hover_colors[default_material]] = default_material
	hover_colors[hover_colors[selected_region_material] ] = selected_region_material
	hover_colors[hover_colors[move_neigbour_material]] = move_neigbour_material
	hover_colors[hover_colors[attack_neigbour_material]] = attack_neigbour_material

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


func _set_hover_color(p_material: StandardMaterial3D) -> StandardMaterial3D:
	var material := p_material.duplicate(true)
	material.emission_enabled = true
	material.emission_energy_multiplier = 0.4
	material.emission = Color.GHOST_WHITE

	return material


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
	var dict_collor: StandardMaterial3D
	for material: StandardMaterial3D in hover_colors.keys():
		if material.albedo_color == current_collor.albedo_color && not material.emission_enabled:
			dict_collor = material

	if hover_colors.has(dict_collor):
		self.set_surface_override_material(0, hover_colors[dict_collor])


func _on_mouse_exited() -> void:
	var current_collor: StandardMaterial3D = self.get_surface_override_material(0)
	var dict_collor: StandardMaterial3D
	for material: StandardMaterial3D in hover_colors.keys():
		if material.albedo_color == current_collor.albedo_color && material.emission_enabled:
			dict_collor = material

	if hover_colors.has(dict_collor):
		self.set_surface_override_material(0, hover_colors[dict_collor])

	region_unhovered.emit(self)


func reset() -> void:
	self.set_surface_override_material(0, default_material)


func reset_neighbours() -> void:
	for neighbour in neighbours:
		neighbour.reset()
