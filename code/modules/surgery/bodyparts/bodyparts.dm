
/obj/item/bodypart
	name = "limb"
	desc = "Why is it detached..."
	force = 3
	throwforce = 3
	icon = 'icons/mob/human_parts_greyscale.dmi'
	icon_state = ""
	//so it isn't hidden behind objects when on the floor
	layer = BELOW_MOB_LAYER

///TRUE/FALSE variables-------------------------
	//Does this limb have a greyscale version?
	var/uses_mutcolor = TRUE
	//Is there a sprite difference between male and female?
	var/is_dimorphic = FALSE
	///are we husked?
	var/is_husked = FALSE
	//For limbs that don't really exist, eg chainsaws
	var/is_pseudopart = FALSE
	//is this limb in need of an update?
	var/no_update = FALSE
	//whether it can be dismembered with a weapon.
	var/dismemberable = TRUE
	///does the limb need to be processing?
	var/needs_processing = FALSE
///--------------------------------------------

///ICONS AND ICON PATH VARIABLES---------------
	/// the husked icon of the bodypart
	var/husk_icon = 'icons/mob/human_parts.dmi'
	/// what type of husk
	var/husk_type = "humanoid"
	//Uncolorable sprites
	var/static_icon = 'icons/mob/human_parts.dmi'
	//the type of damage overlay (if any) to use when this bodypart is bruised/burned.
	var/dmg_overlay_type
///--------------------------------------------

///COLORINGS and OVERLAY VARIABLES ------------
	//Coloring and proper item icon update
	var/skin_tone = ""
	//list of skin tones
	var/skin_tone_list = "" //monkestation edit - skin tone refactor
	//Limbs need this information as a back-up incase they are generated outside of a carbon (limbgrower)
	var/should_draw_greyscale = TRUE
	//the color given by the species for limbs
	var/species_color = ""
	//the mutation color given by the mcolor dna strand
	var/mutation_color = ""
	//Defines what sprite the limb should use if it is also sexually dimorphic.
	var/limb_gender = "m"
	//Greyscale draw color
	var/draw_color
///--------------------------------------------

///REFERENCES----------------------------------
	//limb current owner
	var/mob/living/carbon/owner = null
	//limbs original owner
	var/datum/weakref/original_owner = null
///--------------------------------------------

///FLAGS AND DATA------------------------------
	///If you'd like to know if a bodypart is organic, please use is_organic_limb()
	//List of bodytypes flags, important for fitting clothing.
	var/bodytype = BODYTYPE_HUMANOID | BODYTYPE_ORGANIC
	//Defines when a bodypart should not be changed. Example: BP_BLOCK_CHANGE_SPECIES prevents the limb from being overwritten on species gain
	var/change_exempt_flags
	//This is effectively the icon_state for limbs.
	var/limb_id = SPECIES_HUMAN
	///If disabled, limb is as good as missing.
	var/bodypart_disabled = FALSE
	///Multiplied by max_damage it returns the threshold which defines a limb being disabled or not. From 0 to 1.
	var/disable_threshold = 1
	///Controls whether bodypart_disabled makes sense or not for this limb.
	var/can_be_disabled = FALSE

	//BODY_ZONE_CHEST, BODY_ZONE_L_ARM, etc , used for def_zone
	var/body_zone
	//used for hands
	var/aux_zone
	///layer for hands
	var/aux_layer
	//bitflag used to check which clothes cover this bodypart
	var/body_part = null
	//are we a hand? if so, which one!
	var/held_index = 0
	//for nonhuman bodypart (e.g. monkey)
	var/animal_origin = null
	//x pixel of the limb
	var/px_x = 0
	//y pixel of the limb
	var/px_y = 0
///--------------------------------------------

///LISTS---------------------------------------
	//list of flags based on the species of the limb
	var/species_flags_list = list()
	//list of all embedded objects
	var/list/embedded_objects = list()
///--------------------------------------------

///LIMB DAMAGE INFORMATION---------------------
	//Multiplier of the limb's damage that gets applied to the mob
	var/body_damage_coeff = 1
	//Multiplier of the limb's stamina damage, set lower so to not make stun locking easier.
	var/stam_damage_coeff = 0.7
	//the brute damage state of the limb
	var/brutestate = 0
	//the burn damage state of the limb
	var/burnstate = 0
	//the brute damage of the limb
	var/brute_dam = 0
	//the burn damage of the limb
	var/burn_dam = 0
	//the maximum amount of damage the limb can take stamina wise
	var/max_stamina_damage = 0
	//the maximum amount of damage the limb can take
	var/max_damage = 0

	//how much stamina damage we have taken
	var/stamina_dam = 0
	//Stamina heal multiplier
	var/stamina_heal_rate = 1

	//Subtracted to brute damage taken
	var/brute_reduction = 0
	//Subtracted to burn damage taken
	var/burn_reduction = 0
///--------------------------------------------

///LIMB DAMAGE TEXT----------------------------
	//Damage messages used by help_shake_act()
	var/light_brute_msg = "bruised"
	var/medium_brute_msg = "battered"
	var/heavy_brute_msg = "mangled"

	var/light_burn_msg = "numb"
	var/medium_burn_msg = "blistered"
	var/heavy_burn_msg = "peeling away"
///--------------------------------------------

/obj/item/bodypart/Initialize(mapload)
	..()
	if(can_be_disabled)
		RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS), .proc/on_paralysis_trait_gain)
		RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS), .proc/on_paralysis_trait_loss)
	name = "[limb_id] [parse_zone(body_zone)]"
	if(is_dimorphic)
		limb_gender = pick("m", "f")
	update_icon_dropped()

/obj/item/bodypart/Destroy()
	if(owner)
		owner.remove_bodypart(src)
		set_owner(null)
	return ..()

/obj/item/bodypart/forceMove(atom/destination) //Please. Never forcemove a limb if its's actually in use. This is only for borgs.
	. = ..()
	if(isturf(destination))
		update_icon_dropped()

