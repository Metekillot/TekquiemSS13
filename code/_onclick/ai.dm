/*
	AI ClickOn()

	The AI can double click to move the camera (this was already true but is cleaner),
	or double click a mob to track them.

	Note that AI have no need for the adjacency proc, and so this proc is a lot cleaner.
*/
/mob/living/silicon/ai/DblClickOn(atom/A, params)
	if(control_disabled || incapacitated())
		return

	if(ismob(A))
		ai_actual_track(A)
	else
		A.move_camera_by_click()

/mob/living/silicon/ai/ClickOn(atom/A, params)
	if(world.time <= next_click)
		return
	next_click = world.time + 1

	if(!can_interact_with(A))
		return

	if(multicam_on)
		var/turf/T = get_turf(A)
		if(T)
			for(var/atom/movable/screen/movable/pic_in_pic/ai/P in T.vis_locs)
				if(P.ai == src)
					P.Click(params)
					break

	if(check_click_intercept(params,A))
		return

	if(control_disabled || incapacitated())
		return

	var/turf/pixel_turf = get_turf_pixel(A)
	if(isnull(pixel_turf))
		return
	if(!can_see(A))
		if(isturf(A)) //On unmodified clients clicking the static overlay clicks the turf underneath
			return //So there's no point messaging admins
		message_admins("[ADMIN_LOOKUPFLW(src)] might be running a modified client! (failed can_see on AI click of [A] (Turf Loc: [ADMIN_VERBOSEJMP(pixel_turf)]))")
		var/message = "[key_name(src)] might be running a modified client! (failed can_see on AI click of [A] (Turf Loc: [AREACOORD(pixel_turf)]))"
		log_admin(message)
		if(REALTIMEOFDAY >= chnotify + 9000)
			chnotify = REALTIMEOFDAY
			send2tgs_adminless_only("NOCHEAT", message)
		return

	var/list/modifiers = params2list(params)
	if(modifiers["shift"] && modifiers["ctrl"])
		CtrlShiftClickOn(A)
		return
	if(modifiers["shift"])
		ShiftClickOn(A)
		return
	if(LAZYACCESS(modifiers, ALT_CLICK)) // alt and alt-gr (rightalt)
		ai_base_click_alt(A)
		return
	if(modifiers["ctrl"])
		CtrlClickOn(A)
		return
	if(modifiers["middle"])
		MiddleClickOn(A, params)
		return

	if(world.time <= next_move)
		return

	if(aicamera.in_camera_mode)
		aicamera.toggle_camera_mode(sound = FALSE)
		aicamera.captureimage(pixel_turf, usr)
		return
	if(waypoint_mode)
		waypoint_mode = 0
		set_waypoint(A)
		return

	A.attack_ai(src)

/*
	AI has no need for the UnarmedAttack() and RangedAttack() procs,
	because the AI code is not generic;	attack_ai() is used instead.
	The below is only really for safety, or you can alter the way
	it functions and re-insert it above.
*/
/mob/living/silicon/ai/UnarmedAttack(atom/A)
	A.attack_ai(src)
/mob/living/silicon/ai/RangedAttack(atom/A)
	A.attack_ai(src)

/atom/proc/attack_ai(mob/user)
	return

/*
	Since the AI handles shift, ctrl, and alt-click differently
	than anything else in the game, atoms have separate procs
	for AI shift, ctrl, and alt clicking.
*/

/mob/living/silicon/ai/CtrlShiftClickOn(atom/target)
	target.AICtrlShiftClick(src)

/mob/living/silicon/ai/ShiftClickOn(atom/target)
	target.AIShiftClick(src)

/mob/living/silicon/ai/CtrlClickOn(atom/target)
	target.AICtrlClick(src)


/// Reimplementation of base_click_alt for AI
/mob/living/silicon/ai/proc/ai_base_click_alt(atom/target)
	// If for some reason we can't alt click
	if(SEND_SIGNAL(src, COMSIG_MOB_ALTCLICKON, target) & COMSIG_MOB_CANCEL_CLICKON)
		return

	if(!isturf(target) && can_perform_action(target, (target.interaction_flags_click | SILENT_ADJACENCY)))
		// Signal intercept
		if(SEND_SIGNAL(target, COMSIG_CLICK_ALT, src) & CLICK_ACTION_ANY)
			return

		// AI alt click interaction succeeds
		if(target.ai_click_alt(src) & CLICK_ACTION_ANY)
			return

	client.loot_panel.open(get_turf(target))


