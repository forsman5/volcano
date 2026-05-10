# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Running the game

Open the Godot 4.6 editor and press **F5**, or from the command line:

```powershell
# Open editor
Godot_v4.6.2-stable_win64.exe --editor volcano/project.godot

# Run headless
Godot_v4.6.2-stable_win64.exe volcano/project.godot
```

There is no build step — Godot interprets GDScript directly.

## Web export

`export_and_serve.ps1` (in the project root) exports a release web build and starts a local HTTPS server. Run once to install the cert dependency:

```powershell
pip install cryptography
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

Then just run `.\export_and_serve.ps1`. The web export writes to a `web/` directory.

## Architecture

### Turn phases

The game has two alternating phases managed in `scripts/main.gd`:

- **Planning**: Player selects units, right-clicks to queue moves and attacks. Visualised via `_draw()` (arcs, circles, lines — all redrawn with `queue_redraw()`).
- **Execution**: Runs for `GameConfig.budget_ticks` frames (counted in `_physics_process`). All queued actions resolve simultaneously. Melee damage resolves at `_end_execution()`; ranged attacks fire `Projectile` nodes at `_begin_execution()`.

Pressing End Turn triggers validation (`ready_for_end_turn()` on each unit). Warnings show a confirmation panel; the player can proceed anyway.

### Unit hierarchy

`BaseUnit` (CharacterBody2D) → `PlayerUnit` / `EnemyUnit`

`BaseUnit` owns pending-action state (`_pending_move_target`, `_pending_attack_target`, `_has_pending_move`, `_has_pending_attack`), health, and the optional health bar. It does not make AI decisions.

`EnemyUnit` has two behaviour types set per-instance at spawn time in `main.gd._spawn_units()`:
- `MELEE_CHASER` — moves toward nearest player unit and attacks
- `RANGED_FLEEING` — stays beyond `alert_radius` and fires projectiles

`Projectile` is an independent Node2D added to the Main scene at `_begin_execution`. It tracks its target via physics ray queries and despawns on hit or if the target dies.

### Game configuration & persistence

`GameConfig` is the autoloaded singleton (registered in `project.godot`). Its `_ready()` loads from `user://config.cfg` immediately on startup via `ConfigFile`.

**Adding a new user-configurable field requires changes in two places:**
1. `scripts/game_config.gd` — add to `USER_FIELDS` array, `DEFAULTS` dict, and declare the property.
2. `scripts/menu.gd` — add one entry to `_field_map` (maps field name → `[control_node, "property_name"]`).

The `save()` and `load_config()` functions loop over `USER_FIELDS` using `get()`/`set()`, so no other changes are needed.

Config is **not** saved on game start — it is saved only when the player explicitly chooses "Back to Menu + Save Settings" (pause menu or win screen). This lets players try different configs without overwriting the saved default.

### Texture loading

`_pick_texture(prefix, index, fallbacks)` in `main.gd` checks `res://assets/{prefix}{index+1}.png` at runtime via `ResourceLoader.exists()`. If found, it loads it; otherwise it cycles over the preloaded fallback array. Dropping a new `enemyN.png` or `allyN.png` into `assets/` is sufficient — no code change needed.

### Escape key / pause interaction

`Main` runs with `PROCESS_MODE_ALWAYS` so `_unhandled_input` fires even when `get_tree().paused = true`. The Escape handler checks `_confirm_panel.visible` first: if the end-turn confirmation is open it closes that; otherwise it toggles the pause menu. `_physics_process` explicitly guards against advancing execution ticks while paused.
