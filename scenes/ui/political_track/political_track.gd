extends Control

var shadow: Faction = preload("res://scripts/resources/factions/shadow.tres")
var free_people: Faction = preload("res://scripts/resources/factions/free_people.tres")
var root: TreeItem
var ready_3: TreeItem
var ready_2: TreeItem
var ready_1: TreeItem
var ready_0: TreeItem
var nation_item_map: Dictionary


@export var shadow_legend: Legend
@export var free_people_legend: Legend
@export var inactive_legend: Legend

@onready var tree := %Tree
@onready var legend_container := %LegendContainer


func _ready() -> void:
	var correct_array_type: Array[Legend] = [inactive_legend, shadow_legend, free_people_legend]
	legend_container.legend_entries = correct_array_type
	root = tree.create_item()

	ready_3 = tree.create_item(root)
	ready_3.set_text(0, "III")
	ready_2 = tree.create_item(root)
	ready_2.set_text(0, "II")
	ready_1 = tree.create_item(root)
	ready_1.set_text(0, "I")
	ready_0 = tree.create_item(root)
	ready_0.set_text(0, "At War")

	nation_item_map = {}
	for nation: Nation in Nation.get_valid_nations():
		nation.readyness_changed.connect(readyness_changed)
		nation.activated.connect(activated)
		var branch := get_branch_by_readyness(nation.readyness)
		var child := branch.create_child()
		child.set_text(0, nation.title)
		child.set_metadata(0, nation)
		color_item_text(child, nation)

		var a_texture: Texture = load("res://assets/images/placeholders/icon32.svg")
		child.add_button(0, a_texture, -1, false, "> Left Click - increase war readyness \n> Right Click - activate nation")
		nation_item_map[nation.id] = child


func _on_button_clicked(item: TreeItem, _column: int, _id: int, mouse_button_index: int) -> void:
	var nation: Nation = item.get_metadata(0)
	if mouse_button_index == MOUSE_BUTTON_LEFT:
		nation.closer_to_war()
	elif mouse_button_index == MOUSE_BUTTON_RIGHT:
		nation.active = true


func get_branch_by_readyness(readynes: int) -> TreeItem:
	var branch: TreeItem
	match readynes:
		3:
			branch = ready_3
		2:
			branch = ready_2
		1:
			branch = ready_1
		0:
			branch = ready_0
		_:
			push_error("dont got that")

	return branch


func color_item_text(item: TreeItem, nation: Nation) -> TreeItem:
	if nation.active && nation.faction == Faction.free_people():
		item.set_custom_color(0, free_people_legend.color.color)
	elif nation.active && nation.faction == Faction.shadow():
		item.set_custom_color(0, shadow_legend.color.color)
	else:
		item.set_custom_color(0, inactive_legend.color.color)

	return item


func readyness_changed(nation: Nation, readyness: int) -> void:
	var item: TreeItem = nation_item_map[nation.id]
	item.get_parent().remove_child(item)
	var branch := get_branch_by_readyness(nation.readyness)
	branch.add_child(item)


func activated(nation: Nation) -> void:
	color_item_text(nation_item_map[nation.id] as TreeItem, nation)
