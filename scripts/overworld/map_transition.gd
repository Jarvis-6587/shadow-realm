extends Area2D

@export var target_scene: String = ""
@export var target_position: Vector2 = Vector2.ZERO
@export var map_name: String = ""

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D):
	if body.is_in_group("player"):
		GameData.current_map = map_name
		GameData.player_position = target_position
		if target_scene != "":
			get_tree().change_scene_to_file(target_scene)