/obj/item/bodypart/examine(mob/user)
	. = ..()
	if(brute_dam >= DAMAGE_PRECISION)
		. += "<span class='warning'>This limb has [brute_dam > 30 ? "severe" : "minor"] bruising.</span>"
	if(burn_dam >= DAMAGE_PRECISION)
		. += "<span class='warning'>This limb has [burn_dam > 30 ? "severe" : "minor"] burns.</span>"
	if(limb_id)
		. += "<span class='notice'>It is a [limb_id] [parse_zone(body_zone)].</span>"

/obj/item/bodypart/blob_act()
	take_damage(max_damage)

/obj/item/bodypart/Destroy()
	if(owner)
		owner.bodyparts -= src
		owner = null
	return ..()

/obj/item/bodypart/attack(mob/living/carbon/carbon_target, mob/user)
	if(ishuman(carbon_target))
		var/mob/living/carbon/human/human_target = carbon_target
		if(HAS_TRAIT(carbon_target, TRAIT_LIMBATTACHMENT))
			if(!human_target.get_bodypart(body_zone) && !animal_origin)
				if(human_target == user)
					human_target.visible_message("<span class='warning'>[human_target] jams [src] into [human_target.p_their()] empty socket!</span>",\
					"<span class='notice'>You force [src] into your empty socket, and it locks into place!</span>")
				else
					human_target.visible_message("<span class='warning'>[user] jams [src] into [human_target]'s empty socket!</span>",\
					"<span class='notice'>[user] forces [src] into your empty socket, and it locks into place!</span>")
				user.temporarilyRemoveItemFromInventory(src, TRUE)
				attach_limb(carbon_target)
				return
	..()

/obj/item/bodypart/attackby(obj/item/attacking_item, mob/user, params)
	if(attacking_item.is_sharp())
		add_fingerprint(user)
		if(!contents.len)
			to_chat(user, "<span class='warning'>There is nothing left inside [src]!</span>")
			return
		playsound(loc, 'sound/weapons/slice.ogg', 50, 1, -1)
		user.visible_message("<span class='warning'>[user] begins to cut open [src].</span>",\
			"<span class='notice'>You begin to cut open [src]...</span>")
		if(do_after(user, 54, target = src))
			drop_organs(user, TRUE)
	else
		return ..()

/obj/item/bodypart/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	..()
	if(IS_ORGANIC_LIMB(src))
		playsound(get_turf(src), 'sound/misc/splort.ogg', 50, 1, -1)
	pixel_x = rand(-3, 3)
	pixel_y = rand(-3, 3)

//empties the bodypart from its organs and other things inside it
/obj/item/bodypart/proc/drop_organs(mob/user, violent_removal)
	var/turf/T = get_turf(src)
	if(IS_ORGANIC_LIMB(src))
		playsound(T, 'sound/misc/splort.ogg', 50, 1, -1)
	for(var/obj/item/I in src)
		I.forceMove(T)

/obj/item/bodypart/proc/consider_processing()
	if(stamina_dam >= DAMAGE_PRECISION)
		. = TRUE
	//else if.. else if.. so on.
	else
		. = FALSE
	needs_processing = .

//Return TRUE to get whatever mob this is in to update health.
/obj/item/bodypart/proc/on_life(stam_regen)
	if(stamina_dam >= DAMAGE_PRECISION && stam_regen)					//DO NOT update health here, it'll be done in the carbon's life.
		heal_damage(0, 0, stam_regen, null, FALSE)
		. |= BODYPART_LIFE_UPDATE_HEALTH

//Applies brute and burn damage to the organ. Returns 1 if the damage-icon states changed at all.
//Damage will not exceed max_damage using this proc
//Cannot apply negative damage
/obj/item/bodypart/proc/receive_damage(brute = 0, burn = 0, stamina = 0, blocked = 0, updating_health = TRUE, required_status = null)
	var/hit_percent = (100-blocked)/100
	if((!brute && !burn && !stamina) || hit_percent <= 0)
		return FALSE
	if(owner && (owner.status_flags & GODMODE))
		return FALSE	//godmode
	if(required_status && !(bodytype & required_status))
		return FALSE

	var/dmg_mlt = CONFIG_GET(number/damage_multiplier) * hit_percent
	brute = round(max(brute * dmg_mlt, 0),DAMAGE_PRECISION)
	burn = round(max(burn * dmg_mlt, 0),DAMAGE_PRECISION)
	stamina = round(max(stamina * dmg_mlt, 0),DAMAGE_PRECISION)
	brute = max(0, brute - brute_reduction)
	burn = max(0, burn - burn_reduction)
	//No stamina scaling.. for now..

	if(!brute && !burn && !stamina)
		return FALSE

	switch(animal_origin)
		if(ALIEN_BODYPART,LARVA_BODYPART) //aliens take double burn //nothing can burn with so much snowflake code around
			burn *= 2

	var/can_inflict = (max_damage * 2) - get_damage()
	if(can_inflict <= 0)
		return FALSE

	var/total_damage = brute + burn

	if(total_damage > can_inflict)
		brute = round(brute * (can_inflict / total_damage),DAMAGE_PRECISION)
		burn = round(burn * (can_inflict / total_damage),DAMAGE_PRECISION)

	if(brute)
		set_brute_dam(brute_dam + brute)
	if(burn)
		set_burn_dam(burn_dam + burn)

	//We've dealt the physical damages, if there's room lets apply the stamina damage.
	if(stamina)
		set_stamina_dam(stamina_dam + round(clamp(stamina, 0, max_stamina_damage - stamina_dam), DAMAGE_PRECISION))


	if(owner)
		if(can_be_disabled)
			update_disabled()
		if(updating_health)
			owner.updatehealth()
			if(stamina > DAMAGE_PRECISION)
				owner.update_stamina()
				owner.stam_regen_start_time = world.time + STAMINA_REGEN_BLOCK_TIME
				. = TRUE
	return update_bodypart_damage_state()

