# Move Validation

Keep movement and clearing logic separate.

## `Piece.gd`

Responsible for:

- piece type
- piece color
- movement rules
- helper methods for legal movement

Expected method:

```gdscript
get_legal_moves()
```

Returns empty destination cells only.

Do not make normal movement capture pieces.

## Traps

Advanced puzzle levels can add traps on otherwise empty board cells:

- level index 0 has no traps
- level index 1 has 1 trap
- level index 2 and later have 2 traps

Current trap behavior sacrifices a piece that moves onto the trap and does not let that piece occupy the cell. A piece may target a trap only if its normal movement reaches that empty cell. Random spawning must not place pieces on traps.

Trap visuals and future trap behaviors are theme-specific. Each trap visual should be animated by a shader. Trap random appearance rules are intentionally left open until the product spec defines them.

### Attack / Capture Logic

Older logic may include:

```gdscript
get_legal_captures()
```

This can remain for experiments or future mechanics, but the current target design should prioritize Lines-style clearing, not attack-chain clearing.

Do not use alternating-color attack chains as the main mechanic unless explicitly requested again.
