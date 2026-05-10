extends Node2D

const UNIT_SCENE := preload("res://scenes/player.tscn")
const ENEMY_SCENE := preload("res://scenes/enemy.tscn")
const ALLY_TEXTURES = [
	preload("res://assets/ally1.png"),
	preload("res://assets/ally2.png"),
]
const ENEMY_TEXTURES = [
	preload("res://assets/enemy1.png"),
	preload("res://assets/enemy2.png"),
]

enum TurnPhase { PLANNING, EXECUTING }

var selected_unit: PlayerUnit = null
var _enemies_remaining: int = 0
var _turn_phase := TurnPhase.PLANNING
var _player_units: Array[PlayerUnit] = []
var _enemy_units: Array[EnemyUnit] = []
var _exec_frames: int = 0

@onready var _end_turn_btn: Button = $HUDLayer/EndTurnButton
@onready var _confirm_panel: CanvasLayer = $ConfirmPanel
@onready var _confirm_label: Label = $ConfirmPanel/PanelCenter/Panel/VBox/WarningLabel


func _ready() -> void:
	_spawn_units()
	$PauseMenu/PanelCenter/VBoxContainer/ResumeButton.pressed.connect(_toggle_pause)
	$PauseMenu/PanelCenter/VBoxContainer/MenuButton.pressed.connect(_go_to_menu)
	$PauseMenu/PanelCenter/VBoxContainer/MenuSaveButton.pressed.connect(_go_to_menu_save)
	_end_turn_btn.pressed.connect(_on_end_turn)
	$ConfirmPanel/PanelCenter/Panel/VBox/HBox/ConfirmYes.pressed.connect(_on_confirm_yes)
	$ConfirmPanel/PanelCenter/Panel/VBox/HBox/ConfirmNo.pressed.connect(_on_confirm_no)


func _spawn_units() -> void:
	var player := UNIT_SCENE.instantiate() as PlayerUnit
	player.position = Vector2(200, 324)
	player.clicked.connect(_on_unit_clicked)
	add_child(player)
	_player_units.append(player)

	var ally_positions := _spread_positions(GameConfig.ally_count, 380.0)
	for i in range(GameConfig.ally_count):
		var ally := UNIT_SCENE.instantiate() as PlayerUnit
		ally.position = ally_positions[i]
		ally.unit_texture = ALLY_TEXTURES[i % ALLY_TEXTURES.size()]
		ally.move_speed = 120.0
		ally.clicked.connect(_on_unit_clicked)
		add_child(ally)
		_player_units.append(ally)

	_enemies_remaining = GameConfig.enemy_count
	var enemy_positions := _spread_positions(GameConfig.enemy_count, 900.0)
	for i in range(GameConfig.enemy_count):
		var enemy := ENEMY_SCENE.instantiate() as EnemyUnit
		enemy.position = enemy_positions[i]
		enemy.unit_texture = ENEMY_TEXTURES[i % ENEMY_TEXTURES.size()]
		enemy.caught.connect(_on_enemy_caught)
		add_child(enemy)
		_enemy_units.append(enemy)


func _spread_positions(count: int, x: float) -> Array:
	var positions: Array = []
	if count == 0:
		return positions
	var top := 80.0
	var bottom := 570.0
	var step := (bottom - top) / (count + 1)
	for i in range(count):
		positions.append(Vector2(x, top + step * (i + 1)))
	return positions


func _physics_process(_delta: float) -> void:
	if _turn_phase != TurnPhase.EXECUTING:
		return
	_exec_frames += 1
	if _exec_frames >= GameConfig.budget_ticks:
		_end_execution()


func _draw() -> void:
	if _turn_phase != TurnPhase.PLANNING:
		return
	for unit in _player_units:
		if unit._has_pending:
			draw_circle(unit._pending_target, 6.0, Color(0.3, 0.8, 1.0, 0.8))
			draw_line(unit.global_position, unit._pending_target, Color(0.3, 0.8, 1.0, 0.4), 1.0)
	if selected_unit != null:
		var budget_radius := GameConfig.budget_ticks / 60.0 * selected_unit.move_speed
		draw_arc(selected_unit.global_position, budget_radius, 0.0, TAU, 64, Color(1.0, 1.0, 1.0, 0.15), 1.0)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_ESCAPE and event.pressed:
			if _confirm_panel.visible:
				_on_confirm_no()
			else:
				_toggle_pause()
			return
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_RIGHT and mb.pressed:
			if selected_unit != null and _turn_phase == TurnPhase.PLANNING:
				selected_unit.set_pending_move(get_global_mouse_position())
				queue_redraw()


func _on_end_turn() -> void:
	var warnings: Array[String] = []
	for unit in _player_units:
		var w := unit.ready_for_end_turn()
		if w != "" and w not in warnings:
			warnings.append(w)
	if warnings.is_empty():
		_begin_execution()
	else:
		_show_confirm_panel(warnings)


func _begin_execution() -> void:
	_turn_phase = TurnPhase.EXECUTING
	_exec_frames = 0
	_end_turn_btn.disabled = true
	queue_redraw()
	for unit in _player_units:
		unit.begin_execution()
	for enemy in _enemy_units:
		if is_instance_valid(enemy):
			enemy.begin_execution()


func _end_execution() -> void:
	_turn_phase = TurnPhase.PLANNING
	_end_turn_btn.disabled = false
	for unit in _player_units:
		unit.end_execution()
	for enemy in _enemy_units:
		if is_instance_valid(enemy):
			enemy.end_execution()
	queue_redraw()


func _show_confirm_panel(warnings: Array[String]) -> void:
	_confirm_label.text = "\n".join(warnings)
	_confirm_panel.visible = true


func _on_confirm_yes() -> void:
	_confirm_panel.visible = false
	_begin_execution()


func _on_confirm_no() -> void:
	_confirm_panel.visible = false


func _toggle_pause() -> void:
	get_tree().paused = not get_tree().paused
	$PauseMenu.visible = get_tree().paused


func _go_to_menu() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu.tscn")


func _go_to_menu_save() -> void:
	GameConfig.save()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu.tscn")


func _on_unit_clicked(unit: PlayerUnit) -> void:
	if selected_unit != null and selected_unit != unit:
		selected_unit.set_selected(false)
	selected_unit = unit
	selected_unit.set_selected(true)
	queue_redraw()


func _on_enemy_caught() -> void:
	_enemies_remaining -= 1
	if _enemies_remaining == 0:
		$WinScreen.visible = true
		$WinScreen/CenterContainer/VBoxContainer/MenuButton.pressed.connect(_go_to_menu)
		$WinScreen/CenterContainer/VBoxContainer/MenuSaveButton.pressed.connect(_go_to_menu_save)
