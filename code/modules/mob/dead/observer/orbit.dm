/datum/orbit_menu
	var/mob/dead/observer/owner
	var/auto_observe = FALSE

/datum/orbit_menu/New(mob/dead/observer/new_owner)
	if(!istype(new_owner))
		qdel(src)
	owner = new_owner

/datum/orbit_menu/ui_state(mob/user)
	return GLOB.observer_state

/datum/orbit_menu/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "Orbit")
		ui.open()

/datum/orbit_menu/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if ("orbit")
			var/ref = params["ref"]
			var/atom/movable/poi = (locate(ref) in GLOB.mob_list) || (locate(ref) in GLOB.poi_list)
			if (poi == null)
				. = TRUE
				return
			owner.ManualFollow(poi)
			owner.reset_perspective(null)
			if (auto_observe)
				owner.do_observe(poi)
			. = TRUE
		if ("refresh")
			update_static_data(owner, ui)
			. = TRUE
		if ("toggle_observe")
			auto_observe = !auto_observe
			if (auto_observe && owner.orbit_target)
				owner.do_observe(owner.orbit_target)
			else
				owner.reset_perspective(null)

/datum/orbit_menu/ui_static_data(mob/user)
	var/list/data = list()

	var/list/alive = list()
	var/list/antagonists = list()
	var/list/dead = list()
	var/list/ghosts = list()
	var/list/misc = list()
	var/list/npcs = list()

	var/list/pois = getpois(skip_mindless = TRUE, specify_dead_role = FALSE)
	for (var/name in pois)
		var/list/serialized = list()

		var/mob/mob_poi = new_mob_pois[name]

		var/poi_ref = REF(mob_poi)
		serialized["ref"] = poi_ref
		serialized["full_name"] = name

		var/poi = pois[name]

		serialized["ref"] = REF(poi)

		var/mob/M = poi
		if (istype(M))
			if (isobserver(M))
				var/number_of_orbiters = length(M.get_all_orbiters())
				if (number_of_orbiters)
					serialized["orbiters"] = number_of_orbiters
				ghosts += list(serialized)
			else if (M.stat == DEAD)
				dead += list(serialized)
			else if (M.mind == null)
				npcs += list(serialized)
			else
				var/number_of_orbiters = length(M.get_all_orbiters())
				if (number_of_orbiters)
					serialized["orbiters"] = number_of_orbiters

				var/datum/mind/mind = M.mind
				var/was_antagonist = FALSE

				for (var/_A in mind.antag_datums)
					var/datum/antagonist/A = _A
					if (A.show_to_ghosts)
						was_antagonist = TRUE
						serialized["antag"] = A.name
						antagonists += list(serialized)
						break

		serialized["name"] = mob_poi.real_name

		if(isliving(mob_poi)) // handles edge cases like blob
			var/mob/living/player = mob_poi
			serialized["health"] = FLOOR((player.health / player.maxHealth * 100), 1)
			if(issilicon(player))
				serialized["job"] = player.job
			else
				var/obj/item/card/id/id_card = player.get_idcard(hand_first = FALSE)
				serialized["job"] = id_card?.get_trim_assignment()

		for(var/datum/antagonist/antag_datum as anything in mind.antag_datums)
			if (antag_datum.show_to_ghosts)
				was_antagonist = TRUE
				serialized["antag"] = antag_datum.name
				serialized["antag_group"] = antag_datum.antagpanel_category
				antagonists += list(serialized)
				break

	data["alive"] = alive
	data["antagonists"] = antagonists
	data["dead"] = dead
	data["ghosts"] = ghosts
	data["misc"] = misc
	data["npcs"] = npcs
	return data

	for(var/name in new_other_pois)
		var/atom/atom_poi = new_other_pois[name]

		misc += list(list(
			"ref" = REF(atom_poi),
			"full_name" = name,
		))

		// Display the supermatter crystal integrity
		if(istype(atom_poi, /obj/machinery/power/supermatter_crystal))
			var/obj/machinery/power/supermatter_crystal/crystal = atom_poi
			misc[length(misc)]["extra"] = "Integrity: [crystal.get_integrity_percent()]%"
			continue
		// Display the nuke timer
		if(istype(atom_poi, /obj/machinery/nuclearbomb))
			var/obj/machinery/nuclearbomb/bomb = atom_poi
			if(bomb.timing)
				misc[length(misc)]["extra"] = "Timer: [bomb.countdown?.displayed_text]s"
			continue
		// Display the holder if its a nuke disk
		if(istype(atom_poi, /obj/item/disk/nuclear))
			var/obj/item/disk/nuclear/disk = atom_poi
			var/mob/holder = disk.pulledby || get(disk, /mob)
			misc[length(misc)]["extra"] = "Location: [holder?.real_name || "Unsecured"]"
			continue

	return list(
		"alive" = alive,
		"antagonists" = antagonists,
		"dead" = dead,
		"ghosts" = ghosts,
		"misc" = misc,
		"npcs" = npcs,
	)

/// Shows the UI to the specified user.
/datum/orbit_menu/proc/show(mob/user)
	ui_interact(user)

/**
 * Helper POI validation function passed as a callback to various SSpoints_of_interest procs.
 *
 * Provides extended validation above and beyond standard, limiting mob POIs without minds or ckeys
 * unless they're mobs, camera mobs or megafauna.
 *
 * If they satisfy that requirement, falls back to default validation for the POI.
 */
/datum/orbit_menu/proc/validate_mob_poi(datum/point_of_interest/mob_poi/potential_poi)
	var/mob/potential_mob_poi = potential_poi.target
	// Skip mindless and ckeyless mobs except bots, cameramobs and megafauna.
	if(!potential_mob_poi.mind && !potential_mob_poi.ckey)
		if(!isbot(potential_mob_poi) && !iscameramob(potential_mob_poi) && !ismegafauna(potential_mob_poi))
			return FALSE

	return potential_poi.validate()
