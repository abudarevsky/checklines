# Rendering Principles

Current project uses PNG sprites.

Do not replace PNG rendering with procedural drawing unless explicitly requested.

Tint white PNG sprites using `sprite.modulate` for piece color.

Use existing assets from:

```text
assets/sprites/
```

Avoid Godot SVG import dependency for runtime rendering.

## Theme System

The project now has a theme concept.

A theme is a collection of visual resources and presentation values only.

Current implementation uses:

```text
autoload/ThemeManager.gd
scripts/theme/ThemeData.gd
themes/default_theme.tres
```

Theme scope includes:

- piece textures
- piece tint colors
- board cell colors
- selected trap type id from the common trap library
- side border colors
- move and attack overlay colors
- HUD colors
- top badge texture
- puzzle board images and reveal-cover colors
- message display colors
- game board screen frame colors and glow
- dialog colors and typography
- menu colors and button styles
- main menu background artwork
- main menu kingdom card frame artwork
- main menu kingdom card artwork
- settings dialog colors and theme selector popup styling
- other purely visual presentation values
- gameplay background image

Theme scope does not include:

- board size
- scoring
- movement rules
- spawn counts
- piece inventory limits
- king gameplay rules

The active theme is selected through persisted settings and loaded by `ThemeManager`.
Current available theme ids are `default` and `neon`.

Gameplay screens should use `ThemeData.gameplay_background_texture` as the visible backdrop when a theme provides it. The generated gameplay gradient is a fallback for themes without a background texture, not an overlay that hides theme artwork.

Theme selection now lives in the main menu settings dialog. Keep it persisted and theme-driven, but do not add extra theme management UI unless explicitly requested.

When adding new visual elements, route their colors/resources through `ThemeData` instead of hardcoding them locally.

When refactoring themed code, preserve default-theme parity:

- the game should look the same after extraction
- `default_theme.tres` is the canonical baseline for the current look
- theme work should not alter gameplay behavior
