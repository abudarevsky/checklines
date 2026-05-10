# King Rule

Kings are special joker pieces with the following behavior:

- can move and capture using standard king movement  
- cannot be captured by other pieces  
- can participate in type-based lines as a wildcard (joker)  
- only one king should exist on the board at a time  

Kings are not treated as normal pieces for removal unless explicitly part of a valid line.

## Spawn Rule

- Start with 3 random pieces
- After each player move, spawn 3 new random pieces
- Preview next 3 pieces if implemented
- Spawned pieces may complete normal Lines-style removals
- King spawn is very rare
- Random spawning must respect per-color inventory limits based on normal chess counts
- Spawn placement should avoid creating removable lines when an alternative empty cell exists
- If every remaining empty cell would create a line, spawning may still use one of those cells
- If normal spawn inventory is exhausted under the current one-king-total rule, remaining empty cells should be filled with kings and the game should end immediately

## Movement Rule

- Player selects a piece
- Valid empty destination cells are highlighted
- Player moves selected piece to a highlighted empty cell
- Movement uses chess-inspired rules
- Movement and line-clearing are separate systems

## Pawn Rule

Pawn should not depend on White/Black sides in the multicolor version.

Target pawn rule:

- Pawn is a restricted connector piece
- Pawn can move toward a nearby same-color piece
- If there is no same-color piece within 1 cell, pawn cannot move
- Pawn behavior should support line-building, not chess faction logic

Keep pawn simple and readable.

## King Rule

King is a rare special piece.

Possible target role:

- wildcard / joker-like piece
- only one king should exist on the board at a time
- king should help difficult line completion
- king should not introduce separate king-attack gameplay

Do not build current features around attacking or defending kings.