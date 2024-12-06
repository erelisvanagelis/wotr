extends VBoxContainer

@export var _map: Map

var all_regions: Array[StringName]
var filtered_regions: Array[StringName]

@onready var search_field: LineEdit = %SearchLineEdit
@onready var region_list: ItemList = %RegionList


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for title: StringName in _map.title_to_region_map.keys():
		all_regions.append(title)

	filtered_regions = all_regions
	update_region_list(filtered_regions)


func _on_search_field_text_changed(query: String) -> void:
	if !query:
		filtered_regions = all_regions
	else:
		filtered_regions = all_regions.filter(func(title: StringName) -> bool: return title.containsn(query))

	update_region_list(filtered_regions)


func _on_item_list_item_selected(index: int) -> void:
	_map.selected_region = _map.title_to_region_map[filtered_regions[index]]


func update_region_list(titles: Array[StringName]) -> void:
	region_list.clear()
	for title: StringName in titles:
		region_list.add_item(title)
