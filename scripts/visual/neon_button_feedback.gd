class_name NeonButtonFeedback
extends RefCounted

static func attach(button: Button) -> void:
	button.mouse_entered.connect(func(): _animate(button, Vector2(1.025, 1.025), 0.12))
	button.mouse_exited.connect(func(): _animate(button, Vector2.ONE, 0.12))
	button.button_down.connect(func(): _animate(button, Vector2(0.97, 0.97), 0.06))
	button.button_up.connect(func(): _animate(button, Vector2.ONE, 0.09))

static func _animate(button: Button, target: Vector2, duration: float) -> void:
	button.pivot_offset = button.size * 0.5
	var tween := button.create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "scale", target, duration)
