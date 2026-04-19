extends CanvasLayer

signal dialogue_finished

@onready var panel: Panel = $Panel
@onready var name_label: Label = $Panel/NameLabel
@onready var text_label: Label = $Panel/TextLabel
@onready var continue_label: Label = $Panel/ContinueLabel

var is_showing := false

func _ready():
	panel.visible = false
	continue_label.text = "[Space/Enter to continue]"

func show_text(speaker: String, text: String):
	name_label.text = speaker
	text_label.text = text
	panel.visible = true
	is_showing = true

	# Disable player input
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.set_input_enabled(false)

func hide_box():
	panel.visible = false
	is_showing = false

func _unhandled_input(event: InputEvent):
	if not is_showing:
		return
	if event.is_action_pressed("interact") or event.is_action_pressed("cancel"):
		dialogue_finished.emit()
		get_viewport().set_input_as_handled()
