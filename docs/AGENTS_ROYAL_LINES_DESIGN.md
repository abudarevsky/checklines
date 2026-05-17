# Royal Lines Design Summary

Royal Lines is a tactical survival strategy game built from:

- chess-inspired movement
- line formation
- dynamic traps
- survival pressure

The core goal is to survive, optimize score, adapt tactically, and play elegantly.

## Core Formations

- Color Lines
- Type Lines
- Royal Lines: 4 same-type pieces plus the only King on the board

Only one King exists on the board.

## Kingdoms

Each kingdom provides:

- unique atmosphere
- unique visual theme
- unique traps
- unique badge styling
- 4 difficulty levels

Example kingdom directions include Medieval, Neon, and Blue Moon.

Level structure:

1. Introduction
2. Trap pressure
3. Tactical mastery
4. Endless survival prestige mode

Level 4 cannot truly be completed. Measure it through survival time, score, removed lines, and tactical mastery.

## Mastery Badges

Each kingdom has 3 persistent badges. Every badge has Bronze, Silver, and Gold tiers. Badges brighten when reconfirmed, dim over time, and represent maintained mastery.

### Progression Badge

Represents kingdom advancement and survival capability.

- Bronze: reached the level milestone
- Silver: strong level completion
- Gold: mastery of Level 4 survival

Current main-menu implementation uses the first badge slot for completed progression levels only:

- Bronze: maximum completed level 1
- Silver: maximum completed level 2
- Gold: maximum completed level 3

Level 4 prestige is reserved for an additional future overlay.

### Tactical Mastery Badge

Represents elegant tactical play and score purity.

Calculate mainly from:

- percentage of lines completed without sacrificing pieces
- tactical efficiency
- controlled survival

Gold represents highly efficient elegant gameplay.

Current initial tier thresholds use best clean-turn percentage per kingdom:

- Bronze: at least 5%
- Silver: at least 15%
- Gold: at least 25%

A clean turn has neither a capture nor a sacrifice.

### Campaign Mastery Badge

Represents successful completion of optional dynamic tactical campaigns.

Campaigns are:

- optional
- short, with a maximum of 3 turns
- generated from current board state
- proposed only when likely achievable

Examples:

- Protect the King
- Ceasefire
- Royal Migration

The campaign engine should evaluate king safety, mobility, trap pressure, reachable paths, and tactical success likelihood.

Gold requires successful completion of multiple advanced campaigns.

## Rewards

Rewards should be:

- cosmetic
- prestige-oriented
- mastery-oriented
- non-grindy

Players may specialize in favorite kingdoms indefinitely.

## Core Loop

1. Survive
2. Build formations
3. Handle traps
4. Accept optional campaigns
5. Improve mastery badges
6. Maintain badge brightness
7. Beat previous scores

## Design Philosophy

- elegant tactical survival
- replayability through emergent situations
- mastery through adaptation
- atmospheric kingdom identity
- optional tactical challenges instead of forced grind
