extends RefCounted
class_name KingdomCatalog

const MAIN_FRAME_TEXTURE := preload("res://assets/ui/themes/main_screen/main_screen_backround_mainframe.png")
const NEON_MAIN_FRAME_TEXTURE := preload("res://assets/ui/themes/main_screen/main_screen_mainframe_neon_bg.png")
const ACTIVE_FRAME_TEXTURE := preload("res://assets/ui/themes/main_screen/card_frame_active_final.png")
const INACTIVE_FRAME_TEXTURE := preload("res://assets/ui/themes/main_screen/card_frame_inactive_final.png")
const NEON_ACTIVE_FRAME_TEXTURE := preload("res://assets/ui/themes/main_screen/card_frame_active_kindom2.png")
const NEON_INACTIVE_FRAME_TEXTURE := preload("res://assets/ui/themes/main_screen/card_frame_inactive_kindom2.png")
const CARD_TEXTURES := [
	preload("res://assets/ui/themes/main_screen/kingdom1.png"),
	preload("res://assets/ui/themes/main_screen/kingdom2.png"),
	preload("res://assets/ui/themes/main_screen/kingdom3.png"),
]
const THEMES := [
	preload("res://themes/default_theme.tres"),
	preload("res://themes/neon_theme.tres"),
	null,
]
const THEME_IDS := ["default", "neon", ""]

static func get_theme_id(index: int) -> String:
	return str(THEME_IDS[index]) if index >= 0 and index < THEME_IDS.size() else ""

static func get_theme(index: int) -> ThemeData:
	return THEMES[index] as ThemeData if index >= 0 and index < THEMES.size() else null

static func get_fallback_card_texture(index: int) -> Texture2D:
	return CARD_TEXTURES[index] as Texture2D if index >= 0 and index < CARD_TEXTURES.size() else null

static func get_main_frame_texture(index: int) -> Texture2D:
	return NEON_MAIN_FRAME_TEXTURE if index == 1 else MAIN_FRAME_TEXTURE

static func get_card_frame_texture(index: int, active: bool) -> Texture2D:
	if index == 1:
		return NEON_ACTIVE_FRAME_TEXTURE if active else NEON_INACTIVE_FRAME_TEXTURE
	return ACTIVE_FRAME_TEXTURE if active else INACTIVE_FRAME_TEXTURE
