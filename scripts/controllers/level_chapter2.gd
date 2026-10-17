extends Node3D

@onready var player: CharacterBody3D = $Player
@onready var meera: CharacterBody3D = $NPCMeera
@onready var rohan: CharacterBody3D = $NPCRohan

func _ready() -> void:
	StoryManager.dialogue_ended.connect(_on_dialogue_ended)

func _on_dialogue_ended() -> void:
	# Check if player just finished talking with Meera in Ch 2
	if meera and meera.is_talking == false and not SaveSystem.current_data["flags"].get("phone_chat_ch2", false):
		var hud := get_tree().root.find_child("HUD", true, false)
		var phone_ui := get_tree().root.find_child("PhoneUI", true, false)
		
		# Give a short breather, then trigger the evening SMS
		var timer := get_tree().create_timer(1.5)
		timer.timeout.connect(func():
			if phone_ui:
				SaveSystem.current_data["flags"]["phone_chat_ch2"] = true
				SaveSystem.save_game()
				
				var chap := StoryManager.get_chapter_data(2)
				var events: Dictionary = chap.get("events", {})
				var messages: Array = events.get("phone_chat", [])
				
				phone_ui.start_chat_sequence(messages, "Meera 🌸", func():
					StoryManager.trigger_mission_complete("Chaha Ani Gappa")
					var trans_timer := get_tree().create_timer(3.0)
					trans_timer.timeout.connect(func():
						GameManager.transition_to_chapter(3)
					)
				)
		)
