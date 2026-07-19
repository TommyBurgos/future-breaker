extends Node2D

const LEVELS := [
	preload("res://resources/levels/level_1.tres"),
	preload("res://resources/levels/level_2.tres"),
	preload("res://resources/levels/level_3.tres"),
	preload("res://resources/levels/level_4.tres"),
	preload("res://resources/levels/level_5.tres"),
	preload("res://resources/levels/level_6.tres"),
	preload("res://resources/levels/level_7.tres"),
	preload("res://resources/levels/level_8.tres"),
	preload("res://resources/levels/level_9.tres"),
	preload("res://resources/levels/level_10.tres"),
]
const BALL_SCENE := preload("res://scenes/gameplay/ball.tscn")
const BLOCK_SCENE := preload("res://scenes/gameplay/block.tscn")
const POWER_SCENE := preload("res://scenes/gameplay/power_up.tscn")
const BURST_SCENE := preload("res://scenes/ui/neon_burst.tscn")
const BACKGROUND_LEVELS_1_TO_3 := preload("res://assets/textures/backgrounds/img_nvl1A3.png")
const BACKGROUND_LEVELS_4_TO_5 := preload("res://assets/textures/backgrounds/img_nvl4y5.png")
const BACKGROUND_LEVEL_6 := preload("res://assets/textures/backgrounds/img_nvl6.png")
const GRID_VERTICAL_SPACING := 72.0
const BLOCK_HALF_HEIGHT := 27.0
const DESCENT_INTERVAL := 7.5
const TOUCH_DRAG_THRESHOLD := 28.0
@export var danger_line_y := 1540.0
@export var danger_warning_rows := 2
@export var descent_tween_duration := 0.32
@export_range(0.0, 0.8, 0.01) var background_dim_opacity := 0.18
@onready var paddle: PlayerPaddle = $Paddle
@onready var balls: Node2D = $Balls
@onready var blocks: Node2D = $Blocks
var level: LevelData
var phase_timer := 0.0
var active_balls := 0
var rng := RandomNumberGenerator.new()
var descent_elapsed := 0.0
var blocks_descending := false
var danger_handling := false
var launch_touch_index := -1
var launch_touch_origin := Vector2.ZERO
var launch_touch_dragged := false

func _ready() -> void:
	# Every gameplay scene owns its balls; never carry counters across scenes.
	active_balls = 0
	phase_timer = 0.0
	descent_elapsed = 0.0
	blocks_descending = false
	danger_handling = false
	level = LEVELS[GameStateManager.current_level - 1]
	_apply_level_background(level.level_number)
	GameStateManager.start(level.level_number)
	AudioManager.play_game_music(level.level_number)
	SignalBus.block_destroyed.connect(_on_block_destroyed)
	SignalBus.power_up_collected.connect(_on_power_up_collected)
	SignalBus.game_won.connect(_show_win)
	SignalBus.game_lost.connect(_show_loss)
	SignalBus.ball_speed_multiplier_changed.connect(_on_ball_speed_multiplier_changed)
	_build_level(); _spawn_ball(true); _bind_hud()
	_refresh_launch_prompt()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_handle_launch_touch(event)
		return
	if event is InputEventScreenDrag:
		_handle_launch_drag(event)
		return
	# Touch-generated mouse presses arrive while the touch sequence is active.
	# Ignoring them prevents one physical touch from taking both input paths.
	if event is InputEventMouseButton:
		if event.device != InputEvent.DEVICE_ID_EMULATION and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and launch_touch_index < 0:
			_try_launch_waiting_ball()
		return
	if event is InputEventKey and event.is_action_pressed("launch_ball", false):
		_try_launch_waiting_ball()

func _handle_launch_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		if launch_touch_index < 0 and _can_launch_waiting_ball():
			launch_touch_index = event.index
			launch_touch_origin = event.position
			launch_touch_dragged = false
		return
	if event.index != launch_touch_index:
		return
	var was_tap := not launch_touch_dragged and event.position.distance_to(launch_touch_origin) <= TOUCH_DRAG_THRESHOLD
	_reset_launch_touch()
	if was_tap:
		_try_launch_waiting_ball()

func _handle_launch_drag(event: InputEventScreenDrag) -> void:
	if event.index == launch_touch_index and event.position.distance_to(launch_touch_origin) > TOUCH_DRAG_THRESHOLD:
		launch_touch_dragged = true

func _reset_launch_touch() -> void:
	launch_touch_index = -1
	launch_touch_origin = Vector2.ZERO
	launch_touch_dragged = false

