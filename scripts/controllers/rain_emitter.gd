extends Node3D

@export var follow_target: Node3D = null

func _process(_delta: float) -> void:
	if follow_target and is_instance_valid(follow_target):
		global_position.x = follow_target.global_position.x
		global_position.z = follow_target.global_position.z
	elif GameManager.player_node and is_instance_valid(GameManager.player_node):
		global_position.x = GameManager.player_node.global_position.x
		global_position.z = GameManager.player_node.global_position.z
