extends Node

enum GameState {
	MAIN_MENU,
	EXPLORING,
	DIALOGUE,
	PHONE_CHAT,
	PAUSED,
	ENDING
}

var current_state: GameState = GameState.MAIN_MENU
var player_node: CharacterBody3D = null
var active_camera: Camera3D = null
var current_level_node: Node3D = null

signal state_changed(new_state: GameState)
signal screen_fade_requested(fade_in: bool, duration: float)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func set_state(new_state: GameState) -> void:
	if current_state == new_state:
		return
	current_state = new_state
	state_changed.emit(new_state)
	print("GameManager: State changed to ", GameState.keys()[new_state])

func is_gameplay_active() -> bool:
	return current_state == GameState.EXPLORING

func transition_to_chapter(chapter_num: int) -> void:
	print("GameManager: Transitioning to chapter ", chapter_num)
	set_state(GameState.EXPLORING)
	
	var chap_data := StoryManager.get_chapter_data(chapter_num)
	if chap_data.is_empty():
		push_error("GameManager: Cannot load chapter ", chapter_num)
		return
	
	var scene_path: String = chap_data.get("scene_path", "")
	if ResourceLoader.exists(scene_path):
		var main_root := get_tree().root.get_node_or_null("Main")
		if main_root and main_root.has_method("load_level_scene"):
			main_root.load_level_scene(scene_path, chapter_num)
		else:
			get_tree().change_scene_to_file(scene_path)
	else:
		push_error("GameManager: Scene file not found: ", scene_path)

func pause_game() -> void:
	if current_state != GameState.PAUSED:
		set_state(GameState.PAUSED)
		get_tree().paused = true

func resume_game() -> void:
	if current_state == GameState.PAUSED:
		get_tree().paused = false
		set_state(GameState.EXPLORING)

func quit_to_title() -> void:
	get_tree().paused = false
	set_state(GameState.MAIN_MENU)
	get_tree().change_scene_to_file("res://scenes/main/main.tscn")
