# Input Handling

Keep input centralized in:

```text
BoardManager._input()
```

Do not move gameplay click logic into `Area2D.input_event` unless explicitly requested.

Expected flow:

1. Convert mouse world position to grid position
2. If clicking a piece, select it
3. Show valid move highlights
4. If clicking a highlighted empty cell, move selected piece
5. Clear highlights
6. Resolve line clearing
7. Spawn new pieces

Use:

```gdscript
world_to_grid()
```

for grid conversion.

Gameplay scene UI caveat:

- Pause UI lives under `CanvasLayer/UI/PauseOverlay`
- Game-over UI lives under `CanvasLayer/UI/GameOverOverlay`
- Keep the full-screen `CanvasLayer/UI` control on `mouse_filter = ignore` so it does not block normal gameplay or the gear button
- Only visible modal/dialog controls should consume pointer input

