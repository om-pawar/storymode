extends Control
class_name VirtualJoystickTouch

@export var max_distance: float = 75.0
@export var deadzone: float = 10.0

var output_vector: Vector2 = Vector2.ZERO
var is_dragging: bool = false
var touch_index: int = -1

@onready var base: TextureRect = $Base
@onready var tip: TextureRect = $Base/Tip

var base_radius: float

func _ready() -> void:
	base_radius = max_distance

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			if not is_dragging:
				is_dragging = true
				touch_index = event.index
				_update_tip(event.position)
		elif event.index == touch_index:
			_reset_joystick()
			
	elif event is InputEventScreenDrag:
		if is_dragging and event.index == touch_index:
			_update_tip(event.position)
			
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_dragging = true
				touch_index = -1
				_update_tip(event.position)
			else:
				_reset_joystick()
				
	elif event is InputEventMouseMotion:
		if is_dragging and touch_index == -1:
			_update_tip(event.position)

func _update_tip(touch_pos: Vector2) -> void:
	var center := size * 0.5
	var diff := touch_pos - center
	var dist: float = diff.length()
	
	if dist > deadzone:
		var clamped_dist: float = min(dist, max_distance)
		var norm := diff.normalized()
		tip.position = (size * 0.5) + (norm * clamped_dist) - (tip.size * 0.5)
		output_vector = norm * ((clamped_dist - deadzone) / (max_distance - deadzone))
	else:
		tip.position = (size * 0.5) - (tip.size * 0.5)
		output_vector = Vector2.ZERO

func _reset_joystick() -> void:
	is_dragging = false
	touch_index = -1
	output_vector = Vector2.ZERO
	if tip:
		tip.position = (size * 0.5) - (tip.size * 0.5)

func get_value() -> Vector2:
	return output_vector
