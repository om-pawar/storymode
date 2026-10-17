extends Node

signal chapter_started(chapter_data: Dictionary)
signal dialogue_started(dialogue_list: Array)
signal dialogue_line(data: Dictionary)
signal dialogue_ended()
signal choice_requested(choices: Array)
signal choice_selected(choice_data: Dictionary)
signal mission_completed(mission_title: String)
signal phone_chat_started(messages: Array)
signal ending_triggered(ending_data: Dictionary)

var story_data: Dictionary = {}
var current_chapter_index := 1
var is_in_dialogue := false
var current_dialogue_queue: Array = []
var current_dialogue_index := -1
var pending_choices: Array = []
var pending_post_event = null

func _ready() -> void:
	_load_story_data()

func _load_story_data() -> void:
	var path := "res://scripts/data/story_data.json"
	if not FileAccess.file_exists(path):
		push_error("StoryManager: story_data.json not found at " + path)
		return
	
	var file := FileAccess.open(path, FileAccess.READ)
	var content := file.get_as_text()
	file.close()
	
	var json := JSON.new()
	var err := json.parse(content)
	if err == OK:
		story_data = json.data
		print("StoryManager: Loaded story database with ", story_data.get("chapters", {}).size(), " chapters.")
	else:
		push_error("StoryManager: Failed to parse story_data.json: " + json.get_error_message())

func get_chapter_data(chapter_id: int) -> Dictionary:
	var chapters: Dictionary = story_data.get("chapters", {})
	var key := str(chapter_id)
	if chapters.has(key):
		return chapters[key]
	return {}

func start_chapter(chapter_id: int) -> void:
	current_chapter_index = chapter_id
	SaveSystem.current_data["current_chapter"] = chapter_id
	SaveSystem.save_game()
	
	var chap := get_chapter_data(chapter_id)
	if chap.is_empty():
		push_error("StoryManager: Chapter not found: " + str(chapter_id))
		return
	
	print("StoryManager: Starting ", chap.get("title", ""))
	AudioManager.play_bgm(chap.get("bgm", "rain_melancholy"))
	AudioManager.play_ambient(chap.get("ambient", "monsoon_rain"))
	
	chapter_started.emit(chap)

func start_dialogue(lines: Array, choices: Array = [], post_event = null) -> void:
	if lines.is_empty():
		return
	
	is_in_dialogue = true
	current_dialogue_queue = lines.duplicate()
	current_dialogue_index = -1
	pending_choices = choices.duplicate()
	pending_post_event = post_event
	
	dialogue_started.emit(lines)
	advance_dialogue()

func advance_dialogue() -> void:
	if not is_in_dialogue:
		return
	
	current_dialogue_index += 1
	if current_dialogue_index < current_dialogue_queue.size():
		var line_data: Dictionary = current_dialogue_queue[current_dialogue_index]
		AudioManager.play_sfx("dialogue_blip")
		dialogue_line.emit(line_data)
	else:
		# Dialogue lines exhausted
		if not pending_choices.is_empty():
			# Show choices
			var choices := pending_choices.duplicate()
			pending_choices.clear()
			choice_requested.emit(choices)
		else:
			_finish_dialogue()

func _finish_dialogue() -> void:
	is_in_dialogue = false
	current_dialogue_queue.clear()
	current_dialogue_index = -1
	dialogue_ended.emit()
	
	if pending_post_event != null:
		var post = pending_post_event
		pending_post_event = null
		if post is Array:
			start_dialogue(post)
		elif post is Dictionary:
			start_dialogue([post])

func select_choice(choice_index: int, choices: Array) -> void:
	if choice_index < 0 or choice_index >= choices.size():
		return
	
	var chosen: Dictionary = choices[choice_index]
	AudioManager.play_sfx("choice_select")
	
	# Apply effects
	var effects: Dictionary = chosen.get("effects", {})
	for stat in ["affection", "trust", "friendship", "insecurity", "romance"]:
		if effects.has(stat):
			var current_val: int = SaveSystem.current_data.get(stat, 0)
			SaveSystem.current_data[stat] = clamp(current_val + effects[stat], 0, 100)
			print("Stat changed: ", stat, " -> ", SaveSystem.current_data[stat])
	
	# Apply flags
	var flags: Dictionary = SaveSystem.current_data.get("flags", {})
	for key in effects.keys():
		if key not in ["affection", "trust", "friendship", "insecurity", "romance"]:
			flags[key] = effects[key]
	SaveSystem.current_data["flags"] = flags
	SaveSystem.save_game()
	
	choice_selected.emit(chosen)
	
	# If this choice has a follow-up response dialogue:
	var response: Array = chosen.get("response", [])
	if not response.is_empty():
		start_dialogue(response, [], pending_post_event)
	elif pending_post_event != null:
		var post = pending_post_event
		pending_post_event = null
		if post is Array:
			start_dialogue(post)
		elif post is Dictionary:
			start_dialogue([post])
	else:
		_finish_dialogue()

func trigger_mission_complete(mission_title: String) -> void:
	var completed: Array = SaveSystem.current_data.get("completed_missions", [])
	if mission_title not in completed:
		completed.append(mission_title)
		SaveSystem.current_data["completed_missions"] = completed
		SaveSystem.save_game()
	
	AudioManager.play_sfx("mission_complete")
	mission_completed.emit(mission_title)

func evaluate_ending() -> Dictionary:
	var affection: int = SaveSystem.current_data.get("affection", 0)
	var trust: int = SaveSystem.current_data.get("trust", 0)
	var insecurity: int = SaveSystem.current_data.get("insecurity", 0)
	var friendship: int = SaveSystem.current_data.get("friendship", 0)
	
	var endings: Dictionary = story_data.get("endings", {})
	var chosen_id := "1"
	
	if insecurity >= 35 or trust < 30:
		chosen_id = "4" # Punha Anolakhi (Strangers Again)
	elif affection >= 60 and trust >= 60 and insecurity < 30:
		chosen_id = "1" # Aapla Prem (Our Love)
	elif affection >= 40 and trust >= 40:
		chosen_id = "2" # Antar (Distance)
	else:
		chosen_id = "3" # Apuri Goshta (Unfinished Story)
	
	var ending_data: Dictionary = endings.get(chosen_id, {})
	
	var unlocked: Array = SaveSystem.current_data.get("unlocked_endings", [])
	if chosen_id not in unlocked:
		unlocked.append(chosen_id)
		SaveSystem.current_data["unlocked_endings"] = unlocked
	SaveSystem.current_data["flags"]["unlocked_ending"] = ending_data.get("title", "")
	SaveSystem.save_game()
	
	ending_triggered.emit(ending_data)
	return ending_data
