extends Node3D
class_name CharacterAnimator

@export var is_female: bool = false
@export var character_name: String = "Aarav"

@onready var head_node: Node3D = get_node_or_null("Body/Chest/Head")
@onready var left_arm: Node3D = get_node_or_null("Body/Chest/LeftArm")
@onready var right_arm: Node3D = get_node_or_null("Body/Chest/RightArm")
@onready var left_leg: Node3D = get_node_or_null("Body/Hips/LeftLeg")
@onready var right_leg: Node3D = get_node_or_null("Body/Hips/RightLeg")
@onready var body: Node3D = get_node_or_null("Body")

var walk_phase: float = 0.0
var current_emotion: String = "idle"
var look_target: Node3D = null
var current_speed: float = 0.0

func _process(delta: float) -> void:
	if not body:
		return
	
	if current_speed > 0.1:
		# Walking / Running animation cycle
		var freq: float = 8.0 if current_speed < 4.0 else 12.0
		walk_phase += delta * freq
		var arm_swing: float = sin(walk_phase) * 0.65
		var leg_swing: float = sin(walk_phase) * 0.75
		var body_bob: float = abs(cos(walk_phase)) * 0.08
		
		if left_leg and right_leg:
			left_leg.rotation.x = leg_swing
			right_leg.rotation.x = -leg_swing
		if left_arm and right_arm:
			left_arm.rotation.x = -arm_swing
			right_arm.rotation.x = arm_swing
		
		body.position.y = body_bob
	else:
		# Idle breathing & subtle sway
		walk_phase += delta * 2.0
		var breathe := sin(walk_phase) * 0.025
		body.position.y = breathe
		
		if left_leg and right_leg:
			left_leg.rotation.x = lerp(left_leg.rotation.x, 0.0, delta * 5.0)
			right_leg.rotation.x = lerp(right_leg.rotation.x, 0.0, delta * 5.0)
		if left_arm and right_arm:
			left_arm.rotation.x = lerp(left_arm.rotation.x, 0.0, delta * 5.0)
			right_arm.rotation.x = lerp(right_arm.rotation.x, 0.0, delta * 5.0)
	
	_handle_emotion_expression(delta)
	_handle_head_look(delta)

func _handle_emotion_expression(delta: float) -> void:
	match current_emotion:
		"happy", "laughing":
			if head_node:
				head_node.rotation.z = sin(walk_phase * 3.0) * 0.08
		"shy", "blushing":
			if head_node:
				head_node.rotation.x = lerp(head_node.rotation.x, 0.2, delta * 3.0)
				head_node.rotation.z = lerp(head_node.rotation.z, 0.15, delta * 3.0)
		"sad", "tearful":
			if head_node:
				head_node.rotation.x = lerp(head_node.rotation.x, 0.25, delta * 3.0)
		"thinking":
			if right_arm:
				right_arm.rotation.x = lerp(right_arm.rotation.x, -1.2, delta * 4.0)
				right_arm.rotation.z = lerp(right_arm.rotation.z, -0.4, delta * 4.0)

func _handle_head_look(delta: float) -> void:
	if look_target and head_node and is_instance_valid(look_target):
		var target_pos := look_target.global_position + Vector3(0, 1.4, 0)
		var dir := (target_pos - head_node.global_position).normalized()
		var local_dir := global_transform.basis.inverse() * dir
		var target_rot_y: float = clamp(atan2(local_dir.x, local_dir.z), -0.8, 0.8)
		head_node.rotation.y = lerp_angle(head_node.rotation.y, target_rot_y, delta * 4.0)
	elif head_node:
		head_node.rotation.y = lerp_angle(head_node.rotation.y, 0.0, delta * 4.0)

func set_motion(speed: float) -> void:
	current_speed = speed

func set_emotion(emotion: String) -> void:
	current_emotion = emotion

func look_at_character(other: Node3D) -> void:
	look_target = other
