// datums for each ship's info

/datum/map_template/scrap_shuttles
	var/prefix = "_maps/scrap_shuttles/"
	var/id = "scrap_debug"
	var/suffix = "debug.dmm"
	var/description = "Who needs mining, anyways?"

	var/value = 5000
	// cosmetic name parts
	// names shown to the player will be [class_name]-class [random pre_list] [random post_list]
	// e.g. "Debug-class Salvage Shuttle"
	var/class_name = "Debug"
	var/list/pre_list = list(
		"Salvage",
		"Light",
		"Heavy",
		"Containment",
		"Research",
		"Science",
		"Rescue",
		"Emergency",
		"Escape",
		"Medical",
		"Engineering",
		"Transport",
		"Stealth"
	)
	var/list/post_list = list(
		"Shuttle",
		"Cruiser",
		"Wreck",
		"Frigate",
		"Fighter",
		"Vessel",
		"Ship",
		"Facility"
	)


/datum/map_template/scrap_shuttles/goon
	id = "scrap_goon"
	suffix = "emergency_goon.dmm"

	class_name = "Goon"
	pre_list = list(
		"Emergency",
		"Rescure",
		"Transport",
		"Escape"
	)
	post_list = list(
		"Shuttle",
		"Ship",
		"Vessel"
	)