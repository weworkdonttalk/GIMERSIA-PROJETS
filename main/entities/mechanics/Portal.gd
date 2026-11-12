extends Area2D
class_name Portal

@export var target_portal: Area2D
@export var target_portal_path: NodePath
@export var portal_color: Color = Color(0.22, 0.82, 0.88, 1.0)
@export var exit_direction: Vector2 = Vector2.ZERO
@export var speed_multiplier: float = 1.35
@export var min_slingshot_speed: float = 380.0

@onready var ring: Node2D = $RingContainer
@onready var core: Polygon2D = $RingContainer/Core
@onready var exit_arrow: Node2D = $ExitArrow

func _ready() -> void:
	if target_portal == null and not target_portal_path.is_empty():
		target_portal = get_node_or_null(target_portal_path) as Area2D

	collision_layer = 16 # Layer 5
	collision_mask = 2   # Layer 2
	body_entered.connect(_on_body_entered)
	_apply_visual()

func _process(delta: float) -> void:
	ring.rotate(2.0 * delta)

func _apply_visual() -> void:
	core.color = portal_color
	for child in ring.get_children():
		if child is Polygon2D:
			child.color = portal_color

	if exit_arrow != null:
		if exit_direction.is_zero_approx():
			exit_arrow.visible = false
		else:
			exit_arrow.visible = true
			exit_arrow.rotation = exit_direction.angle()

func _on_body_entered(body: Node2D) -> void:
	if target_portal == null:
		return
	if body.has_method("can_teleport") and body.can_teleport():
		var target_exit_dir: Vector2 = target_portal.exit_direction if "exit_direction" in target_portal else Vector2.ZERO
		var target_mult: float = target_portal.speed_multiplier if "speed_multiplier" in target_portal else 1.0
		var target_min: float = target_portal.min_slingshot_speed if "min_slingshot_speed" in target_portal else 0.0

		if not target_exit_dir.is_zero_approx() and body.has_method("apply_slingshot"):
			var current_speed: float = body.velocity.length() if "velocity" in body else 300.0
			var fling_speed: float = max(current_speed * target_mult, target_min)
			var new_vel: Vector2 = target_exit_dir.normalized() * fling_speed
			body.apply_slingshot(target_portal.global_position, new_vel)
		elif body.has_method("teleport_to"):
			body.teleport_to(target_portal.global_position)

		_trigger_teleport_effect()
		if target_portal.has_method("_trigger_teleport_effect"):
			target_portal._trigger_teleport_effect()

func _trigger_teleport_effect() -> void:
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(ring, "scale", Vector2(1.4, 1.4), 0.08)
	tween.tween_property(ring, "scale", Vector2.ONE, 0.15)
