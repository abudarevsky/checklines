# Development Rules for opencode / qwen3-coder

### Before Editing

Always inspect existing files before changing them.

Check at least:

```text
autoload/GameManager.gd
scenes/BoardManager.gd
scenes/Piece.gd
scenes/GameBoard.gd
scripts/ChainDetector.gd
```

Actual paths may differ; search the repo before editing.

### When Refactoring

Prefer small safe changes.

Do not rewrite the whole game loop unless explicitly requested.

Preserve working behavior:

- click selection
- valid move highlighting
- movement to empty cells
- spawning
- score updates
- game-over flow
- centered main menu layout
- checkerboard menu background
- resize-safe board presentation
- default theme visual parity

### When Changing Rules

Update only the relevant system:

- movement changes -> `Piece.gd`
- board selection/movement -> `BoardManager.gd`
- spawning/scoring/game loop -> `GameBoard.gd`
- global values -> `GameManager.gd`
- visual styling/resources -> `ThemeData.gd` and `ThemeManager.gd`
- line detection -> detector script

### Avoid

Do not:

- hardcode board size or cell size
- reintroduce capture-by-moving-onto-piece
- rely on White/Black faction attack logic for core clearing
- remove PNG rendering
- scatter input logic across piece nodes
- create hidden full-board effects that are hard to explain
- make pawn movement too chess-realistic for the multicolor puzzle version

