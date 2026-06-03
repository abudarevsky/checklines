# Current Working Definition

Royal Lines is the current target design for this codebase: a tactical survival strategy game on an 8x8 chess-sized board that combines chess-inspired movement, line formation, dynamic traps, and survival pressure.

The player builds:

- color lines
- type lines
- Royal Lines made from 4 same-type pieces plus the only King on the board

The player aims to survive, optimize score, adapt tactically, and play elegantly across themed kingdoms with distinct traps and four difficulty levels. A kingdom run reaches its win dialog by completing Level 4 only after the normal post-turn spawn validation succeeds, and is lost when fewer than 3 playable empty spawn cells remain before that spawn. After completing Level 4, the player may enter Survival mode, which repeatedly restarts the Level 4 puzzle with one additional trap per survival round until the player loses; that final loss is presented as a win summary with the number of survived rounds.

Mastery is expressed through persistent kingdom badges for progression, tactical efficiency, and campaign success. Optional short campaigns are generated from board state when they are likely achievable, and rewards stay cosmetic, prestige-oriented, mastery-oriented, and non-grindy.

For the concise target-design summary, read `AGENTS_ROYAL_LINES_DESIGN.md`.
