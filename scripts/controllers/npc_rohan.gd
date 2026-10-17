extends CharacterBody3D
class_name NPCRohan

@export var interaction_name: String = "Talk to Rohan"
@onready var prompt_bubble: Label3D = $PromptBubble

func _ready() -> void:
	if prompt_bubble:
		prompt_bubble.text = "💬 " + interaction_name

func interact(_player: Node) -> void:
	GameManager.set_state(GameManager.GameState.DIALOGUE)
	var chap := StoryManager.get_chapter_data(2)
	var events: Dictionary = chap.get("events", {})
	var lines: Array = events.get("with_rohan", [])
	StoryManager.start_dialogue(lines)
	StoryManager.dialogue_ended.connect(_on_dialogue_finished, CONNECT_ONE_SHOT)

func _on_dialogue_finished() -> void:
	GameManager.set_state(GameManager.GameState.EXPLORING)
	# Update objective to go talk to Meera
	var hud := get_tree().root.find_child("HUD", true, false)
	if hud:
		var obj_lbl: Label = hud.find_child("Objective", true, false)
		if obj_lbl:
			obj_lbl.text = "🎯 Go over to Meera's table and say hello!"
