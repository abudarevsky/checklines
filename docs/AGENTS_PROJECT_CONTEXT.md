# Royal Lines - Project Context

## Project Overview

Royal Lines is the current target design for this Godot 4.6 codebase: a tactical survival strategy game combining chess-inspired movement, line formation, dynamic traps, and survival pressure.

The player moves chess pieces on a fixed 8x8 board. Pieces move according to chess-inspired movement rules, can capture eligible pieces by moving onto occupied cells when the rules allow it, and primarily score by creating valuable formations while surviving increasing pressure.

The design goal is elegant tactical survival rather than faction-based chess combat.

## Current Target Game Rules

### Color Palette

Puzzle colors for pieces and borders:

- RED, BLUE, GREEN, ORANGE
- Border colors: Left=RED, Top=BLUE, Right=GREEN, Bottom=ORANGE
- Border width: 3 pixels

### Board

- Board size: 8x8
- Board cells: Light gray / Dark gray (neutral colors)
- Pieces occupy grid cells
- Piece movement, line formation, trap handling, and survival pressure form the main loop
- Game flow is measured through kingdom progression and survival performance

### Piece Types

Supported piece types:

- Pawn
- Knight
- Bishop
- Rook
- Queen
- King

Piece type defines movement.

### Colors

Pieces have puzzle colors.

Color defines one type of removable line.

Do not use White/Black faction combat as the main rule.

### Formation Types

- Color Line: matching colors
- Type Line: matching chess-piece types
- Royal Line: 4 same-type pieces plus the only King on the board

### Kingdom Structure

Each kingdom has:

- a unique visual theme
- unique traps
- 4 difficulty levels

Level 4 is an endless prestige mode measured by survival time, score, removed lines, and tactical mastery rather than true completion.
