extends Node2D

const UNIT_SCENE := preload("res://scenes/player.tscn")
const ENEMY_SCENE := preload("res://scenes/enemy.tscn")
const PLAYER_TEXTURE := preload("res://assets/player.png")
const SELECTION_PANEL_SCENE := preload("res://scenes/selection_panel.tscn")
const ALLY_TEXTURES = [
	preload("res://assets/ally1.png"),
	preload("res://assets/ally2.png"),
]
const ENEMY_TEXTURES = [
	preload("res://assets/enemy1.png"),
	preload("res://assets/enemy2.png"),
]

var selected_unit: BaseUnit = null
var _enemies_remaining: int = 0
var _player_units: Array[PlayerUnit] = []
var _enemy_units: Array[EnemyUnit] = []
var _overlay: Node2D

var _sel_panel: SelectionPanel
var _active_action_index: int = -1

@onready var _end_turn_btn: Button = $HUDLayer/EndTurnButton
@onready var _confirm_panel: CanvasLayer = $ConfirmPanel
@onready var _confirm_label: Label = $ConfirmPanel/PanelCenter/Panel/VBox/WarningLabel


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_spawn_units()
	_overlay = Node2D.new()
	_overlay.z_index = 1
	add_child(_overlay)
	_overlay.draw.connect(_on_overlay_draw)
	_sel_panel = SELECTION_PANEL_SCENE.instantiate()
	$HUDLayer.add_child(_sel_panel)
	_sel_panel.action_selected.connect(_on_action_selected)
	$PauseMenu/PanelCenter/VBoxContainer/ResumeButton.pressed.connect(_toggle_pause)
	$PauseMenu/PanelCenter/VBoxContainer/MenuButton.pressed.connect(_go_to_menu)
	$PauseMenu/PanelCenter/VBoxContainer/MenuSaveButton.pressed.connect(_go_to_menu_save)
	_end_turn_btn.pressed.connect(_on_end_turn)
	$ConfirmPanel/PanelCenter/Panel/VBox/HBox/ConfirmYes.pressed.connect(_on_confirm_yes)
	$ConfirmPanel/PanelCenter/Panel/VBox/HBox/ConfirmNo.pressed.connect(_on_confirm_no)


func _spawn_units() -> void:
	if GameConfig.unit_weapons.is_empty():
		GameConfig.reset_unit_weapons()

	var use_weapon := ActionDef.new()
	use_weapon.name = "Use Weapon"

	var defend := ActionDef.new()
	defend.name = "Defend"
	defend.targeting = ActionDef.TargetType.SELF

	var player := UNIT_SCENE.instantiate() as PlayerUnit
	player.position = Vector2(200, 324)
	player.unit_texture = PLAYER_TEXTURE
	player.unit_name = "Player"
	player.actions = [use_weapon, defend]
	var pw: Dictionary = WeaponData.WEAPONS[GameConfig.unit_weapons[0]]
	player.is_melee = pw["is_melee"]
	player.attack_range = pw["attack_range"]
	player.attack_damage = pw["attack_damage"]
	player.heals = pw["heals"]
	player.clicked.connect(_on_unit_clicked)
	player.died.connect(func(): _player_units.erase(player))
	add_child(player)
	_player_units.append(player)

	var ally_positions := _spread_positions(GameConfig.ally_count, 380.0)
	for i in range(GameConfig.ally_count):
		var ally := UNIT_SCENE.instantiate() as PlayerUnit
		ally.position = ally_positions[i]
		ally.unit_texture = _pick_texture("ally", i, ALLY_TEXTURES)
		ally.unit_name = "Ally %d" % (i + 1)
		ally.actions = [use_weapon, defend]
		var aw: Dictionary = WeaponData.WEAPONS[GameConfig.unit_weapons[i + 1]]
		ally.is_melee = aw["is_melee"]
		ally.attack_range = aw["attack_range"]
		ally.attack_damage = aw["attack_damage"]
		ally.heals = aw["heals"]
		ally.clicked.connect(_on_unit_clicked)
		ally.died.connect(func(): _player_units.erase(ally))
		add_child(ally)
		_player_units.append(ally)

	_enemies_remaining = GameConfig.enemy_count
	var enemy_positions := _spread_positions(GameConfig.enemy_count, 900.0)
	for i in range(GameConfig.enemy_count):
		var enemy := ENEMY_SCENE.instantiate() as EnemyUnit
		enemy.position = enemy_positions[i]
		enemy.unit_texture = _pick_texture("enemy", i, ENEMY_TEXTURES)
		enemy.unit_name = "Enemy %d" % (i + 1)
		enemy.behavior = EnemyUnit.BehaviorType.RANGED_FLEEING if i == 1 else EnemyUnit.BehaviorType.MELEE_CHASER
		enemy.died.connect(_on_enemy_died)
		enemy.died.connect(func():
			if selected_unit == enemy:
				selected_unit = null
				_update_selection_panel()
		)
		enemy.clicked.connect(_on_unit_clicked)
		add_child(enemy)
		_enemy_units.append(enemy)

	for enemy in _enemy_units:
		enemy.pick_target()


func _pick_texture(prefix: String, index: int, fallbacks: Array) -> Texture2D:
	var path := "res://assets/%s%d.png" % [prefix, index + 1]
	if ResourceLoader.exists(path):
		return load(path)
	return fallbacks[index % fallbacks.size()]


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


