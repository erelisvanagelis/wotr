extends Node

const FACTION := {
	FREE_PEOPLE = 'Free People',
	SHADOW = 'Shadow',
	UNALIGNED = 'Unaligned'
}

const TEST := {
	FREE_PEOPLE = {
		NAME = 'Free People',
		COLOR = ''
	},
	SHADOW = {
		NAME = 'Shadow',
		COLOR = ''
	},
	UNALIGNED = {
		NAME = 'Unaligned',
		COLOR = ''
	}
}

var SHADOW: Faction = Faction.new('Shadow')

const NATION := {
	ELVES = {
		ID = 1,
		NAME = 'Elves',
		FACTION = FACTION.FREE_PEOPLE,
		COLOR = '048f1a'
	},
	DWARVES = {
		ID = 2,
		NAME = 'Dwarves',
		FACTION = FACTION.FREE_PEOPLE,
		COLOR = '501b13'
	},
	GONDOR = {
		ID = 3,
		NAME = 'Gondor',
		FACTION = FACTION.FREE_PEOPLE,
		COLOR = '43426c'
	},
	THE_NORTH = {
		ID = 4,
		NAME = 'The North',
		FACTION = FACTION.FREE_PEOPLE,
		COLOR = '0c8ab3'
	},
	ROHAN = {
		ID = 5,
		NAME = 'Rohan',
		FACTION = FACTION.FREE_PEOPLE,
		COLOR = '046b26'
	},
	ISENGARD = {
		ID = 6,
		NAME = 'Isengard',
		FACTION = FACTION.SHADOW,
		COLOR = 'ded800'
	},
	SAURON = {
		ID = 7,
		NAME = 'Sauron',
		FACTION = FACTION.SHADOW,
		COLOR = 'a93f2f'
	},
	SOUTHRONS = {
		ID = 8,
		NAME = 'Southrons',
		FACTION = FACTION.SHADOW,
		COLOR = 'd38a33'
	},
	EASTERLINGS = {
		ID = 9,
		NAME = 'Easterlings',
		FACTION = FACTION.SHADOW,
		COLOR = 'dc9337'
	},
	REGIONES_LIBRES =  {
		ID = 10,
		NAME = 'Regiones Libres',
		FACTION = FACTION.UNALIGNED,
		COLOR = 'A9A9A9'
	}
}

const MAP_DATA := {
	REGIONS = 'regions',
	ID = 'id',
	PARENT_ID = 'parentId',
	NAME = 'name',
	IS_SHADOW = 'isShadows',
	COLOR = 'color',
	BOUNDS = 'Bounds',
	REGION = 'province',
	NEIGHBOURS = 'neighbours'
}

const GROUP := {
	REGIONS = 'regions'
}
