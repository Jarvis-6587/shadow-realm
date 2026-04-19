extends Node

const SAVE_PATH := "user://shadow_realm_save.json"

func save_game() -> bool:
	var save_data = GameData.to_dict()
	var json_string = JSON.stringify(save_data, "\t")
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(json_string)
		file.close()
		return true
	return false

func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return false
	var json_string = file.get_as_text()
	file.close()
	var json = JSON.new()
	var result = json.parse(json_string)
	if result != OK:
		return false
	var data = json.get_data()
	if data is Dictionary:
		GameData.from_dict(data)
		return true
	return false

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func delete_save():
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
