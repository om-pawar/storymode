extends Node

const SAVE_FILE_PATH := "user://after_the_rain_save.json"

var default_data := {
	"current_chapter": 1,
	"affection": 20,
	"trust": 20,
	"friendship": 30,
	"insecurity": 0,
	"romance": 0,
	"flags": {
		"caught_drawing": false,
		"shared_chai": false,
		"phone_chat_ch2": false,
		"tekdi_choice": "",
		"confessed_love": false,
		"held_hand": false,
		"supported_dreams": false,
		"ch5_choice": "",
		"apologized": false,
		"gifted_sketchbook": false,
		"unlocked_ending": ""
	},
	"completed_missions": [],
	"unlocked_endings": [],
	"settings": {
		"bgm_volume": 0.8,
		"sfx_volume": 0.8,
		"camera_sensitivity": 1.0,
		"touch_controls": true,
		"subtitles_english": true
	}
}

var current_data := {}

func _ready() -> void:
	current_data = default_data.duplicate(true)
	load_game()

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_FILE_PATH)

func save_game() -> bool:
	var file := FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if not file:
		push_error("SaveSystem: Could not open file for writing at " + SAVE_FILE_PATH)
		return false
	
	var json_str := JSON.stringify(current_data, "\t")
	file.store_string(json_str)
	file.close()
	print("SaveSystem: Game successfully saved to " + SAVE_FILE_PATH)
	return true

func load_game() -> bool:
	if not has_save():
		print("SaveSystem: No save file found, using default state.")
		current_data = default_data.duplicate(true)
		return false
	
	var file := FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if not file:
		push_error("SaveSystem: Failed to open save file at " + SAVE_FILE_PATH)
		return false
	
	var content := file.get_as_text()
	file.close()
	
	var json := JSON.new()
	var error := json.parse(content)
	if error != OK:
		push_error("SaveSystem: JSON Parse Error: " + json.get_error_message())
		return false
	
	var loaded: Dictionary = json.data
	# Merge keys with defaults
	for key in default_data.keys():
		if not loaded.has(key):
			loaded[key] = default_data[key]
	current_data = loaded
	print("SaveSystem: Game successfully loaded. Chapter: ", current_data.get("current_chapter", 1))
	return true

func reset_game() -> void:
	current_data = default_data.duplicate(true)
	if has_save():
		var dir := DirAccess.open("user://")
		if dir:
			dir.remove("after_the_rain_save.json")
	print("SaveSystem: Game reset to fresh state.")
