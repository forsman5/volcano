class_name Projectile
extends Node2D

var target_unit: Node2D
var speed: float = 500.0
var heals: bool = false

var _cached_target_pos: Vector2


func _ready() -> void:
	if is_instance_valid(target_unit):
		_cached_target_pos = target_unit.global_position
	queue_redraw()


func _draw() -> void:
	draw_circle(Vector2.ZERO, 4.0, Color.GREEN if heals else Color.RED)


func _process(delta: float) -> void:
	if get_tree().paused:
		return
	if is_instance_valid(target_unit):
		_cached_target_pos = target_unit.global_position

	var space := get_world_2d().direct_space_state
	var query := PhysicsRayQueryParameters2D.create(global_position, _cached_target_pos)
	var hit := space.intersect_ray(query)
	if hit and hit.collider is StaticBody2D:
		queue_free()
		return

	var dir := _cached_target_pos - global_position
	if dir.length() <= speed * delta:
		queue_free()
		return
	global_position += dir.normalized() * speed * delta