func _can_launch_waiting_ball() -> bool:
	if get_tree().paused or GameStateManager.ended or not GameStateManager.gameplay_active:
		return false
	if danger_handling or GameStateManager.launched_ball_count > 0:
		return false
	for child: Node in balls.get_children():
		if child is EnergyBall and is_instance_valid(child) and child.attached and child.visible:
			return true
	return false

func _try_launch_waiting_ball() -> void:
	if not _can_launch_waiting_ball():
		return
	for child: Node in balls.get_children():
		if child is EnergyBall and is_instance_valid(child) and child.attached and child.visible:
			child.launch()
			return

func _refresh_launch_prompt() -> void:
	var prompt := $HUD/LaunchPrompt as Label
	prompt.text = "TOCA PARA LANZAR" if OS.has_feature("mobile") else "PRESIONA ESPACIO O HAZ CLIC PARA LANZAR"
	prompt.visible = _can_launch_waiting_ball()

func _apply_level_background(level_number: int) -> void:
	var background_texture: Texture2D
	if level_number <= 3:
		background_texture = BACKGROUND_LEVELS_1_TO_3
	elif level_number <= 5:
		background_texture = BACKGROUND_LEVELS_4_TO_5
	else:
		background_texture = BACKGROUND_LEVEL_6
	$GameplayBackground/LevelTexture.texture = background_texture
	$GameplayBackground/DimOverlay.color = Color(0.005, 0.012, 0.04, background_dim_opacity)

func _exit_tree() -> void:
	_disconnect_global_signals()

func _process(delta: float) -> void:
	if phase_timer > 0.0:
		phase_timer -= delta
		SignalBus.publish_active_power_up("Phase Ball", maxf(phase_timer, 0.0))
		if phase_timer <= 0.0:
			for ball: Node in balls.get_children():
				if ball is EnergyBall: ball.set_phase(false)
	_update_block_descent(delta)

func _update_block_descent(delta: float) -> void:
	if danger_handling or blocks_descending or GameStateManager.ended: return
	if GameStateManager.launched_ball_count <= 0: return
	descent_elapsed += delta
	if descent_elapsed >= DESCENT_INTERVAL:
		descent_elapsed -= DESCENT_INTERVAL
		_descend_all_blocks()

func _descend_all_blocks() -> void:
	if blocks_descending or danger_handling: return
	blocks_descending = true
	var target_position := blocks.position + Vector2(0, GRID_VERTICAL_SPACING)
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(blocks, "position", target_position, descent_tween_duration)
	await tween.finished
	blocks_descending = false
	if GameStateManager.ended or danger_handling: return
	if _has_block_crossed_danger_line():
		_handle_danger_limit()
	else:
		_refresh_danger_warning()

func _has_block_crossed_danger_line() -> bool:
	for child: Node in blocks.get_children():
		if child is BreakerBlock and is_instance_valid(child):
			if child.global_position.y + BLOCK_HALF_HEIGHT >= danger_line_y:
				return true
	return false

func _refresh_danger_warning() -> void:
	var warning := $HUD/DangerWarning as Label
	var lowest_edge := -INF
	for child: Node in blocks.get_children():
		if child is BreakerBlock and is_instance_valid(child):
			lowest_edge = maxf(lowest_edge, child.global_position.y + BLOCK_HALF_HEIGHT)
	if is_inf(lowest_edge):
		warning.visible = false
		return
	var rows_remaining := ceili((danger_line_y - lowest_edge) / GRID_VERTICAL_SPACING)
	if rows_remaining <= danger_warning_rows:
		warning.text = "⚠  PELIGRO: MATRIZ A %d FILA%s" % [maxi(rows_remaining, 1), "" if rows_remaining == 1 else "S"]
		warning.visible = true
		var tween := create_tween()
		tween.tween_property(warning, "modulate:a", 0.45, 0.16)
		tween.tween_property(warning, "modulate:a", 1.0, 0.16)
	else:
		warning.visible = false

func _handle_danger_limit() -> void:
	if danger_handling or GameStateManager.ended: return
	danger_handling = true
	descent_elapsed = 0.0
	GameStateManager.set_launched_ball_count(0)
	GameStateManager.reset_ball_speed(false)
	_clear_runtime_level()
	var has_lives_remaining := GameStateManager.lose_life()
	if has_lives_remaining:
		await get_tree().process_frame
		blocks.position = Vector2.ZERO
		_build_level()
		await get_tree().create_timer(0.55).timeout
		_spawn_ball(true)
	danger_handling = false

