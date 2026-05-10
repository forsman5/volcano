extends Control

@onready var _config_overlay := $ConfigOverlay
@onready var _ally_spin: SpinBox = $ConfigOverlay/PanelCenter/Panel/Content/AllyRow/AllySpinBox
@onready var _enemy_spin: SpinBox = $ConfigOverlay/PanelCenter/Panel/Content/EnemyRow/EnemySpinBox
@onready var _health_bars_check: CheckBox = $ConfigOverlay/PanelCenter/Panel/Content/HealthBarsRow/HealthBarsCheck
@onready var _speed_spin: SpinBox = $ConfigOverlay/PanelCenter/Panel/Content/SpeedRow/SpeedSpinBox

# Maps GameConfig field name → [control_node, control_property].
# To add a new persisted field: add it here + one entry in game_config.gd's USER_FIELDS.
var _field_map: Dictionary


func _ready() -> void:
	$CenterContainer/VBoxContainer/StartButton.pressed.connect(_on_start_default)
	$CenterContainer/VBoxContainer/CustomButton.pressed.connect(_on_custom_pressed)
	$ConfigOverlay/PanelCenter/Panel/Content/Buttons/ResetButton.pressed.connect(_on_reset_defaults)
	$ConfigOverlay/PanelCenter/Panel/Content/Buttons/StartButton.pressed.connect(_on_config_start)
	$ConfigOverlay/PanelCenter/Panel/Content/Buttons/CancelButton.pressed.connect(_on_config_cancel)
	_field_map = {
		"ally_count":       [_ally_spin,        "value"],
		"enemy_count":      [_enemy_spin,        "value"],
		"show_health_bars": [_health_bars_check, "button_pressed"],
		"speed_multiplier": [_speed_spin,        "value"],
	}
	_sync_ui_from_config()


func _sync_ui_from_config() -> void:
	for key in _field_map:
		_field_map[key][0].set(_field_map[key][1], GameConfig.get(key))


func _sync_config_from_ui() -> void:
	for key in _field_map:
		var raw = _field_map[key][0].get(_field_map[key][1])
		GameConfig.set(key, int(raw) if GameConfig.get(key) is int else raw)


func _on_start_default() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_custom_pressed() -> void:
	_config_overlay.visible = true


func _on_reset_defaults() -> void:
	GameConfig.reset_to_defaults()
	_sync_ui_from_config()


func _on_config_cancel() -> void:
	_config_overlay.visible = false


func _on_config_start() -> void:
	_sync_config_from_ui()
	GameConfig.save()
	get_tree().change_scene_to_file("res://scenes/main.tscn")
