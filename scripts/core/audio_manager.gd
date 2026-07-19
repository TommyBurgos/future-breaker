extends Node

const MENU_TRACK := &"menu"
const LEVELS_1_TO_5_TRACK := &"levels_1_5"
const LEVELS_6_TO_10_TRACK := &"levels_6_10"
const LEVELS_11_PLUS_TRACK := &"levels_11_plus"
var MENU_STREAM: AudioStream
var LEVELS_1_TO_5_STREAM: AudioStream
var LEVELS_6_TO_10_STREAM: AudioStream
var LEVELS_11_PLUS_STREAM: AudioStream
var BRICK_HIT_STREAM: AudioStream
var INDESTRUCTIBLE_HIT_STREAM: AudioStream
const FADE_OUT_SECONDS := 0.32
const FADE_IN_SECONDS := 0.48
const SILENT_DB := -45.0
const SFX_POOL_SIZE := 8
const MAX_SIMULTANEOUS_PER_SOUND := 3
const SAME_SFX_COOLDOWN_MS := 28
const BRICK_HIT_GAIN_DB := 16.0
const INDESTRUCTIBLE_HIT_GAIN_DB := 17.0

var music_player: AudioStreamPlayer
var transition: Tween
var current_track_id: StringName = &""
var pending_track_id: StringName = &""
var sfx_players: Array[AudioStreamPlayer] = []
var last_sfx_started_ms: Dictionary = {}

func _ready() -> void:
	MENU_STREAM = load("res://assets/audio/music/space.mp3")
	LEVELS_1_TO_5_STREAM = load("res://assets/audio/music/TallGrass.mp3")
	LEVELS_6_TO_10_STREAM = load("res://assets/audio/music/TallGrass2.mp3")
	LEVELS_11_PLUS_STREAM = load("res://assets/audio/music/cyberpunk-gaming.mp3")
	BRICK_HIT_STREAM = load("res://assets/audio/sfx/brick_hit.wav")
	INDESTRUCTIBLE_HIT_STREAM = load("res://assets/audio/sfx/indestructible_hit.wav")	
	_ensure_audio_buses()
	_configure_music_streams()
	music_player = AudioStreamPlayer.new()
	music_player.name = "MusicPlayer"
	music_player.bus = &"Music"
	music_player.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(music_player)
	_build_sfx_pool()
	apply_settings()

func apply_settings() -> void:
	var settings: Dictionary = SaveManager.data.get("settings", {})
	_set_bus("Master", float(settings.get("master", 1.0)))
	_set_bus("Music", float(settings.get("music", 0.8)))
	_set_bus("SFX", float(settings.get("sfx", 0.9)))

func play_menu_music() -> void:
	_request_music(MENU_TRACK, MENU_STREAM)

func play_game_music(level_number: int) -> void:
	var selection := get_track_for_level(level_number)
	_request_music(selection.id, selection.stream)

func play_for_scene(scene_path: String, level_number: int) -> void:
	if scene_path == "res://scenes/gameplay/gameplay.tscn":
		play_game_music(level_number)
	else:
		play_menu_music()

func get_track_for_level(level_number: int) -> Dictionary:
	if level_number <= 5:
		return {"id": LEVELS_1_TO_5_TRACK, "stream": LEVELS_1_TO_5_STREAM}
	if level_number <= 10:
		return {"id": LEVELS_6_TO_10_TRACK, "stream": LEVELS_6_TO_10_STREAM}
	return {"id": LEVELS_11_PLUS_TRACK, "stream": LEVELS_11_PLUS_STREAM}

func stop_music(fade_out := true) -> void:
	if not is_instance_valid(music_player): return
	_kill_transition()
	pending_track_id = &""
	if fade_out and music_player.playing:
		transition = create_tween()
		transition.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		transition.tween_property(music_player, "volume_db", SILENT_DB, FADE_OUT_SECONDS)
		transition.tween_callback(_stop_player)
	else:
		_stop_player()