/*
	The following criminally helpful code is just the previous code cleaned up;
	I have no idea why it was in atoms.dm instead of respective files.
*/
/* Questions: Instead of an Emag check on every function, can we not add to airlocks onclick if emag return? */

/* Atom Procs */
/atom/proc/AICtrlClick()
	return

/atom/proc/ai_click_alt(mob/living/silicon/ai/user)
	return
/atom/proc/AIShiftClick()
	return
/atom/proc/AICtrlShiftClick()
	return

/* Airlocks */
/obj/machinery/door/airlock/AICtrlClick() // Bolts doors
	if(obj_flags & EMAGGED)
		return

	toggle_bolt(usr)
	add_hiddenprint(usr)

/obj/machinery/door/airlock/ai_click_alt(mob/living/silicon/ai/user)
	if(obj_flags & EMAGGED)
		return

	if(!secondsElectrified)
		shock_perm(usr)
	else
		shock_restore(usr)

/obj/machinery/door/airlock/AIShiftClick()  // Opens and closes doors!
	if(obj_flags & EMAGGED)
		return

	user_toggle_open(usr)
	add_hiddenprint(usr)

/obj/machinery/door/airlock/AICtrlShiftClick()  // Sets/Unsets Emergency Access Override
	if(obj_flags & EMAGGED)
		return

	toggle_emergency(usr)
	add_hiddenprint(usr)

/////////////
/*   APC   */
/////////////

/// Toggle APC power settings
/obj/machinery/power/apc/AICtrlClick(mob/living/silicon/ai/user)
	if(!can_use(user, loud = TRUE))
		return

	toggle_breaker(user)

/// Toggle APC environment settings (atmos)
/obj/machinery/power/apc/AICtrlShiftClick(mob/living/silicon/ai/user)
	if(!can_use(user, loud = TRUE))
		return

	if(!is_operational || failure_timer)
		return

	environ = environ ? APC_CHANNEL_OFF : APC_CHANNEL_ON
	if (user)
		add_hiddenprint(user)
		var/enabled_or_disabled = environ ? "enabled" : "disabled"
		balloon_alert(user, "environment power [enabled_or_disabled]")
		user.log_message("[enabled_or_disabled] the [src] environment settings", LOG_GAME)
	update_appearance()
	update()

/// Toggle APC lighting settings
/obj/machinery/power/apc/AIShiftClick(mob/living/silicon/ai/user)
	if(!can_use(user, loud = TRUE))
		return

	if(!is_operational || failure_timer)
		return

	lighting = lighting ? APC_CHANNEL_OFF : APC_CHANNEL_ON
	if (user)
		var/enabled_or_disabled = lighting ? "enabled" : "disabled"
		add_hiddenprint(user)
		balloon_alert(user, "lighting power toggled [enabled_or_disabled]")
		user.log_message("turned [enabled_or_disabled] the [src] lighting settings", LOG_GAME)
	update_appearance()
	update()

/// Toggle APC equipment settings
/obj/machinery/power/apc/ai_click_alt(mob/living/silicon/ai/user)
	if(!can_use(user, loud = TRUE))
		return

	if(!is_operational || failure_timer)
		return

	equipment = equipment ? APC_CHANNEL_OFF : APC_CHANNEL_ON
	if (user)
		var/enabled_or_disabled = equipment ? "enabled" : "disabled"
		balloon_alert(user, "equipment power toggled [enabled_or_disabled]")
		add_hiddenprint(user)
		user.log_message("turned [enabled_or_disabled] the [src] equipment settings", LOG_GAME)
	update_appearance()
	update()

/obj/machinery/power/apc/attack_ai_secondary(mob/living/silicon/user, list/modifiers)
	if(!can_use(user, loud = TRUE))
		return

	togglelock(user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/* AI Turrets */
/obj/machinery/turretid/ai_click_alt(mob/living/silicon/ai/user) //toggles lethal on turrets
	if(ailock)
		return
	toggle_lethal(usr)

/obj/machinery/turretid/AICtrlClick() //turns off/on Turrets
	if(ailock)
		return
	toggle_on(usr)

/* Holopads */
/obj/machinery/holopad/ai_click_alt(mob/living/silicon/ai/user)
	if (user)
		balloon_alert(user, "disrupted all active calls")
		add_hiddenprint(user)
	hangup_all_calls()
	add_hiddenprint(usr)

//
// Override TurfAdjacent for AltClicking
//

/mob/living/silicon/ai/TurfAdjacent(turf/T)
	return (GLOB.cameranet && GLOB.cameranet.checkTurfVis(T))
