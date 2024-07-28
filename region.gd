class_name Region
extends MeshInstance3D

signal region_selected(emmiter: Region)

@export var id: String
@export var title: String
@export var faction: String
@export var nation: String
@export var neighbours: Array[Region] = []
@export var default_material_test: StandardMaterial3D = null

var cyl: CharacterBody3D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var body: StaticBody3D = get_node("StaticBody3D") as StaticBody3D
	body.input_event.connect(_on_static_body_3d_input_event)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_static_body_3d_input_event(_camera: Node, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if (event is InputEventMouseButton && event.is_pressed()):
		#print(faction_test.title)
		region_selected.emit(self)

func reset_material() -> void:
	self.set_surface_override_material(0, default_material_test)
