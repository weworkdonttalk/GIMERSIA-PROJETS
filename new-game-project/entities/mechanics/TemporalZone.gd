extends Area2D
class_name TemporalZone

@export_enum("LOCK_SWITCH", "FORCE_PAST", "FORCE_FUTURE") var zone_mode: String = "LOCK_SWITCH"
@export var zone_size: Vector2 = Vector2(120, 120)

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var visual_rect: ColorRect = $VisualRect
@onready var border: ReferenceRect = $Border

func _ready() -> void:
	collision_layer = 16 # Layer 5
	collision_mask = 2   # Layer 2
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_setup_visual_and_shape()

func _setup_visual_and_shape() -> void:
	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = zone_size
	collision_shape.shape = shape
	collision_shape.position = Vector2.ZERO

	visual_rect.size = zone_size
	visual_rect.position = -zone_size / 2.0

	border.size = zone_size
	border.position = -zone_size / 2.0
	border.editor_only = false
	border.border_width = 2.0

	match zone_mode:
		"LOCK_SWITCH":
			visual_rect.color = Color(0.55, 0.2, 0.9, 0.28)
			border.border_color = Color(0.78, 0.45, 1.0, 0.85)
		"FORCE_PAST":
			visual_rect.color = Color(0.9, 0.75, 0.2, 0.28)
			border.border_color = Color(1.0, 0.88, 0.4, 0.85)
		"FORCE_FUTURE":
			visual_rect.color = Color(0.2, 0.65, 0.9, 0.28)
			border.border_color = Color(0.4, 0.85, 1.0, 0.85)

func _process(delta: float) -> void:
	var pulse: float = (sin(Time.get_ticks_msec() / 200.0) * 0.08) + 0.92
	border.modulate.a = pulse

func _on_body_entered(body: Node2D) -> void:
	if "time_switch_locked" in body:
		match zone_mode:
			"LOCK_SWITCH":
				body.time_switch_locked = true
			"FORCE_PAST":
				if not GameManager.is_past_timeline:
					GameManager.toggle_dimension()
			"FORCE_FUTURE":
				if GameManager.is_past_timeline:
					GameManager.toggle_dimension()

func _on_body_exited(body: Node2D) -> void:
	if "time_switch_locked" in body and zone_mode == "LOCK_SWITCH":
		body.time_switch_locked = false
