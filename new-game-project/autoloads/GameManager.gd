extends Node

var is_past_timeline: bool = true

func _ready() -> void:
	EventBus.player_died.connect(_on_player_died)
	EventBus.level_completed.connect(_on_level_completed)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart"):
		restart_level()

func restart_level() -> void:
	call_deferred("_reload_scene")

func _reload_scene() -> void:
	get_tree().reload_current_scene()

func _on_player_died() -> void:
	if CheckpointManager.current_checkpoint_pos != Vector3.ZERO:
		var player = get_tree().get_first_node_in_group("player")
		if player:
			CheckpointManager.respawn_player(player)
			return
	restart_level()

func _on_level_completed() -> void:
	var current_scene_path: String = get_tree().current_scene.scene_file_path
	await get_tree().create_timer(1.0).timeout
	if current_scene_path.ends_with("Chapter1_Toys.tscn"):
		call_deferred("_change_scene", "res://scenes/Chapter2_Clock.tscn")
	elif current_scene_path.ends_with("Chapter2_Clock.tscn"):
		call_deferred("_change_scene", "res://scenes/Chapter3_Door.tscn")
	else:
		call_deferred("_change_scene", "res://scenes/Chapter1_Toys.tscn")

func _change_scene(path: String) -> void:
	get_tree().change_scene_to_file(path)
