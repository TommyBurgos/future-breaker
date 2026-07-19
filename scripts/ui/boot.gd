extends Control

var progress: ProgressBar
var status: Label
var logo: Label
var portal: EnergyCore

func _ready() -> void:
	AppManager.initialize()
	UIFactory.prepare_screen(self)
	_build_boot_ui()
	_play_intro()

func _build_boot_ui() -> void:
	var margin := SafeAreaMargin.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.base_left = 92
	margin.base_right = 92
	margin.base_top = 170
	margin.base_bottom = 130
	add_child(margin)
	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 25)
	margin.add_child(box)
	logo = Label.new()
	logo.name = "Logo"
	logo.text = "FUTURE\nBREAKER"
	logo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	logo.add_theme_font_size_override("font_size", 78)
	logo.add_theme_color_override("font_color", Color("74efff"))
	logo.add_theme_color_override("font_shadow_color", Color(0.55, 0.12, 1, 0.85))
	logo.add_theme_constant_override("shadow_offset_x", 5)
	logo.add_theme_constant_override("shadow_offset_y", 6)
	box.add_child(logo)
	portal = EnergyCore.new()
	portal.name = "PortalCore"
	portal.core_radius = 116
	portal.custom_minimum_size = Vector2(0, 760)
	box.add_child(portal)
	progress = ProgressBar.new()
	progress.custom_minimum_size = Vector2(0, 28)
	progress.show_percentage = false
	progress.value = 0
	box.add_child(progress)
	status = UIFactory.label(box, "INICIALIZANDO NÚCLEO...", 23)
	status.add_theme_color_override("font_color", Color("9cbcff"))

func _play_intro() -> void:
	await get_tree().process_frame
	if not is_instance_valid(logo) or not is_instance_valid(portal) or not is_instance_valid(progress) or not is_instance_valid(status):
		push_error("Boot UI was not initialized correctly.")
		SceneManager.go("res://scenes/menus/main_menu.tscn")
		return
	logo.modulate.a = 0.0
	portal.modulate.a = 0.0
	portal.scale = Vector2(0.78, 0.78)
	portal.pivot_offset = portal.size * 0.5
	var intro := create_tween().set_parallel(true)
	intro.tween_property(logo, "modulate:a", 1.0, 0.5)
	intro.tween_property(portal, "modulate:a", 1.0, 0.65)
	intro.tween_property(portal, "scale", Vector2.ONE, 0.75).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	var loading := create_tween()
	loading.tween_property(progress, "value", 42.0, 0.35)
	loading.tween_callback(func(): status.text = "CARGANDO MATRIZ ESTELAR...")
	loading.tween_property(progress, "value", 78.0, 0.35)
	loading.tween_callback(func(): status.text = "SINCRONIZACIÓN COMPLETA")
	loading.tween_property(progress, "value", 100.0, 0.25)
	loading.tween_interval(0.18)
	loading.tween_property(self, "modulate:a", 0.0, 0.32)
	loading.tween_callback(func(): SceneManager.go("res://scenes/menus/main_menu.tscn"))
