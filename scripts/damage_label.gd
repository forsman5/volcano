class_name DamageLabel
extends Node2D

func setup(amount: float) -> void:
	var label := Label.new()
	label.text = "-%d" % int(amount)
	label.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2))
	label.add_theme_font_size_override("font_size", 18)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.position = Vector2(-15.0, 0.0)
	add_child(label)
	var tween := create_tween()
	tween.tween_property(self, "global_position", global_position + Vector2(0, -45), 0.9)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.9)
	tween.tween_callback(queue_free)
