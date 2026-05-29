# Dialogs

Current modal/dialog presentation includes:

- a large centered win/loss card
- a settings dialog in the main menu
- dark overlay backdrop
- brisk modern dialog typography
- shared font family for menu, HUD messages, and game-over text

When adding or refactoring dialogs:

- keep titles proportionally larger than body text
- keep dialog buttons large and easy to hit
- route dialog colors and font settings through `ThemeData`
- preserve the current centered card style for game over unless explicitly redesigned
- keep settings dialog popup/dropdown text readable in the neon theme

Session-end dialogs should:

- show win copy when the player completes Level 4
- show loss copy when no eligible move or capture remains
- congratulate the player when a new best score is achieved
- display session score, removed color lines, removed type lines, and played campaigns
- keep played campaigns at `0` until the campaign system is implemented
