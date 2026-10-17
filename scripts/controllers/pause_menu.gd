extends Control

@onready var resume_btn: Button = $PanelContainer/MarginContainer/VBoxContainer/ResumeBtn
@onready var restart_btn: Button = $PanelContainer/MarginContainer/VBoxContainer/RestartBtn
@onready var save_btn: Button = $PanelContainer/MarginContainer/VBoxContainer/SaveBtn
@onready var quit_btn: Button = $PanelContainer/MarginContainer/VBoxContainer/QuitBtn
@onready var bgm_slider: HSlider = $PanelContainer/MarginContainer/VBoxContainer/AudioSettings/BGMBox/BGMSlider
@onready var sfx_slider: HSlider = $PanelContainer/MarginContainer/VBoxContainer/AudioSettings/SFXBox/SFXSlider
@onready var save_status_label: Label = $PanelContainer/MarginContainer/VBoxContainer/SaveStatusLabel

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	if resume_btn: resume_btn.pressed.connect(_on_resume_pressed)
	if restart_btn: restart_btn.pressed.connect(_on_restart_pressed)
	if save_btn: save_btn.pressed.connect(_on_save_pressed)
	if quit_btn: quit_btn.pressed.connect(_on_quit_pressed)
	
	if bgm_slider:
		bgm_slider.value = SaveSystem.current_data.get("settings", {}).get("bgm_volume", 0.8)
		bgm_slider.value_changed.connect(_on_bgm_changed)
	if sfx_slider:
		sfx_slider.value = SaveSystem.current_data.get("settings", {}).get("sfx_volume", 0.8)
		sfx_slider.value_changed.connect(_on_sfx_changed)

func open_pause_menu() -> void:
	visible = true
	save_status_label.text = ""
	GameManager.pause_game()

func _on_resume_pressed() -> void:
	visible = false
	GameManager.resume_game()

func _on_restart_pressed() -> void:
	visible = false
	GameManager.resume_game()
	GameManager.transition_to_chapter(StoryManager.current_chapter_index)

func _on_save_pressed() -> void:
	var success := SaveSystem.save_game()
	if success:
		save_status_label.text = "✓ Game saved successfully!"
	else:
		save_status_label.text = "✗ Failed to save game."

func _on_quit_pressed() -> void:
	visible = false
	GameManager.quit_to_title()

func _on_bgm_changed(val: float) -> void:
	SaveSystem.current_data["settings"]["bgm_volume"] = val
	var bus_idx := AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(bus_idx, linear_to_db(val))

func _on_sfx_changed(val: float) -> void:
	SaveSystem.current_data["settings"]["sfx_volume"] = val
