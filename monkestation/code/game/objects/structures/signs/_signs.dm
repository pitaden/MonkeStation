/obj/structure/sign
	//Scaling Posters
	var/size = 1

/obj/structure/sign/attack_hand(mob/user)
	//Scaling Posters
	if(user.a_intent == INTENT_HELP)
		add_fingerprint(user)
		visible_message("<span class='warning'>[pick("[user] taps the sign.", "[user] stares intently as they tap that sign.", "Don't make [user] tap that sign again.")]</span>")
		var/matrix/M = new
		M.Scale(size*0.25+1)
		animate(src, transform = M, time = 5)
		playsound(src, 'sound/effects/Glassknock.ogg', 50, 1)
		user.changeNext_move(CLICK_CD_MELEE)
		spawn(1 SECONDS)
			if(size)
				var/scaled = 100/(100+((size*0.25)*100))
				M.Scale(scaled)
				animate(src, transform = M, time = 5)
				size++
