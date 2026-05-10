extends Control

@onready var _unit_list: VBoxContainer = $CenterContainer/Panel/MarginContainer/VBoxContainer/UnitList
@onready var _back_btn: Button = $CenterContainer/Panel/MarginContainer/VBoxContainer/HBoxContainer/BackButton
@onready var _start_btn: Button = $CenterContainer/Panel/MarginContainer/VBoxContainer/HBoxContainer/StartButton


func _ready() -> void:
	_back_btn.pressed.connect(_on_back)
	_start_btn.pressed.connect(_on_start)
	_build_rows()


func _build_rows() -> void:
	var unit_count := GameConfig.ally_count + 1
	while GameConfig.unit_weapons.size() < unit_count:
		GameConfig.unit_weapons.append(0)

	for i in range(unit_count):
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 12)

		var lbl := Label.new()
		lbl.text = "Player" if i == 0 else "Ally %d" % i
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(lbl)

		var opt := OptionButton.new()
		for w in WeaponData.WEAPONS:
			opt.add_item(w["name"])
		opt.selected = GameConfig.unit_weapons[i]
		var idx := i
		opt.item_selected.connect(func(sel: int) -> void: GameConfig.unit_weapons[idx] = sel)
		row.add_child(opt)

		_unit_list.add_child(row)


func _on_back() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn")


func _on_start() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")
