extends Node

# Global EventBus for decoupled communication
signal dimension_switched(is_light: bool)
signal timeline_switched(is_past: bool)
signal player_died
signal level_completed
signal gravity_changed(new_dir: Vector2)

# Chrono-Key & Paradox Gate Signals
signal chrono_key_collected(max_switches: int)
signal chrono_key_switches_updated(switches_left: int, max_switches: int)
signal chrono_key_broken
signal chrono_key_used
signal paradox_gate_opened
