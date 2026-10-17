extends Control

@onready var continue_btn: Button = $MenuVBox/ContinueBtn
@onready var new_game_btn: Button = $MenuVBox/NewGameBtn
@onready var chapter_select_btn: Button = $MenuVBox/ChapterSelectBtn
@onready var credits_btn: Button = $MenuVBox/CreditsBtn
@onready var quit_btn: Button = $MenuVBox/QuitBtn

@onready var chapter_modal: PanelContainer = $ChapterSelectModal
@onready var chapter_list: VBoxContainer = $ChapterSelectModal/MarginContainer/VBoxContainer/ScrollContainer/ChapterList
@onready var modal_close_btn: Button = $ChapterSelectModal/MarginContainer/VBoxContainer/CloseBtn

@onready var credits_modal: PanelContainer = $CreditsModal
@onready var credits_close_btn: Button = $CreditsModal/MarginContainer/VBoxContainer/CloseBtn

func _ready() -> void:
	AudioManager.play_bgm("rain_melancholy")
	AudioManager.play_ambient("monsoon_rain")
	
	if chapter_modal: chapter_modal.visible = false
	if credits_modal: credits_modal.visible = false
	
	new_game_btn.pressed.connect(_on_new_game)
	chapter_select_btn.pressed.connect(_on_chapter_select)
	credits_btn.pressed.connect(_on_credits)
	quit_btn.pressed.connect(_on_quit)
	
	if modal_close_btn: modal_close_btn.pressed.connect(func(): chapter_modal.visible = false)
	if credits_close_btn: credits_close_btn.pressed.connect(func(): credits_modal.visible = false)
	
	var has_save := SaveSystem.has_save()
	continue_btn.disabled = not has_save
	if has_save:
		continue_btn.text = "Continue (Chapter %d)" % SaveSystem.current_data.get("current_chapter", 1)
		continue_btn.pressed.connect(_on_continue)
	
	_build_chapter_buttons()

func _on_new_game() -> void:
	SaveSystem.reset_game()
	GameManager.transition_to_chapter(1)

func _on_continue() -> void:
	var chap: int = SaveSystem.current_data.get("current_chapter", 1)
	GameManager.transition_to_chapter(chap)

func _on_chapter_select() -> void:
	chapter_modal.visible = true

func _on_credits() -> void:
	credits_modal.visible = true

func _on_quit() -> void:
	get_tree().quit()

func _build_chapter_buttons() -> void:
	for child in chapter_list.get_children():
		child.queue_free()
	
	var chapters: Dictionary = StoryManager.story_data.get("chapters", {})
	for i in range(1, 7):
		var key := str(i)
		if chapters.has(key):
			var data: Dictionary = chapters[key]
			var btn := Button.new()
			btn.text = data.get("title", "Chapter " + str(i))
			btn.custom_minimum_size = Vector2(0, 44)
			btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
			var chap_num := i
			btn.pressed.connect(func():
				chapter_modal.visible = false
				SaveSystem.current_data["current_chapter"] = chap_num
				SaveSystem.save_game()
				GameManager.transition_to_chapter(chap_num)
			)
			chapter_list.add_child(btn)
