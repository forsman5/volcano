class_name PlayerUnit
extends BaseUnit

signal clicked(unit: PlayerUnit)

@onready var _area: Area2D = $Area2D
@onready var _sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	super._ready()
	add_to_group("heroes")
	if unit_texture:
		_sprite.texture = unit_texture
	_area.input_event.connect(_on_area_input_event)


func _physics_process(_delta: float) -> void:
	_move_step()


func set_selected(selected: bool) -> void:
	_sprite.modulate = Color(0.4, 1.0, 0.4) if selected else Color.WHITE


func _on_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
			clicked.emit(self)
