class_name Projectile
extends Node2D

var target_unit: Node2D
var damage: float = 25.0
var speed: float = 500.0
var heals: bool = false


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	draw_circle(Vector2.ZERO, 4.0, Color.GREEN if heals else Color.RED)


func _process(delta: float) -> void:
	if get_tree().paused:
		return
	if not is_instance_valid(target_unit):
		queue_free()
		return

	var target_pos := target_unit.global_position

	var space := get_world_2d().direct_space_state
	var query := PhysicsRayQueryParameters2D.create(global_position, target_pos)
	var hit := space.intersect_ray(query)
	if hit and hit.collider is StaticBody2D:
		queue_free()
		return

	var dir := target_pos - global_position
	if dir.length() <= speed * delta:
		if heals:
			target_unit.heal(damage)
		else:
			target_unit.take_damage(damage)
		queue_free()
		return

	global_position += dir.normalized() * speed * delta
