# PRD & Technical Specification
## 2D Single-Screen Puzzle Platformer (Godot 4.x)

---

### 1. Game Overview
- **Genre:** 2D Single-Screen Puzzle Platformer.
- **Engine:** Godot Engine 4.x (GDScript 2.0).
- **Inspirasi Mekanik:** *Time to Go, Boy!*
- **Resolusi Viewport:** 1152 x 648 (Canvas Items, aspect: `expand`).
- **Pilar Mekanik:**
  1. **Dual-Timeline Map Switching:** Transisi instan Masa Lalu (Past Memory - hangat/krem/emas) dan Masa Depan (Future Reality - dingin/suram/ungu monokrom) dengan "Memory Ghosting" (alpha 0.12) tanpa reset momentum.
  2. **4-Way Gravity Manipulation:** Gravitasi 4 arah (`DOWN`, `UP`, `LEFT`, `RIGHT`) dengan adaptasi orientasi & axis gerak screen-space (W/S di dinding, A/D di lantai/atap).
  3. **Momentum Slingshot Portals:** Teleportasi instan sepasang portal dengan opsi pelontaran terarah (`exit_direction`) dan multiplier kecepatan.
  4. **Time-Synced Moving Platforms:** Bergerak di satu era dan membeku statis di era lain untuk menciptakan pijakan strategis.
  5. **Chrono-Key & Paradox Gate:** Kunci waktu instabil (Unstable Memory) dengan kuota batas switch waktu.
  6. **Temporal Anchor Zone:** Area pengunci manipulasi waktu.

---

### 2. Architecture & Folder Structure
```text
res://
├── autoloads/
│   ├── EventBus.gd
│   └── GameManager.gd
├── entities/
│   ├── player/
│   │   ├── Player.gd
│   │   └── Player.tscn
│   └── mechanics/
│       ├── TimelineContainer.gd
│       ├── StaticPlatform.gd
│       ├── StaticPlatform.tscn
│       ├── SyncedPlatform.gd
│       ├── SyncedPlatform.tscn
│       ├── DimensionPlatform.gd
│       ├── DimensionPlatform.tscn
│       ├── GravityBlock.gd
│       ├── GravityBlock.tscn
│       ├── Portal.gd
│       ├── Portal.tscn
│       ├── TemporalZone.gd
│       ├── TemporalZone.tscn
│       ├── ChronoKey.gd
│       ├── ChronoKey.tscn
│       ├── ParadoxGate.gd
│       ├── ParadoxGate.tscn
│       ├── Hazard.gd
│       ├── Hazard.tscn
│       ├── MovingPlatform.gd
│       ├── MovingPlatform.tscn
│       ├── GoalDoor.gd
│       └── GoalDoor.tscn
├── levels/
│   ├── LevelBase.gd
│   ├── LevelBase.tscn
│   ├── Level_01.tscn
│   └── Level_02.tscn
│   ├── LevelBase.gd
│   ├── LevelBase.tscn
│   └── Level_01.tscn
├── project.godot
└── PRD.md
```

---

### 3. Physics & 2D Collision Layer Matrix
Godot 4 menggunakan 1-based indexing untuk layer mask helper script (`set_collision_mask_value`), dan bitmask biner pada `.tscn` / `project.godot`:

| Layer # | Bit Value | Nama Layer | Deskripsi & Entitas |
|---|---|---|---|
| **1** | 1 | `World_Static` | Dinding pembatas luar, blok solid permanen di kedua dimensi. |
| **2** | 2 | `Player` | `CharacterBody2D` pemain. |
| **3** | 4 | `Light_Dimension` | Platform & rintangan solid HANYA saat Light World aktif. |
| **4** | 8 | `Dark_Dimension` | Platform & rintangan solid HANYA saat Dark World aktif. |
| **5** | 16 | `Interactables_And_Hazards` | `Area2D` trigger: GravityBlock, Portal, Hazard Spikes, GoalDoor. |

#### Collision Rules:
- **Player Mask:**
  - Layer 1 (`World_Static`) selalu `true`.
  - Layer 3 (`Light_Dimension`) aktif saat `is_light == true`, nonaktif saat `false`.
  - Layer 4 (`Dark_Dimension`) aktif saat `is_light == false`, nonaktif saat `true`.
  - Layer 5 dideteksi melalui `Area2D` (atau `Player.collision_mask` & area triggers).
- **DimensionPlatform:**
  - Light Platform: Layer 3 (`Light_Dimension`), Mask 0.
  - Dark Platform: Layer 4 (`Dark_Dimension`), Mask 0.
- **Interactables (GravityBlock, Portal, Hazard, GoalDoor):**
  - Layer: 5 (`Interactables_And_Hazards`).
  - Mask: 2 (`Player`).

