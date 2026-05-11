class_name BaseUnit
extends CharacterBody2D

signal died

@export var unit_texture: Texture2D
@export var max_health: float = 100.0
@export var is_melee: bool = false
@export var attack_range: float = 200.0
@export var attack_damage: float = 25.0

var health: float
var _is_dead: bool = false

var heals: bool = false
var unit_name: String = ""
var actions: Array[ActionDef] = []

var _pending_attack_target: Node2D = null
var _pending_defend: bool = false
var _pending_taunt: bool = false
var _defend_bonus: float = 0.0
var _has_pending_attack: bool = false
var _has_attacked: bool = false
var _status_effects: Array[StatusEffect] = []

var _health_bar: HealthBar = null


func _ready() -> void:
	health = max_health
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	if GameConfig.show_health_bars:
		_health_bar = HealthBar.new()
		_health_bar.position = Vector2(0.0, -35.0)
		add_child(_health_bar)
		_health_bar.setup(health, max_health)


func set_selected(_selected: bool) -> void:
	pass


func set_pending_attack(target: Node2D) -> void:
	_pending_defend = false
	_pending_taunt = false
	_defend_bonus = 0.0
	_pending_attack_target = target
	_has_pending_attack = true


func set_pending_defend() -> void:
	_pending_attack_target = null
	_pending_taunt = false
	_pending_defend = true
	_defend_bonus = 20.0
	_has_pending_attack = true


func set_pending_taunt(enemy: EnemyUnit) -> void:
	_pending_defend = false
	_pending_attack_target = enemy
	_pending_taunt = true
	_has_pending_attack = true


func has_status(type: StatusEffect.StatusType) -> bool:
	for s in _status_effects:
		if s.type == type:
			return true
	return false


func get_status_duration(type: StatusEffect.StatusType) -> int:
	for s in _status_effects:
		if s.type == type:
			return s.duration
	return 0


func _apply_effect(effect: StatusEffect) -> void:
	_status_effects = _status_effects.filter(func(s): return s.type != effect.type)
	_status_effects.append(effect)


func apply_status(type: StatusEffect.StatusType, duration: int) -> void:
	_apply_effect(StatusEffect.new(type, duration))


func tick_status_effects() -> void:
	for s in _status_effects:
		s.duration -= 1
	_status_effects = _status_effects.filter(func(s): return s.duration > 0)


func ready_for_end_turn() -> Array[String]:
	var w: Array[String] = []
	if not _has_pending_attack:
		w.append("attack remaining")
	return w


func begin_execution() -> void:
	if _pending_defend:
		_apply_effect(DefendEffect.new(_defend_bonus))
	for s in _status_effects:
		s.on_start_of_turn(self)


func end_execution() -> void:
	_has_attacked = false
	_pending_taunt = false
	_pending_defend = false
	for s in _status_effects:
		s.on_end_of_turn(self)
	tick_status_effects()
	if not is_instance_valid(_pending_attack_target):
		_has_pending_attack = false


func execute_attack() -> void:
	if _pending_defend or not _has_pending_attack:
		return
	if not is_instance_valid(_pending_attack_target):
		return
	if _pending_taunt:
		(_pending_attack_target as BaseUnit)._apply_effect(TauntEffect.new(self, 2))
		return
	if heals:
		_pending_attack_target.heal(attack_damage)
	else:
		_pending_attack_target.take_damage(attack_damage)


func heal(amount: float) -> void:
	if _is_dead:
		return
	health = minf(health + amount, max_health)
	if _health_bar:
		_health_bar.setup(health, max_health)


func take_damage(amount: float) -> void:
	if _is_dead:
		return
	health -= amount
	if _health_bar:
		_health_bar.setup(health, max_health)
	if GameConfig.show_combat_text:
		var dmg_label := DamageLabel.new()
		get_parent().add_child(dmg_label)
		dmg_label.global_position = global_position + Vector2(0, -20)
		dmg_label.setup(amount)
	if health <= 0.0:
		_is_dead = true
		die()


func die() -> void:
	died.emit()
	queue_free()
