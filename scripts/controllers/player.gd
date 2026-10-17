extends CharacterBody3D
class_name PlayerController

@export var walk_speed: float = 3.6
@export var sprint_speed: float = 6.2
@export var acceleration: float = 12.0
@export var friction: float = 14.0
@export var rotation_speed: float = 10.0
@export var mouse_sensitivity: float = 0.003
@export var touch_sensitivity: float = 0.004

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity", 9.8)

@onready var spring_arm: SpringArm3D = $CameraRig/SpringArm3D
@onready var camera: Camera3D = $CameraRig/SpringArm3D/Camera3D
@onready var camera_rig: Node3D = $CameraRig
@onready var character_mesh: Node3D = $CharacterMeshAarav
@onready var interact_area: Area3D = $InteractArea

var virtual_input_vector: Vector2 = Vector2.ZERO
var is_sprinting: bool = false
var nearby_interactable: Node = null

var right_touch_index: int = -1
var last_touch_pos: Vector2 = Vector2.ZERO

func _ready() -> void:
	GameManager.player_node = self
	GameManager.active_camera = camera
	
	if interact_area:
		interact_area.area_entered.connect(_on_interact_area_entered)
		interact_area.area_exited.connect(_on_interact_area_exited)
		interact_area.body_entered.connect(_on_interact_body_entered)
		interact_area.body_exited.connect(_on_interact_body_exited)

func _unhandled_input(event: InputEvent) -> void:
	if not GameManager.is_gameplay_active():
		return
	
	# Mouse look
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		rotate_camera(-event.relative.x * mouse_sensitivity, -event.relative.y * mouse_sensitivity)
		
	# Touch screen swipe for camera (right half of screen)
	elif event is InputEventScreenTouch:
		var screen_width := get_viewport().get_visible_rect().size.x
		if event.position.x > screen_width * 0.4:
			if event.pressed:
				right_touch_index = event.index
				last_touch_pos = event.position
			elif event.index == right_touch_index:
				right_touch_index = -1
				
	elif event is InputEventScreenDrag:
		if event.index == right_touch_index:
			var touch_delta: Vector2 = event.position - last_touch_pos
			last_touch_pos = event.position
			rotate_camera(-touch_delta.x * touch_sensitivity, -touch_delta.y * touch_sensitivity)
	
	# Keyboard sprint
	if event.is_action_pressed("sprint"):
		is_sprinting = true
	elif event.is_action_released("sprint"):
		is_sprinting = false
		
	# Interaction key
	if event.is_action_pressed("interact"):
		trigger_interaction()

func rotate_camera(yaw_delta: float, pitch_delta: float) -> void:
	camera_rig.rotate_y(yaw_delta)
	spring_arm.rotate_x(pitch_delta)
	spring_arm.rotation.x = clamp(spring_arm.rotation.x, deg_to_rad(-65.0), deg_to_rad(30.0))

func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0
	
	if not GameManager.is_gameplay_active():
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)
		velocity.z = move_toward(velocity.z, 0.0, friction * delta)
		move_and_slide()
		if character_mesh and character_mesh.has_method("set_motion"):
			character_mesh.set_motion(0.0)
		return
	
	# Gather keyboard & virtual joystick inputs
	var input_x := Input.get_axis("move_left", "move_right")
	var input_z := Input.get_axis("move_forward", "move_backward")
	var input_dir := Vector2(input_x, input_z)
	
	if virtual_input_vector.length_squared() > 0.01:
		input_dir = virtual_input_vector
	
	if input_dir.length() > 1.0:
		input_dir = input_dir.normalized()
	
	var target_speed := sprint_speed if is_sprinting else walk_speed
	
	# Project input relative to camera orientation
	var cam_basis := camera_rig.global_transform.basis
	var forward := -cam_basis.z
	forward.y = 0.0
	forward = forward.normalized()
	var right := cam_basis.x
	right.y = 0.0
	right = right.normalized()
	
	var move_dir := (right * input_dir.x + forward * -input_dir.y).normalized()
	
	if move_dir.length() > 0.1:
		velocity.x = move_toward(velocity.x, move_dir.x * target_speed, acceleration * delta)
		velocity.z = move_toward(velocity.z, move_dir.z * target_speed, acceleration * delta)
		
		# Smooth mesh rotation
		var target_angle := atan2(-move_dir.x, -move_dir.z)
		character_mesh.rotation.y = lerp_angle(character_mesh.rotation.y, target_angle, rotation_speed * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)
		velocity.z = move_toward(velocity.z, 0.0, friction * delta)
	
	move_and_slide()
	
	var horizontal_speed := Vector2(velocity.x, velocity.z).length()
	if character_mesh and character_mesh.has_method("set_motion"):
		character_mesh.set_motion(horizontal_speed)

func set_virtual_joystick(vec: Vector2) -> void:
	virtual_input_vector = vec

func set_virtual_sprint(sprinting: bool) -> void:
	is_sprinting = sprinting

func trigger_interaction() -> void:
	if nearby_interactable and nearby_interactable.has_method("interact"):
		nearby_interactable.interact(self)

func _on_interact_area_entered(area: Area3D) -> void:
	if area.has_method("interact") or area.get_parent().has_method("interact"):
		nearby_interactable = area if area.has_method("interact") else area.get_parent()
		_update_interaction_hud(true)

func _on_interact_area_exited(area: Area3D) -> void:
	if nearby_interactable == area or (nearby_interactable and nearby_interactable == area.get_parent()):
		nearby_interactable = null
		_update_interaction_hud(false)

func _on_interact_body_entered(body: Node3D) -> void:
	if body != self and body.has_method("interact"):
		nearby_interactable = body
		_update_interaction_hud(true)

func _on_interact_body_exited(body: Node3D) -> void:
	if nearby_interactable == body:
		nearby_interactable = null
		_update_interaction_hud(false)

func _update_interaction_hud(show_prompt: bool) -> void:
	var hud := get_tree().root.find_child("HUD", true, false)
	if hud and hud.has_method("set_interact_visible"):
		var prompt_text := "Interact"
		if nearby_interactable and "interaction_name" in nearby_interactable:
			prompt_text = nearby_interactable.interaction_name
		hud.set_interact_visible(show_prompt, prompt_text)
