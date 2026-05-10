# Main Menu Rendering

Current main menu implementation uses:

```text
scenes/ui/MainMenu.tscn
scripts/ui/MainMenu.gd
scripts/ui/MainMenuBoard.gd
```

The intended presentation is:

- full-screen dark checkerboard background
- centered dark menu panel
- primary actions in the center
- settings dialog with sound, vibration, theme, and language controls
- full-screen HowToPlay overlay panel

Use `MainMenuBoard.gd` for the checkerboard background layer.

Do not replace the current menu background with a stretched `TextureRect` checkerboard unless explicitly requested.

Keep the menu scene as a `Control`-based layout.

Prefer stable node paths and direct button signal wiring in `MainMenu.gd`.

Avoid duplicated scene subtrees or duplicate node names in `MainMenu.tscn`.

If you change the HowToPlay layout, update script node paths at the same time.

Main menu visuals should remain theme-driven through `ThemeManager` and `ThemeData`, even though only the default theme exists for now.
Main menu typography should use the same brisk dialog font family as the game-over screen and other modal dialogs.
The settings theme and language selector dropdowns should use the dialog body font scale, not the smaller button scale.
Menu and game UI labels should be routed through `Localization` so the language setting updates visible text.
When no language is saved yet, initialize the language from `OS.get_locale_language()` and fall back to English if unsupported.
Runtime banner and scoring messages should also use `Localization`; do not leave puzzle banners or score events as hardcoded English.
