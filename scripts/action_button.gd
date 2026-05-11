class_name ActionButton
extends Button

signal activated(index: int)

var action_index: int = 0


func setup(action: ActionDef, idx: int, group: ButtonGroup) -> void:
	action_index = idx
	text = action.name
	button_group = group
	toggled.connect(func(on: bool):
		if on:
			activated.emit(action_index)
	)
