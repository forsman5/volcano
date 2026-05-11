extends Node

const SAVE_PATH := "user://config.cfg"

# Single source of truth for user-configurable fields.
# To add a new persisted field: add it here + one entry in menu.gd's _field_map.
const USER_FIELDS: Array[String] = [
	"ally_count",
	"enemy_count",
	"show_health_bars",
	"show_combat_text",
	"show_enemy_pending",
]

const DEFAULTS := {
	"ally_count": 2,
	"enemy_count": 2,
	"show_health_bars": true,
	"show_combat_text": true,
	"show_enemy_pending": true,
}

var ally_count: int = 2
var enemy_count: int = 2
var show_health_bars: bool = true
var show_combat_text: bool = true
var show_enemy_pending: bool = true
var unit_weapons: Array[int] = []


func _ready() -> void:
	load_config()


func save() -> void:
	var cfg := ConfigFile.new()
	for key in USER_FIELDS:
		cfg.set_value("custom", key, get(key))
	cfg.set_value("custom", "unit_weapons", unit_weapons)
	cfg.save(SAVE_PATH)


func load_config() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return
	for key in USER_FIELDS:
		set(key, cfg.get_value("custom", key, get(key)))
	unit_weapons = Array(cfg.get_value("custom", "unit_weapons", []), TYPE_INT, "", null)


func reset_to_defaults() -> void:
	for key in DEFAULTS:
		set(key, DEFAULTS[key])


func reset_unit_weapons() -> void:
	var needed := ally_count + 1
	while unit_weapons.size() < needed:
		unit_weapons.append(0)
	while unit_weapons.size() > needed:
		unit_weapons.pop_back()
