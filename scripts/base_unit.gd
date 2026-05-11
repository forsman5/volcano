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

var _pending_attack_target: Node2D = null
var _has_pending_attack: bool = false
var _has_attacked: bool = false
var _is_executing: bool = false

var _health_bar: HealthBar = null


func _ready() -> void:
	health = max_health
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	if GameConfig.show_health_bars:
		_health_bar = HealthBar.new()
		_health_bar.position = Vector2(0.0, -35.0)
		add_child(_health_bar)
		_health_bar.setup(health, max_health)


func set_pending_attack(target: Node2D) -> void:
	_pending_attack_target = target
	_has_pending_attack = true


func ready_for_end_turn() -> Array[String]:
	var w: Array[String] = []
	if not _has_pending_attack:
		w.append("attack remaining")
	return w


func begin_execution() -> void:
	_is_executing = true


func end_execution() -> void:
	_has_attacked = false
	_is_executing = false
	if not is_instance_valid(_pending_attack_target):
		_has_pending_attack = false


func _try_melee_attack() -> void:
	if not is_melee or _has_attacked or not _has_pending_attack or not _is_executing:
		return
	if not is_instance_valid(_pending_attack_target):
		return
	_pending_attack_target.take_damage(attack_damage)
	_has_attacked = true


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
