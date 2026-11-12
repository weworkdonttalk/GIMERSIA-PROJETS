extends Node

var is_past_timeline: bool = true

var is_light_dimension: bool:
	get:
		return is_past_timeline
	set(val):
		is_past_timeline = val

func _ready() -> void:
	EventBus.player_died.connect(_on_player_died)
	EventBus.level_completed.connect(_on_level_completed)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart"):
		restart_level()

func toggle_dimension() -> void:
	is_past_timeline = !is_past_timeline
	EventBus.dimension_switched.emit(is_past_timeline)
	EventBus.timeline_switched.emit(is_past_timeline)

func restart_level() -> void:
	call_deferred("_reload_scene")

func _reload_scene() -> void:
	is_past_timeline = true
	get_tree().reload_current_scene()

func _on_player_died() -> void:
	restart_level()

func _on_level_completed() -> void:
	var current_scene_path: String = get_tree().current_scene.scene_file_path
	await get_tree().create_timer(0.8).timeout
	if current_scene_path.ends_with("Level_01.tscn"):
		call_deferred("_change_scene", "res://levels/Level_02.tscn")
	else:
		call_deferred("_reload_scene")

func _change_scene(path: String) -> void:
	is_past_timeline = true
	get_tree().change_scene_to_file(path)
