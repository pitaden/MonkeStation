/obj/item/clothing/shoes/magboots/boomboots
	desc = "The ultimate in clown shoe technology."
	name = "boom boots"
	icon_state = "boomboot0"
	item_state = "boomboot0"
	magboot_state = "boomboot"
	slowdown = SHOES_SLOWDOWN
	item_color = "boomboots"
	actions_types = list(/datum/action/item_action/toggle)
	pocket_storage_component_path = /datum/component/storage/concrete/pockets/shoes/clown
	var/datum/component/waddle
	var/enabled_waddle = TRUE

/obj/item/clothing/shoes/magboots/boomboots/Initialize()
	. = ..()
	AddComponent(/datum/component/squeak, list('monkestation/sound/misc/boomboot1.ogg'=1,'monkestation/sound/misc/boomboot2.ogg'=1), 50)

/obj/item/clothing/shoes/magboots/boomboots/equipped(mob/user, slot)
	. = ..()
	if(slot == ITEM_SLOT_FEET)
		if(enabled_waddle)
			waddle = user.AddComponent(/datum/component/waddling)
		if(user.mind && user.mind.assigned_role == "Clown")
			SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "clownshoes", /datum/mood_event/clownshoes)

/obj/item/clothing/shoes/magboots/boomboots/MouseDrop(atom/over_object)
	if(usr)
		var/mob/living/carbon/C = usr
		if(src == C.shoes && magpulse)
			to_chat(C, "<span class='userdanger'>It would be unwise to remove these while activated!</span>")
			return
	..()

/obj/item/clothing/shoes/magboots/boomboots/attack_hand(mob/user)
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		if(src == C.shoes && magpulse)
			to_chat(user, "<span class='userdanger'>It would be unwise to remove these while activated!</span>")
			return
	..()

/obj/item/clothing/shoes/magboots/boomboots/dropped(mob/user)
	. = ..()
	QDEL_NULL(waddle)
	if(user.mind && user.mind.assigned_role == "Clown")
		SEND_SIGNAL(user, COMSIG_CLEAR_MOOD_EVENT, "clownshoes")
	if(magpulse)
		explosion(src,2,4,8,6)

/obj/item/clothing/shoes/magboots/boomboots/attack_self(mob/user)
	magpulse = !magpulse
	if(magpulse)
		clothing_flags &= ~NOSLIP
		slowdown = SHOES_SLOWDOWN
		strip_delay = 100
	else
		clothing_flags |= NOSLIP
		slowdown = slowdown_active
	icon_state = "[magboot_state][magpulse]"
	to_chat(user, "<span class='notice'>You [magpulse ? "enable" : "disable"] the mag-pulse traction system.</span>")
	user.update_inv_shoes()	//so our mob-overlays update
	user.update_gravity(user.has_gravity())
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

