extends Control

@onready var _unit_list: VBoxContainer = $CenterContainer/Panel/MarginContainer/VBoxContainer/UnitList
@onready var _back_btn: Button = $CenterContainer/Panel/MarginContainer/VBoxContainer/HBoxContainer/BackButton
@onready var _next_btn: Button = $CenterContainer/Panel/MarginContainer/VBoxContainer/HBoxContainer/NextButton


func _ready() -> void:
	_back_btn.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/menu.tscn"))
	_next_btn.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/inventory.tscn"))
	_build_rows()


func _build_rows() -> void:
	var unit_count := GameConfig.ally_count + 1
	GameConfig.reset_unit_classes()
	for i in range(unit_count):
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 12)

		var lbl := Label.new()
		lbl.text = "Player" if i == 0 else "Ally %d" % i
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(lbl)

		var opt := OptionButton.new()
		for c in ClassData.CLASSES:
			opt.add_item(c["name"])
		opt.selected = GameConfig.unit_classes[i]
		var idx := i
		opt.item_selected.connect(func(sel: int) -> void: GameConfig.unit_classes[idx] = sel)
		row.add_child(opt)

		_unit_list.add_child(row)
