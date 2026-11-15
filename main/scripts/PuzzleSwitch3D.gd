extends Area3D
class_name PuzzleSwitch3D

@export var switch_id: String = "switch_1"
var is_active: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body is Player3D or body is RigidBody3D:
		is_active = !is_active
		EventBus.puzzle_switch_triggered.emit(switch_id, is_active)
