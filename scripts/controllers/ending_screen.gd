extends Control

@onready var ending_title_label: Label = $PanelContainer/MarginContainer/VBoxContainer/EndingTitle
@onready var ending_summary_label: Label = $PanelContainer/MarginContainer/VBoxContainer/EndingSummary
@onready var epilogue_scroll: ScrollContainer = $PanelContainer/MarginContainer/VBoxContainer/EpilogueScroll
@onready var epilogue_text: RichTextLabel = $PanelContainer/MarginContainer/VBoxContainer/EpilogueScroll/EpilogueText
@onready var stats_summary: Label = $PanelContainer/MarginContainer/VBoxContainer/StatsSummary
@onready var view_final_btn: Button = $PanelContainer/MarginContainer/VBoxContainer/ButtonHBox/ViewFinalSceneBtn
@onready var restart_btn: Button = $PanelContainer/MarginContainer/VBoxContainer/ButtonHBox/RestartBtn
@onready var title_btn: Button = $PanelContainer/MarginContainer/VBoxContainer/ButtonHBox/TitleBtn

var current_ending_data: Dictionary = {}

func _ready() -> void:
	visible = false
	if view_final_btn: view_final_btn.pressed.connect(_on_view_final_scene)
	if restart_btn: restart_btn.pressed.connect(_on_restart_pressed)
	if title_btn: title_btn.pressed.connect(_on_title_pressed)
	
	StoryManager.ending_triggered.connect(display_ending)

func display_ending(ending_data: Dictionary) -> void:
	current_ending_data = ending_data
	visible = true
	GameManager.set_state(GameManager.GameState.ENDING)
	
	ending_title_label.text = ending_data.get("title", "Ending")
	ending_summary_label.text = ending_data.get("summary", "")
	
	var epilogue_paragraphs: Array = ending_data.get("epilogue", [])
	var combined_text := ""
	for p in epilogue_paragraphs:
		combined_text += p + "\n\n"
	epilogue_text.text = combined_text
	
	var aff: int = SaveSystem.current_data.get("affection", 0)
	var tru: int = SaveSystem.current_data.get("trust", 0)
	var insec: int = SaveSystem.current_data.get("insecurity", 0)
	stats_summary.text = "Final Bond: ❤️ Affection %d | 🤝 Trust %d | ⚠️ Insecurity %d" % [aff, tru, insec]

func _on_view_final_scene() -> void:
	# Show the final epilogue scene: Several months later, Pune chai tapri SMS
	var phone_ui := get_tree().root.find_child("PhoneUI", true, false)
	if phone_ui:
		var final_scene_data: Dictionary = StoryManager.story_data.get("final_scene", {})
		var dialog_items: Array = final_scene_data.get("dialogue", [])
		var messages := []
		for item in dialog_items:
			if item.get("speaker") == "Phone":
				messages.append({
					"sender": item.get("sender"),
					"text": item.get("text")
				})
			else:
				messages.append({
					"sender": "Aarav_Thought",
					"text": item.get("text")
				})
		
		visible = false
		phone_ui.start_chat_sequence(messages, "Meera 🌸", func():
			visible = true
		)

func _on_restart_pressed() -> void:
	visible = false
	SaveSystem.reset_game()
	GameManager.transition_to_chapter(1)

func _on_title_pressed() -> void:
	visible = false
	GameManager.quit_to_title()
