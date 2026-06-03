# Testing

### Quick Syntax Check (2-3 seconds)

```bash
GODOT_BIN=${GODOT_BIN:-godot}
"$GODOT_BIN" --path . --script-check
```

### Headless Run with Output Capture

```bash
GODOT_BIN=${GODOT_BIN:-godot}
"$GODOT_BIN" --path . --script-check > output.txt 2>&1 &
GPID=$!; sleep 10; kill $GPID; cat output.txt
```

### Debug Output

Debug `print()` statements appear in terminal/console when running headless.

Run from command line:

```bash
GODOT_BIN=${GODOT_BIN:-godot}
"$GODOT_BIN" --path .
```

Open editor:

```bash
GODOT_BIN=${GODOT_BIN:-godot}
"$GODOT_BIN" --editor --path .
```

### Manual Test Checklist

Core functionality:

1. Game starts
2. Board is 8x8
3. Clicking a piece selects it
4. Valid empty moves are highlighted
5. Clicking a highlighted cell moves the piece
6. Completed color lines of 5+ are removed
7. Completed type lines of 5+ are removed
8. Type lines score more than color lines
9. 3 new pieces spawn after a move
10. Board state remains consistent
11. Game-over condition triggers only when fewer than 3 playable empty spawn cells remain
12. At most one king exists on the board at any time
13. No color exceeds chess-style inventory limits for any piece type
14. Spawn placement avoids immediate line clears when another empty cell exists
15. A full board ends the game as a loss without adding extra Kings

Attack highlighting:

14. Attack overlays display attacker sprite on target pieces
15. Attack borders show attacker color on target cell
16. Target pieces dimmed (0.35 opacity) when selectable
17. Overlays disappear on piece deselection
18. Pawn moves in correct direction (away from home border)

UI:

19. Main menu centered with dark panel and board visible beneath
20. Settings dialog opens with sound, vibration, and theme controls
21. Theme selector dropdown text matches the dialog body font scale
22. HowToPlay panel fully opaque
23. Main menu buttons remain centered after window resize
24. Gameplay board is nearly full-width on mobile and remains fully visible after window resize
25. Desktop gameplay window stays close to board width and fits HUD and board
26. Score row is wrapped in its own frame, separate from the puzzle frame
27. Gear button sits centered between the left HUD edge and the centered badge, and opens the pause dialog
28. Pause dialog shows `"Game paused."` and vertically stacked Resume, Reset, and Main Menu actions
29. The full-screen UI overlay does not block normal gameplay or gear button input
30. Puzzle board reveals tiles as pieces are removed
31. Message display shows line-clear and level-complete messages with the expected wording
32. HUD messages use an opaque backing panel inside the score row, wipe in from the left, wipe out to the right, and temporarily push score/best text away
33. Game-over dialog uses a large centered card with Cormorant Garamond typography
