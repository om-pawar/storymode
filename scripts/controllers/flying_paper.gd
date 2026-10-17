extends Area3D

@export var interaction_name: String = "Catch Flying Drawing"
@onready var prompt_bubble: Label3D = $PromptBubble
@onready var mesh: MeshInstance3D = $PaperMesh

var time_passed: float = 0.0
var initial_pos: Vector3
var is_collected: bool = false

func _ready() -> void:
	initial_pos = position
	if prompt_bubble:
		prompt_bubble.text = "📄 " + interaction_name

func _process(delta: float) -> void:
	if is_collected:
		return
	time_passed += delta
	# Floating/fluttering in wind animation
	position.y = initial_pos.y + sin(time_passed * 3.5) * 0.15
	rotation.y += delta * 1.2
	rotation.z = sin(time_passed * 2.0) * 0.2

func interact(player: Node) -> void:
	if is_collected:
		return
	is_collected = true
	AudioManager.play_sfx("paper_caught")
	
	SaveSystem.current_data["flags"]["caught_drawing"] = true
	SaveSystem.save_game()
	
	visible = false
	collision_layer = 0
	
	# Start dialogue with Meera
	var npc_meera := get_tree().root.find_child("NPCMeera", true, false)
	if npc_meera and npc_meera.has_method("interact"):
		npc_meera.interact(player)
	else:
		var chap := StoryManager.get_chapter_data(1)
		var events: Dictionary = chap.get("events", {})
		StoryManager.start_dialogue(events.get("paper_caught", []))
	
	# When dialogue ends, trigger mission complete!
	StoryManager.dialogue_ended.connect(func():
		StoryManager.trigger_mission_complete("The First Meeting")
	, CONNECT_ONE_SHOT)
