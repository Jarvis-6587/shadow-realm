extends Control

signal battle_ended

var wild_monster: GameData.MonsterInstance
var player_monster: GameData.MonsterInstance
var is_player_turn := true
var battle_active := false
var battle_log: Array[String] = []

@onready var battle_ui = $BattleUI

func _ready():
	player_monster = GameData.get_first_alive_monster()
	if not player_monster or not wild_monster:
		end_battle()
		return
	battle_active = true
	battle_ui.setup(player_monster, wild_monster)
	battle_ui.attack_selected.connect(_on_attack_selected)
	battle_ui.soul_card_selected.connect(_on_soul_card_selected)
	battle_ui.flee_selected.connect(_on_flee_selected)

	# Determine first turn by speed
	is_player_turn = player_monster.spd >= wild_monster.spd
	if is_player_turn:
		add_log("A wild %s appeared!" % wild_monster.nickname)
		battle_ui.show_message("A wild %s appeared!" % wild_monster.nickname)
		await get_tree().create_timer(1.5).timeout
		battle_ui.show_actions()
	else:
		add_log("A wild %s appeared! It's fast!" % wild_monster.nickname)
		battle_ui.show_message("A wild %s appeared! It's fast!" % wild_monster.nickname)
		await get_tree().create_timer(1.5).timeout
		enemy_turn()

func _on_attack_selected(attack_idx: int):
	if not battle_active:
		return
	var attack_id = player_monster.attacks[attack_idx]
	await execute_attack(player_monster, wild_monster, attack_id, true)

	if not battle_active:
		return

	if not wild_monster.is_alive():
		await on_enemy_defeated()
		return

	await enemy_turn()

func enemy_turn():
	if not battle_active or not wild_monster.is_alive():
		return
	# Enemy picks random attack
	var attack_id = wild_monster.attacks[randi() % wild_monster.attacks.size()]
	await execute_attack(wild_monster, player_monster, attack_id, false)

	if not battle_active:
		return

	if not player_monster.is_alive():
		await on_player_monster_fainted()
		return

	battle_ui.update_stats(player_monster, wild_monster)
	battle_ui.show_actions()

func execute_attack(attacker: GameData.MonsterInstance, defender: GameData.MonsterInstance, attack_id: String, is_player: bool):
	var attack = MonsterDB.get_attack(attack_id)
	if not attack:
		return

	var attacker_name = "Your %s" % attacker.nickname if is_player else "Wild %s" % attacker.nickname
	battle_ui.show_message("%s used %s!" % [attacker_name, attack.name])
	await get_tree().create_timer(1.0).timeout

	# Accuracy check
	if randi() % 100 >= attack.accuracy:
		battle_ui.show_message("It missed!")
		add_log("%s used %s but missed!" % [attacker_name, attack.name])
		await get_tree().create_timer(1.0).timeout
		return

	# Healing attacks
	if attack.power == 0:
		var heal_amount = attacker.max_hp / 4
		attacker.current_hp = mini(attacker.current_hp + heal_amount, attacker.max_hp)
		battle_ui.show_message("%s restored some HP!" % attacker_name)
		add_log("%s used %s and healed!" % [attacker_name, attack.name])
		await get_tree().create_timer(1.0).timeout
		battle_ui.update_stats(player_monster, wild_monster)
		return

	# Damage calculation
	var type_mult = TypeChart.get_effectiveness(attack.type, defender.type)
	var base_damage = ((2.0 * attacker.level / 5.0 + 2.0) * attack.power * (float(attacker.atk) / float(defender.def_stat))) / 50.0 + 2.0
	var random_mult = randf_range(0.85, 1.0)
	var damage = int(base_damage * type_mult * random_mult)
	damage = maxi(damage, 1)

	defender.current_hp = maxi(defender.current_hp - damage, 0)
	battle_ui.update_stats(player_monster, wild_monster)
	battle_ui.shake_sprite(not is_player)

	# Type effectiveness message
	if type_mult > 1.0:
		battle_ui.show_message("It's super effective!")
		add_log("%s used %s for %d damage (super effective!)" % [attacker_name, attack.name, damage])
		await get_tree().create_timer(1.0).timeout
	elif type_mult < 1.0:
		battle_ui.show_message("It's not very effective...")
		add_log("%s used %s for %d damage (not very effective)" % [attacker_name, attack.name, damage])
		await get_tree().create_timer(1.0).timeout
	else:
		add_log("%s used %s for %d damage" % [attacker_name, attack.name, damage])

