class_name TauntEffect
extends StatusEffect

var taunter: BaseUnit


func _init(t: BaseUnit, d: int) -> void:
	super._init(StatusEffect.StatusType.TAUNT, d)
	taunter = t
