# King Rule

Kings are special pieces with the following behavior:

- can move and capture using standard king movement  
- cannot be captured by other pieces  
- only one king should exist on the board at a time  
- enables Royal Lines made from 4 same-type pieces plus King

Kings are not treated as normal pieces for removal unless explicitly part of a valid scoring formation.

## Spawn Rule

- Start with 3 random pieces
- After each player move, spawn 3 new random pieces
- Preview next 3 pieces if implemented
- Spawned pieces may complete normal Lines-style removals
- King spawn is very rare
- Random spawning must respect per-color inventory limits based on normal chess counts
- Spawn placement should avoid creating removable lines when an alternative empty cell exists
- If every remaining empty cell would create a line, spawning may still use one of those cells
- Under normal play, only one King should exist on the board at a time
- Never fill remaining cells with Kings; a full board or lack of eligible moves ends the game as a loss

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

## Product Direction

The King is the unique anchor piece for Royal Lines.

- only one King should exist on the board at a time
- the King should support high-value tactical formations
- the King should not introduce separate king-attack gameplay unless the product definition changes
