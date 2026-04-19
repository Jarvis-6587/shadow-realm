extends Node

# Attack data structure
class AttackData:
	var name: String
	var type: TypeChart.Type
	var power: int
	var accuracy: int
	var description: String
	var effect: String  # "", "heal", "def_buff", "spd_buff"

	func _init(n: String, t: TypeChart.Type, p: int, a: int, d: String, e: String = ""):
		name = n
		type = t
		power = p
		accuracy = a
		description = d
		effect = e

# Monster species data
class MonsterSpecies:
	var id: String
	var name: String
	var type: TypeChart.Type
	var base_hp: int
	var base_atk: int
	var base_def: int
	var base_spd: int
	var attacks: Array[String]  # attack IDs learned by level [level, attack_id] pairs
	var attack_levels: Dictionary  # {level: attack_id}
	var description: String
	var evolution_id: String  # empty if no evolution
	var evolution_level: int
	var sprite_color: Color
	var is_rare: bool

var attacks: Dictionary = {}  # attack_id -> AttackData
var monsters: Dictionary = {}  # monster_id -> MonsterSpecies

func _ready():
	_init_attacks()
	_init_monsters()

func _init_attacks():
	# Dark attacks
	_add_attack("shadow_ball", "Shadow Ball", TypeChart.Type.DARK, 50, 95, "A shadowy orb strikes the foe.")
	_add_attack("dark_magic", "Dark Magic", TypeChart.Type.DARK, 70, 90, "Powerful dark sorcery.")
	_add_attack("shadow_game", "Shadow Game", TypeChart.Type.DARK, 90, 80, "Drags the foe into the Shadow Realm.")
	_add_attack("dark_pulse", "Dark Pulse", TypeChart.Type.DARK, 60, 95, "A wave of dark energy.")
	_add_attack("nightmare", "Nightmare", TypeChart.Type.DARK, 40, 100, "Haunts the foe with nightmares.")
	_add_attack("void_strike", "Void Strike", TypeChart.Type.DARK, 80, 85, "Strikes from the void.")
	_add_attack("hex_blast", "Hex Blast", TypeChart.Type.DARK, 55, 95, "A cursed energy blast.")
	_add_attack("soul_drain", "Soul Drain", TypeChart.Type.DARK, 45, 100, "Drains life force from the target.")

	# Light attacks
	_add_attack("holy_light", "Holy Light", TypeChart.Type.LIGHT, 50, 95, "A burst of radiant light.")
	_add_attack("divine_wrath", "Divine Wrath", TypeChart.Type.LIGHT, 80, 85, "The fury of the heavens.")
	_add_attack("light_arrow", "Light Arrow", TypeChart.Type.LIGHT, 60, 95, "A piercing arrow of light.")
	_add_attack("celestial_beam", "Celestial Beam", TypeChart.Type.LIGHT, 90, 80, "A devastating beam from above.")
	_add_attack("heal_light", "Healing Light", TypeChart.Type.LIGHT, 0, 100, "Restores HP with holy light.", "heal")
	_add_attack("radiance", "Radiance", TypeChart.Type.LIGHT, 45, 100, "Glows with blinding light.")
	_add_attack("white_lightning", "White Lightning", TypeChart.Type.LIGHT, 85, 85, "A bolt of pure white energy.")

	# Fire attacks
	_add_attack("fireball", "Fireball", TypeChart.Type.FIRE, 55, 95, "A blazing fireball.")
	_add_attack("flame_sword", "Flame Sword", TypeChart.Type.FIRE, 70, 90, "A sword wreathed in flame.")
	_add_attack("inferno", "Inferno", TypeChart.Type.FIRE, 85, 80, "An all-consuming blaze.")
	_add_attack("ember", "Ember", TypeChart.Type.FIRE, 40, 100, "Small flames hit the foe.")
	_add_attack("blaze_kick", "Blaze Kick", TypeChart.Type.FIRE, 60, 90, "A fiery kick.")

	# Water attacks
	_add_attack("tidal_wave", "Tidal Wave", TypeChart.Type.WATER, 70, 90, "A massive wave crashes down.")
	_add_attack("water_jet", "Water Jet", TypeChart.Type.WATER, 45, 100, "A fast jet of water.")
	_add_attack("deep_sea", "Deep Sea Crush", TypeChart.Type.WATER, 80, 85, "Crushing ocean pressure.")
	_add_attack("bubble_shot", "Bubble Shot", TypeChart.Type.WATER, 40, 100, "Fires rapid bubbles.")
	_add_attack("whirlpool", "Whirlpool", TypeChart.Type.WATER, 60, 90, "Traps foe in a whirlpool.")

	# Earth attacks
	_add_attack("rock_smash", "Rock Smash", TypeChart.Type.EARTH, 50, 95, "Smashes with a boulder.")
	_add_attack("earthquake", "Earthquake", TypeChart.Type.EARTH, 80, 85, "Shakes the ground violently.")
	_add_attack("stone_wall", "Stone Wall", TypeChart.Type.EARTH, 0, 100, "Raises defense with stone.", "def_buff")
	_add_attack("earth_spike", "Earth Spike", TypeChart.Type.EARTH, 60, 90, "Spikes erupt from below.")
	_add_attack("ground_pound", "Ground Pound", TypeChart.Type.EARTH, 45, 100, "Slams the ground hard.")

	# Wind attacks
	_add_attack("gust", "Gust", TypeChart.Type.WIND, 40, 100, "A powerful gust of wind.")
	_add_attack("tornado", "Tornado", TypeChart.Type.WIND, 70, 85, "A raging tornado.")
	_add_attack("air_slash", "Air Slash", TypeChart.Type.WIND, 55, 95, "A blade of compressed air.")
	_add_attack("cyclone", "Cyclone", TypeChart.Type.WIND, 80, 80, "A devastating cyclone.")
	_add_attack("tailwind", "Tailwind", TypeChart.Type.WIND, 0, 100, "Boosts speed with wind.", "spd_buff")
	_add_attack("dragon_breath", "Dragon Breath", TypeChart.Type.WIND, 65, 90, "A fearsome dragon's breath.")

	# Normal/physical attacks
	_add_attack("tackle", "Tackle", TypeChart.Type.EARTH, 35, 100, "A basic physical attack.")
	_add_attack("slash", "Slash", TypeChart.Type.EARTH, 50, 95, "Slashes with claws or blade.")

