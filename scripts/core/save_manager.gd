extends Node

const SAVE_PATH := "user://future_breaker_save.json"
const TEMP_PATH := "user://future_breaker_save.tmp"
const FORMAT_VERSION := 1
var data: Dictionary = {}

func _ready() -> void:
	load_data()

func defaults() -> Dictionary:
	return {"version": FORMAT_VERSION, "guest_id": "", "high_score": 0, "level_scores": {}, "unlocked_levels": [1], "last_level": 1, "session": {}, "settings": {"master": 1.0, "music": 0.8, "sfx": 0.9, "vibration": true, "visual_effects": true}}

func load_data() -> void:
	data = defaults()
	if not FileAccess.file_exists(SAVE_PATH):
		save_data(); return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null: return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		_merge_known(data, parsed)
		_normalize_progress()
		save_data()
	else:
		DirAccess.rename_absolute(ProjectSettings.globalize_path(SAVE_PATH), ProjectSettings.globalize_path(SAVE_PATH + ".corrupt"))
		save_data()

func _normalize_progress() -> void:
	var unlocked: Array = data.get("unlocked_levels", [])
	var highest_unlocked := 1
	for value: Variant in unlocked:
		highest_unlocked = maxi(highest_unlocked, clampi(int(value), 1, 10))
	highest_unlocked = maxi(highest_unlocked, clampi(int(data.get("last_level", 1)), 1, 10))
	var normalized: Array = []
	for level in range(1, highest_unlocked + 1):
		normalized.append(level)
	data.unlocked_levels = normalized
	data.last_level = clampi(int(data.get("last_level", 1)), 1, highest_unlocked)

func _merge_known(target: Dictionary, source: Dictionary) -> void:
	for key: Variant in source:
		if target.has(key):
			if target[key] is Dictionary and source[key] is Dictionary: _merge_known(target[key], source[key])
			else: target[key] = source[key]

func save_data() -> void:
	var file := FileAccess.open(TEMP_PATH, FileAccess.WRITE)
	if file == null: return
	file.store_string(JSON.stringify(data, "  "))
	file.close()
	var target := ProjectSettings.globalize_path(SAVE_PATH)
	if FileAccess.file_exists(SAVE_PATH): DirAccess.remove_absolute(target)
	DirAccess.rename_absolute(ProjectSettings.globalize_path(TEMP_PATH), target)
	SignalBus.publish_save_changed()

func record_score(level: int, score: int) -> void:
	data.high_score = maxi(int(data.high_score), score)
	var key := str(level)
	data.level_scores[key] = maxi(int(data.level_scores.get(key, 0)), score)
	data.last_level = level
	save_data()

func unlock_level(level: int) -> void:
	if level <= 10 and not level in data.unlocked_levels: data.unlocked_levels.append(level)
	save_data()

func reset_progress() -> void:
	var settings: Dictionary = data.get("settings", defaults().settings).duplicate(true)
	data = defaults(); data.settings = settings
	save_data()
