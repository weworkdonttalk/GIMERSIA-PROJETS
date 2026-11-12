extends StaticBody2D
class_name ParadoxGate

@export var gate_size: Vector2 = Vector2(24, 96)

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var trigger_area: Area2D = $TriggerArea
@onready var trigger_shape: CollisionShape2D = $TriggerArea/CollisionShape2D
@onready var visual_rect: ColorRect = $VisualRect
@onready var border: ReferenceRect = $Border
@onready var lock_icon: Polygon2D = $LockIcon

var is_open: bool = false

func _ready() -> void:
	collision_layer = 1 # World_Static
	collision_mask = 0
	trigger_area.collision_layer = 16 # Layer 5
	trigger_area.collision_mask = 2   # Layer 2
	trigger_area.body_entered.connect(_on_trigger_body_entered)
	_setup_gate_visual()

func _setup_gate_visual() -> void:
	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = gate_size
	collision_shape.shape = shape
	collision_shape.position = Vector2.ZERO

	var t_shape: RectangleShape2D = RectangleShape2D.new()
	t_shape.size = gate_size + Vector2(16, 8)
	trigger_shape.shape = t_shape
	trigger_shape.position = Vector2.ZERO

	visual_rect.size = gate_size
	visual_rect.position = -gate_size / 2.0
	border.size = gate_size
	border.position = -gate_size / 2.0
	border.editor_only = false
	border.border_width = 2.0

func _on_trigger_body_entered(body: Node2D) -> void:
	if is_open:
		return
	if "held_chrono_key" in body and body.held_chrono_key != null:
		var key = body.held_chrono_key
		key.consume()
		_open_gate()

func _open_gate() -> void:
	is_open = true
	collision_shape.set_deferred("disabled", true)
	trigger_area.set_deferred("monitoring", false)
	EventBus.paradox_gate_opened.emit()

	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 0.0, 0.35)
	tween.tween_property(visual_rect, "scale:y", 0.0, 0.35)
	await tween.finished
	queue_free()
