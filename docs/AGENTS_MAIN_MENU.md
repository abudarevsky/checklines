# Main Menu Rendering

Current main menu implementation uses:

```text
scenes/ui/MainMenu.tscn
scripts/ui/MainMenu.gd
scripts/ui/MainMenuBoard.gd
```

The intended presentation is a theme-driven art menu with a stable layout:

- full-screen main screen background artwork
- global best-score label under the main header and above the scrollable kingdom area
- scrollable kingdom selection area
- kingdom cards composed from themed progression art and themed card-frame artwork
- three distinct matte-glass badge overlays attached to each kingdom card frame: progression ribbon, tactical cross, and reserved campaign crown
- bottom action panel with How To Play, Settings, and Exit actions
- settings dialog with sound, vibration, theme, and language controls
- full-screen HowToPlay overlay panel

Main screen background images, kingdom card frames, and other menu art may vary by theme.
The main-screen backdrop should follow the active theme background texture when selection changes, while kingdom-specific art such as the neon frame and card-frame variants may switch with the selected kingdom.
Playable kingdom cards should use that kingdom's recorded best progression to choose the displayed puzzle image.
The global best-score row should use localized `"Your best"` text plus the numeric value on a transparent background; both label and value colors are theme-driven.
Kingdom badges should use compact matte-glass overlays arranged horizontally from the former lowest vertical-badge position, keeping that lower badge location as the baseline while all three fit inside the card footprint. Use a waving ribbon for progression, a Maltese-style cross for tactical mastery, and a crown for campaigns.
Explain badge meaning and achievement thresholds in the localized How To Play content.
The progression badge maps maximum completed kingdom level `1/2/3` to bronze/silver/gold. Stars on the progression badge come only from completed survival loops saved in `kingdom_survival_rounds`; do not draw stars from ordinary completed levels.
The tactical mastery badge maps the last winning session's clean-turn percentage to bronze/silver/gold at `5%/15%/25%`, where a clean turn has neither a capture nor a sacrifice. Losing sessions do not change this badge color.
The campaign badge remains visually empty until campaigns are implemented.
The menu image progression intentionally lags gameplay progression: keep showing puzzle image index `0` until level 2 has been completed, then advance through later available images with the shared theme-image fallback rule.
Card artwork should fill the visible inner opening by width while allowing the frame's decorative corner elements to remain overlaid.
Do not change the conceptual menu layout when updating art: keep the scroll area, bottom action panel, and kingdom selection model intact unless explicitly asked to redesign the menu.

Selecting a kingdom is a single tap/click.
Starting a kingdom session is a double tap/click on that kingdom.

Keep the menu scene as a `Control`-based layout.

Prefer stable node paths and direct button signal wiring in `MainMenu.gd`.

Avoid duplicated scene subtrees or duplicate node names in `MainMenu.tscn`.

If you change the HowToPlay layout, update script node paths at the same time.

Main menu visuals should remain theme-driven through `ThemeManager` and `ThemeData`, even though only the default theme exists for now.
Main menu typography should use the Cormorant Garamond font assets from `assets/fonts/Cormorant_Garamond` through `ThemeData`, with the same theme font resources shared by the game-over screen and other modal dialogs.
The settings theme and language selector dropdowns should use the dialog body font scale, not the smaller button scale.
Menu and game UI labels should be routed through `Localization` so the language setting updates visible text.
When no language is saved yet, initialize the language from `OS.get_locale_language()` and fall back to English if unsupported.
Runtime banner and scoring messages should also use `Localization`; do not leave puzzle banners or score events as hardcoded English.
