# Game State Ownership

### `GameManager.gd`

Owns:

- global constants
- score
- high score persistence
- piece weights
- global gameplay parameters

`GameManager.gd` should not become the primary owner of visual styling now that themes exist.

### `BoardManager.gd`

Owns:

- board grid
- piece positions
- selection state
- input handling
- move execution
- move highlights
- board occupancy
- spawn placement over currently empty cells

### `GameBoard.gd`

Owns or coordinates:

- game loop
- spawning
- progression-based trap generation, including per-level full-board trap rotation limits without changing trap count or turn spawn count
- line detection call
- score updates
- UI updates
- win/loss condition
- next-spawn-capacity loss handling

`GameBoard.gd` coordinates scene-bound sequencing. Reusable state and rules should remain in focused modules rather than being added inline.

### `ConfigStore.gd`

Owns merged `ConfigFile` reads and writes shared by settings and game-state persistence.

### `TurnSessionState.gd`

Owns per-session turn counters, clean-turn tracking, pending completion flags, and per-turn spawn exclusions.

### `SessionHistory.gd` and `HudMessageLog.gd`

Own rewind-history retention and recent HUD-message retention. `GameBoard.gd` owns their scene presentation.

### `TrapProfile.gd` and `TrapLineDetector.gd`

Own kingdom trap tuning and reusable trap-line candidate detection. `GameBoard.gd` owns runtime pulse sequencing.

### `KingdomCatalog.gd`

Owns main-menu kingdom IDs, themes, frame assets, and fallback card art.

### `SpawnPlanner.gd`

Owns:

- spawn-cell preference logic
- avoiding line-making spawn placements when alternatives exist
- detecting when normal spawn inventory is exhausted

### `Piece.gd`

Owns:

- piece type
- piece color
- sprite setup
- movement logic

### `ThemeManager.gd`

Owns:

- loading the active theme resource
- exposing the current `ThemeData`
- central access point for theme-driven visuals
- reloading the active theme when persisted settings change

### `PuzzleTileCover.gd`

Owns:

- the drawn puzzle-piece cover shape used by revealed and unrevealed puzzle tiles
- the paper-like fill, outline, and simple lighting of puzzle cover tiles

Keep puzzle tile cover work here instead of reverting to flat `ColorRect` tiles.
