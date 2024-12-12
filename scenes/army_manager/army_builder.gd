class_name ArmyBuilder
extends Node

static var army_scene: PackedScene = preload("res://scenes/army/army.tscn")
var types := Constants.UNIT_TYPE

var _units: Dictionary = {}
var _nation: Nation
var _region: Region
var _faction: Faction
var _army_manager: ArmyManager
var _ignore_reserves: bool = false


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


func faction(p_faction: Faction) -> ArmyBuilder:
	_faction = p_faction
	return self


func ignored_reserves(p_ignore_reserves: bool) -> ArmyBuilder:
	_ignore_reserves = p_ignore_reserves
	return self


func build() -> Army:
	assert(_nation || _region || _faction, "Region or Nation or Faction must be set")

	if _region:
		_nation = _nation if _nation else _region.nation

	if _nation:
		_faction = _faction if _faction else _nation.faction

	var army: Army = army_scene.instantiate()
	var new_units: Array[Unit] = []
	for unit_type: String in _units:
		var unit_count: int = _units[unit_type]
		if !_ignore_reserves:
			_army_manager.update_nation_reserves(unit_type, _nation, -unit_count)

		new_units.append_array(Unit.select_units(_nation, unit_type, unit_count))

	army.units = new_units
	army.faction = _faction
	army.selected.connect(
		func(selected_army: Army) -> void: _army_manager.selected_army = selected_army
	)
	army.deselected.connect(func() -> void: _army_manager.selected_army = null)
	army.hovered.connect(
		func(hovered_army: Army) -> void: _army_manager.hovered_army = hovered_army
	)
	army.unhovered.connect(
		func(unhovered_army: Army) -> void: _army_manager.hovered_army = unhovered_army
	)
	_army_manager.add_child(army)

	return army


func build_and_assign_to_region() -> Army:
	assert(_region, "Region must be set")

	var army := build()
	_region.army = army
	return army
