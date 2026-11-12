extends StaticBody2D
class_name DimensionPlatform

@export_enum("LIGHT", "DARK") var dimension_type: String = "LIGHT"
@export var size: Vector2 = Vector2(96, 24)

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var background: ColorRect = $Background
@onready var border: ReferenceRect = $Border

func _ready() -> void:
	EventBus.dimension_switched.connect(_on_dimension_switched)
	_setup_visual_and_collision()
	_update_state(GameManager.is_light_dimension, false)

func _setup_visual_and_collision() -> void:
	# Configure shape size & center
	var rect_shape: RectangleShape2D = RectangleShape2D.new()
	rect_shape.size = size
	collision_shape.shape = rect_shape
	collision_shape.position = Vector2.ZERO

	# Configure visual rects
	background.size = size
	background.position = -size / 2.0
	border.size = size
	border.position = -size / 2.0
	border.editor_only = false
	border.border_width = 2.0

	if dimension_type == "LIGHT":
		# Layer 3 = Light Dimension (bit value 4)
		collision_layer = 4
		background.color = Color(0.96, 0.94, 0.85, 0.9)
		border.border_color = Color(1.0, 0.85, 0.2, 1.0)
	else:
		# Layer 4 = Dark Dimension (bit value 8)
		collision_layer = 8
		background.color = Color(0.28, 0.22, 0.45, 0.9)
		border.border_color = Color(0.72, 0.55, 0.95, 1.0)
	collision_mask = 0

func _on_dimension_switched(is_light: bool) -> void:
	_update_state(is_light, true)

func _update_state(is_light: bool, animate: bool) -> void:
	var is_active: bool = (dimension_type == "LIGHT" and is_light) or (dimension_type == "DARK" and !is_light)
	var target_alpha: float = 1.0 if is_active else 0.2

	collision_shape.set_deferred("disabled", !is_active)

	if animate:
		var tween: Tween = create_tween()
		tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "modulate:a", target_alpha, 0.15)
	else:
		modulate.a = target_alpha
