extends Area2D
class_name ChronoKey

@export var max_switches: int = 2

var switches_left: int = 2
var is_collected: bool = false
var origin_position: Vector2
var target_player: Node2D = null

@onready var visual: Node2D = $Visual
@onready var glow: Polygon2D = $Visual/Glow

func _ready() -> void:
	origin_position = global_position
	switches_left = max_switches
	collision_layer = 16 # Layer 5
	collision_mask = 2   # Layer 2
	body_entered.connect(_on_body_entered)
	EventBus.timeline_switched.connect(_on_timeline_switched)

func _process(delta: float) -> void:
	if is_collected and target_player != null:
		var target_offset: Vector2 = Vector2(-20, -26)
		if "visual" in target_player and target_player.visual != null:
			target_offset.x = -20.0 * target_player.visual.scale.x
		global_position = global_position.lerp(target_player.global_position + target_offset, 12.0 * delta)
	else:
		var float_y: float = sin(Time.get_ticks_msec() / 250.0) * 4.0
		visual.position.y = float_y

func _on_body_entered(body: Node2D) -> void:
	if not is_collected and "held_chrono_key" in body:
		is_collected = true
		target_player = body
		body.held_chrono_key = self
		switches_left = max_switches
		EventBus.chrono_key_collected.emit(max_switches)
		EventBus.chrono_key_switches_updated.emit(switches_left, max_switches)

		var tween: Tween = create_tween()
		tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(visual, "scale", Vector2(1.3, 1.3), 0.1)
		tween.tween_property(visual, "scale", Vector2.ONE, 0.1)

func _on_timeline_switched(is_past: bool) -> void:
	if is_collected:
		switches_left -= 1
		EventBus.chrono_key_switches_updated.emit(switches_left, max_switches)
		if switches_left < 0:
			_break_and_respawn()

func consume() -> void:
	EventBus.chrono_key_used.emit()
	if target_player != null and "held_chrono_key" in target_player and target_player.held_chrono_key == self:
		target_player.held_chrono_key = null
	queue_free()

func _break_and_respawn() -> void:
	EventBus.chrono_key_broken.emit()
	if target_player != null and "held_chrono_key" in target_player and target_player.held_chrono_key == self:
		target_player.held_chrono_key = null
	target_player = null
	is_collected = false
	switches_left = max_switches

	# Visual flash break tween
	var tween: Tween = create_tween()
	tween.tween_property(visual, "modulate", Color(1, 0.2, 0.2, 1), 0.1)
	tween.tween_property(self, "global_position", origin_position, 0.2)
	tween.tween_property(visual, "modulate", Color.WHITE, 0.1)
