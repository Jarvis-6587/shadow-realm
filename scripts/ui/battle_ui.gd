extends Control

signal attack_selected(attack_idx: int)
signal soul_card_selected(tier: String)
signal flee_selected

var player_mon: GameData.MonsterInstance
var wild_mon: GameData.MonsterInstance

@onready var message_label: Label = $MessagePanel/MessageLabel
@onready var action_panel: VBoxContainer = $ActionPanel
@onready var attack_panel: VBoxContainer = $AttackPanel
@onready var soul_card_panel: VBoxContainer = $SoulCardPanel
@onready var player_hp_bar: ProgressBar = $PlayerPanel/HPBar
@onready var player_name_label: Label = $PlayerPanel/NameLabel
@onready var player_level_label: Label = $PlayerPanel/LevelLabel
@onready var player_hp_label: Label = $PlayerPanel/HPLabel
@onready var enemy_hp_bar: ProgressBar = $EnemyPanel/HPBar
@onready var enemy_name_label: Label = $EnemyPanel/NameLabel
@onready var enemy_level_label: Label = $EnemyPanel/LevelLabel
@onready var player_sprite: ColorRect = $PlayerSprite
@onready var enemy_sprite: ColorRect = $EnemySprite

func setup(player: GameData.MonsterInstance, wild: GameData.MonsterInstance):
	player_mon = player
	wild_mon = wild
	update_stats(player, wild)

	# Set sprite colors based on monster
	var p_species = MonsterDB.get_species(player.species_id)
	var w_species = MonsterDB.get_species(wild.species_id)
	if p_species:
		player_sprite.color = p_species.sprite_color
	if w_species:
		enemy_sprite.color = w_species.sprite_color

func update_stats(player: GameData.MonsterInstance, wild: GameData.MonsterInstance):
	player_mon = player
	wild_mon = wild

	player_name_label.text = player.nickname
	player_level_label.text = "Lv.%d" % player.level
	player_hp_bar.max_value = player.max_hp
	player_hp_bar.value = player.current_hp
	player_hp_label.text = "%d/%d" % [player.current_hp, player.max_hp]

	enemy_name_label.text = wild.nickname
	enemy_level_label.text = "Lv.%d" % wild.level
	enemy_hp_bar.max_value = wild.max_hp
	enemy_hp_bar.value = wild.current_hp

func show_message(text: String):
	message_label.text = text
	action_panel.visible = false
	attack_panel.visible = false
	soul_card_panel.visible = false

func show_actions():
	action_panel.visible = true
	attack_panel.visible = false
	soul_card_panel.visible = false

func _on_fight_pressed():
	action_panel.visible = false
	attack_panel.visible = true
	# Populate attack buttons
	for child in attack_panel.get_children():
		child.queue_free()
	for i in range(player_mon.attacks.size()):
		var atk = MonsterDB.get_attack(player_mon.attacks[i])
		if atk:
			var btn = Button.new()
			btn.text = "%s (%s, Pow:%d)" % [atk.name, TypeChart.get_type_name(atk.type), atk.power]
			var idx = i
			btn.pressed.connect(func(): _on_attack_btn(idx))
			attack_panel.add_child(btn)
	var back_btn = Button.new()
	back_btn.text = "Back"
	back_btn.pressed.connect(func(): show_actions())
	attack_panel.add_child(back_btn)

func _on_attack_btn(idx: int):
	attack_panel.visible = false
	attack_selected.emit(idx)

func _on_soul_card_pressed():
	action_panel.visible = false
	soul_card_panel.visible = true
	for child in soul_card_panel.get_children():
		child.queue_free()
	for tier in ["normal", "silver", "gold"]:
		var count = GameData.soul_cards.get(tier, 0)
		var btn = Button.new()
		btn.text = "%s Soul Card (x%d)" % [tier.capitalize(), count]
		btn.disabled = count <= 0
		var t = tier
		btn.pressed.connect(func(): _on_card_btn(t))
		soul_card_panel.add_child(btn)
	var back_btn = Button.new()
	back_btn.text = "Back"
	back_btn.pressed.connect(func(): show_actions())
	soul_card_panel.add_child(back_btn)

func _on_card_btn(tier: String):
	soul_card_panel.visible = false
	soul_card_selected.emit(tier)

func _on_flee_pressed():
	action_panel.visible = false
	flee_selected.emit()

func shake_sprite(is_enemy: bool):
	var target = enemy_sprite if is_enemy else player_sprite
	var original_pos = target.position
	var tween = create_tween()
	tween.tween_property(target, "position", original_pos + Vector2(5, 0), 0.05)
	tween.tween_property(target, "position", original_pos - Vector2(5, 0), 0.05)
	tween.tween_property(target, "position", original_pos + Vector2(3, 0), 0.05)
	tween.tween_property(target, "position", original_pos, 0.05)
