/area/vtm/vtr
	var/sector
	var/ambiance_message

	//what z-level the area is located on
	var/floor

	var/datum/area_group/area_group

	//An id matching area's group, for pathing
	var/id

	//marked true if an area cannot be reached via stairs
	var/inaccessible = FALSE