extends Control

@onready var messages_container: VBoxContainer = $PhoneBody/Screen/VBox/ChatScroll/MessagesVBox
@onready var phone_body: PanelContainer = $PhoneBody
@onready var contact_label: Label = $PhoneBody/Screen/VBox/TopHeader/HBox/ContactName
@onready var typing_indicator: Label = $PhoneBody/Screen/VBox/TypingIndicator
@onready var reply_button: Button = $PhoneBody/Screen/VBox/BottomBar/SendBtn

var message_queue: Array = []
var current_step: int = 0
var on_finished_callback: Callable

signal chat_completed()

func _ready() -> void:
	visible = false
	if reply_button:
		reply_button.pressed.connect(_on_reply_pressed)

func start_chat_sequence(messages: Array, contact_name: String = "Meera 🌸", callback: Callable = Callable()) -> void:
	visible = true
	message_queue = messages
	current_step = 0
	on_finished_callback = callback
	contact_label.text = contact_name
	
	# Clear old messages
	for child in messages_container.get_children():
		child.queue_free()
	
	typing_indicator.visible = false
	_process_next_message()

func _process_next_message() -> void:
	if current_step >= message_queue.size():
		typing_indicator.visible = false
		reply_button.text = "Close Phone"
		reply_button.disabled = false
		return
	
	var msg: Dictionary = message_queue[current_step]
	var sender: String = msg.get("sender", "")
	var text: String = msg.get("text", "")
	
	if sender == "Meera":
		# Show typing dots, then spawn bubble
		typing_indicator.visible = true
		reply_button.disabled = true
		var timer := get_tree().create_timer(1.2)
		timer.timeout.connect(func():
			typing_indicator.visible = false
			_add_bubble(text, false)
			AudioManager.play_sfx("phone_chime")
			current_step += 1
			_process_next_message()
		)
	elif sender == "Aarav":
		# Prompt player to tap Send
		reply_button.text = "Send: \"" + text + "\""
		reply_button.disabled = false
	elif sender == "Rohan_Note" or sender == "Aarav_Thought":
		_add_system_note(text)
		current_step += 1
		_process_next_message()

func _on_reply_pressed() -> void:
	if current_step >= message_queue.size():
		visible = false
		chat_completed.emit()
		if on_finished_callback.is_valid():
			on_finished_callback.call()
		return
	
	var msg: Dictionary = message_queue[current_step]
	_add_bubble(msg.get("text", ""), true)
	AudioManager.play_sfx("dialogue_blip")
	current_step += 1
	_process_next_message()

func _add_bubble(text: String, is_player: bool) -> void:
	var bubble := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.set_corner_radius_all(14)
	style.set_content_margin_all(10)
	
	if is_player:
		style.bg_color = Color(0.2, 0.45, 0.75, 0.95)
		bubble.size_flags_horizontal = Control.SIZE_SHRINK_END
	else:
		style.bg_color = Color(0.24, 0.28, 0.38, 0.95)
		bubble.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	
	bubble.add_theme_stylebox_override("panel", style)
	
	var lbl := Label.new()
	lbl.text = text
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl.custom_minimum_size = Vector2(min(text.length() * 10, 240), 0)
	lbl.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	bubble.add_child(lbl)
	
	messages_container.add_child(bubble)

func _add_system_note(text: String) -> void:
	var lbl := Label.new()
	lbl.text = text
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_color_override("font_color", Color(0.9, 0.7, 0.4, 0.9))
	lbl.add_theme_font_size_override("font_size", 12)
	messages_container.add_child(lbl)
