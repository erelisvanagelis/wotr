class_name Region
extends MeshInstance3D

signal region_selected(emmiter: Region)
signal region_targeted(emmiter: Region)
signal army_selected(emmiter: Region, army: Army)

@export var id: String
@export var title: String
@export var nation: Nation
@export var neighbours: Array[Region] = []
@export var default_material_test: StandardMaterial3D = null
@export var army: Army: 
	set(new_army):
		if army && army.army_selected.is_connected(on_army_selected):
			army.army_selected.disconnect(on_army_selected)

		if (army && new_army) && army != new_army:
			army.queue_free()

		army = new_army
		if !army:
			return

		army.army_selected.connect(on_army_selected)
		army.move_to_parent_center(position)

var free_regions: Nation = load("res://data/nations/unaligned.tres")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var body: StaticBody3D = get_node("StaticBody3D") as StaticBody3D
	body.input_event.connect(_on_static_body_3d_input_event)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_static_body_3d_input_event(_camera: Node, _event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if !(_event is InputEventMouseButton) || !_event.is_pressed():
		return

	var event := _event as InputEventMouseButton
	match event.button_index:
		MOUSE_BUTTON_LEFT:
			region_selected.emit(self)
		MOUSE_BUTTON_RIGHT:
			region_targeted.emit(self)

func on_army_selected() -> void:
	army_selected.emit(self, army)
	print("Army selected")

func reset_material() -> void:
	self.set_surface_override_material(0, default_material_test)

func can_army_enter(army: Army) -> bool:
	if nation == free_regions:
		return true
	elif are_units_at_war(army.units):
		return true
	elif are_units_from_the_same_nation(army.units, nation):
		return true
	
	return false
func are_units_at_war(units: Array[Unit])-> bool:
	#var count := 0
	#for unit in units:
		#if unit.nation.at_war:
			#count += 1
		#print(unit)
	return units.filter(func(x: Unit) -> bool: return x.nation.at_war).size() == units.size()
	#return count == units.size()
	
func are_units_from_the_same_nation(units: Array[Unit], nation: Nation)-> bool:
	return units.filter(func(x: Unit) -> bool: return x.nation == nation).size() == units.size()
