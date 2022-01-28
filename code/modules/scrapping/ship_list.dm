// datums for each ship's info

/datum/scrap_ship
	var/map = "shuttles/scrap/debug.dmm"

	// cosmetic name parts
	// names shown to the player will be [class_name]-class [random pre_list] [random post_list]
	// e.g. "Debug-class Salvage Shuttle"
	var/class_name = "Debug"
	var/pre_list = list(
		"Salvage",
		"Light",
		"Heavy",
		"Containment",
		"Research",
		"Science",
		"Rescue",
		"Emergency",
		"Medical",
		"Engineering",
		"Transport",
		"Stealth"
	)
	var/post_list = list(
		"Shuttle",
		"Cruiser",
		"Wreck",
		"Frigate",
		"Fighter",
		"Vessel",
		"Ship",
		"Facility"
	)