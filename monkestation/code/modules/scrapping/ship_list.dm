// datums for each ship's info

/datum/map_template/scrap_shuttles
	mappath = "_maps/scrap_shuttles/debug.dmm"
	var/id = "scrap_debug"
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


/datum/map_template/scrap_shuttles/proc/check_zone(turf/start_loc)
	var/affected = get_affected_turfs(start_loc, centered=FALSE)
	for(var/turf/T in affected)
		// we don't want to destroy players, so lets make sure no mobs inside are players
		for(var/mob/M in T)
			if(!M.ckey == null || !M.key == null)
				return FALSE
	return TRUE

/datum/map_template/scrap_shuttles/goon
	id = "scrap_goon"
	mappath = "_maps/scrap_shuttles/emergency_goon.dmm"

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