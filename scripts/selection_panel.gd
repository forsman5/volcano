class_name SelectionPanel
extends PanelContainer

@onready var _icon: TextureRect = $Margin/HBox/Icon
@onready var _name_lbl: Label = $Margin/HBox/Info/NameLabel
@onready var _health_bar: ProgressBar = $Margin/HBox/Info/HealthBar
@onready var _health_lbl: Label = $Margin/HBox/Info/HealthLabel
@onready var _action_lbl: Label = $Margin/HBox/Info/ActionLabel


func refresh(unit: PlayerUnit) -> void:
	if unit == null or not is_instance_valid(unit):
		visible = false
		return
	visible = true
	_icon.texture = unit.unit_texture
	_name_lbl.text = unit.unit_name
	_health_bar.max_value = unit.max_health
	_health_bar.value = unit.health
	_health_lbl.text = "%d / %d" % [int(unit.health), int(unit.max_health)]

	if not unit._has_pending_attack or not is_instance_valid(unit._pending_attack_target):
		_action_lbl.text = "None"
	else:
		var verb := "Healing" if unit.heals else "Attacking"
		var target := unit._pending_attack_target
		var target_name := (target as BaseUnit).unit_name if target is BaseUnit else "?"
		_action_lbl.text = "%s %s" % [verb, target_name]
