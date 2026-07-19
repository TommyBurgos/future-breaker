extends Control

func _ready() -> void:
	UIFactory.prepare_screen(self)
	_build_layout()
	modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.45)

func _build_layout() -> void:
	var safe_margin := SafeAreaMargin.new()
	safe_margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	safe_margin.base_left = 82
	safe_margin.base_right = 82
	safe_margin.base_top = 88
	safe_margin.base_bottom = 78
	add_child(safe_margin)
	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 18)
	safe_margin.add_child(box)
	var profile := PanelContainer.new()
	profile.custom_minimum_size.y = 126
	box.add_child(profile)
	var profile_row := HBoxContainer.new()
	profile_row.add_theme_constant_override("separation", 22)
	profile.add_child(profile_row)
	var identity := Label.new()
	identity.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	identity.text = "PILOTO  %s\nRANGO  %02d" % [str(SessionManager.session.get("display_name", "SIN SESIÓN")).to_upper(), (SaveManager.data.unlocked_levels as Array).max()]
	identity.add_theme_font_size_override("font_size", 24)
	profile_row.add_child(identity)
	var record := Label.new()
	record.text = "MEJOR PUNTUACIÓN\n%09d" % int(SaveManager.data.high_score)
	record.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	record.add_theme_color_override("font_color", Color("55eaff"))
	record.add_theme_font_size_override("font_size", 24)
	profile_row.add_child(record)
	var logo := Label.new()
	logo.text = "FUTURE\nBREAKER"
	logo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	logo.add_theme_font_size_override("font_size", 72)
	logo.add_theme_color_override("font_color", Color("8cf5ff"))
	logo.add_theme_color_override("font_shadow_color", Color(0.45, 0.12, 1.0, 0.85))
	logo.add_theme_constant_override("shadow_offset_x", 4)
	logo.add_theme_constant_override("shadow_offset_y", 5)
	box.add_child(logo)
	var core := EnergyCore.new()
	core.custom_minimum_size = Vector2(0, 455)
	core.core_radius = 92.0
	box.add_child(core)
	UIFactory.button(box, "▶  INICIAR JUEGO", _start_new_game)
	if SessionManager.is_active():
		UIFactory.button(box, "↻  CONTINUAR", _continue_game)
	UIFactory.button(box, "▦  NIVELES", func(): SceneManager.go("res://scenes/menus/level_selection.tscn"))
	UIFactory.button(box, "⚙  AJUSTES", func(): SceneManager.go("res://scenes/menus/settings.tscn"))
	if not SessionManager.is_active():
		UIFactory.button(box, "◇  INICIAR SESIÓN", func(): SceneManager.go("res://scenes/menus/authentication.tscn"))
	else:
		var status := UIFactory.label(box, "NÚCLEO SINCRONIZADO • NIVEL %d" % int(SaveManager.data.last_level), 21)
		status.add_theme_color_override("font_color", Color("a877ff"))

func _start_new_game() -> void:
	if not SessionManager.is_active():
		SessionManager.play_as_guest()
	GameStateManager.current_level = 1
	SceneManager.go("res://scenes/gameplay/gameplay.tscn")

func _continue_game() -> void:
	GameStateManager.current_level = int(SaveManager.data.last_level)
	SceneManager.go("res://scenes/gameplay/gameplay.tscn")
