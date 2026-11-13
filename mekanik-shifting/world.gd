extends Node3D

@onready var remembered = $remembered
@onready var forgotten = $forgotten

var in_memory := true

func _ready() -> void:
	forgotten.hide()
	_set_collisions(remembered, true)
	_set_collisions(forgotten, false)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_SHIFT:
		in_memory = not in_memory
		remembered.visible = in_memory
		forgotten.visible = not in_memory
		_set_collisions(remembered, in_memory)
		_set_collisions(forgotten, not in_memory)

func _set_collisions(node: Node, active: bool) -> void:
	if node is CollisionShape3D:
		node.set_deferred("disabled", not active)

	for child in node.get_children():
		_set_collisions(child, active)