func play_sfx(id: StringName) -> void:
	var stream := _get_sfx_stream(id)
	if stream == null: return
	var now := Time.get_ticks_msec()
	if now - int(last_sfx_started_ms.get(id, -SAME_SFX_COOLDOWN_MS)) < SAME_SFX_COOLDOWN_MS: return
	var same_sound_count := 0
	var available_player: AudioStreamPlayer = null
	for player: AudioStreamPlayer in sfx_players:
		if player.playing and player.stream == stream:
			same_sound_count += 1
		elif not player.playing and available_player == null:
			available_player = player
	if same_sound_count >= MAX_SIMULTANEOUS_PER_SOUND or available_player == null: return
	last_sfx_started_ms[id] = now
	available_player.stream = stream
	available_player.volume_db = BRICK_HIT_GAIN_DB if id == &"brick_hit" else INDESTRUCTIBLE_HIT_GAIN_DB
	available_player.pitch_scale = randf_range(0.97, 1.03) if id == &"brick_hit" else randf_range(0.92, 0.98)
	available_player.play()

func _get_sfx_stream(id: StringName) -> AudioStream:
	if id == &"brick_hit": return BRICK_HIT_STREAM
	if id == &"indestructible_hit": return INDESTRUCTIBLE_HIT_STREAM
	return null

func _build_sfx_pool() -> void:
	for index in SFX_POOL_SIZE:
		var player := AudioStreamPlayer.new()
		player.name = "SFXPlayer%d" % index
		player.bus = &"SFX"
		player.process_mode = Node.PROCESS_MODE_ALWAYS
		add_child(player)
		sfx_players.append(player)

func _ensure_audio_buses() -> void:
	for bus_name: StringName in [&"Music", &"SFX"]:
		if AudioServer.get_bus_index(bus_name) >= 0: continue
		AudioServer.add_bus()
		var bus_index := AudioServer.bus_count - 1
		AudioServer.set_bus_name(bus_index, bus_name)
		AudioServer.set_bus_send(bus_index, &"Master")

func _request_music(track_id: StringName, stream: AudioStream) -> void:
	if not is_instance_valid(music_player) or stream == null: return
	if track_id == current_track_id and music_player.playing: return
	if track_id == pending_track_id: return
	pending_track_id = track_id
	_kill_transition()
	transition = create_tween()
	transition.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	if music_player.playing:
		transition.tween_property(music_player, "volume_db", SILENT_DB, FADE_OUT_SECONDS)
	else:
		music_player.volume_db = SILENT_DB
	transition.tween_callback(_swap_stream.bind(track_id, stream))
	transition.tween_property(music_player, "volume_db", 0.0, FADE_IN_SECONDS)

func _swap_stream(track_id: StringName, stream: AudioStream) -> void:
	music_player.stop()
	music_player.stream = stream
	music_player.play()
	current_track_id = track_id
	pending_track_id = &""

func _stop_player() -> void:
	if is_instance_valid(music_player):
		music_player.stop()
		music_player.stream = null
	current_track_id = &""
	pending_track_id = &""

func _kill_transition() -> void:
	if is_instance_valid(transition): transition.kill()
	transition = null

func _configure_music_streams() -> void:
	for stream: AudioStream in [MENU_STREAM, LEVELS_1_TO_5_STREAM, LEVELS_6_TO_10_STREAM, LEVELS_11_PLUS_STREAM]:
		if stream is AudioStreamMP3:
			(stream as AudioStreamMP3).loop = true

func _set_bus(bus_name: String, value: float) -> void:
	var index := AudioServer.get_bus_index(bus_name)
	if index < 0: return
	var muted := value <= 0.001
	AudioServer.set_bus_mute(index, muted)
	if not muted: AudioServer.set_bus_volume_db(index, linear_to_db(clampf(value, 0.001, 1.0)))

func _notification(what: int) -> void:
	if not is_instance_valid(music_player): return
	if what == NOTIFICATION_APPLICATION_PAUSED:
		music_player.stream_paused = true
	elif what == NOTIFICATION_APPLICATION_RESUMED:
		music_player.stream_paused = false
	elif what == NOTIFICATION_WM_CLOSE_REQUEST:
		music_player.stop()
		_stop_all_sfx()

func _exit_tree() -> void:
	_kill_transition()
	if is_instance_valid(music_player): music_player.stop()
	_stop_all_sfx()

func _stop_all_sfx() -> void:
	for player: AudioStreamPlayer in sfx_players:
		if is_instance_valid(player): player.stop()
