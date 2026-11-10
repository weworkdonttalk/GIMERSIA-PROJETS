extends Area2D
class_name GravityBlock

@export_enum("DOWN", "UP", "LEFT", "RIGHT") var direction: String = "DOWN"

@onready var arrow: Node2D = $ArrowContainer
@onready var background: ColorRect = $Background

func _ready() -> void:
	collision_layer = 16 # Layer 5: Interactables_And_Hazards
	collision_mask = 2   # Layer 2: Player
	body_entered.connect(_on_body_entered)
	_apply_direction_visual()

func _apply_direction_visual() -> void:
	match direction:
		"DOWN":
			arrow.rotation = 0.0
		"UP":
			arrow.rotation = PI
		"LEFT":
			arrow.rotation = PI / 2.0
		"RIGHT":
			arrow.rotation = -PI / 2.0

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("set_gravity_direction"):
		var target_gravity: Vector2 = Vector2.DOWN
		match direction:
			"DOWN":
				target_gravity = Vector2.DOWN
			"UP":
				target_gravity = Vector2.UP
			"LEFT":
				target_gravity = Vector2.LEFT
			"RIGHT":
				target_gravity = Vector2.RIGHT

		body.set_gravity_direction(target_gravity)

		# Visual punch feedback
		var tween: Tween = create_tween()
		tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(arrow, "scale", Vector2(1.35, 1.35), 0.08)
		tween.tween_property(arrow, "scale", Vector2.ONE, 0.12)
