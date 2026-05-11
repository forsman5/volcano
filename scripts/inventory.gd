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

		var class_id := GameConfig.unit_classes[i] if i < GameConfig.unit_classes.size() else 0
		var allowed: Array = ClassData.CLASSES[class_id]["allowed_weapons"]

		if GameConfig.unit_weapons[i] not in allowed:
			GameConfig.unit_weapons[i] = allowed[0]

		var opt := OptionButton.new()
		for w_idx in allowed:
			opt.add_item(WeaponData.WEAPONS[w_idx]["name"])
		opt.selected = allowed.find(GameConfig.unit_weapons[i])

		var idx := i
		var allowed_copy := allowed
		opt.item_selected.connect(func(sel: int) -> void: GameConfig.unit_weapons[idx] = allowed_copy[sel])
		row.add_child(opt)

		_unit_list.add_child(row)


func _on_back() -> void:
	get_tree().change_scene_to_file("res://scenes/class_selection.tscn")


func _on_start() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")