func _clear_runtime_level() -> void:
	_reset_launch_touch()
	active_balls = 0
	phase_timer = 0.0
	paddle.reset_effects()
	$HUD/DangerWarning.visible = false
	for child: Node in balls.get_children():
		if child is EnergyBall:
			child.visible = false
			child.set_physics_process(false)
		child.queue_free()
	for child: Node in blocks.get_children():
		child.queue_free()
	for child: Node in get_children():
		if child is FallingPowerUp: child.queue_free()

func _build_level() -> void:
	var columns := 8
	for row in level.rows.size():
		for column in columns:
			var type := level.cell_type(row, column)
			if type == 0: continue
			var block := BLOCK_SCENE.instantiate() as BreakerBlock
			blocks.add_child(block); block.position = Vector2(92 + column * 128, 340 + row * 72); block.configure(type)

func _spawn_ball(attached: bool, custom_direction := Vector2.ZERO) -> void:
	if active_balls >= 5: return
	var ball := BALL_SCENE.instantiate() as EnergyBall
	balls.add_child(ball)
	ball.fell.connect(_on_ball_fell)
	ball.launched.connect(_on_ball_launched)
	ball.setup(paddle, level.ball_speed, GameStateManager.ball_speed_multiplier)
	if phase_timer > 0.0: ball.set_phase(true)
	if not attached: ball.global_position = paddle.global_position + Vector2(0, -80); ball.launch(custom_direction)
	active_balls += 1
	_sync_launched_ball_count()
	_refresh_launch_prompt()

func _on_ball_launched(_ball: EnergyBall) -> void:
	_sync_launched_ball_count()
	_reset_launch_touch()
	_refresh_launch_prompt()

func _on_ball_fell(ball: EnergyBall) -> void:
	active_balls -= 1
	_sync_launched_ball_count()
	ball.queue_free()
	if active_balls == 0 and not GameStateManager.ended:
		descent_elapsed = 0.0
		GameStateManager.reset_ball_speed(false)
		if GameStateManager.lose_life(): await get_tree().create_timer(0.7).timeout; _spawn_ball(true)

func _sync_launched_ball_count() -> void:
	var launched_count := 0
	for child: Node in balls.get_children():
		if child is EnergyBall and is_instance_valid(child) and not child.attached and child.visible:
			launched_count += 1
	GameStateManager.set_launched_ball_count(launched_count)

func _on_block_destroyed(_points: int, spawn_position: Vector2) -> void:
	if bool(SaveManager.data.settings.get("visual_effects", true)):
		var burst := BURST_SCENE.instantiate() as CPUParticles2D
		burst.position = spawn_position
		add_child(burst)
		_play_screen_shake()
	if rng.randf() <= 0.2:
		var power := POWER_SCENE.instantiate() as FallingPowerUp
		power.id = [&"giant_paddle", &"multi_ball", &"phase_ball"][rng.randi_range(0, 2)]
		power.position = spawn_position
		add_child(power)
	await get_tree().process_frame
	if not danger_handling and get_tree().get_nodes_in_group("destructible_blocks").is_empty(): GameStateManager.win()

func _on_power_up_collected(id: StringName, duration: float) -> void:
	GameStateManager.reset_ball_speed(false)
	if id == &"giant_paddle":
		paddle.activate_giant(duration)
		SignalBus.publish_active_power_up("Giant Paddle", duration)
	elif id == &"multi_ball":
		call_deferred("_activate_multi_ball")
		SignalBus.publish_active_power_up("Multi Ball", 0)
	elif id == &"phase_ball":
		phase_timer = duration
		for ball: Node in balls.get_children():
			if ball is EnergyBall: ball.set_phase(true)

func _activate_multi_ball() -> void:
	if GameStateManager.ended or not is_inside_tree(): return
	_spawn_ball(false, Vector2(-0.55, -0.84))
	_spawn_ball(false, Vector2(0.55, -0.84))

func _bind_hud() -> void:
	SignalBus.score_changed.connect(_on_score_changed)
	SignalBus.lives_changed.connect(_on_lives_changed)
	SignalBus.active_power_up_changed.connect(_on_active_power_up_changed)
	$HUD/Margin/VBox/Top/Level.text = "NIVEL\n%d" % level.level_number
	$HUD/Margin/VBox/Top/Record.text = "RÉCORD\n%06d" % int(SaveManager.data.high_score)
	_on_score_changed(GameStateManager.score)
	_on_lives_changed(GameStateManager.lives)

func _on_score_changed(value: int) -> void:
	$HUD/Margin/VBox/Top/Score.text = "PUNTOS\n%06d" % value

