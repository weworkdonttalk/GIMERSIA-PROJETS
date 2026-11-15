# GIMERSIA: Memory Shift

An atmospheric 3D 2.5D puzzle-platformer inspired by *Little Nightmares*, built in Godot 4.

## Mechanics
- **Dual Reality (Memory Shift):** Press `Shift` or `E` to toggle between *Remembered Reality* (Warm Amber) and *Forgotten Reality* (Cold Purple).
- **2.5D Movement:** `WASD` / Arrow keys to move in X/Z space, `Space` to jump, `C` / `Ctrl` to crouch/hide in Safe Zones.
- **The Eraser:** Avoid the silent red silhouette. Crouch in Safe Zones to break line of sight.

## Chapters
- **Chapter 1: Toys** (`res://scenes/Chapter1_Toys.tscn`)
- **Chapter 2: Clock** (`res://scenes/Chapter2_Clock.tscn`)
- **Chapter 3: Door** (`res://scenes/Chapter3_Door.tscn`)

## Running the Project
```bash
# Launch directly
godot --path ./main

# Run automated tests
godot --headless --path ./main -s tests/test_game_systems.gd
```
