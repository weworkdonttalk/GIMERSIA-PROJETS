extends CharacterBody3D
class_name Player3D

@export var speed: float = 5.0
@export var jump_velocity: float = 5.5
@export var push_force: float = 2.0

@onready var anti_stuck_detector: Area3D = $AntiStuckDetector

var is_hidden: bool = false
var is_shifting_blocked: bool = false

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	if Input.is_action_pressed("crouch"):
		is_hidden = true
	else:
		is_hidden = false

	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := Vector3(input_dir.x, 0, input_dir.y).normalized()
	
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		if collision.get_collider() is RigidBody3D:
			var collider := collision.get_collider() as RigidBody3D
			collider.apply_central_impulse(-collision.get_normal() * push_force)

func check_anti_stuck() -> bool:
	if anti_stuck_detector and anti_stuck_detector.has_overlapping_bodies():
		for body in anti_stuck_detector.get_overlapping_bodies():
			if body is StaticBody3D and not body.is_in_group("ignore_stuck"):
				return false
	return true