func _draw() -> void:
	for child in get_children():
		if child is StaticBody2D:
			var cs := child.get_node_or_null("CollisionShape2D") as CollisionShape2D
			if cs and cs.shape is RectangleShape2D:
				var half := (cs.shape as RectangleShape2D).size / 2.0
				draw_rect(Rect2(child.position - half, (cs.shape as RectangleShape2D).size), Color.BLACK)


func _on_overlay_draw() -> void:
	for unit in _player_units:
		if not is_instance_valid(unit):
			continue
		if unit._has_pending_attack and is_instance_valid(unit._pending_attack_target):
			var col := Color(0.2, 1.0, 0.3, 0.9) if unit.heals else Color(1.0, 0.2, 0.2, 0.9)
			var line_col := Color(0.2, 1.0, 0.3, 0.7) if unit.heals else Color(1.0, 0.2, 0.2, 0.7)
			_overlay.draw_circle(unit._pending_attack_target.global_position, 10.0, col)
			_overlay.draw_line(unit.global_position, unit._pending_attack_target.global_position, line_col, 2.0)
	if GameConfig.show_enemy_pending:
		for enemy in _enemy_units:
			if not is_instance_valid(enemy):
				continue
			if enemy._has_pending_attack and is_instance_valid(enemy._pending_attack_target):
				_overlay.draw_circle(enemy._pending_attack_target.global_position, 10.0, Color(1.0, 0.5, 0.0, 0.9))
				_overlay.draw_line(enemy.global_position, enemy._pending_attack_target.global_position, Color(1.0, 0.5, 0.0, 0.7), 2.0)


func _enemy_at(pos: Vector2) -> EnemyUnit:
	for enemy in _enemy_units:
		if is_instance_valid(enemy) and pos.distance_to(enemy.global_position) <= 30.0:
			return enemy
	return null


func _ally_at(pos: Vector2) -> PlayerUnit:
	for unit in _player_units:
		if is_instance_valid(unit) and unit != selected_unit and pos.distance_to(unit.global_position) <= 30.0:
			return unit
	return null


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
			if selected_unit != null and selected_unit is PlayerUnit:
				var action_idx := _active_action_index if _active_action_index >= 0 else 0
				var current_action: ActionDef = null
				if selected_unit.actions.size() > action_idx:
					current_action = selected_unit.actions[action_idx]

				if current_action != null and current_action.targeting == ActionDef.TargetType.SELF:
					selected_unit.set_pending_defend()
					_reset_action_state()
					_update_selection_panel()
				else:
					var mouse_pos := get_global_mouse_position()
					if selected_unit.heals:
						var target_ally := _ally_at(mouse_pos)
						if target_ally != null:
							selected_unit.set_pending_attack(target_ally)
							_overlay.queue_redraw()
							_reset_action_state()
							_update_selection_panel()
					else:
						var target_enemy := _enemy_at(mouse_pos)
						if target_enemy != null:
							selected_unit.set_pending_attack(target_enemy)
							_overlay.queue_redraw()
							_reset_action_state()
							_update_selection_panel()


func _on_end_turn() -> void:
	var warnings: Array[String] = []
	for unit in _player_units:
		for w in unit.ready_for_end_turn():
			if w not in warnings:
				warnings.append(w)
	if warnings.is_empty():
		_begin_execution()
	else:
		_show_confirm_panel(warnings)


func _begin_execution() -> void:
	_overlay.queue_redraw()
	_reset_action_state()
	_update_selection_panel()

	for unit in _player_units:
		unit.begin_execution()
	for enemy in _enemy_units:
		if is_instance_valid(enemy):
			enemy.begin_execution()

	for unit in _player_units:
		unit.execute_attack()
	for enemy in _enemy_units:
		if is_instance_valid(enemy):
			enemy.execute_attack()

	for unit in _player_units:
		if not unit.is_melee and unit._has_pending_attack and is_instance_valid(unit._pending_attack_target):
			var proj := Projectile.new()
			proj.global_position = unit.global_position
			proj.target_unit = unit._pending_attack_target
			proj.heals = unit.heals
			add_child(proj)
	for enemy in _enemy_units:
		if is_instance_valid(enemy) and not enemy.is_melee and enemy._has_pending_attack and is_instance_valid(enemy._pending_attack_target):
			var proj := Projectile.new()
			proj.global_position = enemy.global_position
			proj.target_unit = enemy._pending_attack_target
			add_child(proj)

	_end_execution()


func _end_execution() -> void:
	for unit in _player_units:
		unit.end_execution()
	for enemy in _enemy_units:
		if is_instance_valid(enemy):
			enemy.end_execution()
			enemy.pick_target()
	_overlay.queue_redraw()
	_update_selection_panel()


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


func _on_unit_clicked(unit: BaseUnit) -> void:
	if selected_unit != null and selected_unit != unit:
		selected_unit.set_selected(false)
		_reset_action_state()
	selected_unit = unit
	selected_unit.set_selected(true)
	_overlay.queue_redraw()
	_update_selection_panel()


func _on_enemy_died() -> void:
	_enemies_remaining -= 1
	if _enemies_remaining == 0:
		$WinScreen.visible = true
		$WinScreen/CenterContainer/VBoxContainer/MenuButton.pressed.connect(_go_to_menu)
		$WinScreen/CenterContainer/VBoxContainer/MenuSaveButton.pressed.connect(_go_to_menu_save)


func _on_action_selected(index: int) -> void:
	_active_action_index = index
	Input.set_default_cursor_shape(Input.CURSOR_CROSS)


func _reset_action_state() -> void:
	_active_action_index = -1
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	_sel_panel.deselect_action_buttons()


func _update_selection_panel() -> void:
	_sel_panel.refresh(selected_unit)