func _on_lives_changed(value: int) -> void:
	$HUD/Margin/VBox/Top/Lives.text = "VIDAS\n" + "◆".repeat(maxi(value, 0))

func _on_active_power_up_changed(label: String, remaining: float) -> void:
	$HUD/Margin/VBox/Power.text = label + (" %.1fs" % remaining if remaining > 0 else "")

func _on_ball_speed_multiplier_changed(multiplier: float, show_effect: bool) -> void:
	for child: Node in balls.get_children():
		if child is EnergyBall and is_instance_valid(child):
			child.set_speed_multiplier(multiplier)
	if show_effect:
		_show_speed_boost(multiplier)

func _show_speed_boost(multiplier: float) -> void:
	var label := $HUD/SpeedBoost as Label
	label.text = "VELOCIDAD  x%.2f" % multiplier
	label.visible = true
	label.modulate = Color(0.35, 0.95, 1.0, 0.0)
	label.scale = Vector2(0.88, 0.88)
	label.pivot_offset = label.size * 0.5
	var tween := create_tween().set_parallel(true)
	tween.tween_property(label, "modulate:a", 1.0, 0.12)
	tween.tween_property(label, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.chain().tween_interval(0.55)
	tween.chain().tween_property(label, "modulate:a", 0.0, 0.22)
	tween.chain().tween_callback(func(): label.visible = false)

func _play_screen_shake() -> void:
	if is_instance_valid(get_tree().current_scene) and get_tree().current_scene != self: return
	var origin := position
	var tween := create_tween()
	tween.tween_property(self, "position", origin + Vector2(5, -3), 0.035)
	tween.tween_property(self, "position", origin + Vector2(-4, 2), 0.045)
	tween.tween_property(self, "position", origin, 0.055)

func _disconnect_global_signals() -> void:
	var connections: Array[Array] = [
		[SignalBus.block_destroyed, _on_block_destroyed],
		[SignalBus.power_up_collected, _on_power_up_collected],
		[SignalBus.game_won, _show_win],
		[SignalBus.game_lost, _show_loss],
		[SignalBus.score_changed, _on_score_changed],
		[SignalBus.lives_changed, _on_lives_changed],
		[SignalBus.active_power_up_changed, _on_active_power_up_changed],
		[SignalBus.ball_speed_multiplier_changed, _on_ball_speed_multiplier_changed],
	]
	for connection: Array in connections:
		var event: Signal = connection[0]
		var callback: Callable = connection[1]
		if event.is_connected(callback):
			event.disconnect(callback)

func _show_win(_score: int) -> void:
	_reset_launch_touch()
	$HUD/LaunchPrompt.visible = false
	get_tree().paused = true
	_show_overlay($HUD/WinPanel)
func _show_loss(_score: int) -> void:
	_reset_launch_touch()
	$HUD/LaunchPrompt.visible = false
	get_tree().paused = true
	_show_overlay($HUD/LosePanel)
func _on_pause_pressed() -> void:
	_reset_launch_touch()
	$HUD/LaunchPrompt.visible = false
	get_tree().paused = true
	_show_overlay($HUD/PausePanel)
func _on_resume_pressed() -> void:
	await _hide_overlay($HUD/PausePanel)
	get_tree().paused = false
	_refresh_launch_prompt()

func _show_overlay(panel: Control) -> void:
	panel.visible = true
	panel.modulate.a = 0.0
	panel.scale = Vector2(0.96, 0.96)
	panel.pivot_offset = panel.size * 0.5
	var tween := create_tween().set_parallel(true)
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(panel, "modulate:a", 1.0, 0.16)
	tween.tween_property(panel, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _hide_overlay(panel: Control) -> void:
	var tween := create_tween().set_parallel(true)
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(panel, "modulate:a", 0.0, 0.12)
	tween.tween_property(panel, "scale", Vector2(0.97, 0.97), 0.12)
	await tween.finished
	panel.visible = false
func _on_retry_pressed() -> void:
	get_tree().paused = false
	SceneManager.go("res://scenes/gameplay/gameplay.tscn")
func _on_menu_pressed() -> void: SceneManager.go("res://scenes/menus/main_menu.tscn")
func _on_next_pressed() -> void:
	get_tree().paused = false
	if GameStateManager.current_level < LEVELS.size():
		GameStateManager.prepare_next_level_transition()
		GameStateManager.current_level += 1
		SaveManager.data.last_level = GameStateManager.current_level
		SaveManager.save_data()
		SceneManager.go("res://scenes/gameplay/gameplay.tscn")
	else:
		_on_menu_pressed()