//Heals brute and burn damage for the organ. Returns 1 if the damage-icon states changed at all.
//Damage cannot go below zero.
//Cannot remove negative damage (i.e. apply damage)
/obj/item/bodypart/proc/heal_damage(brute, burn, stamina, required_status, updating_health = TRUE)

	if(required_status && !(bodytype & required_status)) //So we can only heal certain kinds of limbs, ie robotic vs organic.
		return

	if(brute)
		set_brute_dam(round(max(brute_dam - brute, 0), DAMAGE_PRECISION))
	if(burn)
		set_burn_dam(round(max(burn_dam - burn, 0), DAMAGE_PRECISION))
	if(stamina)
		set_stamina_dam(round(max(stamina_dam - stamina, 0), DAMAGE_PRECISION))

	if(owner)
		if(can_be_disabled)
			update_disabled()
		if(updating_health)
			owner.updatehealth()

	return update_bodypart_damage_state()

///Proc to hook behavior associated to the change of the brute_dam variable's value.
/obj/item/bodypart/proc/set_brute_dam(new_value)
	if(brute_dam == new_value)
		return
	. = brute_dam
	brute_dam = new_value


///Proc to hook behavior associated to the change of the burn_dam variable's value.
/obj/item/bodypart/proc/set_burn_dam(new_value)
	if(burn_dam == new_value)
		return
	. = burn_dam
	burn_dam = new_value


///Proc to hook behavior associated to the change of the stamina_dam variable's value.
/obj/item/bodypart/proc/set_stamina_dam(new_value)
	if(stamina_dam == new_value)
		return
	. = stamina_dam
	stamina_dam = new_value
	if(stamina_dam > DAMAGE_PRECISION)
		needs_processing = TRUE
	else
		needs_processing = FALSE

//Returns total damage.
/obj/item/bodypart/proc/get_damage(include_stamina = FALSE)
	var/total = brute_dam + burn_dam
	if(include_stamina)
		total = max(total, stamina_dam)
	return total

//Checks disabled status thresholds
/obj/item/bodypart/proc/update_disabled()
	if(!owner)
		return
	if(!can_be_disabled)
		set_disabled(FALSE)
		CRASH("update_disabled called with can_be_disabled false")

	if(HAS_TRAIT(src, TRAIT_PARALYSIS))
		set_disabled(TRUE)
		return

	var/total_damage = max(brute_dam + burn_dam, stamina_dam)

	if(total_damage >= max_damage * disable_threshold) //Easy limb disable disables the limb at 40% health instead of 0%
		set_disabled(TRUE)
		return

	if(bodypart_disabled && total_damage <= max_damage * 0.8) // reenabled at 80% now instead of 50% as of wounds update
		set_disabled(FALSE)

/obj/item/bodypart/proc/set_disabled(new_disabled)
	if(bodypart_disabled == new_disabled)
		return
	. = bodypart_disabled
	bodypart_disabled = new_disabled

	if(!owner)
		return

	owner.update_health_hud() //update the healthdoll
	owner.update_body()

///Proc to change the value of the `owner` variable and react to the event of its change.
/obj/item/bodypart/proc/set_owner(mob/living/carbon/new_owner)
	SHOULD_CALL_PARENT(TRUE)

	if(owner == new_owner)
		return FALSE //`null` is a valid option, so we need to use a num var to make it clear no change was made.
	var/mob/living/carbon/old_owner = owner
	owner = new_owner
	var/needs_update_disabled = FALSE //Only really relevant if there's an owner
	if(old_owner)
		if(initial(can_be_disabled))
			if(HAS_TRAIT(old_owner, TRAIT_NOLIMBDISABLE))
				if(!owner || !HAS_TRAIT(owner, TRAIT_NOLIMBDISABLE))
					set_can_be_disabled(initial(can_be_disabled))
					needs_update_disabled = TRUE
			UnregisterSignal(old_owner, list(
				SIGNAL_REMOVETRAIT(TRAIT_NOLIMBDISABLE),
				SIGNAL_ADDTRAIT(TRAIT_NOLIMBDISABLE),
				))
	if(owner)
		if(initial(can_be_disabled))
			if(HAS_TRAIT(owner, TRAIT_NOLIMBDISABLE))
				set_can_be_disabled(FALSE)
				needs_update_disabled = FALSE
			RegisterSignal(new_owner, SIGNAL_REMOVETRAIT(TRAIT_NOLIMBDISABLE), .proc/on_owner_nolimbdisable_trait_loss)
			RegisterSignal(new_owner, SIGNAL_ADDTRAIT(TRAIT_NOLIMBDISABLE), .proc/on_owner_nolimbdisable_trait_gain)

		if(needs_update_disabled)
			update_disabled()

	return old_owner


///Proc to change the value of the `can_be_disabled` variable and react to the event of its change.
/obj/item/bodypart/proc/set_can_be_disabled(new_can_be_disabled)
	if(can_be_disabled == new_can_be_disabled)
		return
	. = can_be_disabled
	can_be_disabled = new_can_be_disabled
	if(can_be_disabled)
		if(owner)
			if(HAS_TRAIT(owner, TRAIT_NOLIMBDISABLE))
				CRASH("set_can_be_disabled to TRUE with for limb whose owner has TRAIT_NOLIMBDISABLE")
			RegisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS), .proc/on_paralysis_trait_gain)
			RegisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS), .proc/on_paralysis_trait_loss)
		update_disabled()
	else if(.)
		if(owner)
			UnregisterSignal(owner, list(
				SIGNAL_ADDTRAIT(TRAIT_PARALYSIS),
				SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS),
				))
		set_disabled(FALSE)


///Called when TRAIT_PARALYSIS is added to the limb.
/obj/item/bodypart/proc/on_paralysis_trait_gain(obj/item/bodypart/source)
	SIGNAL_HANDLER
	if(can_be_disabled)
		set_disabled(TRUE)


