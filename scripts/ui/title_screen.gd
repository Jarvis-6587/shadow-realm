extends Control

func _ready():
	$VBox/NewGameBtn.pressed.connect(_on_new_game)
	$VBox/ContinueBtn.pressed.connect(_on_continue)
	$VBox/ContinueBtn.disabled = not SaveManager.has_save()

func _on_new_game():
	# Show starter selection
	show_starter_selection()

func _on_continue():
	if SaveManager.load_game():
		start_game()

func show_starter_selection():
	$VBox.visible = false
	var starter_panel = VBoxContainer.new()
	starter_panel.name = "StarterPanel"
	starter_panel.set_anchors_preset(Control.PRESET_CENTER)

	var title = Label.new()
	title.text = "Choose your first monster!"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	starter_panel.add_child(title)

	var starters = MonsterDB.get_starter_options()
	for species_id in starters:
		var species = MonsterDB.get_species(species_id)
		if species:
			var btn = Button.new()
			btn.text = "%s [%s] - %s" % [species.name, TypeChart.get_type_name(species.type), species.description]
			btn.custom_minimum_size = Vector2(400, 40)
			var sid = species_id
			btn.pressed.connect(func(): select_starter(sid))
			starter_panel.add_child(btn)

	add_child(starter_panel)

func select_starter(species_id: String):
	var starter = GameData.MonsterInstance.create(species_id, 5)
	GameData.team.clear()
	GameData.team.append(starter)
	GameData.player_position = Vector2(160, 240)
	GameData.current_map = "town"
	start_game()

func start_game():
	get_tree().change_scene_to_file("res://scenes/overworld/overworld.tscn")
