class_name HealthBar
extends Node2D

const BAR_WIDTH := 40.0
const BAR_HEIGHT := 4.0

var _ratio: float = 1.0


func setup(current: float, maximum: float) -> void:
	_ratio = current / maximum if maximum > 0.0 else 0.0
	queue_redraw()


func _draw() -> void:
	draw_rect(
		Rect2(-BAR_WIDTH / 2.0, 0.0, BAR_WIDTH, BAR_HEIGHT),
		Color(0.15, 0.15, 0.15)
	)
	draw_rect(
		Rect2(-BAR_WIDTH / 2.0, 0.0, BAR_WIDTH * _ratio, BAR_HEIGHT),
		Color(0.2, 0.85, 0.2)
	)
