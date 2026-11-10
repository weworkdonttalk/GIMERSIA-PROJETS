extends Node2D
class_name TimelineContainer

@export_enum("PAST", "FUTURE") var timeline_type: String = "PAST"

func _ready() -> void:
	EventBus.dimension_switched.connect(_on_dimension_switched)
	_update_state(GameManager.is_light_dimension, false)

func _on_dimension_switched(is_past: bool) -> void:
	_update_state(is_past, true)

func _update_state(is_past: bool, animate: bool) -> void:
	var is_active: bool = (timeline_type == "PAST" and is_past) or (timeline_type == "FUTURE" and !is_past)
	var target_alpha: float = 1.0 if is_active else 0.12

	# Toggle all physics collisions and trigger areas recursively
	_set_active_recursive(self, is_active)

	if animate:
		var tween: Tween = create_tween()
		tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "modulate:a", target_alpha, 0.1)
	else:
		modulate.a = target_alpha

func _set_active_recursive(node: Node, active: bool) -> void:
	for child in node.get_children():
		if child is CollisionShape2D or child is CollisionPolygon2D:
			child.set_deferred("disabled", !active)
		elif child is Area2D:
			child.set_deferred("monitoring", active)
			child.set_deferred("monitorable", active)
			for sub in child.get_children():
				if sub is CollisionShape2D or sub is CollisionPolygon2D:
					sub.set_deferred("disabled", !active)
		elif child is StaticBody2D or child is AnimatableBody2D or child is CharacterBody2D:
			for sub in child.get_children():
				if sub is CollisionShape2D or sub is CollisionPolygon2D:
					sub.set_deferred("disabled", !active)
		
		if child.get_child_count() > 0:
			_set_active_recursive(child, active)
