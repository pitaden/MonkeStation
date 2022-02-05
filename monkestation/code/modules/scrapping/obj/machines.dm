// for the machine that makes the ships show up, and machines related to it

/obj/machinery/scrap/magnet
	name = "scrap magnet"
	desc = "A massive machine built to pull in ships. Older versions used actual magnets, but today, it uses bluespace."
	icon = 'monkestation/icons/obj/scrapping/magnet.dmi'
	icon_state = "magnet_on"

	//use_power = NO_POWER_USE
	// okay i dont know if this should be machinery.

	// area used is 34x34 (32x32 for the ship itself)
	var/turf/target_turf // target turf, bottom left corner

	var/datum/map_template/scrap_shuttles/current_template = new /datum/map_template/scrap_shuttles
	var/list/current_objectives
	// list(mob ref="heal", mob ref="kill", obj ref="item", etc)

	var/scrap_pad // where scrap gets sent
	var/obj/machinery/computer/scrap_controls/console // who we're linked to


/obj/machinery/scrap/magnet/Destroy()
	current_template = null
	. = ..()

/obj/machinery/scrap/magnet/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/multitool))
		var/obj/item/multitool/M = O
		if(istype(M.buffer, /obj/machinery/computer/scrap_controls))
			var/obj/machinery/computer/scrap_controls/console = M.buffer
			console.linked_magnet = src
			src.console = console
			visible_message("Linked [src] to [console]")
			return
	else
		. = ..()

/obj/machinery/scrap/magnet/proc/get_ship_template()
	if(current_template)
		return
	current_template = SSmapping.scrap_templates[current_template]
	if(!current_template)
		WARNING("Ship template not found: [current_template]")

/obj/machinery/scrap/magnet/proc/clear_space()
	var/turf/tt = src.target_turf
	for(var/turf/T in block(tt,locate(tt.x+32, tt.y+32, tt.z)))
		T.ChangeTurf(/turf/closed/indestructible/magnet_wall) // there gotta be. a better way.
	for(var/turf/T in current_template.get_affected_turfs(tt))
		T.ChangeTurf(/turf/open/space) // there's probably a more efficient way to ring the outside with walls, inside with space.
		for(var/obj/O in T)
			while(O.contents)
				for(var/I in O.contents)
					qdel(I)
			qdel(O)
		//T.ChangeTurf(/turf/closed/indestructible/magnet_wall)
	// todo: ring outside with walls

/obj/machinery/scrap/magnet/proc/load_ship()
	var/turf/tt = src.target_turf
	var/safe = current_template.check_zone(tt)
	if(safe)
		icon_state = "magnet_active"
		// put up walls around the edges

		//for(var/turf/T in current_template.get_affected_turfs(locate(tt.x+1, tt.y+1, tt.z))
		var/turf/ne = locate(tt.x+1, tt.y+1, tt.z)
		clear_space()
		current_template.load(ne, centered=FALSE)
		sleep(20)
		icon_state = "magnet_on"


/obj/machinery/scrap/magnet/proc/recover_scrap()
	var/list/recovered = list()
	var/turf/pad_loc = src.console.linked_pad.loc
	for(var/turf/T in current_template.get_affected_turfs(target_turf))
		// get scrap from objects
		for(var/obj/scrappable/S in T)
			for(var/I in S.scrap)
				if(istype(I, /obj/item/stack))
					recovered += new I(pad_loc, S.scrap[I]/4) // you get 1/4 the resources, shoulda grabbed the scrap!
				else
					recovered += new I(pad_loc)
		// get any scrap off the ground
		for(var/obj/item/stack/ore/O in T)
			recovered += O
			O.amount = O.amount/2 // 1/2 instead if you deconstructed but left the scrap
			pad_loc.contents += O // theres gotta be a better alternative
		// get scrap from walls and windows and such
		//if(T.sheet_type)
		//	recovered += new T.sheet_type(null, T.sheet_amount/2)
		// now move all that scrap to the pad
		for(var/obj/item in recovered)
			return //move items onto pad


/turf/closed/indestructible/magnet_wall
	name = "magnet barrier"
	desc = "A protective barrier put up by the magnet."
	icon = 'monkestation/icons/obj/scrapping/mapping.dmi'
	icon_state = "magnet_wall"



/obj/machinery/scrap/pad
	name = "scrap pad"
	desc = "A bluespace receiver that will collect any leftover scrap."
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "broadcaster_off"
	var/console // who we're linked to

/obj/machinery/scrap/pad/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/multitool))
		var/obj/item/multitool/M = O
		if(istype(M.buffer, /obj/machinery/computer/scrap_controls))
			var/obj/machinery/computer/scrap_controls/console = M.buffer
			console.linked_pad = src
			src.console = console
			visible_message("Linked [src] to [console]")
			return
	else
		. = ..()

/obj/machinery/scrap/pad/proc/receive_items(list/R)
	src.icon_state = "broadcaster_send"
	sleep(5)
	for(var/I in R)
		src.loc.contents += I
	sleep(5)
	src.icon_state = "broadcaster_off"
