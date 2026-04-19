extends Node

# Type effectiveness chart for Shadow Realm
# Types: Light, Dark, Fire, Water, Earth, Wind

enum Type { LIGHT, DARK, FIRE, WATER, EARTH, WIND }

const TYPE_NAMES := {
	Type.LIGHT: "Light",
	Type.DARK: "Dark",
	Type.FIRE: "Fire",
	Type.WATER: "Water",
	Type.EARTH: "Earth",
	Type.WIND: "Wind",
}

const TYPE_COLORS := {
	Type.LIGHT: Color(1.0, 0.95, 0.6),
	Type.DARK: Color(0.4, 0.2, 0.6),
	Type.FIRE: Color(1.0, 0.4, 0.2),
	Type.WATER: Color(0.3, 0.5, 1.0),
	Type.EARTH: Color(0.6, 0.5, 0.3),
	Type.WIND: Color(0.5, 0.9, 0.7),
}

# effectiveness[attacker_type][defender_type] = multiplier
# 2.0 = super effective, 0.5 = not very effective, 1.0 = normal
var effectiveness := {
	Type.LIGHT: {Type.LIGHT: 0.5, Type.DARK: 2.0, Type.FIRE: 1.0, Type.WATER: 1.0, Type.EARTH: 1.0, Type.WIND: 1.0},
	Type.DARK:  {Type.LIGHT: 2.0, Type.DARK: 0.5, Type.FIRE: 1.0, Type.WATER: 1.0, Type.EARTH: 1.0, Type.WIND: 1.0},
	Type.FIRE:  {Type.LIGHT: 1.0, Type.DARK: 1.0, Type.FIRE: 0.5, Type.WATER: 0.5, Type.EARTH: 2.0, Type.WIND: 1.0},
	Type.WATER: {Type.LIGHT: 1.0, Type.DARK: 1.0, Type.FIRE: 2.0, Type.WATER: 0.5, Type.EARTH: 1.0, Type.WIND: 0.5},
	Type.EARTH: {Type.LIGHT: 1.0, Type.DARK: 1.0, Type.FIRE: 0.5, Type.WATER: 1.0, Type.EARTH: 0.5, Type.WIND: 2.0},
	Type.WIND:  {Type.LIGHT: 1.0, Type.DARK: 1.0, Type.FIRE: 2.0, Type.WATER: 1.0, Type.EARTH: 0.5, Type.WIND: 0.5},
}

func get_effectiveness(attack_type: Type, defender_type: Type) -> float:
	return effectiveness[attack_type][defender_type]

func get_type_name(type: Type) -> String:
	return TYPE_NAMES[type]

func get_type_color(type: Type) -> Color:
	return TYPE_COLORS[type]

func type_from_string(type_str: String) -> Type:
	match type_str.to_lower():
		"light": return Type.LIGHT
		"dark": return Type.DARK
		"fire": return Type.FIRE
		"water": return Type.WATER
		"earth": return Type.EARTH
		"wind": return Type.WIND
		_: return Type.DARK
