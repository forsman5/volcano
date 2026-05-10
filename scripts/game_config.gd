extends Node

const SAVE_PATH := "user://config.cfg"

# Single source of truth for user-configurable fields.
# To add a new persisted field: add it here + one entry in menu.gd's _field_map.
const USER_FIELDS: Array[String] = [
	"ally_count",
	"enemy_count",
	"show_health_bars",
	"speed_multiplier",
	"show_combat_text",
]

const DEFAULTS := {
	"ally_count": 2,
	"enemy_count": 2,
	"show_health_bars": true,
	"speed_multiplier": 1.0,
	"show_combat_text": true,
}

var ally_count: int = 2
var enemy_count: int = 2
var show_health_bars: bool = true
var speed_multiplier: float = 1.0
var show_combat_text: bool = true
var budget_ticks: int = 120
var unit_weapons: Array[int] = []


func _ready() -> void:
	load_config()


func save() -> void:
	var cfg := ConfigFile.new()
	for key in USER_FIELDS:
		cfg.set_value("custom", key, get(key))
	cfg.save(SAVE_PATH)


func load_config() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return
	for key in USER_FIELDS:
		set(key, cfg.get_value("custom", key, get(key)))


func reset_to_defaults() -> void:
	for key in DEFAULTS:
		set(key, DEFAULTS[key])


func reset_unit_weapons() -> void:
	unit_weapons.clear()
	for i in range(ally_count + 1):
		unit_weapons.append(0)
