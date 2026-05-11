class_name DefendEffect
extends StatusEffect

var bonus: float
var _health_before: float


func _init(b: float) -> void:
	super._init(StatusEffect.StatusType.DEFEND, 1)
	bonus = b


func on_start_of_turn(unit: BaseUnit) -> void:
	_health_before = unit.health
	unit.health += bonus
	if unit._health_bar:
		unit._health_bar.setup(unit.health, unit.max_health)


func on_end_of_turn(unit: BaseUnit) -> void:
	var damage_taken := (_health_before + bonus) - unit.health
	var unabsorbed := maxf(0.0, damage_taken - bonus)
	unit.health = maxf(1.0, _health_before - unabsorbed)
	if unit._health_bar:
		unit._health_bar.setup(unit.health, unit.max_health)
