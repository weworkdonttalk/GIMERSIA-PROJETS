extends Node

func _ready() -> void:
	print("--- STARTING GIMERSIA GAME SYSTEMS TEST ---")
	
	GameState.reset_state()
	assert(GameState.collected_fragments.is_empty(), "GameState should start empty")
	GameState.add_fragment("test_fragment")
	assert(GameState.has_fragment("test_fragment"), "GameState should contain test_fragment")
	print("✓ GameState test passed.")
	
	CheckpointManager.current_checkpoint_id = "checkpoint_1"
	CheckpointManager.current_checkpoint_pos = Vector3(1, 2, 3)
	assert(CheckpointManager.current_checkpoint_id == "checkpoint_1", "Checkpoint ID matched")
	print("✓ CheckpointManager test passed.")
	
	print("--- ALL GIMERSIA TESTS PASSED ---")
	get_tree().quit(0)
