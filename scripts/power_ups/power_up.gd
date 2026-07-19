class_name FallingPowerUp
extends Area2D

var id: StringName = &"giant_paddle"
var fall_speed := 380.0
var elapsed := 0.0
var collected := false
func _ready() -> void:
	_apply_identity()
func _physics_process(delta: float) -> void:
	elapsed += delta
	position.y += fall_speed * delta
	rotation += delta * 0.8
	scale = Vector2.ONE * (1.0 + sin(elapsed * 4.0) * 0.08)
	if position.y > 1980.0: queue_free()
func _on_body_entered(body: Node2D) -> void:
	if not (body is PlayerPaddle) or collected: return
	collected = true
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	set_physics_process(false)
	call_deferred("_complete_collection")

func _complete_collection() -> void:
	SignalBus.publish_power_up_collected(id, 10.0)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector2(1.7, 1.7), 0.12)
	tween.tween_property(self, "modulate:a", 0.0, 0.12)
	await tween.finished
	queue_free()

func _apply_identity() -> void:
	var diamond := get_node_or_null("Diamond") as Polygon2D
	var halo := get_node_or_null("Halo") as Polygon2D
	var symbol := get_node_or_null("Symbol") as Label
	if diamond == null or symbol == null: return
	if id == &"giant_paddle": diamond.color = Color("159dff"); symbol.text = "↔"
	elif id == &"multi_ball": diamond.color = Color("874dff"); symbol.text = "●●●"
	else: diamond.color = Color("ed2ccc"); symbol.text = "Φ"
	if halo: halo.color = Color(diamond.color.r, diamond.color.g, diamond.color.b, 0.2)
