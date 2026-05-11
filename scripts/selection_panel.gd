class_name SelectionPanel
extends PanelContainer

const ACTION_BUTTON_SCENE := preload("res://scenes/action_button.tscn")

signal action_selected(index: int)

@onready var _icon: TextureRect = $Margin/HBox/Icon
@onready var _name_lbl: Label = $Margin/HBox/Info/NameLabel
@onready var _health_bar: ProgressBar = $Margin/HBox/Info/HealthBar
@onready var _health_lbl: Label = $Margin/HBox/Info/HealthLabel
@onready var _action_lbl: Label = $Margin/HBox/Info/ActionLabel
@onready var _action_buttons: VBoxContainer = $Margin/HBox/ActionButtons

var _button_group: ButtonGroup
var _displayed_unit: BaseUnit = null


func _ready() -> void:
	_button_group = ButtonGroup.new()


func refresh(unit: BaseUnit) -> void:
	if unit == null or not is_instance_valid(unit):
		visible = false
		_displayed_unit = null
		return
	visible = true
	_icon.texture = unit.unit_texture
	_name_lbl.text = unit.unit_name
	_health_bar.max_value = unit.max_health
	_health_bar.value = unit.health
	_health_lbl.text = "%d / %d" % [int(unit.health), int(unit.max_health)]

	if unit._pending_taunt:
		var target_name := (unit._pending_attack_target as BaseUnit).unit_name if is_instance_valid(unit._pending_attack_target) else "?"
		_action_lbl.text = "Taunting %s" % target_name
	elif unit._pending_defend:
		_action_lbl.text = "Defending +%d" % int(unit._defend_bonus)
	elif not unit._has_pending_attack or not is_instance_valid(unit._pending_attack_target):
		_action_lbl.text = "None"
	else:
		var verb := "Healing" if unit.heals else "Attacking"
		var target := unit._pending_attack_target
		var target_name := (target as BaseUnit).unit_name if target is BaseUnit else "?"
		_action_lbl.text = "%s %s" % [verb, target_name]

	if unit != _displayed_unit:
		_displayed_unit = unit
		_rebuild_action_buttons(unit)


func _rebuild_action_buttons(unit: BaseUnit) -> void:
	for child in _action_buttons.get_children():
		child.queue_free()
	for i in unit.actions.size():
		var btn := ACTION_BUTTON_SCENE.instantiate() as ActionButton
		btn.setup(unit.actions[i], i, _button_group)
		btn.activated.connect(func(idx: int): action_selected.emit(idx))
		_action_buttons.add_child(btn)


func deselect_action_buttons() -> void:
	var pressed := _button_group.get_pressed_button()
	if pressed:
		pressed.button_pressed = false
