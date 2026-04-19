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
		var lbl = Label.new()
		lbl.text = "%s x%d" % [item_name.capitalize(), GameData.items[item_name]]
		vbox.add_child(lbl)

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
