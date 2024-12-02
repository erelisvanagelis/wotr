extends HFlowContainer

@export var legend_entries: Array[Legend]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var entry_scene: PackedScene = load("res://scripts/resources/legend/legend_entry.tscn")
	for entry in legend_entries:
		var instance: LegendEntry = entry_scene.instantiate()
		instance.entry = entry
		self.add_child(instance)
