extends Node

const SPEED_INCREASE_INTERVAL := 5.0
const SPEED_INCREASE_FACTOR := 1.05
const MAX_SPEED_MULTIPLIER := 2.0

var score := 0
var lives := 3
var current_level := 1
var ended := false
var ball_speed_multiplier := 1.0
var ball_speed_elapsed := 0.0
var launched_ball_count := 0
var gameplay_active := false
var preserve_speed_for_next_level := false

func _ready() -> void:
	# Explicitly guarantees that the progression timer stops with SceneTree.paused.
	process_mode = Node.PROCESS_MODE_PAUSABLE

func _process(delta: float) -> void:
	if not gameplay_active or ended or launched_ball_count <= 0: return
	if ball_speed_multiplier >= MAX_SPEED_MULTIPLIER: return
	ball_speed_elapsed += delta
	while ball_speed_elapsed >= SPEED_INCREASE_INTERVAL and ball_speed_multiplier < MAX_SPEED_MULTIPLIER:
		ball_speed_elapsed -= SPEED_INCREASE_INTERVAL
		ball_speed_multiplier = minf(ball_speed_multiplier * SPEED_INCREASE_FACTOR, MAX_SPEED_MULTIPLIER)
		SignalBus.publish_ball_speed_multiplier(ball_speed_multiplier, true)

func start(level: int) -> void:
	if preserve_speed_for_next_level:
		preserve_speed_for_next_level = false
	else:
		reset_ball_speed(false)
	current_level = clampi(level, 1, 10)
	score = 0
	lives = 3
	ended = false
	launched_ball_count = 0
	gameplay_active = true
	SignalBus.publish_score(score)
	SignalBus.publish_lives(lives)

func prepare_next_level_transition() -> void:
	preserve_speed_for_next_level = true
	launched_ball_count = 0

func set_gameplay_active(value: bool) -> void:
	gameplay_active = value
	if not value: launched_ball_count = 0

func set_launched_ball_count(value: int) -> void:
	launched_ball_count = maxi(value, 0)

func reset_ball_speed(show_effect := false) -> void:
	ball_speed_multiplier = 1.0
	ball_speed_elapsed = 0.0
	SignalBus.publish_ball_speed_multiplier(ball_speed_multiplier, show_effect)
func add_score(points: int) -> void:
	if ended: return
	score += points
	SignalBus.publish_score(score)
func lose_life() -> bool:
	if ended: return false
	lives -= 1
	SignalBus.publish_lives(lives)
	if lives <= 0: lose()
	return lives > 0
func win() -> void:
	if ended: return
	ended = true
	launched_ball_count = 0
	SaveManager.record_score(current_level, score)
	SaveManager.unlock_level(current_level + 1)
	SignalBus.publish_game_won(score)
func lose() -> void:
	if ended: return
	ended = true
	launched_ball_count = 0
	SaveManager.record_score(current_level, score)
	SignalBus.publish_game_lost(score)
