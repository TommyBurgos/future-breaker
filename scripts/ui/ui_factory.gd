class_name UIFactory
extends RefCounted

const NEON_THEME := preload("res://resources/themes/neon_cosmos_theme.tres")

static func prepare_screen(root: Control) -> void:
	root.theme = NEON_THEME
	var background := NeonBackground.new()
	background.name = "NeonBackground"
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(background)
	var frame := NeonFrame.new()
	frame.name = "NeonFrame"
	frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(frame)

static func screen(root: Control, title: String) -> VBoxContainer:
	prepare_screen(root)
	var margin := SafeAreaMargin.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.base_left = 76
	margin.base_right = 76
	margin.base_top = 112
	margin.base_bottom = 86
	root.add_child(margin)
	var panel := PanelContainer.new()
	panel.add_theme_constant_override("margin_left", 34)
	panel.add_theme_constant_override("margin_right", 34)
	panel.add_theme_constant_override("margin_top", 34)
	panel.add_theme_constant_override("margin_bottom", 34)
	margin.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 23)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(box)
	var heading := Label.new()
	heading.text = title
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_font_size_override("font_size", 58)
	heading.add_theme_color_override("font_color", Color("48e8ff"))
	box.add_child(heading)
	root.modulate.a = 0.0
	root.create_tween().tween_property(root, "modulate:a", 1.0, 0.28)
	return box

static func button(box: VBoxContainer, text: String, callable: Callable) -> Button:
	var control := Button.new()
	control.text = text
	control.custom_minimum_size = Vector2(0, 86)
	control.focus_mode = Control.FOCUS_ALL
	control.pressed.connect(callable)
	box.add_child(control)
	NeonButtonFeedback.attach(control)
	return control

static func label(box: VBoxContainer, text: String, size := 26) -> Label:
	var control := Label.new(); control.text = text; control.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; control.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; control.add_theme_font_size_override("font_size", size); box.add_child(control); return control
