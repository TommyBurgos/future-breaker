extends Control
func _ready() -> void:
	var box := UIFactory.screen(self, "SELECCIÓN DE NIVEL")
	for level in range(1, 11):
		var unlocked: bool = level in SaveManager.data.unlocked_levels
		var score := int(SaveManager.data.level_scores.get(str(level), 0))
		var chosen := level
		var button := UIFactory.button(box, "Nivel %d  •  Récord %06d%s" % [level, score, "" if unlocked else "  BLOQUEADO"], func(): _play(chosen))
		button.disabled = not unlocked
	UIFactory.button(box, "Regresar", func(): SceneManager.go("res://scenes/menus/main_menu.tscn"))
func _play(level: int) -> void:
	if level not in SaveManager.data.unlocked_levels: return
	GameStateManager.current_level = level; SaveManager.data.last_level = level; SaveManager.save_data(); SceneManager.go("res://scenes/gameplay/gameplay.tscn")
