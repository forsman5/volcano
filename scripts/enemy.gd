class_name EnemyUnit
extends BaseUnit

enum BehaviorType { MELEE_CHASER, RANGED_FLEEING }

signal clicked(enemy: EnemyUnit)

@export var behavior: BehaviorType = BehaviorType.MELEE_CHASER

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _area: Area2D = $Area2D


func _ready() -> void:
	max_health = 80.0
	is_melee = (behavior == BehaviorType.MELEE_CHASER)
	attack_range = 60.0 if is_melee else 350.0
	attack_damage = 20.0
	super._ready()
	if unit_texture:
		_sprite.texture = unit_texture
	_area.input_event.connect(_on_area_input_event)


func set_selected(selected: bool) -> void:
	_sprite.modulate = Color(1.0, 0.5, 0.5) if selected else Color.WHITE


func pick_target() -> void:
	for s in _status_effects:
		if s is TauntEffect:
			var te := s as TauntEffect
			if is_instance_valid(te.taunter):
				set_pending_attack(te.taunter)
				return
	var nearest := _nearest_hero()
	if nearest == null:
		return
	set_pending_attack(nearest)


func begin_execution() -> void:
	super.begin_execution()


func end_execution() -> void:
	super.end_execution()
	_has_pending_attack = false
	_pending_attack_target = null


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


func _on_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if not GameConfig.show_enemy_pending:
		return
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
			clicked.emit(self)
