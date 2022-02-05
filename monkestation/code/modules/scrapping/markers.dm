// for various map markers

/obj/effect/scrapping
	name = "Uh oh"
	desc = "Yell at pitaden!"
	icon = 'monkestation/icons/obj/scrapping/mapping.dmi'
	icon_state = ""


/obj/effect/scrapping/objective_spawner
	name = "Generic Objective"


/obj/effect/scrapping/objective_spawner/Initialize()
	qdel(src)


/obj/effect/scrapping/objective_spawner/kill
	// where to create a mob for you to beat up
	name = "Kill Objective"
	icon_state = "objective_kill"
	// list( mob = weight )
	var/possible_mobs = list(
		/mob/living/simple_animal/hostile/hivebot = 15,
		/mob/living/simple_animal/hostile/hivebot/strong = 1
	)


/obj/effect/scrapping/objective_spawner/heal
	// where to create a wounded/dead human that you have to heal
	name = "Heal Objective"
	icon_state = "objective_heal"
	var/special_name // if not null, the spawned human will always use this name
	var/unique_appearance // if not null, the spawned human will always use this character appearance
	var/outfit = /datum/outfit/job/assistant // outfit datum to use
	var/min_damage = 100
	var/max_damage = 300
	var/dead = 1

/obj/effect/scrapping/objective_spawner/item
	// where to create an object that you need an item from
	// maps should have at least 2 of these
	name = "Item Objective"
	icon_state = "objective_item"
	var/object
	var/object_item

/obj/effect/scrapping/objective_spawner/survivor
	// ghost role
	name = "Possible Survivor Spawn"
	icon_state = "survivor"
	var/special_name // if not null, the spawned human will always use this name
	var/unique_appearance // if not null, the spawned human will always use this character appearance
	var/outfit = /datum/outfit/job/assistant // outfit datum to use