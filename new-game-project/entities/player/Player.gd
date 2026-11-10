extends CharacterBody2D
class_name Player

@export var speed: float = 240.0
@export var jump_velocity: float = 430.0
@export var gravity: float = 1050.0
@export var coyote_time: float = 0.12
@export var jump_buffer_time: float = 0.12

const ACCELERATION: float = 1800.0
const FRICTION: float = 2200.0
const AIR_RESISTANCE: float = 1200.0

var gravity_direction: Vector2 = Vector2.DOWN
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
var teleport_cooldown: float = 0.0
var micro_hangtime_timer: float = 0.0

var time_switch_locked: bool = false
var held_chrono_key: Node2D = null

@onready var visual: Node2D = $Visual
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	set_gravity_direction(Vector2.DOWN)
	EventBus.dimension_switched.connect(_on_dimension_switched)
	_update_collision_dimensions(GameManager.is_light_dimension)

func _physics_process(delta: float) -> void:
	if teleport_cooldown > 0.0:
		teleport_cooldown = max(0.0, teleport_cooldown - delta)
	if micro_hangtime_timer > 0.0:
		micro_hangtime_timer = max(0.0, micro_hangtime_timer - delta)

	# Handle Timeline Switch with Temporal Lock check & Mid-air Time-Burst
	if (Input.is_action_just_pressed("switch_time") or Input.is_action_just_pressed("switch_dimension")) and not time_switch_locked:
		GameManager.toggle_dimension()
		if not is_on_floor():
			micro_hangtime_timer = 0.12
			# Arrest excess downward fall speed during time-burst
			var fall_component: float = velocity.dot(gravity_direction)
			if fall_component > 60.0:
				velocity -= gravity_direction * (fall_component - 60.0)

	up_direction = -gravity_direction

	# Screen-space intuitive movement axis mapping
	var is_vertical_gravity: bool = abs(gravity_direction.y) > 0.5
	var walk_axis: Vector2 = Vector2.RIGHT if is_vertical_gravity else Vector2.DOWN

	var target_speed_scalar: float = 0.0
	var h_input: float = Input.get_axis("move_left", "move_right")
	var v_input: float = Input.get_axis("move_up", "move_down")

	if is_vertical_gravity:
		# A always moves left on screen, D always moves right on screen
		target_speed_scalar = h_input * speed
		if abs(h_input) > 0.05:
			visual.scale.x = 1.0 if h_input > 0.0 else -1.0
	else:
		# Wall walking: W moves UP on screen, S moves DOWN on screen (with A/D fallback)
		var wall_input: float = v_input if abs(v_input) > 0.05 else h_input
		target_speed_scalar = wall_input * speed
		if abs(wall_input) > 0.05:
			visual.scale.x = 1.0 if wall_input > 0.0 else -1.0

	var target_lateral_vel: Vector2 = walk_axis * target_speed_scalar

	# Decompose velocity
	var lateral_vel: Vector2 = velocity.project(walk_axis)
	var normal_vel: Vector2 = velocity.project(up_direction)

	# Celeste-style snappy acceleration & friction
	var rate: float
	if abs(target_speed_scalar) < 0.01:
		rate = FRICTION if is_on_floor() else AIR_RESISTANCE
	else:
		rate = ACCELERATION if is_on_floor() else (ACCELERATION * 0.75)

	lateral_vel = lateral_vel.move_toward(target_lateral_vel, rate * delta)

	# Gravity application with micro-hangtime stall
	if micro_hangtime_timer > 0.0:
		normal_vel += gravity_direction * (gravity * 0.15 * delta)
	else:
		normal_vel += gravity_direction * (gravity * delta)

	# Ground check & Coyote Time
	if is_on_floor():
		coyote_timer = coyote_time
		if normal_vel.dot(up_direction) < 0.0:
			normal_vel = Vector2.ZERO
	else:
		coyote_timer = max(0.0, coyote_timer - delta)

	# Jump Buffer
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = jump_buffer_time
	else:
		jump_buffer_timer = max(0.0, jump_buffer_timer - delta)

	# Jump execution
	if jump_buffer_timer > 0.0 and coyote_timer > 0.0:
		jump_buffer_timer = 0.0
		coyote_timer = 0.0
		normal_vel = up_direction * jump_velocity

	# Variable Jump Height: cut upward speed in half on button release
	if Input.is_action_just_released("jump"):
		var upward_speed: float = normal_vel.dot(up_direction)
		if upward_speed > 0.0:
			normal_vel = up_direction * (upward_speed * 0.5)

	# Recombine velocity
	velocity = lateral_vel + normal_vel
	move_and_slide()

func set_gravity_direction(new_dir: Vector2) -> void:
	if new_dir.is_zero_approx():
		return
	gravity_direction = new_dir.normalized()
	up_direction = -gravity_direction

	var target_rot: float = gravity_direction.angle() - (PI / 2.0)
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(visual, "rotation", target_rot, 0.14)

	EventBus.gravity_changed.emit(gravity_direction)

func teleport_to(target_pos: Vector2) -> void:
	global_position = target_pos
	teleport_cooldown = 0.25

func apply_slingshot(target_pos: Vector2, new_vel: Vector2) -> void:
	global_position = target_pos
	velocity = new_vel
	teleport_cooldown = 0.25

func can_teleport() -> bool:
	return teleport_cooldown <= 0.0

func _on_dimension_switched(is_light: bool) -> void:
	_update_collision_dimensions(is_light)

func _update_collision_dimensions(is_light: bool) -> void:
	set_collision_mask_value(3, is_light)
	set_collision_mask_value(4, !is_light)
