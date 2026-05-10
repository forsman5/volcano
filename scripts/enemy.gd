class_name EnemyUnit
extends CharacterBody2D

@export var move_speed: float = 160.0
@export var unit_texture: Texture2D
@export var alert_radius: float = 350.0
@export var catch_distance: float = 60.0

@onready var _sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	if unit_texture:
		_sprite.texture = unit_texture


func _physics_process(_delta: float) -> void:
	var nearest := _nearest_hero()

	if nearest == null:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var dist := global_position.distance_to(nearest.global_position)

	if dist <= catch_distance:
		queue_free()
		return

	if dist <= alert_radius:
		velocity = (global_position - nearest.global_position).normalized() * move_speed
	else:
		velocity = Vector2.ZERO

	move_and_slide()


func _nearest_hero() -> Node2D:
	var heroes := get_tree().get_nodes_in_group("heroes")
	var nearest: Node2D = null
	var nearest_dist := INF
	for hero in heroes:
		var d: float = global_position.distance_to(hero.global_position)
		if d < nearest_dist:
			nearest_dist = d
			nearest = hero
	return nearest
