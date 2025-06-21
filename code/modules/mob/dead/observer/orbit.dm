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

/datum/orbit_menu/ui_state(mob/user)
	return GLOB.observer_state

/datum/orbit_menu/ui_data(mob/user)
	var/list/data = list()
	data["auto_observe"] = auto_observe
	return data

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
		serialized["name"] = name

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

				if (!was_antagonist)
					alive += list(serialized)
		else
			misc += list(serialized)

	data["alive"] = alive
	data["antagonists"] = antagonists
	data["dead"] = dead
	data["ghosts"] = ghosts
	data["misc"] = misc
	data["npcs"] = npcs
	return data

/datum/orbit_menu/ui_assets()
	. = ..() || list()
	. += get_asset_datum(/datum/asset/simple/orbit)

