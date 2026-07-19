extends Node

signal score_changed(score: int)
signal lives_changed(lives: int)
signal block_destroyed(points: int, world_position: Vector2)
signal power_up_collected(id: StringName, duration: float)
signal active_power_up_changed(label: String, remaining: float)
signal game_won(score: int)
signal game_lost(score: int)
signal session_changed
signal save_changed
signal ball_speed_multiplier_changed(multiplier: float, show_effect: bool)

# Centralized publishers keep the bus responsible for its own signals and
# prevent gameplay systems from depending on signal implementation details.
func publish_score(value: int) -> void:
	score_changed.emit(value)

func publish_lives(value: int) -> void:
	lives_changed.emit(value)

func publish_block_destroyed(points: int, world_position: Vector2) -> void:
	block_destroyed.emit(points, world_position)

func publish_power_up_collected(id: StringName, duration: float) -> void:
	power_up_collected.emit(id, duration)

func publish_active_power_up(label: String, remaining: float) -> void:
	active_power_up_changed.emit(label, remaining)

func publish_game_won(final_score: int) -> void:
	game_won.emit(final_score)

func publish_game_lost(final_score: int) -> void:
	game_lost.emit(final_score)

func publish_session_changed() -> void:
	session_changed.emit()

func publish_save_changed() -> void:
	save_changed.emit()

func publish_ball_speed_multiplier(multiplier: float, show_effect: bool) -> void:
	ball_speed_multiplier_changed.emit(multiplier, show_effect)
