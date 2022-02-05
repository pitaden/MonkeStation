/datum/scrapping/objective
	var/list/objective_atoms = list()
	// values:
	// Ship - the objective atoms must stay on the ship
	// Pad - the objective item should be placed on the scrap pad
	// None - we don't care about the objective atom's location!
	var/objective_location = "None"
	// I don't think datums keep track of who their parent is? So, this is its parent.
	var/obj/machinery/computer/scrap_controls/console

	var/value = 0

/datum/scrapping/objective/proc/check_completion()
	for(var/obj/A in objective_atoms)
		if(objective_location == "Ship")
			// is A's area the magnet area?
			return TRUE // todo: add this shit
		if(objective_location == "Pad")
			// is our pad on our tile?
			if(!(console.linked_pad.loc == A.loc))
				return FALSE
		return TRUE