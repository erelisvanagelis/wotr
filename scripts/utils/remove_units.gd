@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run() -> void:
	var scene := get_scene()
	if !(scene is Map) || !Engine.is_editor_hint():
		return

	scene.get_tree().call_group(Constants.GROUP.UNITS, "queue_free")
