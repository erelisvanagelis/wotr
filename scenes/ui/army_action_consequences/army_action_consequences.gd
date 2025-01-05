extends Control

@onready var text_box: RichTextLabel = %RichTextLabel
@onready var label: Label = %Label


func on_concequeces_changed(nation_readyness_map: Dictionary) -> void:
	text_box.text = ""
	if nation_readyness_map == null:
		self.custom_minimum_size = Vector2.ZERO
		return

	var line_count := 0

	for nation: Nation in nation_readyness_map.keys():
		var advancement: int = nation_readyness_map[nation]
		var line_text: String = ""
		if not nation.active:
			line_text = "%s - will be activated \n" % nation.title
			line_count += 1

		if nation.readyness - advancement < 1:
			line_text = "%s - will enter war \n" % nation.title
			line_count = 1
		else:
			line_text += "%s - will advance political track by %s \n" % [nation.title, advancement]
			line_count += 1

		text_box.text += line_text

	self.custom_minimum_size = Vector2(0, line_count * 23 + label.size.y + 10)
