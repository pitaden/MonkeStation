/obj/machinery/computer/scrap_controls
	name = "scrap magnet controls"
	desc = "Used to order ships to pull in and scrap."
	icon_screen = "supply"
	icon_keyboard = "power_key"
	circuit = /obj/item/circuitboard/computer/scrap_controls
	light_color = LIGHT_COLOR_YELLOW

	var/obj/machinery/scrap/magnet/linked_magnet
	var/obj/machinery/scrap/pad/linked_pad
	var/list/ships_for_sale

/obj/item/circuitboard/computer/scrap_controls
	name = "Scrap Magnet Controls (Computer Board)"
	icon_state = "engineering"
	build_path = /obj/machinery/computer/scrap_controls

/obj/machinery/computer/scrap_controls/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/multitool))
		var/obj/item/multitool/M = O
		M.buffer = src
		visible_message("Stored [src] to the multitool buffer")
		return
	else
		. = ..()