extends Node3D
class_name ChapterController3D

@export var chapter_name: String = "Chapter 1: Toys"
@export var next_scene_path: String = "res://scenes/Chapter2_Clock.tscn"

@onready var reality_manager: Node3D = $RealityManager
@onready var player: Node3D = $Player3D
@onready var spawn_point: Marker3D = $SpawnPoint

func _ready() -> void:
	if player and spawn_point:
		player.global_position = spawn_point.global_position
		CheckpointManager.current_checkpoint_pos = spawn_point.global_position
	EventBus.memory_fragment_collected.connect(_on_fragment_collected)

func _on_fragment_collected(frag_id: String) -> void:
	if frag_id.contains("door") or frag_id.contains("clock") or frag_id.contains("toy"):
		EventBus.level_completed.emit()
