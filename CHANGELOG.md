# Changelog

All notable changes to GIMERSIA: Memory Shift will be documented in this file.

## [0.1.0-prototype] - 2026-11-15
### Added
- Dual-reality `Memory Shift` mechanic switching visibility and 3D collision between Warm Amber (`#FDE047`) and Cold Purple (`#7E22CE`).
- Three playable chapters: `Chapter1_Toys.tscn`, `Chapter2_Clock.tscn`, `Chapter3_Door.tscn`.
- Antagonist `The Eraser` with patrol, 2s telegraph warning, and erasable object deletion (`queue_free()`).
- Stealth Safe Zones and Anti-Stuck safety check.
- Minimalist HUD, Main Menu, Pause Menu, and Chapter Complete screen using custom UI Theme.
- Automated headless test suite (`tests/test_game_systems.gd`) and GitHub Actions CI workflow.
