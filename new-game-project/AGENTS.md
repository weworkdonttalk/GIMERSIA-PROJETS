# AGENTS.md — Godot 4.x AI Engineering Guidelines

You are working inside a **Godot 4.x (4.2 / 4.3+)** project using **GDScript 2.0**.
Follow every rule below strictly to prevent Godot 3 hallucinations, physics thread crashes, and corrupted `.tscn` scene files.

---

## 1. Strict GDScript 2.0 (Godot 4) Syntax Rules
NEVER use Godot 3 syntax. Always use the Godot 4 equivalents:

- **Exports & Annotations:**
  - Use `@export var speed: float = 200.0` (NEVER `export(float) var speed`).
  - Use `@export_enum("DOWN", "UP", "LEFT", "RIGHT") var dir: String = "DOWN"`.
  - Use `@export_file("*.tscn") var next_level: String`.
  - Use `@onready var sprite: Node2D = $Visual` (NEVER `onready var`).
- **Node & Physics Bodies:**
  - Use `CharacterBody2D` (NEVER `KinematicBody2D`).
  - `velocity` is a built-in property of `CharacterBody2D`. Do NOT redeclare `var velocity: Vector2`.
  - Call `move_and_slide()` with **ZERO arguments** (NEVER `velocity = move_and_slide(velocity, up_direction)`). Set `up_direction` directly on the node before calling `move_and_slide()`.
  - Use `AnimatableBody2D` for moving platforms (NEVER `KinematicBody2D`).
- **Signals & Callables:**
  - Connect signals using `signal_name.connect(_on_callable)` (NEVER `connect("signal_name", self, "_method")`).
  - Emit signals using `signal_name.emit(args)` (NEVER `emit_signal("signal_name", args)`).
- **Tweens & Coroutines:**
  - Use `var tween = create_tween()` (NEVER creating a `Tween` node in the scene tree).
  - Use `await get_tree().create_timer(0.2).timeout` (NEVER `yield(...)`).
- **Scene Switching & Instantiation:**
  - Use `get_tree().change_scene_to_file(path)` or `get_tree().reload_current_scene()` (NEVER `change_scene()`).
  - Use `packed_scene.instantiate()` (NEVER `.instance()`).
- **Transform & Math:**
  - Use `rotation` (radians) or `rotation_degrees` (NEVER `set_rotd`).
  - Always use **static typing** (`var dir: Vector2 = Vector2.ZERO`, `func set_gravity(new_dir: Vector2) -> void:`).

---

## 2. Physics & Collision Safety Rules (CRITICAL)
Godot 4 physics server will throw fatal errors or ignore changes if physics state is modified mid-step during `body_entered` or `area_entered` callbacks:

1. **Deferred Physics Changes:**
   - When disabling/enabling a `CollisionShape2D` inside a signal callback, ALWAYS use `set_deferred("disabled", true)` (NEVER `collision_shape.disabled = true` directly inside `_on_body_entered`).
   - When changing scene or reloading level inside a hazard/door callback, ALWAYS use `call_deferred("_reload_scene")`.
2. **Dimension Switching Collision:**
   - Prefer toggling the `Player`'s `collision_mask` bit via `set_collision_mask_value(layer_number, bool)` OR toggling `CollisionShape2D.set_deferred("disabled", bool)` on platforms.
   - Note: `set_collision_layer_value(layer, value)` and `set_collision_mask_value(layer, value)` use **1-based indexing** (Layer 1 is `1`, NOT `0`).

---

## 3. `.tscn` (Text Scene) & `.godot` File Generation Rules
Hand-writing `.tscn` files is error-prone. Follow these strict rules when creating or editing `.tscn` files:

1. **Header & Format:**
   - Start scenes with `[gd_scene format=3]`. Do NOT invent fake `uid="uid://..."` strings; Godot 4 will auto-generate UIDs when opened.
   - Do NOT calculate wrong `load_steps` counts—omit `load_steps` from `[gd_scene format=3]` or ensure it matches the exact count of `ext_resource` + `sub_resource` + 1.
2. **Resource Ordering:**
   - All `[ext_resource ...]` blocks MUST come first.
   - All `[sub_resource ...]` blocks MUST come second (before any `[node ...]`).
   - `[node ...]` blocks come third, starting with the root node (no `parent` attribute).
3. **Avoid Fragile SubResources When Possible:**
   - For simple placeholder visuals (`Polygon2D`, `ColorRect`, `Line2D`), define points and colors cleanly or construct/configure complex shapes inside `_ready()` in GDScript if `.tscn` serialization becomes overly complex.
   - For `CollisionShape2D`, use simple `[sub_resource type="RectangleShape2D" id="RectangleShape2D_1"]` with `size = Vector2(width, height)`.
4. **Never Leave Broken Paths:**
   - Every `res://...` path referenced in a `.tscn` or script MUST exist on disk before or immediately after the scene is created.

---

## 4. Headless Verification Command
Whenever you finish a milestone or create new scripts/scenes, verify there are no syntax or scene-loading errors by running Godot in headless mode (if the `godot` binary is available in PATH):

```bash
godot --headless --quit