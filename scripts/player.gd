class_name PlayerUnit
extends CharacterBody2D

signal clicked(unit: PlayerUnit)

@export var move_speed: float = 150.0
@export var unit_texture: Texture2D
@export var max_health: float = 100.0

const ARRIVAL_THRESHOLD: float = 4.0

var health: float = 100.0

var _target_position: Vector2 = Vector2.ZERO
var _is_moving: bool = false

var _pending_target: Vector2 = Vector2.ZERO
var _has_pending: bool = false

@onready var _area: Area2D = $Area2D
@onready var _sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	add_to_group("heroes")
	health = max_health
	move_speed *= GameConfig.speed_multiplier
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	if unit_texture:
		_sprite.texture = unit_texture
	_area.input_event.connect(_on_area_input_event)
	if GameConfig.show_health_bars:
		var bar := HealthBar.new()
		bar.position = Vector2(0.0, -35.0)
		add_child(bar)
		bar.setup(health, max_health)


func _physics_process(_delta: float) -> void:
	if not _is_moving:
		return
	var direction := _target_position - global_position
	if direction.length() <= ARRIVAL_THRESHOLD:
		_is_moving = false
		velocity = Vector2.ZERO
		move_and_slide()
		return
	velocity = direction.normalized() * move_speed
	move_and_slide()


func move_to(pos: Vector2) -> void:
	_target_position = pos
	_is_moving = true


func set_pending_move(pos: Vector2) -> void:
	_pending_target = pos
	_has_pending = true


func ready_for_end_turn() -> String:
	if not _has_pending:
		return "movement remaining"
	return ""


func begin_execution() -> void:
	if _has_pending:
		move_to(_pending_target)


func end_execution() -> void:
	_has_pending = false
	_is_moving = false
	velocity = Vector2.ZERO


func set_selected(selected: bool) -> void:
	_sprite.modulate = Color(0.4, 1.0, 0.4) if selected else Color.WHITE


func _on_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
			clicked.emit(self)