///Called when TRAIT_PARALYSIS is removed from the limb.
/obj/item/bodypart/proc/on_paralysis_trait_loss(obj/item/bodypart/source)
	SIGNAL_HANDLER
	if(can_be_disabled)
		update_disabled()


///Called when TRAIT_NOLIMBDISABLE is added to the owner.
/obj/item/bodypart/proc/on_owner_nolimbdisable_trait_gain(mob/living/carbon/source)
	SIGNAL_HANDLER
	set_can_be_disabled(FALSE)


///Called when TRAIT_NOLIMBDISABLE is removed from the owner.
/obj/item/bodypart/proc/on_owner_nolimbdisable_trait_loss(mob/living/carbon/source)
	SIGNAL_HANDLER
	set_can_be_disabled(initial(can_be_disabled))

//Updates an organ's brute/burn states for use by update_damage_overlays()
//Returns 1 if we need to update overlays. 0 otherwise.
/obj/item/bodypart/proc/update_bodypart_damage_state()
	var/tbrute = round((min(brute_dam, max_damage) / max_damage) * 3, 1)
	var/tburn = round((min(burn_dam, max_damage) / max_damage) * 3, 1)
	if((tbrute != brutestate) || (tburn != burnstate))
		brutestate = tbrute
		burnstate = tburn
		return TRUE
	return FALSE

//Change limb between
//Note:This proc only exists because I can't be arsed to remove it yet. Theres no real reason this should ever be used.
/obj/item/bodypart/proc/change_bodypart_status(new_limb_status, heal_limb, change_icon_to_default)
	if(!(bodytype & new_limb_status))
		bodytype &= ~(BODYTYPE_ROBOTIC & BODYTYPE_ORGANIC)
		bodytype |= new_limb_status

	if(heal_limb)
		burn_dam = 0
		brute_dam = 0
		brutestate = 0
		burnstate = 0

	if(change_icon_to_default)
		if(IS_ORGANIC_LIMB(src))
			icon = DEFAULT_BODYPART_ICON_ORGANIC
		else
			icon = DEFAULT_BODYPART_ICON_ROBOTIC

	if(owner)
		owner.updatehealth()
		owner.update_body() //if our head becomes robotic, we remove the lizard horns and human hair.
		owner.update_hair()
		owner.update_damage_overlays()


//we inform the bodypart of the changes that happened to the owner, or give it the informations from a source mob.
//set is_creating to true if you want to change the appearance of the limb outside of mutation changes or forced changes.
/obj/item/bodypart/proc/update_limb(dropping_limb, mob/living/carbon/source, is_creating = FALSE, forcing_update = FALSE)
	// The current host of the limb
	var/mob/living/carbon/limb_host

	if(source) //do we have an attached source?
		limb_host = source //if we do set that to the limb_host
		if(!original_owner)// does the limb have an original owner usually happens with printed limbs or spawned in things
			original_owner = WEAKREF(source)

	else if(original_owner && !IS_WEAKREF_OF(owner, original_owner)) //Foreign limb
		no_update = TRUE

	else
		limb_host = owner
		no_update = FALSE

	if(ishuman(limb_host))
		//Since we checked if we are a human we need to create a new host to access the human specific variables
		var/mob/living/carbon/human/host = limb_host
		//quick access to the hosts species aswell to not have to call host.dna.species every time
		var/datum/species/host_species = host.dna.species

		/// this section will need to be repeated for unique types of bodys that use things other than mutcolor and color non accessories in the future if we ever add them
		if((MUTCOLORS in host_species.species_traits) && should_draw_greyscale) //are we a mutcolor and do we color the limb?
			if((draw_color == host.dna.features["mcolor"])) // does our current color match the mcolor?
				no_update = FALSE

	if(HAS_TRAIT(limb_host, TRAIT_HUSK) && IS_ORGANIC_LIMB(src))
		dmg_overlay_type = "" //no damage overlay shown when husked
		is_husked = TRUE
	else
		dmg_overlay_type = initial(dmg_overlay_type) //revert back to the limbs dmg_overlay
		is_husked = FALSE

	if(!dropping_limb && limb_host.dna?.check_mutation(HULK)) //Please remove hulk from the game. I beg you.
		mutation_color = "00aa00"
	else
		mutation_color = null

	if(mutation_color) //I hate mutations
		draw_color = mutation_color

	else if(should_draw_greyscale)
		draw_color = (species_color) || (skin_tone)
	else
		draw_color = null

	if(no_update)
		return

	if(!is_creating && no_update && !forcing_update) //is it creating? is there an update needed? is it being forced to update regardless?
		return

	if(!animal_origin && ishuman(limb_host))
		//defining human here again because byond moment. Allows access to human variables
		var/mob/living/carbon/human/host = limb_host
		//short hand access for host.dna.species
		var/datum/species/host_species = host.dna.species

		species_flags_list = host.dna.species.species_traits //Literally only exists for a single use of NOBLOOD, but, no reason to remove it i guess...?
		limb_gender = (host.gender == MALE) ? "m" : "f" //we grab the limbs gender for icon rendering from the hosts gender.

		if(SKINTONES in host_species.species_traits) // are we a skintone type of species like human?
			skin_tone = GLOB.skin_tones[host.dna.species.skin_tone_list][host.skin_tone]
		else
			skin_tone = "" //we don't want non skintone creatures having them it looks weird with mutcolors


		if(((MUTCOLORS in host_species.species_traits) || (DYNCOLORS in host_species.species_traits)) && uses_mutcolor) //are we a mutcolor species, or etheral?
			if(host_species.dyncolor)//monkestation edit: add simians; make dyncolor more useful
				host_species.fixed_mut_color = host.dna.features[host_species.dyncolor]//monkestation edit: add simians; make dyncolor more useful
			if(host_species.fixed_mut_color)
				species_color = host_species.fixed_mut_color
			else
				species_color = host.dna.features["mcolor"]
		else
			species_color = "" //same thing here we don't want rgb humans now do we

		draw_color = mutation_color
		if(should_draw_greyscale) //Should the limb be colored?
			draw_color ||= (species_color) || (skin_tone)

	if(dropping_limb)
		no_update = TRUE //when attached, the limb won't be affected by the appearance changes of its mob owner.

