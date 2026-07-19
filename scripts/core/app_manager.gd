extends Node

var initialized := false
func initialize() -> void:
	if initialized: return
	initialized = true
	AudioManager.apply_settings()
	AudioManager.play_menu_music()
