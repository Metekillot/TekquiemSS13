/obj/machinery/computer/apc_control
	name = "power flow control console"
	desc = "Used to remotely control the flow of power to different parts of the station."
	icon_screen = "solar"
	icon_keyboard = "power_key"
	req_access = list(ACCESS_CE)
	circuit = /obj/item/circuitboard/computer/apc_control
	light_color = LIGHT_COLOR_YELLOW
	var/mob/living/operator //Who's operating the computer right now
	var/obj/machinery/power/apc/active_apc //The APC we're using right now
	var/should_log = TRUE
	var/restoring = FALSE
	var/list/logs
	var/auth_id = "\[NULL\]:"

/obj/machinery/computer/apc_control/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()
	logs = list()

/obj/machinery/computer/apc_control/process()
	if(operator && (!operator.Adjacent(src) || machine_stat))
		operator = null
		if(active_apc)
			if(!active_apc.locked)
				active_apc.say("Remote access canceled. Interface locked.")
				playsound(active_apc, 'sound/machines/boltsdown.ogg', 25, FALSE)
				playsound(active_apc, 'sound/machines/terminal_alert.ogg', 50, FALSE)
			active_apc.locked = TRUE
			active_apc.update_icon()
			active_apc.remote_control = null
			active_apc = null

/obj/machinery/computer/apc_control/attack_ai(mob/user)
	if(!isAdminGhostAI(user))
		to_chat(user,"<span class='warning'>[src] does not support AI control.</span>") //You already have APC access, cheater!
		return
	..()

/obj/machinery/computer/apc_control/proc/check_apc(obj/machinery/power/apc/APC)
	return APC.z == z && !APC.malfhack && !APC.aidisabled && !(APC.obj_flags & EMAGGED) && !APC.machine_stat && !istype(APC.area, /area/ai_monitored) && !(APC.area.area_flags & NO_ALERTS)

/obj/machinery/computer/apc_control/ui_interact(mob/user, datum/tgui/ui)
	operator = user
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ApcControl")
		ui.open()

/obj/machinery/computer/apc_control/ui_data(mob/user)
	var/list/data = list()
	data["auth_id"] = auth_id
	data["authenticated"] = authenticated
	data["emagged"] = obj_flags & EMAGGED
	data["logging"] = should_log
	data["restoring"] = restoring
	data["logs"] = list()
	data["apcs"] = list()

	for(var/entry in logs)
		data["logs"] += list(list("entry" = entry))

	for(var/apc in GLOB.apcs_list)
		if(check_apc(apc))
			var/obj/machinery/power/apc/A = apc
			var/has_cell = (A.cell) ? TRUE : FALSE
			data["apcs"] += list(list(
					"name" = A.area.name,
					"operating" = A.operating,
					"charge" = (has_cell) ? A.cell.percent() : "NOCELL",
					"load" = DisplayPower(A.lastused_total),
					"charging" = A.charging,
					"chargeMode" = A.chargemode,
					"eqp" = A.equipment,
					"lgt" = A.lighting,
					"env" = A.environ,
					"responds" = A.aidisabled || A.panel_open,
					"ref" = REF(A)
				)
			)
	return data

