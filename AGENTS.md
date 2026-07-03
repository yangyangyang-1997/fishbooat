# AGENTS.md

## Project Overview

2D horizontal fishing game built in Godot 4.7 (GDScript). Gameplay similar to Gold Miner with boat physics.

**Core mechanics:**
- Player controls boat balance (tilt/rotation) while boat stays centered
- Scene scrolls horizontally to simulate boat movement
- Player controls rotating cannon/hook to catch fish
- Monsters and waves apply forces to boat via impact interface

## Architecture

**Entry point:** `game/fish_scene.tscn` (uid://hpgqchmnbgs8) - set as main scene in project.godot

**Key components:**
- `game/boat/boat.gd` - Boat class with floating and tilt physics
  - Exposes `apply_impact(strength)` and `apply_impact_vector(force)` for external impacts
  - Auto-recovery from tilt using damped spring model
  - Vertical bobbing animation + random wave disturbances
  - Cannon is child sprite at position (0, -62) with rotation
- `fishes/fish.tscn` - Fish entities for catching
- `monster/monster.tscn` - Entities that impact boat stability
- `textures/` - Art assets organized by entity type

**Scene structure:**
- Camera2D at origin
- Boat positioned at (-5, -103) - should remain near center
- Sea ColorRect from y=-112 downward
- Sky ColorRect above sea

## Critical Implementation Notes

**Boat physics requirements:**
1. Boat position must stay fixed at screen center while scene scrolls
2. Boat rotation simulates balance - player controls this
3. External forces (monsters, waves) increase rotation/instability
4. Need `apply_impact(force: Vector2)` or `apply_impulse(strength: float, direction: Vector2)` interface

**Cannon/Hook mechanics:**
1. Cannon sprite rotates around boat pivot
2. Hook extends from cannon on fire
3. Similar to Gold Miner - rotation + launch timing gameplay

**Scene scrolling:**
1. Entire scene moves horizontally (except boat and camera)
2. Parallax or manual translation of background/entities
3. Boat stays centered - only rotates for balance effect

## Development Commands

Open project in Godot Editor:
```bash
godot --editor project.godot
```

Run game directly:
```bash
godot project.godot
```

## Godot-Specific Conventions

- Scene root is `game/fish_scene.tscn` (check project.godot line 14)
- Using GL Compatibility renderer (not Forward+)
- Jolt Physics enabled for 3D (though this is 2D game - may be default/unused)
- Scripts use `class_name` for type registration (e.g., `class_name Boat`)
- Unique IDs in scenes used for node references - preserve these when editing .tscn files

**GDScript typing rules:**
- **NEVER write `:=` yourself** - only use `=` when writing any code
- **NEVER change existing `:=` to `=`** - if you see `:=` in the file, it was added by the developer intentionally, do not touch it
- When writing new lines or modifying existing lines:
  - Use `var x = 0.0` (dynamic typing)
  - OR use `var x: float = 0.0` (explicit type annotation)
  - NEVER use `var x := 0.0` (type inference)
- This applies to ALL variable declarations: `var`, `@export var`, `@onready var`, etc.

**GDScript naming conventions:**
- **Private variables use `_` prefix** - variables not meant to be accessed from outside should start with underscore
- Examples: `var _internal_state = 0`, `var _cache_data = []`
- Public API variables, exported properties, and signals should NOT use `_` prefix
- This helps distinguish internal implementation details from public interface

**GDScript collision event handling:**
- **The `body` parameter IS the colliding node** - don't use `get_parent()` to find it
- In signals like `body_entered`, `body_exited`, `area_entered`, the parameter directly references the collision body/area
- Example: `func _on_body_entered(body: Node): if body is Boat:` NOT `if body.get_parent() is Boat`
- This applies to both RigidBody2D and Area2D collision signals

## Common Pitfalls

1. **Don't move boat with physics** - boat should stay centered, rotate only for balance
2. **Scene scrolling simulates movement** - adjust child positions or use ParallaxBackground, not boat position
3. **Boat vertical movement** - only vertical bobbing for floating effect, horizontal position stays fixed
4. **Cannon rotation** - currently static at 1.164 radians, needs player input control
5. **Editing .tscn directly** - prefer Godot Editor unless making bulk changes; preserve unique_id and uid references

## Asset Organization

```
textures/
  ├── boat.png        # Main boat sprite (scaled 3x in scene)
  ├── cannon.png      # Hook launcher (scaled 1.5x)
  ├── fishes/         # Fish variants
  └── monsters/       # Monster variants
```

Scale factors applied in scene, not in texture files.
