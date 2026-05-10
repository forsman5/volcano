class_name EnemyUnit
extends BaseUnit

enum BehaviorType { MELEE_CHASER, RANGED_FLEEING }

@export var behavior: BehaviorType = BehaviorType.MELEE_CHASER
@export var alert_radius: float = 350.0

@onready var _sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	max_health = 80.0
	move_speed = 160.0
	is_melee = (behavior == BehaviorType.MELEE_CHASER)
	attack_range = 60.0 if is_melee else 350.0
	attack_damage = 20.0
	super._ready()
	if unit_texture:
		_sprite.texture = unit_texture


func _physics_process(_delta: float) -> void:
	if not _is_executing:
		velocity = Vector2.ZERO
		return
	match behavior:
		BehaviorType.MELEE_CHASER:
			_move_step()
			_try_melee_attack()
		BehaviorType.RANGED_FLEEING:
			_flee_step()


func _flee_step() -> void:
	var nearest := _nearest_hero()
	if nearest == null:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	var dist := global_position.distance_to(nearest.global_position)
	if dist <= alert_radius:
		velocity = (global_position - nearest.global_position).normalized() * move_speed
	else:
		velocity = Vector2.ZERO
	move_and_slide()


func begin_execution() -> void:
	_is_executing = true
	var nearest := _nearest_hero()
	if nearest == null:
		return
	set_pending_attack(nearest)
	if behavior == BehaviorType.MELEE_CHASER:
		move_to(nearest.global_position)


func end_execution() -> void:
	super.end_execution()
	_has_pending_attack = false
	_pending_attack_target = null
	_is_executing = false


func _nearest_hero() -> Node2D:
	var heroes := get_tree().get_nodes_in_group("heroes")
	var nearest: Node2D = null
	var nearest_dist := INF
	for hero in heroes:
		if not is_instance_valid(hero):
			continue
		var d := global_position.distance_to(hero.global_position)
		if d < nearest_dist:
			nearest_dist = d
			nearest = hero
	return nearest
