class_name ArmyBuilder
extends Node

var _units: Dictionary = {}
var _nation: Nation
var _region: Region
var _army_manager: ArmyManager
var types := Constants.UNIT_TYPE

static var army_scene: PackedScene = preload("res://scenes/army/army.tscn")


func _init(army_manager: ArmyManager) -> void:
	_army_manager = army_manager


func nazgul(count: int) -> ArmyBuilder:
	_units[types.NAZGUL] = count
	return self


func leader(count: int) -> ArmyBuilder:
	_units[types.LEADER] = count
	return self


func elite(count: int) -> ArmyBuilder:
	_units[types.ELITE] = count
	return self


func regular(count: int) -> ArmyBuilder:
	_units[types.REGULAR] = count
	return self


func nation(p_nation: Nation) -> ArmyBuilder:
	_nation = p_nation
	return self


func region(p_region: Region) -> ArmyBuilder:
	_region = p_region
	return self

func units(p_units: Dictionary) -> ArmyBuilder:
	_units = p_units
	return self


func build() -> Army:
	assert(_nation || _region, "Region or Nation must be set")

	var army_nation := _nation if _nation else _region.nation
	var army: Army = army_scene.instantiate()
	army.faction = army_nation.faction

	var new_units: Array[Unit] = []
	for unit_type: String in _units:
		new_units.append_array(Unit.select_units(army_nation, unit_type, _units[unit_type]))

	army.units = new_units
	army.selected.connect(func(selected_army: Army) -> void: _army_manager.selected_army = selected_army)
	army.deselected.connect(func() -> void: _army_manager.selected_army = null)
	army.hovered.connect(func (hovered_army: Army) -> void: _army_manager.hovered_army = hovered_army)
	army.unhovered.connect(func (unhovered_army: Army) -> void: _army_manager.hovered_army = unhovered_army)
	_army_manager.add_child(army)

	return army


func build_and_assign_to_region() -> Army:
	assert(_region, "Region must be set")

	var army := build()
	_region.army = army
	return army
