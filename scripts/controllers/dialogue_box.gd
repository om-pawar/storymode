extends Control

@onready var panel: PanelContainer = $PanelContainer
@onready var speaker_name_label: Label = $PanelContainer/MarginContainer/VBoxContainer/SpeakerHeader/SpeakerName
@onready var emotion_label: Label = $PanelContainer/MarginContainer/VBoxContainer/SpeakerHeader/EmotionTag
@onready var marathi_text_label: RichTextLabel = $PanelContainer/MarginContainer/VBoxContainer/MarathiText
@onready var english_text_label: RichTextLabel = $PanelContainer/MarginContainer/VBoxContainer/EnglishText
@onready var continue_prompt: Label = $PanelContainer/MarginContainer/VBoxContainer/ContinuePrompt
@onready var choices_container: VBoxContainer = $ChoicesPanel/ChoicesVBox
@onready var choices_panel: PanelContainer = $ChoicesPanel
@onready var portrait_rect: ColorRect = $PanelContainer/MarginContainer/VBoxContainer/SpeakerHeader/PortraitRect
@onready var portrait_initial: Label = $PanelContainer/MarginContainer/VBoxContainer/SpeakerHeader/PortraitRect/InitialLabel

var is_revealing: bool = false
var reveal_progress: float = 0.0
var target_marathi_text: String = ""
var target_english_text: String = ""
var active_choices: Array = []

func _ready() -> void:
	visible = false
	choices_panel.visible = false
	
	StoryManager.dialogue_started.connect(_on_dialogue_started)
	StoryManager.dialogue_line.connect(_on_dialogue_line)
	StoryManager.dialogue_ended.connect(_on_dialogue_ended)
	StoryManager.choice_requested.connect(_on_choice_requested)

func _gui_input(event: InputEvent) -> void:
	if not visible or choices_panel.visible:
		return
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_handle_advance()
	elif event is InputEventScreenTouch and event.pressed:
		_handle_advance()

func _unhandled_input(event: InputEvent) -> void:
	if not visible or choices_panel.visible:
		return
	if event.is_action_pressed("interact"):
		_handle_advance()

func _handle_advance() -> void:
	if is_revealing:
		# Immediately finish typing
		is_revealing = false
		marathi_text_label.visible_characters = -1
		english_text_label.visible_characters = -1
	else:
		StoryManager.advance_dialogue()

func _process(delta: float) -> void:
	if is_revealing:
		reveal_progress += delta * 45.0
		var char_count := int(reveal_progress)
		marathi_text_label.visible_characters = char_count
		english_text_label.visible_characters = char_count
		if char_count >= max(target_marathi_text.length(), target_english_text.length()):
			is_revealing = false
			marathi_text_label.visible_characters = -1
			english_text_label.visible_characters = -1

func _on_dialogue_started(_lines: Array) -> void:
	visible = true
	choices_panel.visible = false

func _on_dialogue_line(data: Dictionary) -> void:
	visible = true
	choices_panel.visible = false
	
	var speaker: String = data.get("speaker", "Narrator")
	speaker_name_label.text = speaker
	
	# Portrait colors & initial
	match speaker:
		"Aarav":
			portrait_rect.color = Color(0.18, 0.38, 0.65)
			portrait_initial.text = "A"
		"Meera":
			portrait_rect.color = Color(0.85, 0.32, 0.45)
			portrait_initial.text = "M"
		"Rohan":
			portrait_rect.color = Color(0.8, 0.55, 0.2)
			portrait_initial.text = "R"
		_:
			portrait_rect.color = Color(0.3, 0.3, 0.4)
			portrait_initial.text = "📖"
	
	var emotion: String = data.get("emotion", "")
	if emotion.is_empty():
		emotion_label.visible = false
	else:
		emotion_label.visible = true
		emotion_label.text = "• " + emotion.capitalize()
	
	target_marathi_text = data.get("marathi", data.get("text", ""))
	target_english_text = data.get("english", "")
	
	marathi_text_label.text = target_marathi_text
	english_text_label.text = target_english_text
	
	# Start typewriter effect
	is_revealing = true
	reveal_progress = 0.0
	marathi_text_label.visible_characters = 0
	english_text_label.visible_characters = 0

func _on_choice_requested(choices: Array) -> void:
	active_choices = choices
	choices_panel.visible = true
	
	# Clear previous choice buttons
	for child in choices_container.get_children():
		child.queue_free()
	
	for i in range(choices.size()):
		var choice_data: Dictionary = choices[i]
		var btn := Button.new()
		btn.text = choice_data.get("label", "Choice " + str(i + 1))
		btn.custom_minimum_size = Vector2(0, 52)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		
		# Stylize button
		var style := StyleBoxFlat.new()
		style.bg_color = Color(0.15, 0.18, 0.26, 0.95)
		style.border_color = Color(0.9, 0.4, 0.5, 0.8)
		style.border_width_left = 4
		style.set_corner_radius_all(8)
		style.set_content_margin_all(12)
		btn.add_theme_stylebox_override("normal", style)
		
		var hover_style := style.duplicate()
		hover_style.bg_color = Color(0.25, 0.3, 0.45, 0.98)
		hover_style.border_color = Color(1.0, 0.55, 0.65, 1.0)
		btn.add_theme_stylebox_override("hover", hover_style)
		btn.add_theme_stylebox_override("pressed", hover_style)
		
		var index := i
		btn.pressed.connect(func():
			choices_panel.visible = false
			StoryManager.select_choice(index, active_choices)
		)
		choices_container.add_child(btn)

func _on_dialogue_ended() -> void:
	visible = false
	choices_panel.visible = false
