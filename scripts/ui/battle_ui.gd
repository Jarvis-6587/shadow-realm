extends Control

signal attack_selected(attack_idx: int)
signal soul_card_selected(tier: String)
signal item_selected(item_name: String)
signal flee_selected
signal move_to_forget_selected(slot_idx: int)

var player_mon: GameData.MonsterInstance
var wild_mon: GameData.MonsterInstance

@onready var message_label: Label = $MessagePanel/MessageLabel
@onready var action_panel: VBoxContainer = $ActionPanel
@onready var attack_panel: VBoxContainer = $AttackPanel
@onready var soul_card_panel: VBoxContainer = $SoulCardPanel
@onready var item_panel: VBoxContainer = $ItemPanel
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
	item_panel.visible = false

func show_actions():
	action_panel.visible = true
	attack_panel.visible = false
	soul_card_panel.visible = false
	item_panel.visible = false

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
			var pow_str = "—" if atk.power == 0 else "Pow:%d" % atk.power
			btn.text = "%s (%s, %s)" % [atk.name, TypeChart.get_type_name(atk.type), pow_str]
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

func _on_item_pressed():
	action_panel.visible = false
	item_panel.visible = true
	for child in item_panel.get_children():
		child.queue_free()
	var has_items = false
	for item_name in GameData.items:
		var count = GameData.items.get(item_name, 0)
		var btn = Button.new()
		btn.text = "%s (x%d)" % [item_name.capitalize(), count]
		btn.disabled = count <= 0
		var iname = item_name
		btn.pressed.connect(func(): _on_item_btn(iname))
		item_panel.add_child(btn)
		has_items = true
	if not has_items:
		var lbl = Label.new()
		lbl.text = "No items!"
		item_panel.add_child(lbl)
	var back_btn = Button.new()
	back_btn.text = "Back"
	back_btn.pressed.connect(func(): show_actions())
	item_panel.add_child(back_btn)

func _on_item_btn(item_name: String):
	item_panel.visible = false
	item_selected.emit(item_name)

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

func show_move_replace_choice(mon: GameData.MonsterInstance, new_attack_id: String):
	action_panel.visible = false
	attack_panel.visible = false
	soul_card_panel.visible = false
	item_panel.visible = false
	attack_panel.visible = true
	for child in attack_panel.get_children():
		child.queue_free()
	var new_atk = MonsterDB.get_attack(new_attack_id)
	var new_atk_name = new_atk.name if new_atk else new_attack_id
	for i in range(mon.attacks.size()):
		var atk = MonsterDB.get_attack(mon.attacks[i])
		if atk:
			var btn = Button.new()
			var pow_str2 = "—" if atk.power == 0 else "Pow:%d" % atk.power
			btn.text = "Forget %s (%s, %s)" % [atk.name, TypeChart.get_type_name(atk.type), pow_str2]
			var idx = i
			btn.pressed.connect(func(): _on_forget_btn(idx))
			attack_panel.add_child(btn)
	var skip_btn = Button.new()
	skip_btn.text = "Don't learn %s" % new_atk_name
	skip_btn.pressed.connect(func(): _on_forget_btn(-1))
	attack_panel.add_child(skip_btn)

func _on_forget_btn(slot_idx: int):
	attack_panel.visible = false
	move_to_forget_selected.emit(slot_idx)

func shake_sprite(is_enemy: bool):
	var target = enemy_sprite if is_enemy else player_sprite
	var original_pos = target.position
	var tween = create_tween()
	tween.tween_property(target, "position", original_pos + Vector2(5, 0), 0.05)
	tween.tween_property(target, "position", original_pos - Vector2(5, 0), 0.05)
	tween.tween_property(target, "position", original_pos + Vector2(3, 0), 0.05)
	tween.tween_property(target, "position", original_pos, 0.05)
