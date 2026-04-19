extends Node

signal scene_changed(scene_name: String)

var current_scene: Node = null
var current_scene_name: String = ""

func _ready():
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)

func change_scene(scene_path: String, scene_name: String = ""):
	call_deferred("_deferred_change_scene", scene_path, scene_name)

func _deferred_change_scene(scene_path: String, scene_name: String):
	if current_scene:
		current_scene.free()
	var new_scene = ResourceLoader.load(scene_path)
	if new_scene:
		current_scene = new_scene.instantiate()
		get_tree().root.add_child(current_scene)
		get_tree().current_scene = current_scene
		current_scene_name = scene_name
		scene_changed.emit(scene_name)
