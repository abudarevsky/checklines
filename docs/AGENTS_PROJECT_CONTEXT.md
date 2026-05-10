# Check Lines - Project Context

## Project Overview

Check Lines is a Godot 4.6 puzzle game combining classic Lines-style clearing with chess-piece movement.

The player moves chess pieces on a fixed 8x8 board. Pieces move according to chess-inspired movement rules, can capture eligible opposing-color pieces by moving onto occupied cells, and primarily score by creating removable lines of 5+ pieces.

The current design direction is closer to classic Lines than chess combat.

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
- Pieces move only to empty cells
- Game ends when no meaningful moves remain or the board is full

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

Do not use White/Black faction combat as the main rule anymore.