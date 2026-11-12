extends Area2D
class_name GoalDoor

@onready var visual: Node2D = $Visual
@onready var light_glow: Polygon2D = $Visual/Glow

var completed: bool = false

func _ready() -> void:
	collision_layer = 16 # Layer 5
	collision_mask = 2   # Layer 2
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	var pulse: float = (sin(Time.get_ticks_msec() / 250.0) * 0.15) + 0.85
	visual.scale = Vector2(pulse, pulse)

func _on_body_entered(body: Node2D) -> void:
	if completed:
		return
	if body.has_method("set_gravity_direction"):
		completed = true
		EventBus.level_completed.emit()
		var tween: Tween = create_tween()
		tween.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(visual, "scale", Vector2(1.6, 1.6), 0.3)