/obj/machinery/computer/apc_control/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	var/mob/living/user = ui.user
	switch(action)
		if("log-in")
			if(obj_flags & EMAGGED)
				authenticated = TRUE
				auth_id = "Unknown (Unknown):"
				log_activity("[auth_id] logged in to the terminal")
				return
			if(!istype(user))
				return
			var/obj/item/card/id/user_id_card = user.get_idcard(TRUE)
			if(istype(user_id_card))
				if(check_access(user_id_card))
					authenticated = TRUE
					auth_id = "[user_id_card.registered_name] ([user_id_card.assignment]):"
					log_activity("[auth_id] logged in to the terminal")
					playsound(src, 'sound/machines/terminal/terminal_on.ogg', 50, FALSE)
				else
					auth_id = "[user_id_card.registered_name] ([user_id_card.assignment]):"
					log_activity("[auth_id] attempted to log into the terminal")
					playsound(src, 'sound/machines/terminal/terminal_error.ogg', 50, FALSE)
					say("ID rejected, access denied!")
				return
			auth_id = "Unknown (Unknown):"
			log_activity("[auth_id] attempted to log into the terminal")
		if("log-out")
			log_activity("[auth_id] logged out of the terminal")
			playsound(src, 'sound/machines/terminal/terminal_off.ogg', 50, FALSE)
			authenticated = FALSE
			auth_id = "\[NULL\]"
		if("toggle-logs")
			should_log = !should_log
			user.log_message("set the logs of [src] [should_log ? "On" : "Off"].", LOG_GAME)
		if("restore-console")
			restoring = TRUE
			addtimer(CALLBACK(src, PROC_REF(restore_comp), user), rand(3,5) * 9 SECONDS)
		if("access-apc")
			var/ref = params["ref"]
			playsound(src, SFX_TERMINAL_TYPE, 50, FALSE)
			var/obj/machinery/power/apc/remote_target = locate(ref) in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/power/apc)
			if(!remote_target || !check_apc(remote_target))
				return
			connect_apc(remote_target, user)
			return TRUE
		if("check-logs")
			log_activity("Checked Logs")
		if("check-apcs")
			log_activity("Checked APCs")
		if("toggle-minor")
			var/ref = params["ref"]
			var/type = params["type"]
			var/value = params["value"]
			var/obj/machinery/power/apc/target = locate(ref) in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/power/apc)
			if(!target || !check_apc(target))
				return

			value = target.setsubsystem(text2num(value))
			switch(type) // Sanity check
				if("equipment")
					target.equipment = value
				if("lighting")
					target.lighting = value
				if("environ")
					target.environ = value
				if(null)
					return
				else
					message_admins("Warning: possible href exploit by [key_name(user)] - attempted to set [html_encode(type)] on [target] to [html_encode(value)]")
					user.log_message("possibly trying to href exploit - attempted to set [html_encode(type)] on [target] to [html_encode(value)]", LOG_ADMIN)
					return

			target.update_appearance()
			target.update()
			var/setTo = ""
			switch(target.vars[type])
				if(0)
					setTo = "Off"
				if(1)
					setTo = "Auto Off"
				if(2)
					setTo = "On"
				if(3)
					setTo = "Auto On"
			log_activity("Set APC [target.area.name] [type] to [setTo]")
			user.log_message("set APC [target.area.name] [type] to [setTo]]", LOG_GAME)
		if("breaker")
			var/ref = params["ref"]
			var/obj/machinery/power/apc/breaker_target = locate(ref) in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/power/apc)
			if(!breaker_target || !check_apc(breaker_target))
				return
			breaker_target.toggle_breaker(user)
			var/setTo = breaker_target.operating ? "On" : "Off"
			log_activity("Turned APC [breaker_target.area.name]'s breaker [setTo]")
			return TRUE

/obj/machinery/computer/apc_control/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	obj_flags |= EMAGGED
	log_game("[key_name(user)] emagged [src] at [AREACOORD(src)]")
	playsound(src, "sparks", 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)

/obj/machinery/computer/apc_control/proc/log_activity(log_text)
	if(!should_log)
		return
	LAZYADD(logs, "([station_time_timestamp()]): [auth_id] [log_text]")

/obj/machinery/computer/apc_control/proc/restore_comp()
	obj_flags &= ~EMAGGED
	should_log = TRUE
	log_game("[key_name(operator)] restored the logs of [src] in [AREACOORD(src)]")
	log_activity("-=- Logging restored to full functionality at this point -=-")
	restoring = FALSE

/mob/proc/using_power_flow_console()
	for(var/obj/machinery/computer/apc_control/A in range(1, src))
		if(A.operator && A.operator == src && !A.machine_stat)
			return TRUE
	return

