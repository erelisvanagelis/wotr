extends Node

const MAP_DATA := {
	REGIONS = 'regions',
	ID = 'id',
	PARENT_ID = 'parentId',
	NAME = 'name',
	IS_SHADOW = 'isShadows',
	COLOR = 'color',
	BOUNDS = 'Bounds',
	REGION = 'province',
	NEIGHBOURS = 'neighbours',
	ARMY = 'army',
	REGULAR = 'regular',
	ELITE = 'elite',
	LEADER = 'leader',
}

const GROUP := {
	REGIONS = 'regions',
	ARMIES = 'armies'
}

const UNIT_TYPE := {
	CHARACTER = 'Character',
	LEADER = 'Leader',
	ELITE = 'Elite',
	REGULAR = 'Regular',
	NAZGUL = 'Nazgûl'
}

const NATION_NAMES := {
	ELVES = 'Elves',
	DWARVES = 'Dwarves',
	GONDOR = 'Gondor',
	THE_NORTH = 'The North',
	ROHAN = 'Rohan',
	ISENGARD = 'Isengard',
	SAURON = 'Sauron',
	SOUTHRONS = 'Southrons',
	EASTERLINGS = 'Easterlings',
	REGIONES_LIBRES = 'Regiones Libres'
}

enum NATIONS_ENUM {ELVES, DWARVES, GONDOR, THE_NORTH, ROHAN, ISENGARD, SAURON, SOUTHRONS, EASTERLINGS, REGIONES_LIBRES}
#
#const NATION_DATA := {
	#NATIONS_ENUM.ELVES = {
		#ID = 1,
		#NAME = NATION_NAMES.ELVES,
		#FACTION = FACTION.FREE_PEOPLE,
		#COLOR = '048f1a'
	#}
#}

#const
