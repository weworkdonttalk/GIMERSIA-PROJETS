extends Area2D
class_name Hazard

func _ready() -> void:
	collision_layer = 16 # Layer 5
	collision_mask = 2   # Layer 2
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("set_gravity_direction"):
		EventBus.player_died.emit()
