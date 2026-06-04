extends SceneTree

const KingdomCatalogScript = preload("res://scripts/ui/KingdomCatalog.gd")

func _initialize():
	var failures: Array[String] = []
	if KingdomCatalogScript.get_theme_id(0) != "default":
		failures.append("first kingdom theme id mismatch")
	if KingdomCatalogScript.get_theme_id(1) != "neon":
		failures.append("second kingdom theme id mismatch")
	if KingdomCatalogScript.get_theme(2) != null:
		failures.append("coming-soon kingdom unexpectedly has a theme")
	if KingdomCatalogScript.get_fallback_card_texture(2) == null:
		failures.append("coming-soon kingdom lacks fallback art")

	if failures.is_empty():
		print("All kingdom catalog tests passed")
		quit(0)
		return
	for failure in failures:
		push_error(failure)
	quit(1)
