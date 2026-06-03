# Piece Distribution

Use weighted random generation.

Suggested identity:

- Pawns: common
- Knights/Bishops/Rooks: medium
- Queens: rare
- Kings: very rare

Piece distribution should support board variety without making powerful pieces too common.

Current enforced inventory limits per color:

- 8 pawns
- 2 knights
- 2 bishops
- 2 rooks
- 1 queen
- 1 king by type inventory, but current gameplay further restricts this to one king total on the whole board

Spawn logic should prefer colors and piece types that are still legal under these limits. These inventory limits must not end the run while at least 3 playable empty cells remain; if legal inventory is exhausted, spawn filler pieces so the 3-piece batch still consumes cells.

Normal player moves always attempt the next 3-piece spawn after resolving move-created clears. If fewer than 3 playable empty cells remain before the next normal spawn, the game ends.

Survival mode starts after the Level 4 win dialog. Each survival round restarts the Level 4 puzzle, adds one more trap than the previous round, and keeps looping until fewer than 3 playable empty cells remain before the next normal spawn.