//to update the bodypart's icon when not attached to a mob
/obj/item/bodypart/proc/update_icon_dropped()
	cut_overlays()
	var/list/standing = get_limb_icon(1)
	if(!standing.len)
		icon_state = initial(icon_state)//no overlays found, we default back to initial icon.
		return
	for(var/image/I in standing)
		I.pixel_x = px_x
		I.pixel_y = px_y
	add_overlay(standing)


/obj/item/bodypart/proc/get_limb_icon(dropped)
	icon_state = "" //to erase the default sprite, we're building the visual aspects of the bodypart through overlays alone.

	. = list()

	//Handles dropped icons
	var/image_dir = 0
	if(dropped)
		image_dir = SOUTH
		if(dmg_overlay_type)
			if(brutestate)
				. += image('icons/mob/dam_mob.dmi', "[dmg_overlay_type]_[body_zone]_[brutestate]0", -DAMAGE_LAYER, image_dir)
			if(burnstate)
				. += image('icons/mob/dam_mob.dmi', "[dmg_overlay_type]_[body_zone]_0[burnstate]", -DAMAGE_LAYER, image_dir)

	var/image/limb = image(layer = -BODYPARTS_LAYER, dir = image_dir)
	var/image/aux


	if(animal_origin) //Cringe ass animal-specific code.
		if(IS_ORGANIC_LIMB(src))
			limb.icon = 'icons/mob/animal_parts.dmi'
			if(is_husked)
				limb.icon_state = "[animal_origin]_husk_[body_zone]"
			else
				limb.icon_state = "[animal_origin]_[body_zone]"
		else
			limb.icon = 'icons/mob/augmentation/augments.dmi'
			limb.icon_state = "[animal_origin]_[body_zone]"

		if(blocks_emissive)
			var/mutable_appearance/limb_em_block = mutable_appearance(limb.icon, limb.icon_state, plane = EMISSIVE_PLANE, appearance_flags = KEEP_APART)
			limb_em_block.dir = image_dir
			limb_em_block.color = GLOB.em_block_color
			limb.overlays += limb_em_block
		. += limb
		return

	if(is_husked)
		limb.icon = husk_icon
		limb.icon_state = "[husk_type]_husk_[body_zone]"
		. += limb
		if(aux_zone) //Hand shit
			aux = image(limb.icon, "[husk_type]_husk_[aux_zone]", -aux_layer, image_dir)
			. += aux
		return

	////This is the MEAT of limb icon code
	if(!should_draw_greyscale || !icon)
		limb.icon = static_icon
	else
		limb.icon = icon

	///The icon_state overlay for the limb
	limb.icon_state = "[limb_id]_[body_zone][is_dimorphic ? "_[limb_gender]" : ""]"

	if(!icon_exists(limb.icon, limb.icon_state))
		stack_trace("Limb generated with nonexistant icon. File: [limb.icon] | State: [limb.icon_state]")

	if(body_zone == BODY_ZONE_R_LEG)
		var/obj/item/bodypart/r_leg/leg = src
		var/limb_overlays = limb.overlays
		var/image/new_limb = leg.generate_masked_right_leg(limb.icon, limb.icon_state, image_dir)
		if(new_limb)
			limb = new_limb
			limb.overlays = limb_overlays

	. += limb

	if(aux_zone) //Hand shit
		aux = image(limb.icon, "[limb_id]_[aux_zone]", -aux_layer, image_dir)
		. += aux

	if(blocks_emissive)
		var/mutable_appearance/limb_em_block = mutable_appearance(limb.icon, limb.icon_state, -BODYPARTS_LAYER, plane = EMISSIVE_PLANE, appearance_flags = KEEP_APART)
		limb_em_block.dir = image_dir
		limb_em_block.color = GLOB.em_block_color
		. += limb_em_block

	draw_color = mutation_color
	if(should_draw_greyscale) //Should the limb be colored?
		draw_color ||= (species_color) || (skin_tone)

	if(draw_color)
		limb.color = "#[draw_color]"
		if(aux_zone)
			aux.color = "#[draw_color]"

	if(blocks_emissive)
		var/mutable_appearance/limb_em_block = mutable_appearance(limb.icon, limb.icon_state, -BODYPARTS_LAYER,  plane = EMISSIVE_PLANE, appearance_flags = KEEP_APART)
		limb_em_block.dir = image_dir
		limb_em_block.color = GLOB.em_block_color
		. += limb_em_block

		if(aux_zone)
			var/mutable_appearance/aux_em_block = mutable_appearance(aux.icon, aux.icon_state, -BODYPARTS_LAYER, plane = EMISSIVE_PLANE, appearance_flags = KEEP_APART)
			aux_em_block.dir = image_dir
			aux_em_block.color = GLOB.em_block_color
			. += aux_em_block

/obj/item/bodypart/deconstruct(disassembled = TRUE)
	drop_organs()
	qdel(src)

/obj/item/bodypart/chest
	name = BODY_ZONE_CHEST
	desc = "It's impolite to stare at a person's chest."
	icon_state = "default_human_chest"
	max_damage = 200
	body_zone = BODY_ZONE_CHEST
	body_part = CHEST
	px_x = 0
	px_y = 0
	stam_damage_coeff = 1
	max_stamina_damage = 120
	is_dimorphic = TRUE
	var/obj/item/cavity_item

	dmg_overlay_type = "human"

/obj/item/bodypart/chest/can_dismember(obj/item/I)
	if(!((owner.stat == DEAD) || owner.InFullCritical()))
		return FALSE
	return ..()

