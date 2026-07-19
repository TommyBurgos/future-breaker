class_name NeonBackground
extends Control

@export var star_count := 72
@export var drift_speed := 8.0
var stars: Array[Vector3] = []
var elapsed := 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var random := RandomNumberGenerator.new()
	random.seed = 24071996
	for _index in star_count:
		stars.append(Vector3(random.randf(), random.randf(), random.randf_range(0.7, 2.3)))
	queue_redraw()

func _process(delta: float) -> void:
	elapsed += delta
	queue_redraw()

func _draw() -> void:
	var area := size
	draw_rect(Rect2(Vector2.ZERO, area), Color("030817"))
	# Layered translucent bands approximate a deep gradient without a shader.
	for band in 12:
		var ratio := float(band) / 12.0
		var color := Color(0.015 + ratio * 0.025, 0.025, 0.11 + ratio * 0.07, 0.36)
		draw_rect(Rect2(0, area.y * ratio, area.x, area.y / 12.0 + 2.0), color)
	for star in stars:
		var y := fmod(star.y * area.y + elapsed * drift_speed * star.z, maxf(area.y, 1.0))
		var pulse := 0.5 + 0.5 * sin(elapsed * star.z + star.x * 12.0)
		var star_color := Color(0.25, 0.72, 1.0, 0.35 + pulse * 0.45)
		draw_circle(Vector2(star.x * area.x, y), star.z, star_color)
	# Sparse cosmic haze.
	draw_circle(Vector2(area.x * 0.82, area.y * 0.3), area.x * 0.42, Color(0.18, 0.03, 0.4, 0.055))
	draw_circle(Vector2(area.x * 0.12, area.y * 0.72), area.x * 0.34, Color(0.0, 0.42, 0.65, 0.045))
