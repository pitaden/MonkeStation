/obj/machinery/meter
	name = "gas flow meter"
	desc = "It measures something."
	icon = 'icons/obj/atmospherics/pipes/meter.dmi'
	icon_state = "meter"
	greyscale_config = /datum/greyscale_config/meter
	greyscale_colors = COLOR_GRAY
	layer = GAS_PUMP_LAYER

	power_channel = AREA_USAGE_ENVIRON
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 0.05
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 0.03

	max_integrity = 150
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 100, BOMB = 0, BIO = 100, RAD = 100, FIRE = 40, ACID = 0, STAMINA = 0)

	var/frequency = 0
	var/atom/target
	var/target_layer = PIPING_LAYER_DEFAULT

/obj/machinery/meter/Initialize(mapload, new_piping_layer)
	if(!isnull(new_piping_layer))
		target_layer = new_piping_layer
	SSair.start_processing_machine(src)
	if(!target)
		reattach_to_layer()
	return ..()

/obj/machinery/meter/Destroy()
	SSair.stop_processing_machine(src)
	target = null
	return ..()

/obj/machinery/meter/proc/reattach_to_layer()
	var/obj/machinery/atmospherics/candidate
	for(var/obj/machinery/atmospherics/pipe/pipe in loc)
		if(pipe.piping_layer == target_layer)
			candidate = pipe
			if(pipe.level == 2)
				break
	if(candidate)
		target = candidate
		setAttachLayer(candidate.piping_layer)

/obj/machinery/meter/proc/setAttachLayer(new_layer)
	target_layer = new_layer
	PIPING_LAYER_DOUBLE_SHIFT(src, target_layer)

/obj/machinery/meter/process_atmos()
	if(machine_stat & (BROKEN|NOPOWER))
		icon_state = "meter"
		return FALSE

	if(!target)
		icon_state = "meter0"
		return FALSE

	var/datum/gas_mixture/pipe_air = target.return_air()
	if(!pipe_air)
		icon_state = "meter0"
		return FALSE

	var/env_pressure = pipe_air.return_pressure()
	if(env_pressure <= 0.15 * ONE_ATMOSPHERE)
		icon_state = "meter0"
	else if(env_pressure <= 1.8 * ONE_ATMOSPHERE)
		var/val = round(env_pressure/ (ONE_ATMOSPHERE * 0.3) + 0.5)
		icon_state = "meter1_[val]"
	else if(env_pressure <= 30 * ONE_ATMOSPHERE)
		var/val = round(env_pressure / (ONE_ATMOSPHERE * 5)-0.35) + 1
		icon_state = "meter2_[val]"
	else if(env_pressure <= 59 * ONE_ATMOSPHERE)
		var/val = round(env_pressure / (ONE_ATMOSPHERE * 5) - 6) + 1
		icon_state = "meter3_[val]"
	else
		icon_state = "meter4"

	var/env_temperature = pipe_air.return_temperature()
	var/new_greyscale = greyscale_colors

	if(env_pressure == 0 || env_temperature == 0)
		new_greyscale = COLOR_GRAY
	else
		switch(env_temperature)
			if(BODYTEMP_HEAT_WARNING_3 to INFINITY) //700K+
				new_greyscale = COLOR_RED
			if(BODYTEMP_HEAT_WARNING_2 to BODYTEMP_HEAT_WARNING_3) //460K to 700K
				new_greyscale = COLOR_ORANGE
			if(BODYTEMP_HEAT_WARNING_1 to BODYTEMP_HEAT_WARNING_2) //340K to 460K
				new_greyscale = COLOR_YELLOW
			if(BODYTEMP_COLD_WARNING_1 to BODYTEMP_HEAT_WARNING_1) //270K to 340K
				new_greyscale = COLOR_VIBRANT_LIME
			if(BODYTEMP_COLD_WARNING_2 to BODYTEMP_COLD_WARNING_1) //200K to 270K
				new_greyscale = COLOR_CYAN
			if(BODYTEMP_COLD_WARNING_3 to BODYTEMP_COLD_WARNING_2) //120K to 270K
				new_greyscale = COLOR_BLUE
			else
				new_greyscale = COLOR_VIOLET

	if(new_greyscale != greyscale_colors) //dont update if nothing has changed since last update
		greyscale_colors = new_greyscale
		set_greyscale(greyscale_colors)

	if(frequency)
		var/datum/radio_frequency/radio_connection = SSradio.return_frequency(frequency)
		if(!radio_connection)
			return
		var/datum/signal/signal = new(list(
			"id_tag" = id_tag,
			"device" = "AM",
			"pressure" = round(env_pressure),
			"sigtype" = "status"
		))
		radio_connection.post_signal(src, signal)

/obj/machinery/meter/proc/status(mob/user)
	if(target)
		var/datum/gas_mixture/pipe_air = target.return_air()
		if(pipe_air)
			to_chat(user, span_info("The thermometrics gauge reads:"))
			to_chat(user, span_info("Temperature: [round(pipe_air.return_temperature(),0.01)] K ([round(pipe_air.return_temperature()-T0C,0.01)]&deg;C)"))
			to_chat(user, span_info("Pressure: [round(pipe_air.return_pressure(), 0.01)] kPa"))
			to_chat(user, span_info("Volume of Pipenet: [pipe_air.return_volume()] L"))
		else
			. = "The sensor error light is blinking."
	else
		. = "The connect error light is blinking."

/obj/machinery/meter/examine(mob/user)
	. = ..()
	status(user)

/obj/machinery/meter/wrench_act(mob/user, obj/item/wrench)
	..()
	balloon_alert(user, "unfastening \the [src]..." )
	to_chat(user, span_notice("You begin to unfasten \the [src]..."))
	if(wrench.use_tool(src, user, 40, volume = 50))
		user.visible_message(
			"[user] unfastens \the [src].",
			span_notice("You unfasten \the [src]."),
			span_hear("You hear ratchet."))
		deconstruct()
	return TRUE

/obj/machinery/meter/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		new /obj/item/pipe_meter(loc)
	qdel(src)

/obj/machinery/meter/interact(mob/user)
	if(machine_stat & (NOPOWER|BROKEN))
		return
	else
		status(user)

/obj/machinery/meter/singularity_pull(S, current_size)
	..()
	if(current_size >= STAGE_FIVE)
		deconstruct()



// Mapping Presets
/obj/machinery/meter/layer2
	target_layer = 2

/obj/machinery/meter/layer4
	target_layer = 4

/obj/machinery/meter/atmos
	frequency = FREQ_ATMOS_STORAGE

/obj/machinery/meter/atmos/atmos_waste_loop
	name = "waste loop gas flow meter"
	id_tag = ATMOS_GAS_MONITOR_LOOP_ATMOS_WASTE

/obj/machinery/meter/atmos/distro_loop
	name = "distribution loop gas flow meter"
	id_tag = ATMOS_GAS_MONITOR_LOOP_DISTRIBUTION

// TURF METER - REPORTS A TILE'S AIR CONTENTS
//	why are you yelling?
/obj/machinery/meter/turf

/obj/machinery/meter/turf/reattach_to_layer()
	target = loc

