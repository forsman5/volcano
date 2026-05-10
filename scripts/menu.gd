extends Control

@onready var _config_overlay := $ConfigOverlay
@onready var _ally_spin: SpinBox = $ConfigOverlay/PanelCenter/Panel/Content/AllyRow/AllySpinBox
@onready var _enemy_spin: SpinBox = $ConfigOverlay/PanelCenter/Panel/Content/EnemyRow/EnemySpinBox
@onready var _health_bars_check: CheckBox = $ConfigOverlay/PanelCenter/Panel/Content/HealthBarsRow/HealthBarsCheck
@onready var _speed_spin: SpinBox = $ConfigOverlay/PanelCenter/Panel/Content/SpeedRow/SpeedSpinBox


func _ready() -> void:
	$CenterContainer/VBoxContainer/StartButton.pressed.connect(_on_start_default)
	$CenterContainer/VBoxContainer/CustomButton.pressed.connect(_on_custom_pressed)
	$ConfigOverlay/PanelCenter/Panel/Content/Buttons/StartButton.pressed.connect(_on_config_start)
	$ConfigOverlay/PanelCenter/Panel/Content/Buttons/CancelButton.pressed.connect(_on_config_cancel)


func _on_start_default() -> void:
	GameConfig.ally_count = 2
	GameConfig.enemy_count = 2
	GameConfig.show_health_bars = true
	GameConfig.speed_multiplier = 1.0
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_custom_pressed() -> void:
	_config_overlay.visible = true


func _on_config_cancel() -> void:
	_config_overlay.visible = false


func _on_config_start() -> void:
	GameConfig.ally_count = int(_ally_spin.value)
	GameConfig.enemy_count = int(_enemy_spin.value)
	GameConfig.show_health_bars = _health_bars_check.button_pressed
	GameConfig.speed_multiplier = _speed_spin.value
	get_tree().change_scene_to_file("res://scenes/main.tscn")
