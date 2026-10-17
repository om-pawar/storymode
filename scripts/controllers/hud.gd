extends Control

@onready var chapter_title_label: Label = $TopBar/MarginContainer/HBoxContainer/VBoxContainer/ChapterTitle
@onready var location_label: Label = $TopBar/MarginContainer/HBoxContainer/VBoxContainer/Location
@onready var objective_label: Label = $TopBar/MarginContainer/HBoxContainer/VBoxContainer/Objective
@onready var affection_val: Label = $TopBar/MarginContainer/HBoxContainer/StatsBox/AffectionLabel
@onready var trust_val: Label = $TopBar/MarginContainer/HBoxContainer/StatsBox/TrustLabel

@onready var virtual_joystick: Control = $VirtualJoystick
@onready var interact_btn: Button = $ActionControls/InteractBtn
@onready var sprint_btn: Button = $ActionControls/SprintBtn
@onready var pause_btn: Button = $TopRightControls/PauseBtn
@onready var mission_banner: PanelContainer = $MissionBanner
@onready var mission_banner_text: Label = $MissionBanner/MarginContainer/Label

var is_sprint_active: bool = false

func _ready() -> void:
	if interact_btn:
		interact_btn.pressed.connect(_on_interact_pressed)
		interact_btn.visible = false
	if sprint_btn:
		sprint_btn.pressed.connect(_on_sprint_pressed)
	if pause_btn:
		pause_btn.pressed.connect(_on_pause_pressed)
	
	if mission_banner:
		mission_banner.visible = false
	
	StoryManager.chapter_started.connect(_on_chapter_started)
	StoryManager.mission_completed.connect(_on_mission_completed)
	
	# Initial stats refresh
	update_stats_display()

func _process(_delta: float) -> void:
	if virtual_joystick and GameManager.player_node:
		var joy_vec: Vector2 = virtual_joystick.get_value()
		GameManager.player_node.set_virtual_joystick(joy_vec)
	update_stats_display()

func update_stats_display() -> void:
	if affection_val:
		affection_val.text = "❤️ " + str(SaveSystem.current_data.get("affection", 0))
	if trust_val:
		trust_val.text = "🤝 " + str(SaveSystem.current_data.get("trust", 0))

func _on_chapter_started(chap_data: Dictionary) -> void:
	chapter_title_label.text = chap_data.get("title", "")
	location_label.text = "📍 " + chap_data.get("location", "")
	objective_label.text = "🎯 " + chap_data.get("objective", "")
	update_stats_display()

func _on_mission_completed(mission_title: String) -> void:
	if mission_banner and mission_banner_text:
		mission_banner_text.text = "✨ MISSION COMPLETE: " + mission_title.to_upper()
		mission_banner.visible = true
		var tween := create_tween()
		tween.tween_interval(3.5)
		tween.tween_callback(func(): mission_banner.visible = false)

func set_interact_visible(is_visible: bool, prompt_text: String = "Interact") -> void:
	if interact_btn:
		interact_btn.visible = is_visible
		interact_btn.text = "💬 " + prompt_text

func _on_interact_pressed() -> void:
	if GameManager.player_node and GameManager.player_node.has_method("trigger_interaction"):
		GameManager.player_node.trigger_interaction()

func _on_sprint_pressed() -> void:
	is_sprint_active = not is_sprint_active
	if sprint_btn:
		sprint_btn.modulate = Color(1, 0.4, 0.6) if is_sprint_active else Color(1, 1, 1)
	if GameManager.player_node and GameManager.player_node.has_method("set_virtual_sprint"):
		GameManager.player_node.set_virtual_sprint(is_sprint_active)

func _on_pause_pressed() -> void:
	var pause_menu := get_tree().root.find_child("PauseMenu", true, false)
	if pause_menu and pause_menu.has_method("open_pause_menu"):
		pause_menu.open_pause_menu()
	else:
		GameManager.pause_game()
