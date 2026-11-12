extends AnimatableBody2D
class_name MovingPlatform

@export var offset: Vector2 = Vector2(0, -120)
@export var duration: float = 2.4

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	collision_layer = 1 # World_Static
	collision_mask = 0
	_start_movement()

func _start_movement() -> void:
	var start_pos: Vector2 = position
	var target_pos: Vector2 = start_pos + offset

	var tween: Tween = create_tween().set_loops()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "position", target_pos, duration)
	tween.tween_property(self, "position", start_pos, duration)