/obj/item/bodypart/chest/Destroy()
	QDEL_NULL(cavity_item)
	return ..()

/obj/item/bodypart/chest/drop_organs(mob/user, violent_removal)
	if(cavity_item)
		cavity_item.forceMove(drop_location())
		cavity_item = null
	..()

/obj/item/bodypart/chest/monkey
	icon = 'icons/mob/animal_parts.dmi'
	icon_state = "default_monkey_chest"
	limb_id = SPECIES_MONKEY
	animal_origin = MONKEY_BODYPART

	dmg_overlay_type = "monkey"

/obj/item/bodypart/chest/monkey/teratoma
	icon_state = "teratoma_chest"
	limb_id = "teratoma"
	animal_origin = TERATOMA_BODYPART

/obj/item/bodypart/chest/alien
	icon = 'icons/mob/animal_parts.dmi'
	icon_state = "alien_chest"
	dismemberable = 0
	max_damage = 500
	animal_origin = ALIEN_BODYPART

/obj/item/bodypart/chest/devil
	dismemberable = 0
	max_damage = 5000
	animal_origin = DEVIL_BODYPART

/obj/item/bodypart/chest/larva
	icon = 'icons/mob/animal_parts.dmi'
	icon_state = "larva_chest"
	dismemberable = 0
	max_damage = 50
	animal_origin = LARVA_BODYPART

/obj/item/bodypart/l_arm
	name = "left arm"
	desc = "Did you know that the word 'sinister' stems originally from the \
		Latin 'sinestra' (left hand), because the left hand was supposed to \
		be possessed by the devil? This arm appears to be possessed by no \
		one though."
	icon_state = "default_human_l_arm"
	attack_verb = list("slapped", "punched")
	max_damage = 50
	max_stamina_damage = 50
	body_zone = BODY_ZONE_L_ARM
	body_part = ARM_LEFT
	aux_zone = BODY_ZONE_PRECISE_L_HAND
	aux_layer = HANDS_PART_LAYER
	body_damage_coeff = 0.75
	held_index = 1
	px_x = -6
	px_y = 0
	can_be_disabled = TRUE
	dmg_overlay_type = "human"

/obj/item/bodypart/l_arm/set_owner(new_owner)
	. = ..()
	if(. == FALSE)
		return
	if(owner)
		if(HAS_TRAIT(owner, TRAIT_PARALYSIS_L_ARM))
			ADD_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_L_ARM)
			RegisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS_L_ARM), .proc/on_owner_paralysis_loss)
		else
			REMOVE_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_L_ARM)
			RegisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS_L_ARM), .proc/on_owner_paralysis_gain)
	if(.)
		var/mob/living/carbon/old_owner = .
		if(HAS_TRAIT(old_owner, TRAIT_PARALYSIS_L_ARM))
			UnregisterSignal(old_owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS_L_ARM))
			if(!owner || !HAS_TRAIT(owner, TRAIT_PARALYSIS_L_ARM))
				REMOVE_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_L_ARM)
		else
			UnregisterSignal(old_owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS_L_ARM))


///Proc to react to the owner gaining the TRAIT_PARALYSIS_L_ARM trait.
/obj/item/bodypart/l_arm/proc/on_owner_paralysis_gain(mob/living/carbon/source)
	SIGNAL_HANDLER
	ADD_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_L_ARM)
	UnregisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS_L_ARM))
	RegisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS_L_ARM), .proc/on_owner_paralysis_loss)


///Proc to react to the owner losing the TRAIT_PARALYSIS_L_ARM trait.
/obj/item/bodypart/l_arm/proc/on_owner_paralysis_loss(mob/living/carbon/source)
	SIGNAL_HANDLER
	REMOVE_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_L_ARM)
	UnregisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS_L_ARM))
	RegisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS_L_ARM), .proc/on_owner_paralysis_gain)

/obj/item/bodypart/l_arm/set_disabled(new_disabled)
	. = ..()
	if(isnull(.) || !owner)
		return

	if(!.)
		if(bodypart_disabled)
			owner.set_usable_hands(owner.usable_hands - 1)
			if(owner.stat < UNCONSCIOUS)
				to_chat(owner, "<span class='userdanger'>Your lose control of your [name]!</span>")
			if(held_index)
				owner.dropItemToGround(owner.get_item_for_held_index(held_index))
	else if(!bodypart_disabled)
		owner.set_usable_hands(owner.usable_hands + 1)

	if(owner.hud_used)
		var/atom/movable/screen/inventory/hand/hand_screen_object = owner.hud_used.hand_slots["[held_index]"]
		hand_screen_object?.update_icon()

/obj/item/bodypart/l_arm/monkey
	icon = 'icons/mob/animal_parts.dmi'
	icon_state = "default_monkey_l_arm"
	limb_id = SPECIES_MONKEY
	animal_origin = MONKEY_BODYPART
	px_x = -5
	px_y = -3

	dmg_overlay_type = "monkey"

/obj/item/bodypart/l_arm/monkey/teratoma
	icon_state = "teratoma_l_arm"
	animal_origin = TERATOMA_BODYPART

/obj/item/bodypart/l_arm/alien
	icon = 'icons/mob/animal_parts.dmi'
	icon_state = "alien_l_arm"
	px_x = 0
	px_y = 0
	dismemberable = FALSE
	can_be_disabled = FALSE
	max_damage = 100
	animal_origin = ALIEN_BODYPART

/obj/item/bodypart/l_arm/devil
	dismemberable = FALSE
	can_be_disabled = FALSE
	max_damage = 5000
	animal_origin = DEVIL_BODYPART

/obj/item/bodypart/r_arm
	name = "right arm"
	desc = "Over 87% of humans are right handed. That figure is much lower \
		among humans missing their right arm."
	icon_state = "default_human_r_arm"
	attack_verb = list("slapped", "punched")
	max_damage = 50
	body_zone = BODY_ZONE_R_ARM
	body_part = ARM_RIGHT
	aux_zone = BODY_ZONE_PRECISE_R_HAND
	aux_layer = HANDS_PART_LAYER
	body_damage_coeff = 0.75
	held_index = 2
	px_x = 6
	px_y = 0
	max_stamina_damage = 50
	can_be_disabled = TRUE
	dmg_overlay_type = "human"

