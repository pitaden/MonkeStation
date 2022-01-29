// base code for any fake ship object players take apart for resources
//

/obj/scrappable
	name = "Scrappable Machine"
	desc = "It may be broken, but you could still salvage some materials from it."
	icon = 'icons/obj/stationobjs.dmi'
	verb_say = "beeps"
	verb_yell = "blares"
	density = 1
	pressure_resistance = 15
	pass_flags_self = PASSMACHINE
	max_integrity = 200
	layer = BELOW_OBJ_LAYER
	flags_ricochet = RICOCHET_HARD
	ricochet_chance_mod = 0.3
	anchored = TRUE
	//interaction_flags_atom = INTERACT_ATOM_ATTACK_HAND


	// every tier lower than expected adds a 30% success chance penalty, up to 90% penalty
	// every tier higher than expected adds 10% success chance
	var/list/required_tools = list(
		TOOL_CROWBAR = list("tier"=1, "chance"=100),
		TOOL_MULTITOOL = list("tier"=1, "chance"=100),
		TOOL_SCREWDRIVER = list("tier"=2, "chance"=90)
	)

	// 0: untouched
	// 1: screwdrivered
	// 2: required_tools is done
	var/decon_step = 0
	var/decon_speed = 10 // 1/10 seconds

	// can be None, Radiation, Fire, Cold, Melt Item, Explosion, Immediate Explosion
	var/failure_effect = "None"

	var/list/scrap = list(
		/obj/item/stack/ore/iron/scrap = 8,
		/obj/item/stack/ore/glass/scrap = 5
	)


/obj/scrappable/attackby(obj/item/I, mob/user, params)
	user.changeNext_move(CLICK_CD_MELEE)
	add_fingerprint(user)
	if(I.tool_behaviour == TOOL_SCREWDRIVER && src.decon_step == 0)
		I.play_tool_sound(src, 50)
		to_chat(user, "<span class='notice'>You open the panel of the [src].</span>")
		src.decon_step = 1

	// main deconstruction, sorta based off goon's deconstruction device decons
	else if(src.required_tools.Find(I.tool_behaviour) && src.decon_step == 1)
		to_chat(user, "<span class='notice'>You begin using the [I] on the [src]...</span>")
		I.play_tool_sound(src, 50)
		if(I.use_tool(src, user, decon_speed))
			I.play_tool_sound(src, 50)
			var/toolstats = src.required_tools[I.tool_behaviour] // separate var for readability

			if(prob(toolstats["chance"] + (1 < toolstats["tier"] ? -30*(toolstats["tier"]-1) : 15*(1-toolstats["tier"])))) //TODO: readability, make 1 into I.tier
				to_chat(user, "<span class='notice'>You use the [I] on the [src]!</span>")
				to_chat(user, "<span class='notice'>(Base chance was [toolstats["chance"]], actual was [toolstats["chance"] + (1 < toolstats["tier"] ? -30*(toolstats["tier"]-1) : 15*(1-toolstats["tier"]))]</span>")
				src.required_tools -= I.tool_behaviour
			else
				src.fail_deconstruction(I, user)
			if(LAZYLEN(src.required_tools) == 0)
				src.decon_step = 2

	// we're almost done!
	else if(I.tool_behaviour == TOOL_CROWBAR && src.decon_step == 2)
		if(I.use_tool(src, user, decon_speed))
			to_chat(user, "<span class='notice'>You take the [src] apart into scrap!</span>")
			for(var/o in src.scrap)
				if(istype(o, /obj/item/stack))
					new o(src.loc, src.scrap[o])
				else
					var/i = 0
					while(i < src.scrap[o])
						new o(src.loc)
						i += 1
			qdel(src)

/obj/scrappable/examine(mob/user)
	. = ..()
	if(src.decon_step == 0)
		. += "<span class='notice'>The protective panel is <b>screwed</b> in place.</span>"

	if(src.decon_step == 1)
		for(var/tool in src.required_tools)
			var/tier = src.required_tools[tool]["tier"]+1
			var/tier_labels = list(
				"They're so <b>simple</b>, you can almost take them apart with your bare hands.",
				"", // normal tools
				"They look <b>complicated</b>.",
				"They would take something <b>high-tech</b> to take apart.",
				"It would take truly <b>alien</b> technology to take them apart safely."
			)
			if(tool == TOOL_CROWBAR)
				. += "<span class='notice'>You see several parts you can <b>pry</b> out. [tier_labels[tier]]</span>"
			if(tool == TOOL_MULTITOOL)
				. += "<span class='notice'>You see circuits you can <b>pulse</b>. [tier_labels[tier]]</span>"
			if(tool == TOOL_WIRECUTTER)
				. += "<span class='notice'>You see various wires you can <b>cut</b>. [tier_labels[tier]]</span>"
			if(tool == TOOL_SCREWDRIVER)
				. += "<span class='notice'>You see <b>screws</b> holding parts in place. [tier_labels[tier]]</span>"
			if(tool == TOOL_WRENCH)
				. += "<span class='notice'>You see <b>bolts</b> holding [src] together. [tier_labels[tier]]</span>"
			if(tool == TOOL_WELDER)
				. += "<span class='notice'>You see some structual components you can <b>weld</b> apart. [tier_labels[tier]]</span>"

	if(src.decon_step == 2)
		. += "<span class='notice'>The [src]'s last panels can be <b>pried</b> apart.</span>"

/obj/scrappable/proc/fail_deconstruction(obj/item/I, mob/living/carbon/user)
	if(src.failure_effect == "Radiation")
		user.show_message("<span class='danger'>You poke something with the [I], and a wave of heat washes over you.</span>")
		radiation_pulse(src, 100, 2)
		for(var/mob/living/L in range(5))
			if(L in viewers(get_turf(src)) && !L == user)
				L.show_message("<span class='danger'>A wave of heat emanates from the [src].</span>")

	if(src.failure_effect == "Fire")
		user.show_message("<span class='danger'>Your hand slips, and the [I] lets off sparks. The [src] flares up!</span>")
		user.IgniteMob()
		for(var/mob/living/L in range(5))
			if(L in viewers(get_turf(src)) && !L == user)
				L.show_message("<span class='danger'>The [src] flares up, and flames billow out!</span>")

	if(src.failure_effect == "Cold")
		user.show_message("<span class='danger'>You hear a snap as the [I] hits something, and freezing air washes over you!</span>")
		user.adjust_bodytemperature(150 - user.bodytemperature)
		for(var/mob/living/L in range(5))
			if(L in viewers(get_turf(src)) && !L == user)
				L.show_message("<span class='danger'>Freezing air pours out of the [src]!</span>")

	if(src.failure_effect == "Explosion")
		user.show_message("<span class='danger'>You hear rapid beeping coming from the [src]!</span>")
		for(var/mob/living/L in range(5))
			if(L in viewers(get_turf(src)) && !L == user)
				L.show_message("<span class='danger'>[src] begins to beep rapidly!</span>")
		var/timer = 5
		while(timer > 0)
			src.say("[timer]...")
			sleep(10)
			timer -= 1
		explosion(src.loc,0,2,2)

	if(src.failure_effect == "Immediate Explosion")
		user.show_message("<span class='danger'>You hear rapid beeping coming from the [src]! Its going to-</span>")
		for(var/mob/living/L in range(5))
			if(L in viewers(get_turf(src)) && !L == user)
				L.show_message("<span class='danger'>[src] begins to beep rapidly! Its going to-</span>")
		explosion(src.loc,0,1,1)

	if(src.failure_effect == "None")
		user.show_message("<span class='danger'>Your hand slips!</span>")
