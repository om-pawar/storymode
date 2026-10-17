extends Node3D

@onready var level_container: Node3D = $LevelContainer
@onready var hud: Control = $UI/HUD
@onready var dialogue_box: Control = $UI/DialogueBox
@onready var phone_ui: Control = $UI/PhoneUI
@onready var pause_menu: Control = $UI/PauseMenu
@onready var ending_screen: Control = $UI/EndingScreen
@onready var screen_fader: ColorRect = $UI/ScreenFader
@onready var main_menu_overlay: Control = $UI/MainMenu

func _ready() -> void:
	screen_fader.modulate = Color(0, 0, 0, 0)
	screen_fader.visible = false
	
	GameManager.screen_fade_requested.connect(_on_screen_fade_requested)
	
	# If launched directly into Main, show MainMenu overlay
	if GameManager.current_state == GameManager.GameState.MAIN_MENU:
		if main_menu_overlay:
			main_menu_overlay.visible = true
		if hud:
			hud.visible = false
	else:
		if main_menu_overlay:
			main_menu_overlay.visible = false
		if hud:
			hud.visible = true
		load_level_scene("res://scenes/environment/levels/chapter1_fc_road.tscn", 1)

func load_level_scene(scene_path: String, chapter_num: int) -> void:
	if main_menu_overlay:
		main_menu_overlay.visible = false
	if hud:
		hud.visible = true
	
	fade_transition(func():
		for child in level_container.get_children():
			child.queue_free()
		
		var level_res := load(scene_path)
		if level_res:
			var level_instance: Node3D = level_res.instantiate()
			level_container.add_child(level_instance)
			GameManager.current_level_node = level_instance
			StoryManager.start_chapter(chapter_num)
		else:
			push_error("Main: Failed to load level scene at " + scene_path)
	)

func fade_transition(mid_callback: Callable, duration: float = 0.5) -> void:
	screen_fader.visible = true
	var tween := create_tween()
	tween.tween_property(screen_fader, "modulate:a", 1.0, duration)
	tween.tween_callback(mid_callback)
	tween.tween_property(screen_fader, "modulate:a", 0.0, duration)
	tween.tween_callback(func(): screen_fader.visible = false)

func _on_screen_fade_requested(fade_in: bool, duration: float) -> void:
	screen_fader.visible = true
	var target_alpha := 0.0 if fade_in else 1.0
	var tween := create_tween()
	tween.tween_property(screen_fader, "modulate:a", target_alpha, duration)
	if fade_in:
		tween.tween_callback(func(): screen_fader.visible = false)
