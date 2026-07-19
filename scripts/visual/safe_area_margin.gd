class_name SafeAreaMargin
extends MarginContainer

@export var base_left := 72
@export var base_top := 72
@export var base_right := 72
@export var base_bottom := 72

func _ready() -> void:
	_apply_safe_area()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and is_inside_tree(): _apply_safe_area()

func _apply_safe_area() -> void:
	var window_size := DisplayServer.window_get_size()
	var viewport_size := get_viewport_rect().size
	if window_size.x <= 0 or window_size.y <= 0: return
	var safe := DisplayServer.get_display_safe_area()
	var scale_to_viewport := Vector2(viewport_size.x / window_size.x, viewport_size.y / window_size.y)
	var left_inset := int(maxf(0.0, safe.position.x * scale_to_viewport.x))
	var top_inset := int(maxf(0.0, safe.position.y * scale_to_viewport.y))
	var right_inset := int(maxf(0.0, (window_size.x - safe.end.x) * scale_to_viewport.x))
	var bottom_inset := int(maxf(0.0, (window_size.y - safe.end.y) * scale_to_viewport.y))
	add_theme_constant_override("margin_left", maxi(base_left, left_inset + 24))
	add_theme_constant_override("margin_top", maxi(base_top, top_inset + 24))
	add_theme_constant_override("margin_right", maxi(base_right, right_inset + 24))
	add_theme_constant_override("margin_bottom", maxi(base_bottom, bottom_inset + 24))
