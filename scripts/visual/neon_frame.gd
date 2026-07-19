class_name NeonFrame
extends Control

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED: queue_redraw()

func _draw() -> void:
	var rect := Rect2(Vector2(18, 18), size - Vector2(36, 36))
	draw_style_box(_box(Color(0.03, 0.75, 1.0, 0.82), 3), rect)
	var inner := rect.grow(-12)
	draw_style_box(_box(Color(0.56, 0.22, 1.0, 0.48), 2), inner)

func _box(color: Color, width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0)
	style.border_color = color
	style.set_border_width_all(width)
	style.set_corner_radius_all(28)
	return style
