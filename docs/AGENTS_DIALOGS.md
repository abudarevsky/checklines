# Dialogs

Current modal/dialog presentation includes:

- a large centered win/loss card
- a settings dialog in the main menu
- dark overlay backdrop
- Cormorant Garamond dialog typography from `ThemeData`
- shared menu font resources for HUD messages and game-over text

When adding or refactoring dialogs:

- keep titles proportionally larger than body text
- keep dialog buttons large and easy to hit
- route dialog colors and font settings through `ThemeData`
- preserve the current centered card style for game over unless explicitly redesigned
- keep settings dialog popup/dropdown text readable in the neon theme

Session-end dialogs should:

- show win copy when the player completes Level 4 and the required post-turn spawn validation succeeds
- show loss copy when fewer than 3 playable empty spawn cells remain
- use `"You won! The kingdom is secured!"` as the win title
- use `"You died for your kingdom!"` as the loss title
- use `"You fell, but heroes never die!"` as the final survival-loss title
- show a `Survive!` action on the Level 4 win dialog
- hide `Survive!` on normal losses and final survival summaries
- after a survival loss, show the final survival-loss title and the number of survived rounds
- congratulate the player when a new best score is achieved
- display session score, removed color lines, removed type lines, and played campaigns
- keep played campaigns at `0` until the campaign system is implemented
- when any game-over dialog opens, cancel gameplay-layer animations first; board effects, trap visuals, spawn/selection motion, HUD message motion, puzzle banners, rewind overlays, and survival overlays must not keep animating under the dialog

The game-over `Play Again` action starts a fresh run from the saved kingdom start level. The pause dialog `Reset` action clears that saved start level back to Level 1 before restarting; it must not clear best score, completed-level badge progress, tactical badge state, or survival stars.