func _add_attack(id: String, atk_name: String, type: TypeChart.Type, power: int, accuracy: int, desc: String, effect: String = ""):
	var atk = AttackData.new(atk_name, type, power, accuracy, desc, effect)
	attacks[id] = atk

func _init_monsters():
	# 1. Kuriboh (Dark, Starter) -> Kuribabylon
	_add_monster("kuriboh", "Kuriboh", TypeChart.Type.DARK, 45, 30, 25, 40,
		{1: "tackle", 4: "nightmare", 8: "shadow_ball", 12: "dark_pulse"},
		"A small furry creature with surprising resilience.",
		"kuribabylon", 16, Color(0.5, 0.35, 0.2), false)

	# Kuribabylon (evolution)
	_add_monster("kuribabylon", "Kuribabylon", TypeChart.Type.DARK, 75, 55, 50, 60,
		{1: "nightmare", 2: "shadow_ball", 16: "dark_pulse", 22: "shadow_game"},
		"Five Kuribohs merged into a powerful dark entity.",
		"", 0, Color(0.6, 0.3, 0.4), false)

	# 2. Dark Magician Apprentice -> Dark Magician
	_add_monster("dark_apprentice", "Dark Magician Apprentice", TypeChart.Type.DARK, 50, 55, 35, 45,
		{1: "shadow_ball", 5: "dark_pulse", 10: "hex_blast", 15: "dark_magic"},
		"A young sorcerer learning the dark arts.",
		"dark_magician", 20, Color(0.3, 0.15, 0.5), false)

	_add_monster("dark_magician", "Dark Magician", TypeChart.Type.DARK, 80, 85, 60, 70,
		{1: "dark_pulse", 2: "dark_magic", 20: "shadow_game", 28: "void_strike"},
		"The ultimate dark sorcerer, master of shadow magic.",
		"", 0, Color(0.4, 0.1, 0.6), false)

	# 3. Blue-Eyes White Dragon (Light, rare, late game)
	_add_monster("blue_eyes", "Blue-Eyes White Dragon", TypeChart.Type.LIGHT, 95, 95, 70, 75,
		{1: "white_lightning", 2: "celestial_beam", 3: "divine_wrath", 4: "light_arrow"},
		"A legendary dragon of immense power with piercing blue eyes.",
		"", 0, Color(0.8, 0.85, 1.0), true)

	# 4. Red-Eyes Black Dragon (Dark)
	_add_monster("red_eyes", "Red-Eyes Black Dragon", TypeChart.Type.DARK, 85, 90, 60, 65,
		{1: "dark_pulse", 2: "void_strike", 3: "shadow_game", 4: "dragon_breath"},
		"A fierce black dragon with burning red eyes.",
		"", 0, Color(0.2, 0.1, 0.15), true)

	# 5. Flame Swordsman (Fire)
	_add_monster("flame_swordsman", "Flame Swordsman", TypeChart.Type.FIRE, 65, 75, 55, 55,
		{1: "slash", 5: "ember", 10: "flame_sword", 18: "inferno"},
		"A warrior who wields a blade of living fire.",
		"", 0, Color(0.9, 0.4, 0.1), false)

	# 6. Mystical Elf (Light)
	_add_monster("mystical_elf", "Mystical Elf", TypeChart.Type.LIGHT, 70, 45, 75, 50,
		{1: "radiance", 5: "holy_light", 10: "heal_light", 16: "divine_wrath"},
		"A peaceful elf with powerful defensive magic.",
		"", 0, Color(0.6, 0.8, 0.95), false)

	# 7. Celtic Guardian (Earth)
	_add_monster("celtic_guardian", "Celtic Guardian", TypeChart.Type.EARTH, 65, 65, 65, 55,
		{1: "slash", 5: "rock_smash", 10: "earth_spike", 16: "earthquake"},
		"An elven warrior with mastery over earth combat.",
		"", 0, Color(0.4, 0.6, 0.3), false)

	# 8. Baby Dragon (Wind) -> Thousand Dragon
	_add_monster("baby_dragon", "Baby Dragon", TypeChart.Type.WIND, 50, 45, 40, 55,
		{1: "gust", 4: "tackle", 8: "air_slash", 12: "dragon_breath"},
		"A small but brave young dragon learning to fly.",
		"thousand_dragon", 18, Color(0.8, 0.6, 0.3), false)

	_add_monster("thousand_dragon", "Thousand Dragon", TypeChart.Type.WIND, 85, 80, 70, 65,
		{1: "dragon_breath", 2: "tornado", 18: "cyclone", 25: "inferno"},
		"An ancient dragon of incredible power, weathered by millennia.",
		"", 0, Color(0.6, 0.5, 0.35), false)

	# 9. Legendary Fisherman (Water)
	_add_monster("fisherman", "Legendary Fisherman", TypeChart.Type.WATER, 60, 60, 55, 50,
		{1: "water_jet", 5: "bubble_shot", 10: "tidal_wave", 16: "deep_sea"},
		"A mysterious fisherman who commands the ocean's power.",
		"", 0, Color(0.2, 0.4, 0.7), false)

	# 10. Time Wizard (Wind)
	_add_monster("time_wizard", "Time Wizard", TypeChart.Type.WIND, 55, 50, 45, 70,
		{1: "gust", 5: "air_slash", 10: "tornado", 15: "cyclone"},
		"A magical being that can manipulate the flow of time.",
		"", 0, Color(0.7, 0.5, 0.8), false)

	# 11. Hane-Hane (Earth)
	_add_monster("hane_hane", "Hane-Hane", TypeChart.Type.EARTH, 50, 40, 50, 45,
		{1: "tackle", 4: "ground_pound", 8: "rock_smash", 13: "earth_spike"},
		"A mischievous beast that can bounce foes away.",
		"", 0, Color(0.7, 0.6, 0.4), false)

	# 12. Squid Kraken (Water)
	_add_monster("squid_kraken", "Squid Kraken", TypeChart.Type.WATER, 65, 55, 60, 40,
		{1: "bubble_shot", 5: "water_jet", 10: "whirlpool", 16: "deep_sea"},
		"A swamp-dwelling tentacled horror from the deep.",
		"", 0, Color(0.3, 0.25, 0.5), false)

	# 13. Flame Knight (Fire)
	_add_monster("flame_knight", "Flame Knight", TypeChart.Type.FIRE, 60, 70, 50, 60,
		{1: "ember", 5: "blaze_kick", 10: "fireball", 15: "flame_sword"},
		"A knight whose armor burns with eternal flame.",
		"", 0, Color(0.95, 0.35, 0.15), false)

	# 14. Winja (Dark)
	_add_monster("winja", "Winja", TypeChart.Type.DARK, 55, 60, 40, 65,
		{1: "tackle", 5: "nightmare", 9: "hex_blast", 14: "shadow_ball"},
		"A shadowy ninja that strikes from the darkness.",
		"", 0, Color(0.25, 0.15, 0.35), false)

	# 15. Breaker of Darkness (Dark)
	_add_monster("breaker", "Breaker of Darkness", TypeChart.Type.DARK, 70, 80, 55, 50,
		{1: "slash", 5: "dark_pulse", 10: "void_strike", 18: "shadow_game"},
		"A powerful dark warrior who shatters all defenses.",
		"", 0, Color(0.3, 0.2, 0.25), false)

