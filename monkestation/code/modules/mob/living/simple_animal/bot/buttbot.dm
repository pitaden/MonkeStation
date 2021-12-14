/mob/living/simple_animal/bot/buttbot
	name = "\improper buttbot"
	desc = "butts"
	icon = 'monkestation/icons/obj/butts.dmi'
	icon_state = "ass" 							//PLACEHOLDER
	density = FALSE
	anchored = FALSE
	health = 25
	maxHealth = 25
	bot_type = BUTTS_BOT
	model = "buttbot"
	window_id = "butt"
	window_name = "butts"
	pass_flags = PASSMOB
	has_unlimited_silicon_privilege = FALSE
	remote_disabled = TRUE
	allow_pai = FALSE
	var/butt_probability = 40
	var/listen_probability = 20

/mob/living/simple_animal/bot/buttbot/Initialize()
	. = ..()
	if(prob(1))
		name = pick("buttsbot", "assbot")
		desc = "buttsbot yes"
		butt_probability = 75

/mob/living/simple_animal/bot/buttbot/emag_act(mob/user)
	if(!emagged)
		visible_message("<span class='warning'>[user] swipes a card through the [src]'s crack!</span>", "<span class='notice'>You swipe a card through the [src]'s crack.</span>")
		listen_probability = 50
		emagged = TRUE
		var/turf/butt = get_turf(src)
		butt.atmos_spawn_air("miasma=5;TEMP=310.15")
		playsound(src, 'monkestation/sound/effects/fart.ogg', 100 ,use_reverb = TRUE)

/mob/living/simple_animal/bot/buttbot/Hear(message, atom/movable/speaker, datum/language/message_language, raw_message, radio_freq, list/spans, list/message_mods)
	. = ..()
	if(ishuman(speaker) && prob(listen_probability))
		var/list/split_message = splittext(raw_message, " ")
		for (var/i in 1 to length(split_message))
			if(prob(butt_probability))
				split_message[i] = pick("butt", "butts")
		if(emagged)
			say(jointext(split_message, " "))
			var/turf/butt = get_turf(src)
			butt.atmos_spawn_air("miasma=5;TEMP=310.15")
		else
			say(jointext(split_message, " "))
		playsound(src, 'monkestation/sound/effects/fart.ogg', 25 ,use_reverb = TRUE)
