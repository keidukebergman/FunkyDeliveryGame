class_name CombatantData extends Resource

enum CombatantType{
	AIRCRAFT,
	EMPLACEMENT
}

enum Sides {
	NONCOMBATANT,
	NEUTRAL,
	CORPA,
	CORPB
}

@export var type:CombatantType
@export var strength:int = 1
@export var is_player:bool = false
