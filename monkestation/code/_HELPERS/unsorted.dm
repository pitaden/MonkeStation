/proc/Grab_Moths(turf/T, range = 6, speed = 0.5) //For all your moth grabbing needs.
	for(var/mob/living/carbon/human/H in oview(range, T))
		if(ismoth(H) && isliving(H))
			pick(H.emote("scream"), H.visible_message("<span class='boldwarning'>[H] lunges for the light!</span>"))
			H.throw_at(T, range, speed)
