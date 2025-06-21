GLOBAL_LIST(labor_sheet_values)

/**********************Prisoners' Console**************************/

/obj/machinery/mineral/labor_claim_console
	name = "point claim console"
	desc = "A stacking console with an electromagnetic writer, used to track ore mined by prisoners."
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "console"
	density = FALSE
	/// Connected stacking machine
	var/obj/machinery/mineral/stacking_machine/laborstacker/stacking_machine = null
	/// Direction of the stacking machine
	var/machinedir = SOUTH
	/// Needed to send messages to sec radio
	var/obj/item/radio/Radio

/obj/machinery/mineral/labor_claim_console/Initialize()
	. = ..()
	Radio = new/obj/item/radio(src)
	Radio.listening = FALSE
	locate_stacking_machine()

	if(!GLOB.labor_sheet_values)
		var/sheet_list = list()
		for(var/sheet_type in subtypesof(/obj/item/stack/sheet))
			var/obj/item/stack/sheet/sheet = sheet_type
			if(!initial(sheet.point_value) || (initial(sheet.merge_type) && initial(sheet.merge_type) != sheet_type)) //ignore no-value sheets and x/fifty subtypes
				continue
			sheet_list += list(list("ore" = initial(sheet.name), "value" = initial(sheet.point_value)))
		GLOB.labor_sheet_values = sortList(sheet_list, GLOBAL_PROC_REF(cmp_sheet_list))

/proc/cmp_sheet_list(list/a, list/b)
	return a["value"] - b["value"]

/obj/machinery/mineral/labor_claim_console/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "LaborClaimConsole", name)
		ui.open()

/obj/machinery/mineral/labor_claim_console/ui_static_data(mob/user)
	var/list/data = list()
	data["ores"] = GLOB.labor_sheet_values
	return data

/obj/machinery/mineral/labor_claim_console/ui_data(mob/user)
	var/list/data = list()
	var/can_go_home = FALSE

	data["emagged"] = FALSE
	if(obj_flags & EMAGGED)
		data["emagged"] = TRUE
		can_go_home = TRUE
	var/obj/item/card/id/I
	if(isliving(usr))
		var/mob/living/L = usr
		I = L.get_idcard(TRUE)
	if(istype(I, /obj/item/card/id/prisoner))
		var/obj/item/card/id/prisoner/P = I
		data["id_points"] = P.points
		if(P.points >= P.goal)
			can_go_home = TRUE
			data["status_info"] = "Goal met!"
		else
			data["status_info"] = "You are [(P.goal - P.points)] points away."
	else
		data["status_info"] = "No Prisoner ID detected."
		data["id_points"] = 0

	if(stacking_machine)
		data["unclaimed_points"] = stacking_machine.points

	data["can_go_home"] = can_go_home
	return data

/obj/machinery/mineral/labor_claim_console/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/mob/user_mob = usr

	switch(action)

		if("claim_points")
			var/obj/item/card/id/worn_id
			if(isliving(user_mob))
				var/mob/living/living_mob = user_mob
				worn_id = living_mob.get_idcard(TRUE)
			if(istype(worn_id, /obj/item/card/id/advanced/prisoner))
				var/obj/item/card/id/advanced/prisoner/worn_prisoner_id = worn_id
				worn_prisoner_id.points += stacking_machine.points
				stacking_machine.points = 0
				say("Points transferred.")
				return TRUE
			else
				if(COOLDOWN_FINISHED(src, say_cooldown))
					say("No valid id for point transfer detected.")
					COOLDOWN_START(src, say_cooldown, 2 SECONDS)

		if("move_shuttle")
			var/list/labor_shuttle_mobs = find_labor_shuttle_mobs()
			if(length(labor_shuttle_mobs) > 1 || labor_shuttle_mobs[1] != user_mob)
				if(COOLDOWN_FINISHED(src, say_cooldown))
					say("Prisoners may only be released one at a time.")
					COOLDOWN_START(src, say_cooldown, 2 SECONDS)
				return

			switch(SSshuttle.moveShuttle("laborcamp", "laborcamp_home", TRUE))
				if(1)
					if(COOLDOWN_FINISHED(src, say_cooldown))
						say("Shuttle not found.")
						COOLDOWN_START(src, say_cooldown, 2 SECONDS)
				if(2)
					if(COOLDOWN_FINISHED(src, say_cooldown))
						say("Shuttle already at station.")
						COOLDOWN_START(src, say_cooldown, 2 SECONDS)
				if(3)
					if(COOLDOWN_FINISHED(src, say_cooldown))
						say("No permission to dock could be granted.")
						COOLDOWN_START(src, say_cooldown, 2 SECONDS)
				else
					if(!(obj_flags & EMAGGED))
						var/datum/record/crew/target = find_record(user_mob.real_name)
						target?.wanted_status = WANTED_PAROLE

						aas_config_announce(/datum/aas_config_entry/security_labor_stacker, list("PERSON" = user_mob.real_name), src, list(RADIO_CHANNEL_SECURITY))
					user_mob.log_message("has completed their labor points goal and is now sending the gulag shuttle back to the station.", LOG_GAME)
					say("Labor sentence finished, shuttle returning.")
					initiated_launch = TRUE
					return TRUE

/obj/machinery/mineral/labor_claim_console/proc/locate_stacking_machine()
	stacking_machine = locate(/obj/machinery/mineral/stacking_machine, get_step(src, machinedir))
	if(stacking_machine)
		stacking_machine.CONSOLE = src
	else
		qdel(src)

/obj/machinery/mineral/labor_claim_console/emag_act(mob/user)
	if(!(obj_flags & EMAGGED))
		obj_flags |= EMAGGED
		to_chat(user, "<span class='warning'>PZZTTPFFFT</span>")

/**********************Prisoner Collection Unit**************************/

/obj/machinery/mineral/stacking_machine/laborstacker
	force_connect = TRUE
	var/points = 0 //The unclaimed value of ore stacked.
	damage_deflection = 21
/obj/machinery/mineral/stacking_machine/laborstacker/process_sheet(obj/item/stack/sheet/inp)
	points += inp.point_value * inp.amount
	..()

/obj/machinery/mineral/stacking_machine/laborstacker/attackby(obj/item/I, mob/living/user)
	if(istype(I, /obj/item/stack/sheet) && user.canUnEquip(I) && user.a_intent == INTENT_HELP)
		var/obj/item/stack/sheet/inp = I
		points += inp.point_value * inp.amount
	return ..()

/**********************Point Lookup Console**************************/

/obj/machinery/mineral/labor_points_checker
	name = "points checking console"
	desc = "A console used by prisoners to check the progress on their quotas. Simply swipe a prisoner ID."
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "console"
	density = FALSE

/obj/machinery/mineral/labor_points_checker/attack_hand(mob/user)
	. = ..()
	if(. || user.is_blind())
		return
	user.examinate(src)

/obj/machinery/mineral/labor_points_checker/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/card/id))
		if(istype(I, /obj/item/card/id/prisoner))
			var/obj/item/card/id/prisoner/prisoner_id = I
			to_chat(user, "<span class='notice'><B>ID: [prisoner_id.registered_name]</B></span>")
			to_chat(user, "<span class='notice'>Points Collected:[prisoner_id.points]</span>")
			to_chat(user, "<span class='notice'>Point Quota: [prisoner_id.goal]</span>")
			to_chat(user, "<span class='notice'>Collect points by bringing smelted minerals to the Labor Shuttle stacking machine. Reach your quota to earn your release.</span>")
		else
			to_chat(user, "<span class='warning'>Error: Invalid ID</span>")
	else
		return ..()

