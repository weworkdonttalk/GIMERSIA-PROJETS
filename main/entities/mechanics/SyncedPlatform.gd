extends AnimatableBody2D
class_name SyncedPlatform

@export_enum("MOVE_IN_PAST_FREEZE_IN_FUTURE", "MOVE_IN_FUTURE_FREEZE_IN_PAST", "REVERSE_DIRECTION") var mode: String = "MOVE_IN_PAST_FREEZE_IN_FUTURE"
@export var move_offset: Vector2 = Vector2(160, 0)
@export var speed: float = 85.0
@export var platform_size: Vector2 = Vector2(84, 20)

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var visual_rect: ColorRect = $VisualRect
@onready var border: ReferenceRect = $Border
@onready var time_gear: Polygon2D = $TimeGear

var start_pos: Vector2
var progress: float = 0.0
var pingpong_dir: float = 1.0
var is_moving: bool = true

func _ready() -> void:
	collision_layer = 1 # World_Static
	collision_mask = 0
	start_pos = position
	EventBus.timeline_switched.connect(_on_timeline_switched)
	_setup_visual()
	_update_timeline_state(GameManager.is_past_timeline)

func _setup_visual() -> void:
	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = platform_size
	collision_shape.shape = shape
	collision_shape.position = Vector2.ZERO

	visual_rect.size = platform_size
	visual_rect.position = -platform_size / 2.0
	border.size = platform_size
	border.position = -platform_size / 2.0
	border.editor_only = false
	border.border_width = 2.0

func _physics_process(delta: float) -> void:
	if not is_moving:
		return

	var distance: float = move_offset.length()
	if distance < 1.0:
		return

	var step: float = (speed / distance) * delta
	progress += pingpong_dir * step

	if progress >= 1.0:
		progress = 1.0
		pingpong_dir = -1.0
	elif progress <= 0.0:
		progress = 0.0
		pingpong_dir = 1.0

	position = start_pos + (move_offset * progress)
	time_gear.rotate(2.5 * pingpong_dir * delta)

func _on_timeline_switched(is_past: bool) -> void:
	_update_timeline_state(is_past)

func _update_timeline_state(is_past: bool) -> void:
	match mode:
		"MOVE_IN_PAST_FREEZE_IN_FUTURE":
			is_moving = is_past
		"MOVE_IN_FUTURE_FREEZE_IN_PAST":
			is_moving = not is_past
		"REVERSE_DIRECTION":
			is_moving = true
			pingpong_dir = -pingpong_dir

	# Visual indicator: frozen platform turns slightly crystalline ice-cyan
	if is_moving:
		border.border_color = Color(0.35, 0.85, 1.0, 1.0)
		visual_rect.color = Color(0.18, 0.28, 0.42, 1.0)
	else:
		border.border_color = Color(0.65, 0.75, 0.85, 0.8)
		visual_rect.color = Color(0.12, 0.16, 0.24, 0.95)
