extends CharacterBody2D

signal interacted

const SPEED := 120.0
const TILE_SIZE := 32

var is_moving := false
var input_enabled := true
var facing_direction := Vector2.DOWN

@onready var sprite: ColorRect = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var ray_cast: RayCast2D = $RayCast2D

func _ready():
	update_ray_cast()

func _physics_process(_delta: float):
	if not input_enabled:
		velocity = Vector2.ZERO
		return

	var input_dir := Vector2.ZERO
	if Input.is_action_pressed("move_up"):
		input_dir = Vector2.UP
	elif Input.is_action_pressed("move_down"):
		input_dir = Vector2.DOWN
	elif Input.is_action_pressed("move_left"):
		input_dir = Vector2.LEFT
	elif Input.is_action_pressed("move_right"):
		input_dir = Vector2.RIGHT

	if input_dir != Vector2.ZERO:
		facing_direction = input_dir
		update_ray_cast()
		velocity = input_dir * SPEED
		update_animation(input_dir)
	else:
		velocity = Vector2.ZERO
		update_idle_animation()

	move_and_slide()

func _unhandled_input(event: InputEvent):
	if not input_enabled:
		return
	if event.is_action_pressed("interact"):
		interact()
	elif event.is_action_pressed("menu"):
		open_menu()

func interact():
	ray_cast.force_raycast_update()
	if ray_cast.is_colliding():
		var collider = ray_cast.get_collider()
		if collider.has_method("on_interact"):
			collider.on_interact()
	interacted.emit()

func open_menu():
	input_enabled = false
	var menu = preload("res://scenes/ui/overworld_menu.tscn").instantiate()
	get_tree().current_scene.add_child(menu)
	menu.menu_closed.connect(func(): input_enabled = true)

func update_ray_cast():
	ray_cast.target_position = facing_direction * 20

func update_animation(direction: Vector2):
	if animation_player and animation_player.has_animation("walk_down"):
		match direction:
			Vector2.UP: animation_player.play("walk_up")
			Vector2.DOWN: animation_player.play("walk_down")
			Vector2.LEFT: animation_player.play("walk_left")
			Vector2.RIGHT: animation_player.play("walk_right")

func update_idle_animation():
	if animation_player and animation_player.has_animation("idle_down"):
		match facing_direction:
			Vector2.UP: animation_player.play("idle_up")
			Vector2.DOWN: animation_player.play("idle_down")
			Vector2.LEFT: animation_player.play("idle_left")
			Vector2.RIGHT: animation_player.play("idle_right")

func set_input_enabled(enabled: bool):
	input_enabled = enabled
	if not enabled:
		velocity = Vector2.ZERO
