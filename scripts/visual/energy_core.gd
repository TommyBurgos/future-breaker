class_name EnergyCore
extends Control

@export var core_radius := 92.0
@export var animated := true
var elapsed := 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(animated)
	queue_redraw()

func _process(delta: float) -> void:
	elapsed += delta
	rotation = sin(elapsed * 0.35) * 0.035
	queue_redraw()

func _draw() -> void:
	var center := size * 0.5
	var pulse := 1.0 + sin(elapsed * 2.1) * 0.045
	for glow in range(6, 0, -1):
		var glow_radius := core_radius * pulse + glow * 18.0
		draw_circle(center, glow_radius, Color(0.05, 0.55, 1.0, 0.012 * glow))
	for ring in 4:
		var radius := core_radius + 28.0 + ring * 24.0
		var color := Color(0.1, 0.82, 1.0, 0.75 - ring * 0.12) if ring % 2 == 0 else Color(0.62, 0.24, 1.0, 0.65)
		draw_arc(center, radius, elapsed * (0.18 + ring * 0.04) + ring, TAU * (0.62 + ring * 0.05), 56, color, 4.0, true)
	draw_circle(center, core_radius * pulse, Color(0.05, 0.28, 0.65, 0.95))
	draw_circle(center, core_radius * 0.67 * pulse, Color(0.12, 0.76, 1.0, 0.9))
	draw_circle(center, core_radius * 0.34 * pulse, Color(0.83, 0.98, 1.0, 1.0))
	draw_circle(center - Vector2(core_radius * 0.13, core_radius * 0.16), core_radius * 0.11, Color.WHITE)
