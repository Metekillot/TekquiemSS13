///a reaction chamber for plumbing. pretty much everything can react, but this one keeps the reagents seperated and only reacts under your given terms
/obj/machinery/plumbing/reaction_chamber
	name = "reaction chamber"
	desc = "Keeps chemicals seperated until given conditions are met."
	icon_state = "reaction_chamber"
	buffer = 200
	reagent_flags = TRANSPARENT | NO_REACT

	/**list of set reagents that the reaction_chamber allows in, and must all be present before mixing is enabled.
	* example: list(/datum/reagent/water = 20, /datum/reagent/fuel/oil = 50)
	*/
	var/list/required_reagents = list()
	///our reagent goal has been reached, so now we lock our inputs and start emptying
	var/emptying = FALSE

/obj/machinery/plumbing/reaction_chamber/Initialize(mapload, bolt)
	. = ..()
	AddComponent(/datum/component/plumbing/reaction_chamber, bolt)

/obj/machinery/plumbing/reaction_chamber/create_reagents(max_vol, flags)
	. = ..()
	RegisterSignal(reagents, list(COMSIG_REAGENTS_REM_REAGENT, COMSIG_REAGENTS_DEL_REAGENT, COMSIG_REAGENTS_CLEAR_REAGENTS, COMSIG_REAGENTS_REACTED), PROC_REF(on_reagent_change))
	RegisterSignal(reagents, COMSIG_PARENT_QDELETING, PROC_REF(on_reagents_del))

/// Handles properly detaching signal hooks.
/obj/machinery/plumbing/reaction_chamber/proc/on_reagents_del(datum/reagents/reagents)
	SIGNAL_HANDLER
	UnregisterSignal(reagents, list(COMSIG_REAGENTS_REM_REAGENT, COMSIG_REAGENTS_DEL_REAGENT, COMSIG_REAGENTS_CLEAR_REAGENTS, COMSIG_REAGENTS_REACTED, COMSIG_PARENT_QDELETING))
	return NONE


/// Handles stopping the emptying process when the chamber empties.
/obj/machinery/plumbing/reaction_chamber/proc/on_reagent_change(datum/reagents/holder, ...)
	SIGNAL_HANDLER
	if(holder.total_volume == 0 && emptying) //we were emptying, but now we aren't
		emptying = FALSE
		holder.flags |= NO_REACT
	return NONE

/obj/machinery/plumbing/reaction_chamber/power_change()
	. = ..()
	if(use_power != NO_POWER_USE)
		icon_state = initial(icon_state) + "_on"
	else
		icon_state = initial(icon_state)

/obj/machinery/plumbing/reaction_chamber/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ChemReactionChamber", name)
		ui.open()

/obj/machinery/plumbing/reaction_chamber/ui_data(mob/user)
	var/list/data = list()
	var/list/text_reagents = list()
	for(var/A in required_reagents) //make a list where the key is text, because that looks alot better in the ui than a typepath
		var/datum/reagent/R = A
		text_reagents[initial(R.name)] = required_reagents[R]

	data["reagents"] = text_reagents
	data["emptying"] = emptying
	return data

/obj/machinery/plumbing/reaction_chamber/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return TRUE

	switch(action)
		if("add")
			var/selected_reagent = tgui_input_list(ui.user, "Select reagent", "Reagent", GLOB.name2reagent)
			if(!selected_reagent)
				return FALSE
			if(QDELETED(ui) || ui.status != UI_INTERACTIVE)
				return FALSE

			var/datum/reagent/input_reagent = GLOB.name2reagent[selected_reagent]
			if(!input_reagent)
				return FALSE

			if(catalysts[input_reagent])
				return FALSE

			var/input_amount = text2num(params["amount"])
			if(!input_amount)
				return FALSE
			input_amount = round(input_amount, CHEMICAL_VOLUME_ROUNDING)

			if(!required_reagents[input_reagent])
				required_reagents[input_reagent] = input_amount
				return TRUE

		if("remove")
			var/reagent = get_chem_id(params["chem"])
			if(reagent)
				required_reagents.Remove(reagent)
				return TRUE

		if("temperature")
			var/target = text2num(params["target"])
			if(!isnull(target))
				target_temperature = clamp(target, 0, 1000)
				return TRUE

		if("catalyst")
			var/reagent = get_chem_id(params["chem"])
			if(!reagent)
				return FALSE

			if(!catalysts[reagent])
				catalysts[reagent] = required_reagents[reagent]
				required_reagents -= reagent
				return TRUE

		if("catremove")
			var/reagent = get_chem_id(params["chem"])
			if(!reagent)
				return FALSE

			if(catalysts[reagent])
				required_reagents[reagent] = catalysts[reagent]
				catalysts -= reagent
				return TRUE

	var/result = handle_ui_act(action, params, ui, state)
	if(isnull(result))
		result = FALSE
	return result

