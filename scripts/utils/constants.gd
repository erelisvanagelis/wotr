extends Node

const MAP_DATA := {
	REGIONS = "regions",
	ID = "id",
	PARENT_ID = "parentId",
	NAME = "name",
	IS_SHADOW = "isShadows",
	COLOR = "color",
	BOUNDS = "Bounds",
	REGION = "province",
	NEIGHBOURS = "neighbours",
	ARMY = "army",
	REGULAR = "regular",
	ELITE = "elite",
	LEADER = "leader",
	UNREACHABLE_NEIGHBOURS = "unreachable_neighbours",
	FORTIFICATION = "isFortification",
	CITY = "isCity",
	TOWN = "isTown",
	STRONGHOLD = "isStronghold",
}

const GROUP := {REGIONS = "regions", ARMIES = "armies", UNITS = "units"}

const UNIT_TYPE := {CHARACTER = "Character", LEADER = "Leader", ELITE = "Elite", REGULAR = "Regular", NAZGUL = "Nazgûl"}

const NATION_NAMES := {
	ELVES = "Elves",
	DWARVES = "Dwarves",
	GONDOR = "Gondor",
	THE_NORTH = "The North",
	ROHAN = "Rohan",
	ISENGARD = "Isengard",
	SAURON = "Sauron",
	SOUTHRONS = "Southrons",
	EASTERLINGS = "Easterlings",
	REGIONES_LIBRES = "Regiones Libres"
}
