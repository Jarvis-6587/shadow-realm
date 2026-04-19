extends CharacterBody2D

@export var npc_name: String = "Villager"
@export var dialogue_lines: Array[String] = ["Hello, traveler!"]
@export var healer: bool = false

var current_line := 0
var is_talking := false

func on_interact():
	if is_talking:
		advance_dialogue()
	else:
		start_dialogue()

func start_dialogue():
	is_talking = true
	current_line = 0
	show_dialogue()

func advance_dialogue():
	current_line += 1
	if current_line >= dialogue_lines.size():
		end_dialogue()
		if healer:
			heal_team()
	else:
		show_dialogue()

func show_dialogue():
	var dialogue_box = get_tree().current_scene.get_node_or_null("DialogueBox")
	if not dialogue_box:
		dialogue_box = preload("res://scenes/ui/dialogue_box.tscn").instantiate()
		dialogue_box.name = "DialogueBox"
		get_tree().current_scene.add_child(dialogue_box)
	dialogue_box.show_text(npc_name, dialogue_lines[current_line])
	dialogue_box.dialogue_finished.connect(_on_dialogue_finished, CONNECT_ONE_SHOT)

func end_dialogue():
	is_talking = false
	var dialogue_box = get_tree().current_scene.get_node_or_null("DialogueBox")
	if dialogue_box:
		dialogue_box.hide_box()
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.set_input_enabled(true)

func heal_team():
	GameData.heal_all_monsters()
	# Show heal message
	var dialogue_box = get_tree().current_scene.get_node_or_null("DialogueBox")
	if not dialogue_box:
		dialogue_box = preload("res://scenes/ui/dialogue_box.tscn").instantiate()
		dialogue_box.name = "DialogueBox"
		get_tree().current_scene.add_child(dialogue_box)
	dialogue_box.show_text(npc_name, "Your monsters have been fully healed!")
	dialogue_box.dialogue_finished.connect(func(): end_dialogue(), CONNECT_ONE_SHOT)

func _on_dialogue_finished():
	advance_dialogue()
