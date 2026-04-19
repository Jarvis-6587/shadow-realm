extends Node

# Runtime game state

signal team_changed
signal item_changed
signal monster_caught(monster)

const MAX_TEAM_SIZE := 6

# Active monster instance
class MonsterInstance:
	var species_id: String
	var nickname: String
	var level: int
	var xp: int
	var current_hp: int
	var max_hp: int
	var atk: int
	var def_stat: int
	var spd: int
	var attacks: Array[String]
	var type: TypeChart.Type

	func _init():
		level = 5
		xp = 0
		attacks = []

	static func create(species_id: String, lvl: int) -> MonsterInstance:
		var mon = MonsterInstance.new()
		var species = MonsterDB.get_species(species_id)
		if not species:
			return null
		mon.species_id = species_id
		mon.nickname = species.name
		mon.level = lvl
		mon.xp = 0
		mon.type = species.type
		mon._recalc_stats()
		mon.current_hp = mon.max_hp
		mon.attacks = MonsterDB.get_attacks_for_level(species_id, lvl)
		return mon

	func _recalc_stats():
		var species = MonsterDB.get_species(species_id)
		if not species:
			return
		max_hp = species.base_hp + (level * 3)
		atk = species.base_atk + (level * 2)
		def_stat = species.base_def + (level * 2)
		spd = species.base_spd + (level * 2)

	func xp_to_next_level() -> int:
		return level * level * 5

	func gain_xp(amount: int) -> Array:
		# Returns array of events: ["level_up"], ["new_attack", attack_id], ["evolution", new_species_id]
		var events: Array = []
		xp += amount
		while xp >= xp_to_next_level():
			xp -= xp_to_next_level()
			level += 1
			_recalc_stats()
			current_hp = max_hp  # Full heal on level up
			events.append(["level_up"])

			# Check for new attacks
			var species = MonsterDB.get_species(species_id)
			if species and species.attack_levels.has(level):
				var new_attack = species.attack_levels[level]
				if attacks.size() < 4:
					attacks.append(new_attack)
					events.append(["new_attack", new_attack])

			# Check evolution
			if species and species.evolution_id != "" and level >= species.evolution_level:
				var old_name = nickname
				species_id = species.evolution_id
				var new_species = MonsterDB.get_species(species_id)
				if new_species:
					if nickname == species.name:
						nickname = new_species.name
					type = new_species.type
					_recalc_stats()
					current_hp = max_hp
					events.append(["evolution", species_id])
		return events

	func is_alive() -> bool:
		return current_hp > 0

	func heal_full():
		current_hp = max_hp

	func to_dict() -> Dictionary:
		return {
			"species_id": species_id,
			"nickname": nickname,
			"level": level,
			"xp": xp,
			"current_hp": current_hp,
			"attacks": attacks,
		}

	static func from_dict(data: Dictionary) -> MonsterInstance:
		var mon = MonsterInstance.new()
		mon.species_id = data["species_id"]
		mon.nickname = data.get("nickname", "")
		mon.level = data.get("level", 5)
		mon.xp = data.get("xp", 0)
		mon.attacks = []
		for a in data.get("attacks", []):
			mon.attacks.append(a)
		var species = MonsterDB.get_species(mon.species_id)
		if species:
			mon.type = species.type
			if mon.nickname == "":
				mon.nickname = species.name
		mon._recalc_stats()
		mon.current_hp = data.get("current_hp", mon.max_hp)
		return mon

# Player state
var player_name: String = "Duelist"
var team: Array = []  # Array of MonsterInstance
var monster_box: Array = []  # Storage
var soul_cards: Dictionary = {"normal": 10, "silver": 3, "gold": 1}
var items: Dictionary = {"potion": 5}
var player_position: Vector2 = Vector2(160, 240)
var current_map: String = "town"
var badges: int = 0

func add_to_team(monster: MonsterInstance) -> bool:
	if team.size() < MAX_TEAM_SIZE:
		team.append(monster)
		team_changed.emit()
		monster_caught.emit(monster)
		return true
	else:
		monster_box.append(monster)
		monster_caught.emit(monster)
		return false

func swap_team_monster(from_idx: int, to_idx: int):
	if from_idx >= 0 and from_idx < team.size() and to_idx >= 0 and to_idx < team.size():
		var temp = team[from_idx]
		team[from_idx] = team[to_idx]
		team[to_idx] = temp
		team_changed.emit()

func swap_team_and_box(team_idx: int, box_idx: int):
	if team_idx >= 0 and team_idx < team.size() and box_idx >= 0 and box_idx < monster_box.size():
		var temp = team[team_idx]
		team[team_idx] = monster_box[box_idx]
		monster_box[box_idx] = temp
		team_changed.emit()

func move_from_box_to_team(box_idx: int) -> bool:
	if box_idx >= 0 and box_idx < monster_box.size() and team.size() < MAX_TEAM_SIZE:
		var mon = monster_box[box_idx]
		monster_box.remove_at(box_idx)
		team.append(mon)
		team_changed.emit()
		return true
	return false

func get_first_alive_monster() -> MonsterInstance:
	for mon in team:
		if mon.is_alive():
			return mon
	return null

func has_alive_monster() -> bool:
	return get_first_alive_monster() != null

func heal_all_monsters():
	for mon in team:
		mon.heal_full()
	for mon in monster_box:
		mon.heal_full()

func use_soul_card(tier: String) -> bool:
	if soul_cards.has(tier) and soul_cards[tier] > 0:
		soul_cards[tier] -= 1
		item_changed.emit()
		return true
	return false

func get_soul_card_catch_rate(tier: String) -> float:
	match tier:
		"normal": return 1.0
		"silver": return 1.5
		"gold": return 2.5
		_: return 1.0

func use_item(item_name: String) -> bool:
	if items.has(item_name) and items[item_name] > 0:
		items[item_name] -= 1
		item_changed.emit()
		return true
	return false

func to_dict() -> Dictionary:
	var team_data: Array = []
	for mon in team:
		team_data.append(mon.to_dict())
	var box_data: Array = []
	for mon in monster_box:
		box_data.append(mon.to_dict())
	return {
		"player_name": player_name,
		"team": team_data,
		"monster_box": box_data,
		"soul_cards": soul_cards.duplicate(),
		"items": items.duplicate(),
		"player_position": {"x": player_position.x, "y": player_position.y},
		"current_map": current_map,
		"badges": badges,
	}

func from_dict(data: Dictionary):
	player_name = data.get("player_name", "Duelist")
	team.clear()
	for md in data.get("team", []):
		team.append(MonsterInstance.from_dict(md))
	monster_box.clear()
	for md in data.get("monster_box", []):
		monster_box.append(MonsterInstance.from_dict(md))
	soul_cards = data.get("soul_cards", {"normal": 10, "silver": 3, "gold": 1})
	items = data.get("items", {"potion": 5})
	var pos = data.get("player_position", {"x": 160, "y": 240})
	player_position = Vector2(pos["x"], pos["y"])
	current_map = data.get("current_map", "town")
	badges = data.get("badges", 0)
	team_changed.emit()
