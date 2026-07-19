class_name EnergyBall
extends CharacterBody2D

signal fell(ball: EnergyBall)
signal launched(ball: EnergyBall)
@export var speed := 760.0
var base_speed := 760.0
var direction := Vector2(0.45, -1.0).normalized()
var attached := true
var phase_mode := false
var paddle: PlayerPaddle
var trail_points: PackedVector2Array = PackedVector2Array()

func setup(owner_paddle: PlayerPaddle, initial_speed: float, speed_multiplier := 1.0) -> void:
	paddle = owner_paddle
	base_speed = initial_speed
	set_speed_multiplier(speed_multiplier)
	attached = true
	visible = true
	global_position = paddle.global_position + Vector2(0, -52)
	set_physics_process(true)

func launch(custom_direction := Vector2.ZERO) -> void:
	if not attached: return
	if custom_direction != Vector2.ZERO: direction = custom_direction.normalized()
	attached = false
	launched.emit(self)

func set_speed_multiplier(multiplier: float) -> void:
	speed = base_speed * clampf(multiplier, 1.0, 2.0)

func _physics_process(delta: float) -> void:
	if attached:
		if is_instance_valid(paddle): global_position = paddle.global_position + Vector2(0, -52)
		if Input.is_action_just_pressed("launch_ball"): launch()
		_update_trail()
		return
	var collision := move_and_collide(direction * speed * delta)
	if collision:
		var collider := collision.get_collider()
		if collider is BreakerBlock:
			collider.hit()
			if not phase_mode: direction = direction.bounce(collision.get_normal())
		elif collider is PlayerPaddle:
			var offset: float = clampf((global_position.x - collider.global_position.x) / (collider.base_width * collider.scale.x * 0.5), -0.9, 0.9)
			direction = Vector2(offset, -maxf(0.35, 1.0 - absf(offset))).normalized()
		else: direction = direction.bounce(collision.get_normal())
		direction.x = signf(direction.x if not is_zero_approx(direction.x) else 1.0) * maxf(absf(direction.x), 0.18)
		direction.y = signf(direction.y if not is_zero_approx(direction.y) else -1.0) * maxf(absf(direction.y), 0.28)
		direction = direction.normalized()
	if global_position.y > 1980.0:
		set_physics_process(false); visible = false; fell.emit(self)
	_update_trail()

func set_phase(enabled: bool) -> void:
	phase_mode = enabled
	var orb := get_node_or_null("Orb") as Polygon2D
	var halo := get_node_or_null("Halo") as Polygon2D
	if orb: orb.color = Color("fff2ff") if enabled else Color("f5ffff")
	if halo: halo.color = Color(1.0, 0.1, 0.82, 0.34) if enabled else Color(0.08, 0.78, 1.0, 0.28)

func _update_trail() -> void:
	var trail := get_node_or_null("Trail") as Line2D
	if trail == null: return
	trail_points.insert(0, global_position)
	if trail_points.size() > 11: trail_points.resize(11)
	var local_points := PackedVector2Array()
	for world_point in trail_points:
		local_points.append(trail.to_local(world_point))
	trail.points = local_points
	trail.default_color = Color(1.0, 0.1, 0.82, 0.52) if phase_mode else Color(0.08, 0.78, 1.0, 0.48)