/obj/item/bodypart/r_arm/set_owner(new_owner)
	. = ..()
	if(. == FALSE)
		return
	if(owner)
		if(HAS_TRAIT(owner, TRAIT_PARALYSIS_R_ARM))
			ADD_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_R_ARM)
			RegisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS_R_ARM), .proc/on_owner_paralysis_loss)
		else
			REMOVE_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_R_ARM)
			RegisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS_R_ARM), .proc/on_owner_paralysis_gain)
	if(.)
		var/mob/living/carbon/old_owner = .
		if(HAS_TRAIT(old_owner, TRAIT_PARALYSIS_R_ARM))
			UnregisterSignal(old_owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS_R_ARM))
			if(!owner || !HAS_TRAIT(owner, TRAIT_PARALYSIS_R_ARM))
				REMOVE_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_R_ARM)
		else
			UnregisterSignal(old_owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS_R_ARM))


///Proc to react to the owner gaining the TRAIT_PARALYSIS_R_ARM trait.
/obj/item/bodypart/r_arm/proc/on_owner_paralysis_gain(mob/living/carbon/source)
	SIGNAL_HANDLER
	ADD_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_R_ARM)
	UnregisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS_R_ARM))
	RegisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS_R_ARM), .proc/on_owner_paralysis_loss)


///Proc to react to the owner losing the TRAIT_PARALYSIS_R_ARM trait.
/obj/item/bodypart/r_arm/proc/on_owner_paralysis_loss(mob/living/carbon/source)
	SIGNAL_HANDLER
	REMOVE_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_R_ARM)
	UnregisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS_R_ARM))
	RegisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS_R_ARM), .proc/on_owner_paralysis_gain)

/obj/item/bodypart/r_arm/set_disabled(new_disabled)
	. = ..()
	if(isnull(.) || !owner)
		return

	if(!.)
		if(bodypart_disabled)
			owner.set_usable_hands(owner.usable_hands - 1)
			if(owner.stat < UNCONSCIOUS)
				to_chat(owner, "<span class='userdanger'>Your lose control of your [name]!</span>")
			if(held_index)
				owner.dropItemToGround(owner.get_item_for_held_index(held_index))
	else if(!bodypart_disabled)
		owner.set_usable_hands(owner.usable_hands + 1)

	if(owner.hud_used)
		var/atom/movable/screen/inventory/hand/hand_screen_object = owner.hud_used.hand_slots["[held_index]"]
		hand_screen_object?.update_icon()

/obj/item/bodypart/r_arm/monkey
	icon = 'icons/mob/animal_parts.dmi'
	icon_state = "default_monkey_r_arm"
	limb_id = SPECIES_MONKEY
	animal_origin = MONKEY_BODYPART
	px_x = 5
	px_y = -3

	dmg_overlay_type = "monkey"
/obj/item/bodypart/r_arm/monkey/teratoma
	icon_state = "teratoma_r_arm"
	limb_id = "teratoma"
	animal_origin = TERATOMA_BODYPART

/obj/item/bodypart/r_arm/alien
	icon = 'icons/mob/animal_parts.dmi'
	icon_state = "alien_r_arm"
	px_x = 0
	px_y = 0
	dismemberable = FALSE
	can_be_disabled = FALSE
	max_damage = 100
	animal_origin = ALIEN_BODYPART

/obj/item/bodypart/r_arm/devil
	dismemberable = FALSE
	can_be_disabled = FALSE
	max_damage = 5000
	animal_origin = DEVIL_BODYPART

/obj/item/bodypart/l_leg
	name = "left leg"
	desc = "Some athletes prefer to tie their left shoelaces first for good \
		luck. In this instance, it probably would not have helped."
	icon_state = "default_human_l_leg"
	attack_verb = list("kicked", "stomped")
	max_damage = 50
	body_zone = BODY_ZONE_L_LEG
	body_part = LEG_LEFT
	body_damage_coeff = 0.75
	px_x = -2
	px_y = 12
	max_stamina_damage = 50
	can_be_disabled = TRUE
	dmg_overlay_type = "human"

/obj/item/bodypart/l_leg/set_owner(new_owner)
	. = ..()
	if(. == FALSE)
		return
	if(new_owner)
		if(HAS_TRAIT(owner, TRAIT_PARALYSIS_L_LEG))
			ADD_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_L_LEG)
			RegisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS_L_LEG), .proc/on_owner_paralysis_loss)
		else
			REMOVE_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_L_LEG)
			RegisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS_L_LEG), .proc/on_owner_paralysis_gain)
	if(.)
		var/mob/living/carbon/old_owner = .
		if(HAS_TRAIT(old_owner, TRAIT_PARALYSIS_L_LEG))
			UnregisterSignal(old_owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS_L_LEG))
			if(!owner || !HAS_TRAIT(owner, TRAIT_PARALYSIS_L_LEG))
				REMOVE_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_L_LEG)
		else
			UnregisterSignal(old_owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS_L_LEG))


///Proc to react to the owner gaining the TRAIT_PARALYSIS_L_LEG trait.
/obj/item/bodypart/l_leg/proc/on_owner_paralysis_gain(mob/living/carbon/source)
	SIGNAL_HANDLER
	ADD_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_L_LEG)
	UnregisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS_L_LEG))
	RegisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS_L_LEG), .proc/on_owner_paralysis_loss)


///Proc to react to the owner losing the TRAIT_PARALYSIS_L_LEG trait.
/obj/item/bodypart/l_leg/proc/on_owner_paralysis_loss(mob/living/carbon/source)
	SIGNAL_HANDLER
	REMOVE_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_L_LEG)
	UnregisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS_L_LEG))
	RegisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS_L_LEG), .proc/on_owner_paralysis_gain)