func _add_monster(id: String, mon_name: String, type: TypeChart.Type,
	hp: int, atk: int, def_stat: int, spd: int,
	atk_levels: Dictionary, desc: String,
	evo_id: String, evo_level: int, color: Color, rare: bool):
	var species = MonsterSpecies.new()
	species.id = id
	species.name = mon_name
	species.type = type
	species.base_hp = hp
	species.base_atk = atk
	species.base_def = def_stat
	species.base_spd = spd
	species.attack_levels = atk_levels
	species.description = desc
	species.evolution_id = evo_id
	species.evolution_level = evo_level
	species.sprite_color = color
	species.is_rare = rare
	monsters[id] = species

func get_species(id: String) -> MonsterSpecies:
	if monsters.has(id):
		return monsters[id]
	return null

func get_attacks_for_level(species_id: String, level: int) -> Array[String]:
	var species = get_species(species_id)
	if not species:
		return []
	var result: Array[String] = []
	for lvl in species.attack_levels:
		if lvl <= level:
			result.append(species.attack_levels[lvl])
	# Cap at 4 attacks, keeping the highest level ones
	if result.size() > 4:
		result = result.slice(result.size() - 4)
	return result

func get_attack(id: String) -> AttackData:
	if attacks.has(id):
		return attacks[id]
	return null

func get_wild_monsters_for_route(route_name: String) -> Array[String]:
	match route_name:
		"route_1":
			return ["kuriboh", "hane_hane", "winja", "baby_dragon"]
		"route_2":
			return ["flame_knight", "squid_kraken", "time_wizard", "fisherman", "breaker"]
		_:
			return ["kuriboh", "hane_hane"]

func get_starter_options() -> Array[String]:
	return ["kuriboh", "flame_knight", "fisherman"]
