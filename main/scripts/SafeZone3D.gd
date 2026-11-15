extends Area3D
class_name SafeZone3D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node3D) -> void:
	if body is Player3D:
		body.is_hidden = true
		EventBus.safe_zone_entered.emit(self)

func _on_body_exited(body: Node3D) -> void:
	if body is Player3D:
		body.is_hidden = false
		EventBus.safe_zone_exited.emit(self)
