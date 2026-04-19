extends CanvasLayer

signal menu_closed

func _ready():
	$Panel/VBox/TeamBtn.pressed.connect(_on_team)
	$Panel/VBox/BagBtn.pressed.connect(_on_bag)
	$Panel/VBox/SaveBtn.pressed.connect(_on_save)
	$Panel/VBox/CloseBtn.pressed.connect(_on_close)

func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("cancel") or event.is_action_pressed("menu"):
		_on_close()
		get_viewport().set_input_as_handled()

func _on_team():
	var team_menu = preload("res://scenes/ui/team_menu.tscn").instantiate()
	add_child(team_menu)
	team_menu.closed.connect(func(): team_menu.queue_free())

func _on_bag():
	# Show bag contents
	var bag_panel = Panel.new()
	bag_panel.set_anchors_preset(Control.PRESET_CENTER)
	bag_panel.custom_minimum_size = Vector2(300, 200)
	bag_panel.position = Vector2(170, 140)
	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("margin_left", 10)
	vbox.add_theme_constant_override("margin_top", 10)
	bag_panel.add_child(vbox)

	var title = Label.new()
	title.text = "== Bag =="
	vbox.add_child(title)

	for item_name in GameData.items:
		var hbox = HBoxContainer.new()
		var lbl = Label.new()
		lbl.text = "%s x%d" % [item_name.capitalize(), GameData.items[item_name]]
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.add_child(lbl)
		var use_btn = Button.new()
		use_btn.text = "Use"
		use_btn.disabled = GameData.items.get(item_name, 0) <= 0
		var iname = item_name
		use_btn.pressed.connect(func(): _pick_monster_for_item(iname, bag_panel))
		hbox.add_child(use_btn)
		vbox.add_child(hbox)

	var sep = Label.new()
	sep.text = "-- Soul Cards --"
	vbox.add_child(sep)

	for tier in GameData.soul_cards:
		var lbl = Label.new()
		lbl.text = "%s Soul Card x%d" % [tier.capitalize(), GameData.soul_cards[tier]]
		vbox.add_child(lbl)

	var close_btn = Button.new()
	close_btn.text = "Close"
	close_btn.pressed.connect(func(): bag_panel.queue_free())
	vbox.add_child(close_btn)

	add_child(bag_panel)

func _pick_monster_for_item(item_name: String, bag_panel: Panel):
	var picker = Panel.new()
	picker.custom_minimum_size = Vector2(260, 160)
	picker.position = Vector2(190, 160)
	var pvbox = VBoxContainer.new()
	pvbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	pvbox.add_theme_constant_override("margin_left", 8)
	pvbox.add_theme_constant_override("margin_top", 8)
	picker.add_child(pvbox)

	var title = Label.new()
	title.text = "Use %s on:" % item_name.capitalize()
	pvbox.add_child(title)

	for mon in GameData.team:
		var btn = Button.new()
		btn.text = "%s  %d/%d HP" % [mon.nickname, mon.current_hp, mon.max_hp]
		btn.disabled = mon.current_hp >= mon.max_hp
		var m = mon
		btn.pressed.connect(func():
			if GameData.use_item(item_name):
				match item_name:
					"potion":
						m.current_hp = mini(m.current_hp + 20, m.max_hp)
			picker.queue_free()
			bag_panel.queue_free()
			_on_bag()
		)
		pvbox.add_child(btn)

	var cancel_btn = Button.new()
	cancel_btn.text = "Cancel"
	cancel_btn.pressed.connect(func(): picker.queue_free())
	pvbox.add_child(cancel_btn)

	add_child(picker)

func _on_save():
	var success = SaveManager.save_game()
	var msg = Label.new()
	msg.text = "Game Saved!" if success else "Save Failed!"
	msg.set_anchors_preset(Control.PRESET_CENTER)
	msg.position = Vector2(280, 220)
	add_child(msg)
	await get_tree().create_timer(1.5).timeout
	if is_instance_valid(msg):
		msg.queue_free()

func _on_close():
	menu_closed.emit()
	queue_free()
