extends MarginContainer

signal list_item_changed(item: StringName)

@export var search_options: SearchOptions

var all_entries: Array[StringName]
var filtered_entries: Array[StringName]

@onready var search_field: LineEdit = %SearchLineEdit
@onready var item_list: ItemList = %ItemList


func _process(_delta: float) -> void:
	if all_entries:
		return

	all_entries.assign(search_options.option_list)
	filtered_entries = all_entries
	update_item_list(filtered_entries)


func _on_search_line_edit_text_changed(query: String) -> void:
	if !query:
		filtered_entries = all_entries
	else:
		filtered_entries = all_entries.filter(func(title: StringName) -> bool: return _filter_entry(title, query))

	update_item_list(filtered_entries)


func _on_list_item_selected(index: int) -> void:
	list_item_changed.emit(filtered_entries[index])


func _extract_filter_value(key: StringName) -> String:
	return search_options.filter_value_extraction.call(search_options.option_dictionary[key])


func _filter_entry(key: StringName, query: String) -> bool:
	var filtrable: String = search_options.filter_value_extraction.call(search_options.option_dictionary[key])
	for part: String in query.split(" "):
		if not filtrable.containsn(part):
			return false

	return true


func update_item_list(titles: Array[StringName]) -> void:
	item_list.clear()
	for index: int in range(0, titles.size()):
		var title: StringName = titles[index]
		var option: Variant = search_options.option_dictionary[title]
		item_list.add_item(title)
		var color: Color = search_options.color_extraction.call(option)
		item_list.set_item_custom_fg_color(index, color)
