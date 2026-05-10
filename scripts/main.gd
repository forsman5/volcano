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

var selected_unit: PlayerUnit = null
var _enemies_remaining: int = 0


func _ready() -> void:
	_spawn_units()
	$PauseMenu/PanelCenter/VBoxContainer/ResumeButton.pressed.connect(_toggle_pause)
	$PauseMenu/PanelCenter/VBoxContainer/MenuButton.pressed.connect(_go_to_menu)


func _spawn_units() -> void:
	var player := UNIT_SCENE.instantiate() as PlayerUnit
	player.position = Vector2(200, 324)
	player.clicked.connect(_on_unit_clicked)
	add_child(player)

	var ally_positions := _spread_positions(GameConfig.ally_count, 380.0)
	for i in range(GameConfig.ally_count):
		var ally := UNIT_SCENE.instantiate() as PlayerUnit
		ally.position = ally_positions[i]
		ally.unit_texture = ALLY_TEXTURES[i % ALLY_TEXTURES.size()]
		ally.move_speed = 120.0
		ally.clicked.connect(_on_unit_clicked)
		add_child(ally)

	_enemies_remaining = GameConfig.enemy_count
	var enemy_positions := _spread_positions(GameConfig.enemy_count, 900.0)
	for i in range(GameConfig.enemy_count):
		var enemy := ENEMY_SCENE.instantiate() as EnemyUnit
		enemy.position = enemy_positions[i]
		enemy.unit_texture = ENEMY_TEXTURES[i % ENEMY_TEXTURES.size()]
		enemy.caught.connect(_on_enemy_caught)
		add_child(enemy)


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


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_ESCAPE and event.pressed:
			_toggle_pause()
			return
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_RIGHT and mb.pressed:
			if selected_unit != null:
				selected_unit.move_to(get_global_mouse_position())


func _toggle_pause() -> void:
	get_tree().paused = not get_tree().paused
	$PauseMenu.visible = get_tree().paused


func _go_to_menu() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu.tscn")


func _on_unit_clicked(unit: PlayerUnit) -> void:
	if selected_unit != null and selected_unit != unit:
		selected_unit.set_selected(false)
	selected_unit = unit
	selected_unit.set_selected(true)


func _on_enemy_caught() -> void:
	_enemies_remaining -= 1
	if _enemies_remaining == 0:
		$WinScreen.visible = true
		$WinScreen/CenterContainer/VBoxContainer/MenuButton.pressed.connect(
			func(): get_tree().change_scene_to_file("res://scenes/menu.tscn")
		)
