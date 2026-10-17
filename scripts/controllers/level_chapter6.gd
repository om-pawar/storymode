extends Node3D

@onready var player: CharacterBody3D = $Player
@onready var meera: CharacterBody3D = $NPCMeera

func _ready() -> void:
	StoryManager.dialogue_ended.connect(_on_farewell_finished)

func _on_farewell_finished() -> void:
	StoryManager.trigger_mission_complete("Shevatcha Paaus")
	SaveSystem.current_data["flags"]["gifted_sketchbook"] = true
	SaveSystem.save_game()
	
	# Give emotional space, then reveal the player's earned ending!
	var timer := get_tree().create_timer(3.0)
	timer.timeout.connect(func():
		var _ending_data := StoryManager.evaluate_ending()
	)
