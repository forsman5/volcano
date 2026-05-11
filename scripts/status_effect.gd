class_name StatusEffect
extends RefCounted

enum StatusType { TAUNT_ALL, DEFEND, TAUNT }

var type: StatusType
var duration: int


func _init(t: StatusType, d: int) -> void:
	type = t
	duration = d


func on_start_of_turn(_unit: BaseUnit) -> void:
	pass


func on_end_of_turn(_unit: BaseUnit) -> void:
	pass
