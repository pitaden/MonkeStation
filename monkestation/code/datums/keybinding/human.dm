//Quick Emote Binds

/datum/keybinding/emote
	category = CATEGORY_EMOTE
	weight = WEIGHT_LIVING

/datum/keybinding/emote/down(client/user)
	. = ..()
	if(ishuman(user.mob))
		user.mob.emote(name)

/datum/keybinding/emote/fart
	key = "Shift-F"
	name = "fart"
	full_name = "Fart"
	description = "GAS GAS GAS..."

/datum/keybinding/emote/fart/down(client/user)
	if(ishuman(user.mob) && user.mob.stat == CONSCIOUS)
		..()

/datum/keybinding/emote/scream
	key = "Shift-R"
	name = "scream"
	full_name = "Scream"
	description = "AAAAAAAAaaaaaaaaaAAAAAAAAAA"

/datum/keybinding/emote/scream/down(client/user)
	if(ishuman(user.mob) && user.mob.stat == CONSCIOUS)
		var/mob/living/carbon/human/Emoter = user.mob
		Emoter.adjustOxyLoss(5)
		..()

/datum/keybinding/emote/clap
	key = "Unbound"
	name = "clap"
	full_name = "Clap"
	description = "BRAVO, BRAVO!"

/datum/keybinding/emote/clap/down(client/user)
	if(ishuman(user.mob) && user.mob.stat == CONSCIOUS)
		var/mob/living/carbon/human/Emoter = user.mob
		Emoter.apply_damage(0.25, "brute", BODY_ZONE_R_ARM)
		Emoter.apply_damage(0.25, "brute", BODY_ZONE_L_ARM)
		..()

/datum/keybinding/emote/flip
	key = "Unbound"
	name = "flip"
	full_name = "Flip"
	description = "Flip out"

/datum/keybinding/emote/flip/down(client/user)
	if(ishuman(user.mob) && user.mob.stat == CONSCIOUS)
		var/mob/living/carbon/human/Emoter = user.mob
		if(Emoter.IsStun())
			return
		if(Emoter.dizziness >= 20)
			Emoter.vomit()
			return
		Emoter.dizziness++
		..()

/datum/keybinding/emote/spin
	key = "Unbound"
	name = "spin"
	full_name = "Spin"
	description = "Spin to win"

/datum/keybinding/emote/spin/down(client/user)
	if(ishuman(user.mob) && user.mob.stat == CONSCIOUS)
		var/mob/living/carbon/human/Emoter = user.mob
		if(Emoter.IsStun())
			return
		if(Emoter.dizziness >= 20)
			Emoter.vomit()
			return
		Emoter.dizziness++
		..()
