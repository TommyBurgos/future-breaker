extends Node

var changing := false
func go(path: String) -> void:
	if changing or path.is_empty(): return
	changing = true
	get_tree().paused = false
	if path != "res://scenes/gameplay/gameplay.tscn":
		GameStateManager.set_gameplay_active(false)
	AudioManager.play_for_scene(path, GameStateManager.current_level)
	var error := get_tree().change_scene_to_file(path)
	if error != OK: push_error("No se pudo abrir: " + path)
	await get_tree().process_frame
	changing = false
