extends Node

# Global EventBus for GIMERSIA: Memory Shift

# Reality & Dimension signals
signal reality_shifted(is_remembered: bool)
signal shift_blocked(reason: String)
signal dimension_switched(is_light: bool)
signal timeline_switched(is_past: bool)

# Player & Gameplay lifecycle
signal player_died
signal player_respawned(at_position: Vector3)
signal level_completed
signal checkpoint_reached(checkpoint_id: String, position_3d: Vector3)

# Interactables & Puzzle
signal memory_fragment_collected(fragment_type: String)
signal puzzle_switch_triggered(switch_id: String, state: bool)
signal safe_zone_entered(zone: Node)
signal safe_zone_exited(zone: Node)

# Antagonist (The Eraser)
signal eraser_warning_triggered(duration: float)
signal eraser_erased_object(object_name: String)

# Legacy 2D compatibility signals
signal gravity_changed(new_dir: Vector2)
signal chrono_key_collected(max_switches: int)
signal chrono_key_switches_updated(switches_left: int, max_switches: int)
signal chrono_key_broken
signal chrono_key_used
signal paradox_gate_opened