func on_enemy_defeated():
	battle_active = false
	# Calculate XP
	var species = MonsterDB.get_species(wild_monster.species_id)
	var base_xp = (wild_monster.level * 10) + 20
	if species and species.is_rare:
		base_xp *= 2

	battle_ui.show_message("Wild %s was defeated!" % wild_monster.nickname)
	add_log("Wild %s defeated!" % wild_monster.nickname)
	await get_tree().create_timer(1.5).timeout

	battle_ui.show_message("%s gained %d XP!" % [player_monster.nickname, base_xp])
	await get_tree().create_timer(1.0).timeout

	var events = player_monster.gain_xp(base_xp)
	for event in events:
		match event[0]:
			"level_up":
				battle_ui.show_message("%s grew to level %d!" % [player_monster.nickname, player_monster.level])
				await get_tree().create_timer(1.5).timeout
			"new_attack":
				var atk = MonsterDB.get_attack(event[1])
				if atk:
					battle_ui.show_message("%s learned %s!" % [player_monster.nickname, atk.name])
					await get_tree().create_timer(1.5).timeout
			"evolution":
				battle_ui.show_message("%s evolved!" % player_monster.nickname)
				battle_ui.update_stats(player_monster, wild_monster)
				await get_tree().create_timer(2.0).timeout

	end_battle()

func on_player_monster_fainted():
	battle_ui.show_message("%s fainted!" % player_monster.nickname)
	add_log("%s fainted!" % player_monster.nickname)
	await get_tree().create_timer(1.5).timeout

	# Try to send next monster
	var next = GameData.get_first_alive_monster()
	if next:
		player_monster = next
		battle_ui.show_message("Go, %s!" % player_monster.nickname)
		battle_ui.setup(player_monster, wild_monster)
		await get_tree().create_timer(1.5).timeout
		battle_ui.show_actions()
	else:
		battle_ui.show_message("All your monsters fainted...")
		await get_tree().create_timer(2.0).timeout
		# Heal and return to town (whiteout)
		GameData.heal_all_monsters()
		GameData.current_map = "town"
		end_battle()

func _on_soul_card_selected(tier: String):
	if not battle_active:
		return

	if not GameData.use_soul_card(tier):
		battle_ui.show_message("No %s Soul Cards left!" % tier.capitalize())
		await get_tree().create_timer(1.0).timeout
		battle_ui.show_actions()
		return

	battle_ui.show_message("You threw a %s Soul Card!" % tier.capitalize())
	await get_tree().create_timer(1.0).timeout

	# Catch calculation
	var hp_factor = 1.0 - (float(wild_monster.current_hp) / float(wild_monster.max_hp)) * 0.5
	var card_rate = GameData.get_soul_card_catch_rate(tier)
	var species = MonsterDB.get_species(wild_monster.species_id)
	var rare_penalty = 0.3 if (species and species.is_rare) else 1.0
	var catch_chance = hp_factor * card_rate * rare_penalty * 0.5

	# Shake animation
	for i in range(3):
		battle_ui.show_message("..." + ".".repeat(i))
		await get_tree().create_timer(0.6).timeout

	if randf() < catch_chance:
		battle_active = false
		battle_ui.show_message("Gotcha! %s was caught!" % wild_monster.nickname)
		add_log("Caught %s with %s Soul Card!" % [wild_monster.nickname, tier])
		GameData.add_to_team(wild_monster)
		await get_tree().create_timer(2.0).timeout
		end_battle()
	else:
		battle_ui.show_message("Oh no! It broke free!")
		add_log("Failed to catch %s" % wild_monster.nickname)
		await get_tree().create_timer(1.0).timeout
		await enemy_turn()

func _on_flee_selected():
	if not battle_active:
		return
	var flee_chance = float(player_monster.spd) / float(wild_monster.spd + player_monster.spd)
	flee_chance = clampf(flee_chance, 0.2, 0.9)

	if randf() < flee_chance:
		battle_ui.show_message("Got away safely!")
		add_log("Fled from wild %s" % wild_monster.nickname)
		await get_tree().create_timer(1.0).timeout
		battle_active = false
		end_battle()
	else:
		battle_ui.show_message("Can't escape!")
		add_log("Failed to flee from %s" % wild_monster.nickname)
		await get_tree().create_timer(1.0).timeout
		await enemy_turn()

func end_battle():
	battle_active = false
	battle_ended.emit()
	queue_free()

func add_log(text: String):
	battle_log.append(text)
