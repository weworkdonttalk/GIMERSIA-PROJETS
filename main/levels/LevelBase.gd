extends Node2D
class_name LevelBase

@onready var background_color: ColorRect = $Background
@onready var flash_overlay: ColorRect = $FlashOverlay
@onready var dimension_label: Label = $HUD/MarginContainer/VBoxContainer/DimensionLabel
@onready var gravity_label: Label = $HUD/MarginContainer/VBoxContainer/GravityLabel
@onready var key_label: Label = $HUD/MarginContainer/VBoxContainer/KeyLabel

var current_gravity_name: String = "DOWN"

func _ready() -> void:
	EventBus.timeline_switched.connect(_on_timeline_switched)
	EventBus.level_completed.connect(_on_level_completed)
	EventBus.gravity_changed.connect(_on_gravity_changed)
	EventBus.chrono_key_collected.connect(_on_key_collected)
	EventBus.chrono_key_switches_updated.connect(_on_key_updated)
	EventBus.chrono_key_broken.connect(_on_key_broken)
	EventBus.chrono_key_used.connect(_on_key_used)

	_update_environment(GameManager.is_past_timeline, false)
	_update_gravity_display(Vector2.DOWN)
	_update_key_display(0, 0, false)

func _on_timeline_switched(is_past: bool) -> void:
	_update_environment(is_past, true)

func _update_environment(is_past: bool, animate: bool) -> void:
	var target_bg: Color = Color(0.18, 0.14, 0.10, 1.0) if is_past else Color(0.06, 0.05, 0.09, 1.0)

	if background_color != null:
		if animate:
			var bg_tween: Tween = create_tween()
			bg_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			bg_tween.tween_property(background_color, "color", target_bg, 0.15)
		else:
			background_color.color = target_bg

	if flash_overlay != null and animate:
		flash_overlay.modulate.a = 0.35
		var flash_tween: Tween = create_tween()
		flash_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		flash_tween.tween_property(flash_overlay, "modulate:a", 0.0, 0.1)

	if dimension_label != null:
		if is_past:
			dimension_label.text = "TIMELINE: PAST (WARM MEMORY) [ACTIVE]"
			dimension_label.modulate = Color(0.98, 0.8, 0.2, 1.0)
		else:
			dimension_label.text = "TIMELINE: FUTURE (RUINED REALITY) [ACTIVE]"
			dimension_label.modulate = Color(0.75, 0.55, 0.98, 1.0)

func _on_gravity_changed(new_dir: Vector2) -> void:
	_update_gravity_display(new_dir)

func _update_gravity_display(dir: Vector2) -> void:
	if dir.is_equal_approx(Vector2.DOWN):
		current_gravity_name = "DOWN (Floor)"
	elif dir.is_equal_approx(Vector2.UP):
		current_gravity_name = "UP (Ceiling)"
	elif dir.is_equal_approx(Vector2.RIGHT):
		current_gravity_name = "RIGHT (Right Wall)"
	elif dir.is_equal_approx(Vector2.LEFT):
		current_gravity_name = "LEFT (Left Wall)"

	if gravity_label != null:
		gravity_label.text = "GRAVITY: " + current_gravity_name

func _on_key_collected(max_switches: int) -> void:
	_update_key_display(max_switches, max_switches, true)

func _on_key_updated(left: int, max_s: int) -> void:
	_update_key_display(left, max_s, true)

func _on_key_broken() -> void:
	if key_label != null:
		key_label.text = "CHRONO-KEY: BROKEN! (UNSTABLE MEMORY - RESPAWNED)"
		key_label.modulate = Color(1.0, 0.3, 0.3, 1.0)

func _on_key_used() -> void:
	if key_label != null:
		key_label.text = "CHRONO-KEY: GATE UNLOCKED!"
		key_label.modulate = Color(0.3, 1.0, 0.4, 1.0)

func _update_key_display(left: int, max_s: int, active: bool) -> void:
	if key_label == null:
		return
	if not active:
		key_label.text = "CHRONO-KEY: NONE"
		key_label.modulate = Color(0.65, 0.7, 0.75, 0.7)
	else:
		key_label.text = "CHRONO-KEY: %d / %d SWITCHES REMAINING" % [max(0, left), max_s]
		key_label.modulate = Color(1.0, 0.85, 0.2, 1.0) if left > 0 else Color(1.0, 0.3, 0.3, 1.0)

func _on_level_completed() -> void:
	if dimension_label != null:
		dimension_label.text = "TIMELINE RESOLVED! LEVEL CLEARED"
		dimension_label.modulate = Color(0.3, 0.95, 0.5, 1.0)
