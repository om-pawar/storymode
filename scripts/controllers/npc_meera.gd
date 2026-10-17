extends CharacterBody3D
class_name NPCMeera

@export var interaction_name: String = "Talk to Meera"
@export var chapter_override: int = 0

@onready var character_mesh: Node3D = $CharacterMeshMeera
@onready var prompt_bubble: Label3D = $PromptBubble

var is_talking: bool = false

func _ready() -> void:
	if prompt_bubble:
		prompt_bubble.text = "💬 " + interaction_name
		prompt_bubble.visible = false

func interact(player: Node) -> void:
	if is_talking:
		return
	
	if character_mesh and character_mesh.has_method("look_at_character"):
		character_mesh.look_at_character(player)
	
	is_talking = true
	GameManager.set_state(GameManager.GameState.DIALOGUE)
	
	var active_chapter := chapter_override if chapter_override > 0 else StoryManager.current_chapter_index
	var chap_data := StoryManager.get_chapter_data(active_chapter)
	
	match active_chapter:
		1:
			var events: Dictionary = chap_data.get("events", {})
			var lines: Array = events.get("paper_caught", [])
			StoryManager.start_dialogue(lines)
		2:
			var events: Dictionary = chap_data.get("events", {})
			var lines: Array = events.get("meet_meera", [])
			StoryManager.start_dialogue(lines)
		3:
			var lines: Array = chap_data.get("dialogue", [])
			var choices: Array = chap_data.get("choices", [])
			var post = chap_data.get("post_event", null)
			StoryManager.start_dialogue(lines, choices, post)
		4:
			var lines: Array = chap_data.get("dialogue", [])
			var choices: Array = chap_data.get("choices", [])
			StoryManager.start_dialogue(lines, choices)
		5:
			var lines: Array = chap_data.get("dialogue", [])
			var choices: Array = chap_data.get("choices", [])
			StoryManager.start_dialogue(lines, choices)
		6:
			var lines: Array = chap_data.get("dialogue", [])
			StoryManager.start_dialogue(lines)
		_:
			push_warning("NPCMeera: No dialogue found for chapter ", active_chapter)
	
	StoryManager.dialogue_ended.connect(_on_dialogue_finished, CONNECT_ONE_SHOT)

func _on_dialogue_finished() -> void:
	is_talking = false
	GameManager.set_state(GameManager.GameState.EXPLORING)

func set_prompt_visible(is_visible: bool) -> void:
	if prompt_bubble:
		prompt_bubble.visible = is_visible
