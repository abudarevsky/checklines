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
- progression-based trap generation, including Level 4+ king-probability trap relocation without changing trap count or turn spawn count
- line detection call
- score updates
- UI updates
- game-over condition
- exhausted-spawn terminal fallback to a king-filled board ending

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
