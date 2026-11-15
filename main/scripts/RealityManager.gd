extends Node3D
class_name RealityManager

@export var remembered_node: Node3D
@export var forgotten_node: Node3D

var in_remembered_reality: bool = true

func _ready() -> void:
	if not remembered_node:
		remembered_node = get_node_or_null("../RememberedWorld")
	if not forgotten_node:
		forgotten_node = get_node_or_null("../ForgottenWorld")
	_apply_reality_state(true)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("switch_dimension"):
		toggle_reality()

func toggle_reality() -> void:
	in_remembered_reality = !in_remembered_reality
	_apply_reality_state(in_remembered_reality)
	EventBus.dimension_switched.emit(in_remembered_reality)
	EventBus.timeline_switched.emit(in_remembered_reality)

func _apply_reality_state(is_rem: bool) -> void:
	if remembered_node:
		remembered_node.visible = is_rem
		_set_node_collisions(remembered_node, is_rem)
	if forgotten_node:
		forgotten_node.visible = !is_rem
		_set_node_collisions(forgotten_node, !is_rem)

func _set_node_collisions(node: Node, active: bool) -> void:
	if node is CollisionShape3D or node is CollisionPolygon3D:
		node.set_deferred("disabled", not active)
	elif node is CollisionObject3D:
		node.set_collision_layer_value(1, active)
	for child in node.get_children():
		_set_node_collisions(child, active)
