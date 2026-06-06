# HUD / Puzzle Board

Current gameplay HUD includes:

- a top puzzle board image panel
- a message display beneath the puzzle board
- score and session line counters beneath the message display on a theme-colored score-row background
- a gear button that opens a pause dialog
- no persistent bottom action row

Puzzle board rules:

- one removed piece reveals one puzzle tile
- fully revealing one picture completes a progression level
- level-complete score/HUD and puzzle overlay messages use one-based numbering: `"Level $number complete!"`
- record the maximum completed progression level per kingdom only when that level is actually completed
- a new kingdom run starts at the highest reached next level, capped at Level 4: completing Level 1 restarts future runs at Level 2, completing Level 2 at Level 3, and completing Level 3 or Level 4 at Level 4
- the pause Reset action clears only the kingdom start level back to Level 1; it should not erase max-completed badge progress
- completing a survival loop records a persistent per-kingdom survival star on the progression badge; ordinary completed levels change the badge tier but do not draw stars; pause Reset must not erase survival stars, badge progress, tactical badge state, or best score
- the current score value should render as individual bordered digit slots, like a mechanical counter, with at least five zero-padded digits while preserving visible spacing between digits
- the best-score HUD uses a compact three-level pedestal icon plus the best score only; do not append a `| L $number` level marker or show a `"Best"` text prefix in the score row
- completing Level 4 wins the active kingdom run after the required post-turn spawn validation succeeds
- puzzle tile counts are 25, 50, 75, then 100 for Level 4
- level images come from the active `ThemeData`
- the default puzzle image sequence comes from `assets/ui/themes/default/level0.png`, `level1.png`, and `level2.png`
- when a theme has no puzzle image at the current level index, reuse the last available prior image
- puzzle tile cover and puzzle board colors should remain theme-driven
- top badge art is theme-driven through `ThemeData.checklines_badge_texture`
- the default top badge art is `assets/ui/checklines-screen-badge.png`
- the neon top badge art is `assets/ui/themes/neon/checklines-screen-badge.svg`
- badge assets should keep the default badge canvas size, currently 963x238
- the badge should sit centered above the puzzle frame and share its top row with the gear button
- the gear button should sit centered between the left HUD edge and the centered badge
- the gear button should use a borderless icon button style
- the gear button touch target should stay at least 72x72 logical pixels even when the visible icon is smaller
- render the gear icon using the same gold color as the puzzle and score frame border
- the badge bottom edge should slightly overlap the puzzle border
- the puzzle image and score row use separate frames; do not wrap the puzzle and score row in one shared frame
- keep a small visible gap between the puzzle frame and the score row frame

Pause dialog rules:

- the gear button opens `CanvasLayer/UI/PauseOverlay`
- the pause dialog title is `"Game paused."`
- the pause dialog uses the same centered card style, colors, fonts, and button treatment as the game-over dialog
- pause dialog actions are vertically aligned
- pause dialog actions should include Resume, Reset, Review moves, and Main Menu
- opening the pause dialog disables board input; Resume re-enables board input unless the game is over or a move is processing
- Review moves or tapping the score HUD opens Rewind mode when session history exists; if no history exists, show the HUD message `"No moves to rewind"`
- Rewind mode shows its `"Rewind mode"` title and Close button in the HUD score row, shows only the scrollable history list inside the puzzle frame, disables board input, and stays active until Close is pressed
- session history stores the last `GameManager.SESSION_HISTORY_DEPTH` score/HUD events with board snapshots
- selecting a history message restores the board snapshot for that event, such as a completed line before removal or a sacrificed piece before it disappears
- trap-capture history identifies the captured piece with a chess icon and the candidate line type, such as `"Trapped ♙ from Color Line"`
- closing rewind mode restores the live board and normal HUD state, then re-enables input when normal play is available

Message display rules:

- color line message: `"$number in a row"`
- type line message: `"$number $piece_name on the march"`
- level complete message: `"Level $number complete!"`
- level start messages are theme-defined through `ThemeData.level_start_message_template`
- if a theme does not define a level start message, use `"Starting level #$number"`
- level start message templates may include `{number}` as the level number placeholder
- current default theme level start message: `"Let the fight begin!"`
- current neon theme level start message: `"Let's shed some light on the dark."`
- trap disappearance messages are localized and use the trap name, such as `Big Swamp`
- trap disappearance cloud messages use `assets/sprites/big_swamp.png` fitted inside the bubble, overlay the swallowed piece inside a dark coffin shape that only partially overlaps the swamp art, and render short localized splash/boo copy above the bottom edge with the HUD panel background, HUD text colors, shared HUD message font, and 1.2x the regular trap-cloud font size
- while Big Swamp is pulsing/capturing, all occupied pieces in the affected candidate line should have a temporary fog overlay that clears when the pulse is canceled or finished; the captured target remains visible enough to tremble during the pulse and does a short trembling fade when swallowed
- an enemy king that is reachable by attack geometry should appear as an attack target with a small crossed/blocked marker rather than the attacker's piece miniature; clicking it reuses the Big Swamp beam shader as a one-second king rebuff light from king to attacker, trembles the attacker, and shows `"The king is untouchable!"` as a normal HUD score event with `-2`
- selecting a trap shows the trap name and description in the move-hint panel
- trap behavior and trap visual definitions come from the common trap library; themes reference trap type ids
- game board screen frames use `ThemeData.gameplay_frame_color`; neon should use cyan frames with cyan glow
- HUD messages should use the shared Cormorant Garamond menu/dialog font at a larger, more prominent size
- HUD messages live inside the score row while displayed
- HUD messages should use an opaque score-row-colored backing panel, not transparent text over the scores
- HUD messages wipe in from the left and wipe out to the right
- score events produced by the same move/turn should be combined into one HUD message, separated by `*`, instead of displayed as sequential HUD messages
- HUD messages should appear immediately and keep recent messages on one line joined by `*`; do not stack recent HUD messages vertically
- score HUD messages are presentation only; board input should resume after board resolution and should not wait for score HUD exposure to finish
- game-over dialogs stop HUD message motion and gameplay visual effects before becoming visible; no board, trap, puzzle, survival, rewind, spawn, or selection animation should continue under the game-over dialog
- in-puzzle level/start messages should appear on the reusable `FlyingBanner` cloth banner across the puzzle image, using the Cormorant Garamond banner font from `assets/fonts/Cormorant_Garamond` through `ThemeData`, not as bare text over artwork
- while the message wipes in, the score and best text slide out as if pushed away, then slide back when the message exits
- message and score animations should be clipped within the score row frame
- the score row frame and side borders must remain fixed; only the inner score content and message wipe panel should slide

If HUD layout changes, preserve:

- near full-width board presentation on mobile and board-footprint desktop presentation
- anchored top HUD controls
- separate puzzle frame and score frame
- centered badge and left-side gear button sharing the same header row
- theme-driven puzzle visuals and message styling
- dark backdrop-colored screen background behind both HUD and board
- full-window theme background image when provided, with the generated vignette/gradient used only as fallback
- default gameplay backdrop should stay close to the reference: near-black center with restrained teal-blue side glow, not a bright vertical gradient
- puzzle cover tiles drawn as puzzle-piece silhouettes with tabs and sockets
