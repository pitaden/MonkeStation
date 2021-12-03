//Used to get a random untouched locker, created for the Stowaway trait
/proc/get_untouched_unlocked_closed_locker() //I've seen worse proc names
	var/list/picked_lockers = list()
	var/turf/object_location
	for(var/obj/structure/closet/find_closet in world)				//Get crates
		if(!istype(find_closet,/obj/structure/closet/secure_closet))//But not the locked crates
			object_location = get_turf(find_closet) 				//Get the location it's at
			if(object_location) 									//If it can't read a Z on the next step, it will error out. Needs a separate check.
				if(is_station_level(object_location.z) && !find_closet.opened && !find_closet.GetComponent(/datum/component/forensics)) //Untouched, on the station and closed.
					picked_lockers += find_closet
	if(picked_lockers) //Catch edge cases where there somehow is no locker.
		return pick(picked_lockers)
	return FALSE
