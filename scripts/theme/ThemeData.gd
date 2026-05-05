extends Resource
class_name ThemeData

@export var pawn_texture: Texture2D
@export var knight_texture: Texture2D
@export var bishop_texture: Texture2D
@export var rook_texture: Texture2D
@export var queen_texture: Texture2D
@export var king_texture: Texture2D

@export var red_piece_color: Color = Color.RED
@export var blue_piece_color: Color = Color.BLUE
@export var green_piece_color: Color = Color.GREEN
@export var orange_piece_color: Color = Color.ORANGE

@export var board_cell_light_color: Color = Color(0.7, 0.7, 0.7)
@export var board_cell_dark_color: Color = Color(0.3, 0.3, 0.3)

@export var left_border_color: Color = Color.RED
@export var top_border_color: Color = Color.BLUE
@export var right_border_color: Color = Color.GREEN
@export var bottom_border_color: Color = Color.ORANGE

@export var move_highlight_color: Color = Color(1.0, 1.0, 0.0, 0.4)
@export var attack_overlay_background_color: Color = Color(0.0, 0.0, 0.0, 0.5)
@export var dim_target_alpha: float = 0.35

@export var hud_panel_color: Color = Color(0.8, 0.8, 0.8, 0.9)
@export var hud_shadow_color: Color = Color(0.1, 0.1, 0.1, 0.5)
@export var hud_primary_text_color: Color = Color(0.05, 0.05, 0.05, 1.0)
@export var hud_secondary_text_color: Color = Color(0.05, 0.05, 0.05, 0.92)
@export var hud_outline_color: Color = Color(0.25, 0.25, 0.25, 0.35)
@export var hud_secondary_outline_color: Color = Color(0.25, 0.25, 0.25, 0.3)
@export var metric_tile_background_color: Color = Color(0.92, 0.92, 0.92, 1.0)
@export var metric_outline_color: Color = Color(0.08, 0.08, 0.08, 0.6)
@export var puzzle_level_images: Array = []
@export var puzzle_board_background_color: Color = Color(0.16, 0.16, 0.16, 1.0)
@export var puzzle_tile_cover_color: Color = Color(0.06, 0.06, 0.06, 0.92)
@export var puzzle_message_text_color: Color = Color(0.12, 0.12, 0.12, 1.0)
@export var puzzle_message_outline_color: Color = Color(1.0, 1.0, 1.0, 0.28)
@export var puzzle_message_font_weight: int = 700
@export var puzzle_message_font_size: int = 30
@export var level_start_message_template: String = ""

@export var gameplay_backdrop_base_color: Color = Color(0.0, 0.004, 0.007, 1.0)
@export var gameplay_backdrop_edge_glow_color: Color = Color(0.0, 0.28, 0.43, 1.0)
@export var gameplay_backdrop_center_glow_color: Color = Color(0.0, 0.09, 0.14, 1.0)

@export var dialog_font_names: PackedStringArray = PackedStringArray(["Avenir Next Condensed", "Helvetica Neue", "Arial Narrow", "Arial"])
@export var dialog_title_font_weight: int = 800
@export var dialog_body_font_weight: int = 600
@export var dialog_button_font_weight: int = 700
@export var dialog_title_font_size: int = 58
@export var dialog_body_font_size: int = 24
@export var dialog_score_font_size: int = 34
@export var dialog_button_font_size: int = 28
@export var dialog_overlay_color: Color = Color(0.02, 0.02, 0.02, 0.62)
@export var dialog_panel_background_color: Color = Color(0.09, 0.1, 0.12, 0.96)
@export var dialog_panel_border_color: Color = Color(1.0, 1.0, 1.0, 0.18)
@export var dialog_title_color: Color = Color(1.0, 1.0, 1.0, 0.98)
@export var dialog_body_color: Color = Color(1.0, 1.0, 1.0, 0.78)
@export var dialog_button_primary_color: Color = Color(0.18, 0.76, 0.34, 1.0)
@export var dialog_button_primary_hover_color: Color = Color(0.26, 0.84, 0.42, 1.0)
@export var dialog_button_secondary_color: Color = Color(0.17, 0.18, 0.2, 0.98)
@export var dialog_button_secondary_hover_color: Color = Color(0.24, 0.25, 0.28, 1.0)
@export var dialog_button_text_color: Color = Color(1.0, 1.0, 1.0, 0.98)
@export var dialog_button_secondary_border_color: Color = Color(1.0, 1.0, 1.0, 0.28)
@export var dialog_button_secondary_border_hover_color: Color = Color(1.0, 1.0, 1.0, 0.48)
@export var dialog_button_link_color: Color = Color(1.0, 1.0, 1.0, 0.45)
@export var dialog_button_link_hover_color: Color = Color(1.0, 1.0, 1.0, 0.95)

@export var menu_checker_light_color: Color = Color(0.34, 0.34, 0.34)
@export var menu_checker_dark_color: Color = Color(0.22, 0.22, 0.22)
@export var menu_overlay_color: Color = Color(0.0, 0.0, 0.0, 0.75)
@export var menu_panel_background_color: Color = Color(0.08, 0.08, 0.08, 0.88)
@export var menu_panel_border_color: Color = Color(1.0, 1.0, 1.0, 0.12)
@export var menu_title_color: Color = Color(1.0, 1.0, 1.0, 0.98)
@export var menu_subtitle_color: Color = Color(1.0, 1.0, 1.0, 0.72)
@export var menu_button_text_color: Color = Color.WHITE
@export var menu_button_text_color_hover: Color = Color.WHITE
@export var menu_outline_button_text_color: Color = Color(1.0, 1.0, 1.0, 0.9)
@export var menu_outline_button_text_color_hover: Color = Color(1.0, 1.0, 1.0, 0.9)
@export var menu_button_green_color: Color = Color(0.2, 0.8, 0.2, 1.0)
@export var menu_button_green_hover_color: Color = Color(0.3, 0.9, 0.3, 1.0)
@export var menu_button_orange_color: Color = Color(1.0, 0.5, 0.0, 1.0)
@export var menu_button_orange_hover_color: Color = Color(1.0, 0.6, 0.1, 1.0)
@export var menu_button_outline_color: Color = Color(0.2, 0.2, 0.2, 0.92)
@export var menu_button_outline_hover_color: Color = Color(0.3, 0.3, 0.3, 0.96)
@export var menu_button_outline_border_color: Color = Color(1.0, 1.0, 1.0, 0.35)
@export var menu_button_outline_border_hover_color: Color = Color(1.0, 1.0, 1.0, 0.55)

func get_piece_texture(piece_type: int) -> Texture2D:
	match piece_type:
		0: return pawn_texture
		1: return knight_texture
		2: return bishop_texture
		3: return rook_texture
		4: return queen_texture
		5: return king_texture
	return pawn_texture

func get_piece_color(piece_color: int) -> Color:
	match piece_color:
		0: return red_piece_color
		1: return blue_piece_color
		2: return green_piece_color
		3: return orange_piece_color
	return Color.WHITE

func get_border_color(piece_color: int) -> Color:
	match piece_color:
		0: return left_border_color
		1: return top_border_color
		2: return right_border_color
		3: return bottom_border_color
	return left_border_color
