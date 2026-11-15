extends CharacterBody3D
class_name TheEraser3D

@export var player_path: NodePath
@export var patrol_speed: float = 3.0
@export var chase_speed: float = 6.0

enum State { PATROL, TELEGRAPH, CHASE }
var current_state: State = State.PATROL
@onready var player: Node3D = get_node_or_null(player_path)

func _physics_process(delta: float) -> void:
	if not player:
		return
	var dist := global_position.distance_to(player.global_position)
	if dist < 8.0 and not player.is_hidden:
		current_state = State.CHASE
	else:
		current_state = State.PATROL

	if current_state == State.CHASE:
		var dir := (player.global_position - global_position).normalized()
		velocity.x = dir.x * chase_speed
		velocity.z = dir.z * chase_speed
		move_and_slide()
	
	for body in $EraserArea.get_overlapping_bodies():
		if body.is_in_group("erasable"):
			body.queue_free()
		elif body == player and not player.is_hidden:
			EventBus.player_died.emit()
