extends Area2D

@export var encounter_rate: float = 0.15  # 15% chance per step
@export var route_name: String = "route_1"
@export var min_level: int = 3
@export var max_level: int = 8

var player_inside := false
var step_counter := 0
var steps_needed := 4  # Check every N steps

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D):
	if body.is_in_group("player"):
		player_inside = true
		step_counter = 0

func _on_body_exited(body: Node2D):
	if body.is_in_group("player"):
		player_inside = false

func _physics_process(_delta: float):
	if not player_inside:
		return
	var player = get_tree().get_first_node_in_group("player")
	if player and player.velocity.length() > 10:
		step_counter += 1
		if step_counter >= steps_needed:
			step_counter = 0
			if randf() < encounter_rate:
				trigger_encounter()

func trigger_encounter():
	if not GameData.has_alive_monster():
		return
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.set_input_enabled(false)

	# Pick a random wild monster
	var available = MonsterDB.get_wild_monsters_for_route(route_name)
	var species_id = available[randi() % available.size()]
	var level = randi_range(min_level, max_level)
	var wild_monster = GameData.MonsterInstance.create(species_id, level)

	# Save player position
	GameData.player_position = player.global_position if player else Vector2.ZERO

	# Start battle
	await get_tree().create_timer(0.3).timeout
	start_battle(wild_monster)

func start_battle(wild_monster):
	var battle_scene = preload("res://scenes/battle/battle.tscn").instantiate()
	battle_scene.wild_monster = wild_monster
	battle_scene.battle_ended.connect(_on_battle_ended)
	get_tree().current_scene.add_child(battle_scene)

func _on_battle_ended():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.set_input_enabled(true)
