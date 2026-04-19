extends CanvasLayer

signal closed

var selected_index := -1

func _ready():
	refresh_list()

func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("cancel"):
		closed.emit()
		get_viewport().set_input_as_handled()

func refresh_list():
	var vbox = $Panel/VBox
	for child in vbox.get_children():
		child.queue_free()

	var title = Label.new()
	title.text = "== Team =="
	vbox.add_child(title)

	for i in range(GameData.team.size()):
		var mon = GameData.team[i]
		var species = MonsterDB.get_species(mon.species_id)
		var btn = Button.new()
		var type_name = TypeChart.get_type_name(mon.type) if species else "???"
		btn.text = "%d. %s Lv.%d  HP:%d/%d  [%s]" % [i + 1, mon.nickname, mon.level, mon.current_hp, mon.max_hp, type_name]
		var idx = i
		btn.pressed.connect(func(): _on_monster_selected(idx))
		vbox.add_child(btn)

	if GameData.team.is_empty():
		var lbl = Label.new()
		lbl.text = "No monsters in team!"
		vbox.add_child(lbl)

	var close_btn = Button.new()
	close_btn.text = "Close"
	close_btn.pressed.connect(func(): closed.emit())
	vbox.add_child(close_btn)

func _on_monster_selected(idx: int):
	if selected_index < 0:
		selected_index = idx
		show_monster_details(idx)
	else:
		# Swap monsters
		if selected_index != idx:
			GameData.swap_team_monster(selected_index, idx)
		selected_index = -1
		refresh_list()

func show_monster_details(idx: int):
	var mon = GameData.team[idx]
	var species = MonsterDB.get_species(mon.species_id)

	var detail_panel = Panel.new()
	detail_panel.name = "DetailPanel"
	detail_panel.custom_minimum_size = Vector2(300, 250)
	detail_panel.position = Vector2(170, 100)

	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("margin_left", 10)
	vbox.add_theme_constant_override("margin_top", 10)
	detail_panel.add_child(vbox)

	var name_lbl = Label.new()
	name_lbl.text = "%s (Lv.%d)" % [mon.nickname, mon.level]
	vbox.add_child(name_lbl)

	if species:
		var type_lbl = Label.new()
		type_lbl.text = "Type: %s" % TypeChart.get_type_name(mon.type)
		vbox.add_child(type_lbl)

		var desc_lbl = Label.new()
		desc_lbl.text = species.description
		desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		vbox.add_child(desc_lbl)

	var stats_lbl = Label.new()
	stats_lbl.text = "HP: %d/%d | ATK: %d | DEF: %d | SPD: %d" % [mon.current_hp, mon.max_hp, mon.atk, mon.def_stat, mon.spd]
	vbox.add_child(stats_lbl)

	var xp_lbl = Label.new()
	xp_lbl.text = "XP: %d / %d" % [mon.xp, mon.xp_to_next_level()]
	vbox.add_child(xp_lbl)

	var atk_title = Label.new()
	atk_title.text = "-- Attacks --"
	vbox.add_child(atk_title)

	for attack_id in mon.attacks:
		var atk = MonsterDB.get_attack(attack_id)
		if atk:
			var atk_lbl = Label.new()
			atk_lbl.text = "%s [%s] Pow:%d Acc:%d" % [atk.name, TypeChart.get_type_name(atk.type), atk.power, atk.accuracy]
			vbox.add_child(atk_lbl)

	if species and species.evolution_id != "":
		var evo_lbl = Label.new()
		var evo_species = MonsterDB.get_species(species.evolution_id)
		evo_lbl.text = "Evolves into %s at Lv.%d" % [evo_species.name if evo_species else species.evolution_id, species.evolution_level]
		vbox.add_child(evo_lbl)

	var swap_btn = Button.new()
	swap_btn.text = "Swap Position (select another)"
	swap_btn.pressed.connect(func():
		detail_panel.queue_free()
	)
	vbox.add_child(swap_btn)

	var close_btn = Button.new()
	close_btn.text = "Back"
	close_btn.pressed.connect(func():
		selected_index = -1
		detail_panel.queue_free()
	)
	vbox.add_child(close_btn)

	add_child(detail_panel)
