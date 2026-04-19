extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var camera: Camera2D = $Player/Camera2D

func _ready():
	# Restore player position
	player.global_position = GameData.player_position

func _exit_tree():
	# Save player position when leaving
	if player:
		GameData.player_position = player.global_position
