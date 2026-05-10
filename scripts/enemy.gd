class_name EnemyUnit
extends BaseUnit

enum BehaviorType { MELEE_CHASER, RANGED_FLEEING }

@export var behavior: BehaviorType = BehaviorType.MELEE_CHASER

@onready var _sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	max_health = 80.0
	is_melee = (behavior == BehaviorType.MELEE_CHASER)
	attack_range = 60.0 if is_melee else 350.0
	attack_damage = 20.0
	super._ready()
	if unit_texture:
		_sprite.texture = unit_texture


func _physics_process(_delta: float) -> void:
	if not _is_executing:
		return
	_try_melee_attack()


func begin_execution() -> void:
	_is_executing = true
	var nearest := _nearest_hero()
	if nearest == null:
		return
	set_pending_attack(nearest)


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
