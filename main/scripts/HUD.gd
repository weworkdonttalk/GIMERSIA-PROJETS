extends Control

@onready var chapter_label: Label = $MarginContainer/VBoxContainer/ChapterLabel
@onready var reality_label: Label = $MarginContainer/VBoxContainer/RealityLabel
@onready var fragments_label: Label = $MarginContainer/VBoxContainer/FragmentsLabel

func _ready() -> void:
	EventBus.timeline_switched.connect(_on_timeline_switched)
	EventBus.memory_fragment_collected.connect(_on_fragment_collected)
	_update_reality_display(true)

func _on_timeline_switched(is_rem: bool) -> void:
	_update_reality_display(is_rem)

func _update_reality_display(is_rem: bool) -> void:
	if reality_label:
		if is_rem:
			reality_label.text = "REALITY: REMEMBERED (Warm Amber)"
			reality_label.modulate = Color(0.98, 0.88, 0.28, 1.0)
		else:
			reality_label.text = "REALITY: FORGOTTEN (Cold Purple)"
			reality_label.modulate = Color(0.49, 0.13, 0.81, 1.0)

func _on_fragment_collected(frag_id: String) -> void:
	if fragments_label:
		fragments_label.text = "Fragments: %d collected" % GameState.collected_fragments.size()
