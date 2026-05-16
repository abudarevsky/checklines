# Current Architecture

## Godot Version

- Godot 4.6 stable

## Main Structure

- `autoload/`
  - global managers
  - `GameManager`
  - `AudioManager`
  - `Settings`
  - `ThemeManager`

- `scenes/`
  - board and gameplay scenes
  - `BoardManager`
- `GameBoard`
- `Piece`
- `MainMenu`
- `SpawnPlanner`

- `scripts/`
  - game logic
  - line detection
  - supporting systems
  - `scripts/traps/` contains the common reusable trap library, trap definitions, and trap visuals

- `assets/sprites/`
  - chess piece SVG sources
  - rendered PNG sprites
  - theme-specific rendered PNG sprites under `assets/sprites/themes/<theme_id>/png/`

- `themes/`
  - theme resources
  - `default_theme.tres`

- `assets/ui/themes/default/`
  - default puzzle images (`level0.png`, `level1.png`, `level2.png`)
  - theme should keep later levels pinned to the last available image when a theme ships fewer than three

- `export_presets.cfg`
  - platform export presets, including Android, Web, and iOS
  - iOS export uses the configured Xcode project path under `exports/ios/`

- `exports/`
  - build output only
  - ignored by git and excluded from project exports
  - do not scan this folder during code or asset searches
