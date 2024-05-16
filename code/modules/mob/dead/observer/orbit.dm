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
			var/auto_observe = params["auto_observe"]
			var/atom/poi = SSpoints_of_interest.get_poi_atom_by_ref(ref)

			if((ismob(poi) && !SSpoints_of_interest.is_valid_poi(poi, CALLBACK(src, PROC_REF(validate_mob_poi)))) \
				|| !SSpoints_of_interest.is_valid_poi(poi)
			)
				to_chat(usr, span_notice("That point of interest is no longer valid."))
				return TRUE

			var/mob/dead/observer/user = usr
			user.ManualFollow(poi)
			user.reset_perspective(null)
			user.orbiting_ref = ref
			if (auto_observe)
				owner.do_observe(poi)
			. = TRUE
		if ("refresh")
			ui.send_full_update()
			return TRUE

	return FALSE


/datum/orbit_menu/ui_data(mob/user)
	var/list/data = list()

	if(isobserver(user))
		data["orbiting"] = get_currently_orbiting(user)

	return data


/datum/orbit_menu/ui_static_data(mob/user)
	var/list/data = list()

	var/list/alive = list()
	var/list/antagonists = list()
	var/list/critical = list()
	var/list/deadchat_controlled = list()
	var/list/dead = list()
	var/list/ghosts = list()
	var/list/misc = list()
	var/list/npcs = list()

	var/list/pois = getpois(skip_mindless = TRUE, specify_dead_role = FALSE)
	for (var/name in pois)
		var/list/serialized = list()
		var/mob/mob_poi = new_mob_pois[name]
		var/number_of_orbiters = length(mob_poi.get_all_orbiters())

		serialized["ref"] = REF(mob_poi)
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

		if(isnull(mob_poi.mind))
			if(isliving(mob_poi))
				var/mob/living/npc = mob_poi
				serialized["health"] = FLOOR((npc.health / npc.maxHealth * 100), 1)

			npcs += list(serialized)
			continue

		serialized["client"] = !!mob_poi.client
		serialized["name"] = mob_poi.real_name

		if(isliving(mob_poi))
			serialized += get_living_data(mob_poi)

		var/list/antag_data = get_antag_data(mob_poi.mind)
		if(length(antag_data))
			serialized += antag_data
			antagonists += list(serialized)
			continue

		alive += list(serialized)

	for(var/name in new_other_pois)
		var/atom/atom_poi = new_other_pois[name]

		// Deadchat Controlled objects are orbitable
		if(atom_poi.GetComponent(/datum/component/deadchat_control))
			var/number_of_orbiters = length(atom_poi.get_all_orbiters())
			deadchat_controlled += list(list(
				"ref" = REF(atom_poi),
				"full_name" = name,
				"orbiters" = number_of_orbiters,
			))
			continue

		var/list/other_data = get_misc_data(atom_poi)
		var/misc_data = list(other_data[1])

		misc += misc_data

		if(other_data[2]) // Critical = TRUE
			critical += misc_data

	return list(
		"alive" = alive,
		"antagonists" = antagonists,
		"critical" = critical,
		"deadchat_controlled" = deadchat_controlled,
		"dead" = dead,
		"ghosts" = ghosts,
		"misc" = misc,
		"npcs" = npcs,
	)


/// Shows the UI to the specified user.
/datum/orbit_menu/proc/show(mob/user)
	ui_interact(user)


/// Helper function to get threat type, group, overrides for job and icon
/datum/orbit_menu/proc/get_antag_data(datum/mind/poi_mind) as /list
	var/list/serialized = list()

	for(var/datum/antagonist/antag as anything in poi_mind.antag_datums)
		if(!antag.show_to_ghosts)
			continue

		serialized["antag"] = antag.name
		serialized["antag_group"] = antag.antagpanel_category
		serialized["job"] = antag.name
		serialized["icon"] = antag.antag_hud_name

		return serialized


/// Helper to get the current thing we're orbiting (if any)
/datum/orbit_menu/proc/get_currently_orbiting(mob/dead/observer/user)
	if(isnull(user.orbiting_ref))
		return

	var/atom/poi = SSpoints_of_interest.get_poi_atom_by_ref(user.orbiting_ref)
	if(isnull(poi))
		user.orbiting_ref = null
		return

	if((ismob(poi) && !SSpoints_of_interest.is_valid_poi(poi, CALLBACK(src, PROC_REF(validate_mob_poi)))) \
		|| !SSpoints_of_interest.is_valid_poi(poi)
	)
		user.orbiting_ref = null
		return

	var/list/serialized = list()

	if(!ismob(poi))
		var/list/misc_info = get_misc_data(poi)
		serialized += misc_info[1]
		return serialized

	var/mob/mob_poi = poi
	serialized["full_name"] = mob_poi.name
	serialized["ref"] = REF(poi)

	if(mob_poi.mind)
		serialized["client"] = !!mob_poi.client
		serialized["name"] = mob_poi.real_name

	if(isliving(mob_poi))
		serialized += get_living_data(mob_poi)

	return serialized


/// Helper function to get job / icon / health data for a living mob
/datum/orbit_menu/proc/get_living_data(mob/living/player) as /list
	var/list/serialized = list()

	serialized["health"] = FLOOR((player.health / player.maxHealth * 100), 1)
	if(issilicon(player))
		serialized["job"] = player.job
		serialized["icon"] = "borg"
	else
		var/obj/item/card/id/id_card = player.get_idcard(hand_first = FALSE)
		serialized["job"] = id_card?.get_trim_assignment()
		serialized["icon"] = id_card?.get_trim_sechud_icon_state()

	return serialized


/// Gets a list: Misc data and whether it's critical. Handles all snowflakey type cases
/datum/orbit_menu/proc/get_misc_data(atom/movable/atom_poi) as /list
	var/list/misc = list()
	var/critical = FALSE

	misc["ref"] = REF(atom_poi)
	misc["full_name"] = atom_poi.name

	// Display the supermatter crystal integrity
	if(istype(atom_poi, /obj/machinery/power/supermatter_crystal))
		var/obj/machinery/power/supermatter_crystal/crystal = atom_poi
		var/integrity = round(crystal.get_integrity_percent())
		misc["extra"] = "Integrity: [integrity]%"

		if(integrity < 10)
			critical = TRUE

		return list(misc, critical)

	// Display the nuke timer
	if(istype(atom_poi, /obj/machinery/nuclearbomb))
		var/obj/machinery/nuclearbomb/bomb = atom_poi

		if(bomb.timing)
			misc["extra"] = "Timer: [bomb.countdown?.displayed_text]s"
			critical = TRUE

		return list(misc, critical)

	// Display the holder if its a nuke disk
	if(istype(atom_poi, /obj/item/disk/nuclear))
		var/obj/item/disk/nuclear/disk = atom_poi
		var/mob/holder = disk.pulledby || get(disk, /mob)
		misc["extra"] = "Location: [holder?.real_name || "Unsecured"]"

		return list(misc, critical)

	// Display singuloths if they exist
	if(istype(atom_poi, /obj/singularity))
		var/obj/singularity/singulo = atom_poi
		misc["extra"] = "Energy: [round(singulo.energy)]"

		if(singulo.current_size > 2)
			critical = TRUE

		return list(misc, critical)

	return list(misc, critical)


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

