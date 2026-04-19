extends CanvasLayer

signal closed

# Selection state: source is "team" or "box", index is position in that array
var selected_source := ""
var selected_index := -1

func _ready():
	refresh_list()

func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("cancel"):
		if selected_source != "":
			# Cancel selection first
			selected_source = ""
			selected_index = -1
			refresh_list()
		else:
			closed.emit()
		get_viewport().set_input_as_handled()

func refresh_list():
	var vbox = $Panel/VBox
	for child in vbox.get_children():
		child.queue_free()

	# --- Team section ---
	var team_title = Label.new()
	team_title.text = "== Team (%d/%d) ==" % [GameData.team.size(), GameData.MAX_TEAM_SIZE]
	vbox.add_child(team_title)

	if GameData.team.is_empty():
		var lbl = Label.new()
		lbl.text = "No monsters in team!"
		vbox.add_child(lbl)

	for i in range(GameData.team.size()):
		var mon = GameData.team[i]
		var species = MonsterDB.get_species(mon.species_id)
		var btn = Button.new()
		var type_name = TypeChart.get_type_name(mon.type) if species else "???"
		btn.text = "%d. %s Lv.%d  HP:%d/%d  [%s]" % [i + 1, mon.nickname, mon.level, mon.current_hp, mon.max_hp, type_name]
		if selected_source == "team" and selected_index == i:
			btn.disabled = true
			btn.text = "▶ " + btn.text
		var idx = i
		btn.pressed.connect(func(): _on_monster_selected("team", idx))
		vbox.add_child(btn)

	# --- Box section ---
	var sep = HSeparator.new()
	vbox.add_child(sep)

	var box_title = Label.new()
	box_title.text = "== Monster Box (%d) ==" % GameData.monster_box.size()
	vbox.add_child(box_title)

	if GameData.monster_box.is_empty():
		var lbl = Label.new()
		lbl.text = "Box is empty."
		vbox.add_child(lbl)

	for i in range(GameData.monster_box.size()):
		var mon = GameData.monster_box[i]
		var species = MonsterDB.get_species(mon.species_id)
		var btn = Button.new()
		var type_name = TypeChart.get_type_name(mon.type) if species else "???"
		btn.text = "B%d. %s Lv.%d  HP:%d/%d  [%s]" % [i + 1, mon.nickname, mon.level, mon.current_hp, mon.max_hp, type_name]
		if selected_source == "box" and selected_index == i:
			btn.disabled = true
			btn.text = "▶ " + btn.text
		var idx = i
		btn.pressed.connect(func(): _on_monster_selected("box", idx))
		vbox.add_child(btn)

	# --- Hint / Close ---
	var sep2 = HSeparator.new()
	vbox.add_child(sep2)

	if selected_source != "":
		var hint = Label.new()
		hint.text = "Select a target to swap. [Cancel] to deselect."
		vbox.add_child(hint)

	var close_btn = Button.new()
	close_btn.text = "Close"
	close_btn.pressed.connect(func(): closed.emit())
	vbox.add_child(close_btn)

func _on_monster_selected(source: String, idx: int):
	# First click — select the monster and show details
	if selected_source == "":
		selected_source = source
		selected_index = idx
		refresh_list()
		show_monster_details(source, idx)
		return

	# Second click — perform swap / move
	if selected_source == source and selected_index == idx:
		# Clicked same monster → deselect
		selected_source = ""
		selected_index = -1
		refresh_list()
		return

	if selected_source == "team" and source == "team":
		# Swap two team slots
		GameData.swap_team_monster(selected_index, idx)
	elif selected_source == "box" and source == "box":
		# Reorder box: swap two box slots directly
		var temp = GameData.monster_box[selected_index]
		GameData.monster_box[selected_index] = GameData.monster_box[idx]
		GameData.monster_box[idx] = temp
	elif selected_source == "team" and source == "box":
		# Swap team monster with box monster
		GameData.swap_team_and_box(selected_index, idx)
	elif selected_source == "box" and source == "team":
		# Swap box monster with team monster
		GameData.swap_team_and_box(idx, selected_index)

	selected_source = ""
	selected_index = -1
	refresh_list()

func show_monster_details(source: String, idx: int):
	var mon = (GameData.team[idx] if source == "team" else GameData.monster_box[idx])
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

	# If monster is in box and team has space, offer direct move
	if source == "box" and GameData.team.size() < GameData.MAX_TEAM_SIZE:
		var move_btn = Button.new()
		move_btn.text = "Add to Team"
		var box_idx = idx
		move_btn.pressed.connect(func():
			detail_panel.queue_free()
			GameData.move_from_box_to_team(box_idx)
			selected_source = ""
			selected_index = -1
			refresh_list()
		)
		vbox.add_child(move_btn)
	else:
		var swap_btn = Button.new()
		swap_btn.text = "Swap (select target on list)"
		swap_btn.pressed.connect(func():
			detail_panel.queue_free()
		)
		vbox.add_child(swap_btn)

	var close_btn = Button.new()
	close_btn.text = "Back"
	close_btn.pressed.connect(func():
		selected_source = ""
		selected_index = -1
		detail_panel.queue_free()
		refresh_list()
	)
	vbox.add_child(close_btn)

	add_child(detail_panel)
