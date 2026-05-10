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

Spawn logic should only generate colors and piece types that are still legal under these limits.