/obj/item/bodypart/l_leg/set_disabled(new_disabled)
	. = ..()
	if(isnull(.) || !owner)
		return

	if(!.)
		if(bodypart_disabled)
			owner.set_usable_legs(owner.usable_legs - 1)
			if(owner.stat < UNCONSCIOUS)
				to_chat(owner, "<span class='userdanger'>Your lose control of your [name]!</span>")
	else if(!bodypart_disabled)
		owner.set_usable_legs(owner.usable_legs + 1)


/obj/item/bodypart/l_leg/monkey
	icon = 'icons/mob/animal_parts.dmi'
	icon_state = "default_monkey_l_leg"
	limb_id = SPECIES_MONKEY
	animal_origin = MONKEY_BODYPART
	px_y = 4

	dmg_overlay_type = "monkey"

/obj/item/bodypart/l_leg/monkey/teratoma
	icon_state = "teratoma_l_leg"
	limb_id = "teratoma"
	animal_origin = TERATOMA_BODYPART

/obj/item/bodypart/l_leg/alien
	icon = 'icons/mob/animal_parts.dmi'
	icon_state = "alien_l_leg"
	px_x = 0
	px_y = 0
	dismemberable = FALSE
	can_be_disabled = FALSE
	max_damage = 100
	animal_origin = ALIEN_BODYPART

/obj/item/bodypart/l_leg/devil
	dismemberable = FALSE
	can_be_disabled = FALSE
	max_damage = 5000
	animal_origin = DEVIL_BODYPART

/obj/item/bodypart/r_leg
	name = "right leg"
	desc = "You put your right leg in, your right leg out. In, out, in, out, \
		shake it all about. And apparently then it detaches.\n\
		The hokey pokey has certainly changed a lot since space colonisation."
	// alternative spellings of 'pokey' are available
	icon_state = "default_human_r_leg"
	attack_verb = list("kicked", "stomped")
	max_damage = 50
	body_zone = BODY_ZONE_R_LEG
	body_part = LEG_RIGHT
	body_damage_coeff = 0.75
	px_x = 2
	px_y = 12
	max_stamina_damage = 50
	can_be_disabled = TRUE
	dmg_overlay_type = "human"

	/// We store this here to generate our icon key more easily.
	var/left_leg_mask_key
	/// The associated list of all the left leg mask keys associated to their cached left leg masks.
	/// It's static, so it's shared between all the left legs there is. Be careful.
	/// Why? Both legs share the same layer for rendering, and since we don't want to do redraws on
	/// each dir changes, we're doing it with a mask instead, which we cache for efficiency reasons.
	var/static/list/left_leg_mask_cache = list()

/obj/item/bodypart/r_leg/set_owner(new_owner)
	. = ..()
	if(. == FALSE)
		return
	if(owner)
		if(HAS_TRAIT(owner, TRAIT_PARALYSIS_R_LEG))
			ADD_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_R_LEG)
			RegisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS_R_LEG), .proc/on_owner_paralysis_loss)
		else
			REMOVE_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_R_LEG)
			RegisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS_R_LEG), .proc/on_owner_paralysis_gain)
	if(.)
		var/mob/living/carbon/old_owner = .
		if(HAS_TRAIT(old_owner, TRAIT_PARALYSIS_R_LEG))
			UnregisterSignal(old_owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS_R_LEG))
			if(!owner || !HAS_TRAIT(owner, TRAIT_PARALYSIS_R_LEG))
				REMOVE_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_R_LEG)
		else
			UnregisterSignal(old_owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS_R_LEG))


///Proc to react to the owner gaining the TRAIT_PARALYSIS_R_LEG trait.
/obj/item/bodypart/r_leg/proc/on_owner_paralysis_gain(mob/living/carbon/source)
	SIGNAL_HANDLER
	ADD_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_R_LEG)
	UnregisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS_R_LEG))
	RegisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS_R_LEG), .proc/on_owner_paralysis_loss)


///Proc to react to the owner losing the TRAIT_PARALYSIS_R_LEG trait.
/obj/item/bodypart/r_leg/proc/on_owner_paralysis_loss(mob/living/carbon/source)
	SIGNAL_HANDLER
	REMOVE_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_R_LEG)
	UnregisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS_R_LEG))
	RegisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS_R_LEG), .proc/on_owner_paralysis_gain)

/obj/item/bodypart/r_leg/set_disabled(new_disabled)
	. = ..()
	if(isnull(.) || !owner)
		return

	if(!.)
		if(bodypart_disabled)
			owner.set_usable_legs(owner.usable_legs - 1)
			if(owner.stat < UNCONSCIOUS)
				to_chat(owner, "<span class='userdanger'>Your lose control of your [name]!</span>")
	else if(!bodypart_disabled)
		owner.set_usable_legs(owner.usable_legs + 1)


/obj/item/bodypart/r_leg/monkey
	icon = 'icons/mob/animal_parts.dmi'
	icon_state = "default_monkey_r_leg"
	limb_id = SPECIES_MONKEY
	animal_origin = MONKEY_BODYPART
	px_y = 4

	dmg_overlay_type = "monkey"

/obj/item/bodypart/r_leg/monkey/teratoma
	icon_state = "teratoma_r_leg"
	limb_id = "teratoma"
	animal_origin = TERATOMA_BODYPART

/obj/item/bodypart/r_leg/alien
	icon = 'icons/mob/animal_parts.dmi'
	icon_state = "alien_r_leg"
	px_x = 0
	px_y = 0
	dismemberable = FALSE
	can_be_disabled = FALSE
	max_damage = 100
	animal_origin = ALIEN_BODYPART

/obj/item/bodypart/r_leg/devil
	dismemberable = FALSE
	can_be_disabled = FALSE
	max_damage = 5000
	animal_origin = DEVIL_BODYPART
