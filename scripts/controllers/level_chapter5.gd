extends Node3D

@onready var player: CharacterBody3D = $Player
@onready var meera: CharacterBody3D = $NPCMeera

func _ready() -> void:
	StoryManager.choice_selected.connect(_on_choice_made)

func _on_choice_made(_chosen: Dictionary) -> void:
	StoryManager.dialogue_ended.connect(func():
		StoryManager.trigger_mission_complete("Trust Is a Choice")
		var timer := get_tree().create_timer(3.5)
		timer.timeout.connect(func():
			GameManager.transition_to_chapter(6)
		)
	, CONNECT_ONE_SHOT)
