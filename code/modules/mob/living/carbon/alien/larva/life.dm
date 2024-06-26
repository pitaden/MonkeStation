

/mob/living/carbon/alien/larva/Life()
	set invisibility = 0
	if (notransform)
		return
	if(..() && !IsInStasis()) //not dead and not in stasis
		// GROW!
		if(amount_grown < max_grown)
			amount_grown++
			update_icons()


/mob/living/carbon/alien/larva/update_stat()
	if(status_flags & GODMODE)
		return
	if(stat != DEAD)
		if(health<= -maxHealth || !getorgan(/obj/item/organ/brain))
			death()
			return
		if((HAS_TRAIT(src, TRAIT_KNOCKEDOUT)))
			set_stat(UNCONSCIOUS)
		else
			if(stat == UNCONSCIOUS)
				adjust_blindness(-1)
				set_stat(CONSCIOUS)
	update_damage_hud()
	update_health_hud()
