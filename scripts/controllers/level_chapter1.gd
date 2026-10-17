extends Node3D

@onready var player: CharacterBody3D = $Player
@onready var meera: CharacterBody3D = $NPCMeera
@onready var flying_paper: Area3D = $FlyingPaper

func _ready() -> void:
	# Start opening monologue for Chapter 1
	var chap := StoryManager.get_chapter_data(1)
	var intro: Array = chap.get("intro_monologue", [])
	
	var timer := get_tree().create_timer(0.6)
	timer.timeout.connect(func():
		StoryManager.start_dialogue(intro)
	)
	
	StoryManager.mission_completed.connect(_on_mission_completed)

func _on_mission_completed(mission_title: String) -> void:
	if mission_title == "The First Meeting":
		# Smooth cinematic pause then chapter progression
		var timer := get_tree().create_timer(3.5)
		timer.timeout.connect(func():
			GameManager.transition_to_chapter(2)
		)
