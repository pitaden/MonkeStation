// for the machine that makes the ships show up, and machines related to it

/obj/scrap/magnet
	name = "scrap magnet"
	desc = "A massive machine built to pull in ships. Older versions used actual magnets, but today, it uses bluespace."
	icon = 'icons/obj/scrapping/magnet.dmi'
	icon_state = "magnet_on"

	//use_power = NO_POWER_USE
	// okay i dont know if this should be machinery.

	// area used is 34x34 (32x32 for the ship itself)
	var/turf/tt // target turf, bottom left corner

	var/datum/map_template/scrap_shuttles/current_template = new /datum/map_template/scrap_shuttles
	var/list/current_objectives
	// list(mob ref="heal", mob ref="kill", obj ref="item", etc)

	var/scrap_pad // where scrap gets sent


/obj/scrap/magnet/proc/get_ship_template()
	if(current_template)
		return
	current_template = SSmapping.scrap_templates[current_template]
	if(!current_template)
		WARNING("Ship template not found: [current_template]")

/obj/scrap/magnet/Destroy()
	current_template = null
	. = ..()


/obj/scrap/magnet/proc/clear_space()
	var/turf/ne = locate(tt.x+1, tt.y+1, tt.z)
	for(var/turf/T in current_template.get_affected_turfs(tt))
		T.ChangeTurf(/turf/open/space) // there's probably a more efficient way to ring the outside with walls, inside with space.
		for(var/O in T)
			qdel(O) // possible problem: what if a player manages to walk in while this is happening? we dont wanna qdel them.
		//T.ChangeTurf(/turf/closed/indestructible/magnet_wall)
	// todo: ring outside with walls

/obj/scrap/magnet/proc/load_ship()
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


/obj/scrap/magnet/proc/recover_scrap()
	var/list/recovered = list()
	for(var/turf/T in current_template.get_affected_turfs(tt))
		for(var/obj/scrappable/S in T)
			for(var/I in S.scrap)
				if(istype(I, /obj/item/stack))
					new I(null, S.scrap[I]/4) // shoulda grabbed the scrap!
		for(var/obj/item/stack/ore/O in T)
			recovered += O
			O.amount = O.amount/2
		//if(T.sheet_type)
		//	recovered += new T.sheet_type(null, T.sheet_amount/2)



/turf/closed/indestructible/magnet_wall
	name = "magnet barrier"
	desc = "A protective barrier put up by the magnet."
	icon = 'icons/obj/scrapping/mapping.dmi'
	icon_state = "magnet_wall"



/obj/scrap/pad
	name = "scrap pad"
	desc = "A bluespace receiver that will collect any leftover scrap."
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "broadcaster_off"

/obj/scrap/pad/proc/receive_items(list/R)
	src.icon_state = "broadcaster_send"
	sleep(5)
	for(var/I in R)
		src.loc.contents += I
	sleep(5)
	src.icon_state = "broadcaster_off"




/obj/machinery/computer/scrap_controls
	name = "scrap magnet controls"
	desc = "Used to order ships to scrap and control the magnet."
	icon_screen = "dna"
	icon_keyboard = "eng_key"
	circuit = /obj/item/circuitboard/computer/scrap_controls
	light_color = LIGHT_COLOR_YELLOW

	var/obj/machinery/scrap_magnet/magnet // linked magnet
	var/list/ships_for_sale // ships you can select to scrap

/obj/item/circuitboard/computer/scrap_controls
	name = "placeholder"
	desc = "placeholder"