---

### 4. Input Map Specification
Dikonfigurasi di `project.godot`:

| Action | Primary Key | Secondary Key | Ternary Key |
|---|---|---|---|
| `move_left` | Key A (`KEY_A`) | Left Arrow (`KEY_LEFT`) | - |
| `move_right` | Key D (`KEY_D`) | Right Arrow (`KEY_RIGHT`) | - |
| `jump` | Space (`KEY_SPACE`) | Key W (`KEY_W`) | Up Arrow (`KEY_UP`) |
| `switch_dimension` | Key E (`KEY_E`) | Shift (`KEY_SHIFT`) | Key K (`KEY_K`) |
| `restart` | Key R (`KEY_R`) | - | - |

---

### 5. Vector Math 4-Way Gravity Specification
1. **Representasi Gravitasi:**
   - Enum / Vector: `DOWN (0, 1)`, `UP (0, -1)`, `LEFT (-1, 0)`, `RIGHT (1, 0)`.
2. **Karakter Physics (`CharacterBody2D`):**
   - `up_direction = -gravity_dir`
   - `move_axis = up_direction.orthogonal()`
   - Proyeksi sumbu gerak:
     - Input axis horizontal (`move_left` / `move_right`) diskalakan terhadap `move_axis`.
     - Vektor kecepatan lateral: `var lateral = velocity.project(move_axis)`.
     - Vektor kecepatan aksial (gravitasi/lompat): `var normal = velocity.project(up_direction)`.
     - Gravitasi per frame: `normal += gravity_dir * (gravity_magnitude * delta)`.
     - Lompat: `normal = up_direction * jump_speed`.
     - Rekonstruksi total: `velocity = lateral + normal`.
   - `move_and_slide()` dipanggil tanpa argumen (aturan Godot 4).
3. **Visual Alignment:**
   - Rotasi node visual (`VisualContainer`):
     - `target_rotation = gravity_dir.angle() - PI/2`
     - Interpolasi rotasi menggunakan `create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)` durasi 0.15 detik.
4. **Coyote Time & Jump Buffer:**
   - `coyote_time`: 0.1 detik (toleransi setelah meninggalkan lantai).
   - `jump_buffer`: 0.12 detik (toleransi input sebelum menyentuh lantai).

---

### 6. Mechanics Specification
1. **DimensionPlatform (`StaticBody2D`):**
   - `@export var dimension_type: String = "LIGHT"` ("LIGHT" atau "DARK").
   - Mendengarkan sinyal `EventBus.dimension_switched(is_light: bool)`.
   - Update visual alpha: Aktif = 1.0, Tidak aktif = 0.25.
   - Menggunakan Layer 3 (Light) dan Layer 4 (Dark).
2. **GravityBlock (`Area2D`):**
   - `@export_enum("DOWN", "UP", "LEFT", "RIGHT") var direction: String = "DOWN"`.
   - Visual panah `Polygon2D` menunjuk arah gravitasi target.
   - Sinyal `body_entered(body)` memvalidasi body adalah Player, lalu memanggil `player.set_gravity_direction(dir_vector)`.
3. **Portal (`Area2D`):**
   - `@export var target_portal: Area2D`.
   - Teleportasi instan: `player.global_position = target_portal.global_position`.
   - `velocity` tetap utuh.
   - Cooldown teleportasi: 0.25 detik (mencegah trigger balik berulang).
4. **Hazard (`Area2D`):**
   - Spikes visual `Polygon2D`.
   - `body_entered(body)` memanggil `EventBus.player_died.emit()` dan reload level aman via `call_deferred`.
5. **GoalDoor (`Area2D`):**
   - `body_entered(body)` memicu `EventBus.level_completed.emit()`.
6. **MovingPlatform (`AnimatableBody2D`):**
   - Bergerak bolak-balik antara dua titik menggunakan `Tween` berulang (`set_loops()`).

---

### 7. Playable Demo (`Level_01.tscn`)
- Ukuran arena: 1152x648 dengan dinding pembatas `World_Static`.
- Puzzle flow:
  1. Pemain mulai di kiri bawah (gravitasi normal `DOWN`).
  2. Hadapi celah duri dan pijakan Light/Dark bergantian (memerlukan `switch_dimension`).
  3. Mengambil `GravityBlock(RIGHT)` untuk memanjat dinding vertikal.
  4. Masuk ke Portal A untuk keluar di Portal B dengan momentum terpreservasi.
  5. Mengambil `GravityBlock(UP)` di atas langit-langit menghindari duri.
  6. Mengambil `GravityBlock(DOWN)` untuk jatuh menuju `GoalDoor`.
