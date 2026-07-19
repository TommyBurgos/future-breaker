class_name BreakerBlock
extends StaticBody2D

signal destroyed(block: BreakerBlock)
var resistance := 1
var max_resistance := 1
var points := 100
var destructible := true
var already_scored := false

func configure(type: int) -> void:
	if type == 2: resistance = 2; points = 250
	elif type == 3: resistance = 999; points = 0; destructible = false
	max_resistance = resistance
	if destructible: add_to_group("destructible_blocks")
	_refresh_color()

func hit() -> void:
	if already_scored: return
	AudioManager.play_sfx(&"brick_hit" if destructible else &"indestructible_hit")
	if not destructible: return
	resistance -= 1
	if resistance <= 0:
		already_scored = true
		GameStateManager.add_score(points)
		SignalBus.publish_block_destroyed(points, global_position)
		destroyed.emit(self)
		queue_free()
	else:
		_refresh_color()
		var tween := create_tween(); tween.tween_property(self, "modulate", Color.WHITE, 0.12).from(Color(1, 0.2, 0.6))

func _refresh_color() -> void:
	var polygon := get_node_or_null("Polygon2D") as Polygon2D
	var border := get_node_or_null("Border") as Line2D
	var glow := get_node_or_null("Glow") as Polygon2D
	if polygon == null: return
	var base_color := Color("8b4dff") if max_resistance > 1 else Color("10cfee")
	if resistance == 1 and max_resistance > 1: base_color = Color("ec36cf")
	if not destructible: base_color = Color("1c2944")
	polygon.color = base_color
	if border: border.default_color = Color("7688a8") if not destructible else base_color.lightened(0.35)
	if glow: glow.color = Color(base_color.r, base_color.g, base_color.b, 0.16)
