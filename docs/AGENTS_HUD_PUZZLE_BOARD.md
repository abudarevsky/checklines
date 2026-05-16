# HUD / Puzzle Board

Current gameplay HUD includes:

- a top puzzle board image panel
- a message display beneath the puzzle board
- score and session line counters beneath the message display
- a gear button that opens a pause dialog
- no persistent bottom action row

Puzzle board rules:

- one removed piece reveals one puzzle tile
- fully revealing one picture completes one level
- level-complete score/HUD and puzzle overlay messages use one-based numbering: `"Level $number complete!"`
- record the maximum completed level per kingdom only when that level is actually completed
- the best-score HUD text appends the humanized best level as `"Best: $score | L: $number"` and never displays a level lower than `1`
- gameplay keeps advancing to higher puzzle levels until the board is full
- puzzle tile counts are 25, 50, 75, then 100 for level 4 and every later level
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
- render the gear icon using the same gold color as the puzzle and score frame border
- the badge bottom edge should slightly overlap the puzzle border
- the puzzle image and score row use separate frames; do not wrap the puzzle and score row in one shared frame
- keep a small visible gap between the puzzle frame and the score row frame

Pause dialog rules:

- the gear button opens `CanvasLayer/UI/PauseOverlay`
- the pause dialog title is `"Game paused."`
- the pause dialog uses the same centered card style, colors, fonts, and button treatment as the game-over dialog
- pause dialog actions are vertically aligned
- pause dialog actions should include Resume, Reset, and Main Menu
- opening the pause dialog disables board input; Resume re-enables board input unless the game is over or a move is processing

Message display rules:

- color line message: `"$number in a row"`
- type line message: `"$number $piece_name on the march"`
- level complete message: `"Level $number complete!"`
- level start messages are theme-defined through `ThemeData.level_start_message_template`
- if a theme does not define a level start message, use `"Starting level #$number"`
- level start message templates may include `{number}` as the level number placeholder
- current default theme level start message: `"Let the fight begin!"`
- current neon theme level start message: `"Let's shed some light on the dark."`
- trap piece disappearance messages are theme-defined through `ThemeData.trap_disappearance_message_template`
- trap behavior and trap visual definitions come from the common trap library; themes reference trap type ids
- current default trap disappearance message: `"I fell for nothing -{cost} :("`
- current neon trap disappearance message: `"Dark is the new light... :( -{cost}"`
- game board screen frames use `ThemeData.gameplay_frame_color`; neon should use cyan frames with cyan glow
- HUD messages should use the dialog font family at a larger, more prominent size
- HUD messages live inside the score row while displayed
- HUD messages should use an opaque score-row-colored backing panel, not transparent text over the scores
- HUD messages wipe in from the left and wipe out to the right
- score events produced by the same move/turn should be combined into one HUD message, separated by bullets, instead of displayed as sequential HUD messages
- HUD messages should appear immediately and keep a two-line recent-message log; if a second score event arrives within two seconds, show it below the previous message instead of delaying display
- score HUD messages are presentation only; board input should resume after board resolution and should not wait for score HUD exposure to finish
- in-puzzle level/start messages should appear on the reusable `FlyingBanner` cloth banner across the puzzle image, not as bare text over artwork
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
