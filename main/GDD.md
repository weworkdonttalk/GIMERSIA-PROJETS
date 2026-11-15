# Game Design Document: GIMERSIA - Memory Shift

## 1. Vision & Core Premise
- **Genre:** 3D 2.5D Atmospheric Puzzle Platformer / Stealth (Little Nightmares style).
- **Core Hook:** Dual Reality Shift ("Remembered" vs "Forgotten" worlds in identical coordinate space).
- **Tone:** Eerie, distorted childhood home, psychological tension, silence telegraphed by dread.

## 2. Core Mechanics
1. **Memory Shift (Shift/E):** Switches collision layers, visibility, and lighting between Warm Amber (`#FDE047`) and Cold Purple (`#7E22CE`). Anti-Stuck Area3D safety check prevents shifting inside target geometry.
2. **Memory Fragments:** Neon-green emissive collectibles opening gates and triggering narrative progression.
3. **The Eraser (Antagonist):** Silent Crimson/Black silhouette (`#EF4444`). Preceded by 2-second telegraph warning (camera shake + red fog). Deletes designated objects (`erasable` group).
4. **Stealth Safe Zones:** Semi-transparent green volumes where crouching hides the player (`is_hidden = true`).

## 3. Chapter Breakdown (~5 Minutes Each)
- **Chapter 1: Toys:** Tutorial on 2.5D movement, pushable toy blocks, dual pressure plate puzzle, bridging the missing chasm, Toy Fragment collection.
- **Chapter 2: Clock:** Multi-floor stairwell across realities, alternating platform ledges, twin clock synchronization, first encounter and chase with The Eraser.
- **Chapter 3: Door:** Erased exterior path, misplaced furniture realignment in hidden Z-rooms, 3-lock master gate sprint while The Eraser erases the floor behind player.
