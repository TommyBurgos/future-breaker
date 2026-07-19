class_name PlayerPaddle
extends CharacterBody2D

@export var speed := 1300.0
@export var base_width := 220.0
var target_x := 540.0
var giant_timer := 0.0

func _ready() -> void:
	target_x = position.x

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		target_x = event.position.x
	elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		target_x = event.position.x

func _physics_process(delta: float) -> void:
	var keyboard := Input.get_axis("move_left", "move_right")
	if not is_zero_approx(keyboard): target_x += keyboard * speed * delta
	var half_width := base_width * scale.x * 0.5
	target_x = clampf(target_x, half_width + 24.0, 1080.0 - half_width - 24.0)
	position.x = move_toward(position.x, target_x, speed * delta)
	if giant_timer > 0.0:
		giant_timer -= delta
		if giant_timer <= 0.0: _set_giant_visual(false)

func activate_giant(duration: float) -> void:
	scale.x = 2.0
	giant_timer = duration
	_set_giant_visual(true)

func reset_effects() -> void:
	scale.x = 1.0; giant_timer = 0.0; _set_giant_visual(false)

func _set_giant_visual(enabled: bool) -> void:
	if not enabled: scale.x = 1.0
	var glow := get_node_or_null("Glow") as Polygon2D
	var core := get_node_or_null("Core") as Polygon2D
	if glow: glow.color = Color("9c5cff") if enabled else Color("20dfff")
	if core: core.color = Color("f7eaff") if enabled else Color("efffff")
