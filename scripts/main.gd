extends Node2D

var selected_unit: PlayerUnit = null

@onready var _player: PlayerUnit = $PlayerUnit


func _ready() -> void:
	_player.clicked.connect(_on_unit_clicked)


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
