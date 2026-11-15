extends Node
class_name CheckpointManagerClass

var current_checkpoint_id: String = "start"
var current_checkpoint_pos: Vector3 = Vector3.ZERO
var active_level_path: String = "res://scenes/Chapter1_Toys.tscn"

func _ready() -> void:
	EventBus.checkpoint_reached.connect(_on_checkpoint_reached)

func _on_checkpoint_reached(checkpoint_id: String, pos: Vector3) -> void:
	current_checkpoint_id = checkpoint_id
	current_checkpoint_pos = pos

func respawn_player(player: Node3D) -> void:
	if player and is_instance_valid(player):
		player.global_position = current_checkpoint_pos
		EventBus.player_respawned.emit(current_checkpoint_pos)
	else:
		GameManager.restart_level()
