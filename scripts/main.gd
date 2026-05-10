extends Node2D

var selected_unit: PlayerUnit = null
var _enemies_remaining: int = 0


func _ready() -> void:
	for child in get_children():
		if child is PlayerUnit:
			child.clicked.connect(_on_unit_clicked)
		elif child is EnemyUnit:
			_enemies_remaining += 1
			child.caught.connect(_on_enemy_caught)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_RIGHT and mb.pressed:
			if selected_unit != null:
				selected_unit.move_to(get_global_mouse_position())


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
