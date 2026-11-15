extends Node
class_name GameStateClass

var collected_fragments: Array[String] = []
var active_chapter: int = 1
var player_health: int = 1
var is_remembered_reality: bool = true

func reset_state() -> void:
	collected_fragments.clear()
	active_chapter = 1
	player_health = 1
	is_remembered_reality = true

func add_fragment(frag_id: String) -> void:
	if not frag_id in collected_fragments:
		collected_fragments.append(frag_id)
		EventBus.memory_fragment_collected.emit(frag_id)

func has_fragment(frag_id: String) -> bool:
	return frag_id in collected_fragments
