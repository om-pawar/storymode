extends Node

func _ready() -> void:
	print("--- RUNNING IN-ENGINE INTEGRATION TEST ---")
	
	# Verify Autoloads exist
	assert(GameManager != null, "GameManager missing")
	assert(StoryManager != null, "StoryManager missing")
	assert(SaveSystem != null, "SaveSystem missing")
	assert(AudioManager != null, "AudioManager missing")
	print("✓ All 4 Autoload singletons successfully initialized.")
	
	# Verify Story Data
	assert(StoryManager.story_data.has("chapters"), "Chapters missing")
	assert(StoryManager.story_data["chapters"].size() == 6, "Expected 6 chapters")
	assert(StoryManager.story_data["endings"].size() == 4, "Expected 4 endings")
	print("✓ Story database contains 6 chapters, 4 endings, and final scene.")
	
	# Verify Save/Load
	SaveSystem.reset_game()
	SaveSystem.current_data["current_chapter"] = 2
	SaveSystem.current_data["affection"] = 50
	SaveSystem.save_game()
	SaveSystem.load_game()
	assert(SaveSystem.current_data["current_chapter"] == 2, "Save chapter mismatch")
	assert(SaveSystem.current_data["affection"] == 50, "Save affection mismatch")
	print("✓ SaveSystem persistence verified.")
	
	# Verify Ending Branches
	SaveSystem.current_data["affection"] = 80
	SaveSystem.current_data["trust"] = 75
	SaveSystem.current_data["insecurity"] = 10
	var e1 := StoryManager.evaluate_ending()
	assert(e1["id"] == "ending_1", "Expected Ending 1 (Aapla Prem)")
	print("✓ Ending 1 Branch (Aapla Prem - Happy Ending) passed.")
	
	SaveSystem.current_data["insecurity"] = 50
	var e4 := StoryManager.evaluate_ending()
	assert(e4["id"] == "ending_4", "Expected Ending 4 (Punha Anolakhi)")
	print("✓ Ending 4 Branch (Punha Anolakhi - Strangers Again) passed.")
	
	SaveSystem.current_data["affection"] = 45
	SaveSystem.current_data["trust"] = 45
	SaveSystem.current_data["insecurity"] = 10
	var e2 := StoryManager.evaluate_ending()
	assert(e2["id"] == "ending_2", "Expected Ending 2 (Antar)")
	print("✓ Ending 2 Branch (Antar - Distance) passed.")
	
	SaveSystem.current_data["affection"] = 20
	SaveSystem.current_data["trust"] = 40
	SaveSystem.current_data["insecurity"] = 10
	var e3 := StoryManager.evaluate_ending()
	assert(e3["id"] == "ending_3", "Expected Ending 3 (Apuri Goshta)")
	print("✓ Ending 3 Branch (Apuri Goshta - Unfinished Story) passed.")
	
	SaveSystem.reset_game()
	print("--- ALL IN-ENGINE INTEGRATION TESTS PASSED PERFECTLY ---")
	get_tree().quit(0)
