/datum/discipline_power
	/// Name of the Discipline power
	var/name = "Discipline power name"
	/// Description of the Discipline power
	var/desc = "Discipline power description"

	/* BASIC INFORMATION */
	/// What rank of the Discipline this Discipline power belongs to.
	var/level = 1
	/// Bitflags determining the requirements to cast this power
	var/check_flags = DISC_CHECK_CONSCIOUS | DISC_CHECK_CAPABLE
	/// How many blood points this power costs to activate
	var/vitae_cost = 1
	/// Bitflags determining what types of entities this power is allowed to target. NONE if self-targeting only.
	var/target_type = NONE
	/// How many tiles away this power can be used from.
	var/range = 0

	/* EXTRA BEHAVIOUR ON ACTIVATION AND DEACTIVATION */
	/// Sound file that plays to the user when this power is activated.
	var/activate_sound
	/// Sound file that plays to the user when this power is deactivated.
	var/deactivate_sound
	/// Sound file that plays to all nearby players when this power is activated.
	var/effect_sound
	/// If this power will upset NPCs when used on them.
	var/aggravating = FALSE
	/// If this power is an aggressive action and logged as such.
	var/hostile = FALSE
	/// If use of this power creates a visible Masquerade breach.
	var/violates_masquerade = FALSE

	/* HOW AND WHEN IT'S ACTIVATED AND DEACTIVATED */
	/// If this Discipline doesn't automatically expire, but rather periodically drains blood.
	var/toggled = FALSE
	/// If this power can be turned on and off.
	var/cancelable = FALSE
	/// If this power can (theoretically, not in reality) have multiple of its effects active at once.
	var/multi_activate = FALSE
	/// Amount of time it takes until this Discipline deactivates itself. 0 if instantaneous.
	var/duration_length = 0
	/// Amount of time it takes until this Discipline can be used again after activation.
	var/cooldown_length = 0
	/// If this power uses its own duration/deactivation handling rather than the default handling
	var/duration_override = FALSE
	/// If this power uses its own cooldown handling rather than the default handling
	var/cooldown_override = FALSE
	/// List of Discipline power types that cannot be activated alongside this power and share a cooldown with it.
	var/list/grouped_powers = list()

	/* NOT MEANT TO BE OVERRIDDEN */
	/// Timer(s) tracking the duration of the power. Can have multiple if multi_activate is true.
	var/list/duration_timers = list()
	/// Timer tracking the cooldown of the power. Starts after deactivation if it has a duration and multi_active isn't true, after activation otherwise.
	var/cooldown_timer
	/// If this Discipline is currently in use.
	var/active = FALSE
	/// The Discipline that this power is part of.
	var/datum/discipline/discipline
	/// The player using this Discipline power.
	var/mob/living/carbon/human/owner

/datum/discipline_power/New(datum/discipline/discipline)
	if (discipline)
		src.discipline = discipline
		src.owner = discipline.owner

/datum/discipline_power/proc/get_cooldown()
	var/time_left = timeleft(cooldown_timer)
	if (isnull(time_left))
		time_left = 0

	return time_left

/datum/discipline_power/proc/get_duration()
	var/highest_timeleft = 0
	for (var/timer_id in duration_timers)
		var/time_left = timeleft(timer_id)
		if (isnull(time_left))
			continue
		if (time_left > highest_timeleft)
			highest_timeleft = time_left

	return highest_timeleft

/datum/discipline_power/proc/can_afford()
	return (owner.bloodpool >= vitae_cost)

/datum/discipline_power/proc/can_activate_untargeted(alert = FALSE)
	SHOULD_CALL_PARENT(TRUE)

	//can't be casted without an actual caster
	if (!owner)
		return FALSE

	//can always be deactivated if that's an option
	if (active && (toggled || cancelable))
		if (can_deactivate_untargeted())
			return TRUE
		else
			return FALSE

	//the power is currently active
	if (active && !multi_activate)
		if (alert)
			to_chat(owner, span_warning("[src] is already active!"))
		return FALSE

	//a mutually exclusive power is already active or on cooldown
	for (var/exclude_power in grouped_powers)
		var/datum/discipline_power/found_power = discipline.get_power(exclude_power)
		if (!found_power || (found_power == src))
			continue

		if (found_power.active)
			if (alert)
				to_chat(owner, "<span class='warning'>You cannot have [src] and [found_power] active at the same time!")
			return FALSE
		if (found_power.get_cooldown())
			if (alert)
				to_chat(owner, "<span class='warning'>You cannot activate [src] before [found_power]'s cooldown expires in [DisplayTimeText(found_power.get_cooldown())].")
			return FALSE

	//the user cannot afford the power's vitae expenditure
	if (!can_afford())
		if (alert)
			to_chat(owner, span_warning("You do not have enough blood to cast [src]!"))
		return FALSE

	//the power's cooldown has not elapsed
	if (get_cooldown())
		if (alert)
			to_chat(owner, span_warning("[src] is still on cooldown for [DisplayTimeText(get_cooldown())]!"))
		return FALSE

	//status checks
	if ((check_flags & DISC_CHECK_TORPORED) && HAS_TRAIT(owner, TRAIT_TORPOR))
		if (alert)
			to_chat(owner, span_warning("You cannot cast [src] while in Torpor!"))
		return FALSE

	if ((check_flags & DISC_CHECK_CONSCIOUS) && HAS_TRAIT(owner, TRAIT_KNOCKEDOUT))
		if (alert)
			to_chat(owner, span_warning("You cannot cast [src] while unconscious!"))
		return FALSE

	if ((check_flags & DISC_CHECK_CAPABLE) && HAS_TRAIT(owner, TRAIT_INCAPACITATED))
		if (alert)
			to_chat(owner, span_warning("You cannot cast [src] while incapacitated!"))
		return FALSE

	if ((check_flags & DISC_CHECK_IMMOBILE) && HAS_TRAIT(owner, TRAIT_IMMOBILIZED))
		if (alert)
			to_chat(owner, span_warning("You cannot cast [src] while immobilised!"))
		return FALSE

	if ((check_flags & DISC_CHECK_LYING) && HAS_TRAIT(owner, TRAIT_FLOORED))
		if (alert)
			to_chat(owner, span_warning("You cannot cast [src] while lying on the floor!"))
		return FALSE

	if ((check_flags & DISC_CHECK_SEE) && HAS_TRAIT(owner, TRAIT_BLIND))
		if (alert)
			to_chat(owner, span_warning("You cannot cast [src] without your sight!"))
		return FALSE

	if ((check_flags & DISC_CHECK_SPEAK) && HAS_TRAIT(owner, TRAIT_MUTE))
		if (alert)
			to_chat(owner, span_warning("You cannot cast [src] without speaking!"))
		return FALSE

	if ((check_flags & DISC_CHECK_FREE_HAND) && HAS_TRAIT(owner, TRAIT_HANDS_BLOCKED))
		if (alert)
			to_chat(owner, span_warning("You cannot cast [src] without free hands!"))
		return FALSE

	//respect pacifism, prevent hostile Discipline usage from pacifists
	if (hostile && HAS_TRAIT(owner, TRAIT_PACIFISM))
		if (alert)
			to_chat(owner, span_warning("You cannot cast [src] as a pacifist!"))
		return FALSE

	//nothing found, it can be casted
	return TRUE

/datum/discipline_power/proc/can_activate(atom/target, alert = FALSE)
	SHOULD_CALL_PARENT(TRUE)

	var/signal_return = SEND_SIGNAL(src, COMSIG_POWER_TRY_ACTIVATE, src, target) | SEND_SIGNAL(owner, COMSIG_POWER_TRY_ACTIVATE, src, target)
	if (target)
		signal_return |= SEND_SIGNAL(target, COMSIG_POWER_TRY_ACTIVATE_ON, src)
	if (signal_return & POWER_PREVENT_ACTIVATE)
		//feedback is sent by the proc preventing activation
		return FALSE

	//can't activate if the owner isn't capable of it
	if (!can_activate_untargeted(alert))
		return FALSE

	//self activated so target doesn't matter
	if (target_type == NONE)
		return TRUE

	//check if distance is in range
	if (get_dist(owner, target) > range)
		if (alert)
			to_chat(owner, span_warning("[target] is out of range!"))
		return FALSE

	//handling for if a ranged Discipline is being used on its caster
	if (target == owner)
		if (target_type & TARGET_SELF)
			return TRUE
		else
			if (alert)
				to_chat(owner, span_warning("You can't use this power on yourself!"))
			return FALSE

	//account for complete supernatural resistance
	if (HAS_TRAIT(target, TRAIT_ANTIMAGIC))
		if (alert)
			to_chat(owner, span_warning("[target] resists your Disciplines!"))
		return FALSE

	//check target type
	if (((target_type & TARGET_MOB) || (target_type & TARGET_LIVING) || (target_type & TARGET_HUMAN) || (target_type & TARGET_PLAYER)) && istype(target, /mob/living))
		//make sure our LIVING target isn't DEAD
		var/mob/living/living_target = target
		if ((target_type & TARGET_LIVING) && (living_target.stat == DEAD))
			if (alert)
				to_chat(owner, span_warning("You cannot cast [src] on dead things!"))
			return FALSE

		if ((target_type & TARGET_PLAYER) && !living_target.client)
			if (alert)
				to_chat(owner, span_warning("You can only cast [src] on other players!"))
			return FALSE

		if (ishuman(target))
			var/mob/living/carbon/human/human_target = living_target
			//todo: remove this variable and refactor it into TRAIT_ANTIMAGIC
			if (human_target.resistant_to_disciplines)
				if (alert)
					to_chat(owner, span_warning("[target] resists your Disciplines!"))
				return FALSE

			if (target_type & TARGET_HUMAN)
				return TRUE

		if (target_type & TARGET_HUMAN)
			return FALSE

		return TRUE

	if ((target_type & TARGET_OBJ) && istype(target, /obj))
		return TRUE

	if ((target_type & TARGET_GHOST) && istype(target, /mob/dead))
		return TRUE

	if ((target_type & TARGET_TURF) && istype(target, /turf))
		return TRUE

	//target doesn't match any targeted types, so can't activate on them
	if (alert)
		to_chat(owner, span_warning("You cannot cast [src] on [target]!"))
	return FALSE

/datum/discipline_power/proc/pre_activation(atom/target)
	SHOULD_CALL_PARENT(FALSE)

	//overrides should take care to still send and receive these signals! copy and paste this!
	var/signal_return = SEND_SIGNAL(src, COMSIG_POWER_PRE_ACTIVATION, src, target) | SEND_SIGNAL(owner, COMSIG_POWER_PRE_ACTIVATION, src, target)
	if (target)
		signal_return |= SEND_SIGNAL(target, COMSIG_POWER_PRE_ACTIVATION_ON, src)
	if (signal_return & POWER_CANCEL_ACTIVATION)
		//feedback is sent by the proc cancelling activation
		return

	activate(target)

/datum/discipline_power/proc/activate(atom/target)
	SHOULD_CALL_PARENT(TRUE)

	//ensure everything is in place for activation to be possible
	if(!target && (target_type != NONE))
		return FALSE
	if(!discipline?.owner)
		return FALSE

	SEND_SIGNAL(src, COMSIG_POWER_ACTIVATE, src, target)
	SEND_SIGNAL(owner, COMSIG_POWER_ACTIVATE, src, target)
	if (target)
		SEND_SIGNAL(target, COMSIG_POWER_ACTIVATE_ON, src)

	//make it active if it can only have one active instance at a time
	if (!multi_activate)
		active = TRUE

	if (!cooldown_override)
		do_cooldown(TRUE)

	if (!duration_override)
		do_duration(target)

	do_activate_sound()

	do_effect_sound(target)

	INVOKE_ASYNC(src, PROC_REF(do_npc_aggro), target)

	INVOKE_ASYNC(src, PROC_REF(do_masquerade_violation), target)

	spend_resources()

	do_caster_notification(target)
	do_logging(target)

	owner.update_action_buttons()

	return TRUE

/datum/discipline_power/proc/do_activate_sound()
	if (activate_sound)
		owner.playsound_local(owner, activate_sound, 50, FALSE)

/datum/discipline_power/proc/do_effect_sound(atom/target)
	if (effect_sound)
		playsound(target ? target : owner, effect_sound, 50, FALSE)

/datum/discipline_power/proc/do_npc_aggro(atom/target)
	if (aggravating && isnpc(target))
		var/mob/living/carbon/human/npc/npc = target
		npc.Aggro(owner, hostile)

/datum/discipline_power/proc/do_masquerade_violation(atom/target)
	if (violates_masquerade)
		if (owner.CheckEyewitness(target ? target : owner, owner, 7, TRUE))
			//TODO: detach this from being a human
			if (ishuman(owner))
				var/mob/living/carbon/human/human = owner
				human.AdjustMasquerade(-1)

/datum/discipline_power/proc/spend_resources()
	owner.bloodpool = clamp(owner.bloodpool - vitae_cost, 0, owner.maxbloodpool)

/datum/discipline_power/proc/do_caster_notification(target)
	to_chat(owner, span_warning("You cast [name][target ? " on [target]!" : "."]"))

/datum/discipline_power/proc/do_logging(target)
	log_combat(owner, target ? target : owner, "casted the power [src.name] of the Discipline [discipline.name] on")

/datum/discipline_power/proc/do_duration(atom/target)
	duration_timers.Add(addtimer(CALLBACK(src, PROC_REF(duration_expire), target), duration_length, TIMER_STOPPABLE | TIMER_DELETE_ME))

/datum/discipline_power/proc/do_cooldown(on_activation = FALSE)
	if (multi_activate && !on_activation)
		return

	cooldown_timer = addtimer(CALLBACK(src, PROC_REF(cooldown_expire)), cooldown_length, TIMER_STOPPABLE | TIMER_DELETE_ME)

/datum/discipline_power/proc/try_activate(atom/target)
	if (can_activate(target, TRUE))
		pre_activation(target)
		return TRUE

	return FALSE

/datum/discipline_power/proc/duration_expire(atom/target)
	//clean up the expired timer, which SHOULD be the first in the list
	deltimer(duration_timers[1])
	duration_timers.Cut(1, 2)

	//proceed to deactivation or refreshing
	if (toggled)
		refresh(target)
	else
		try_deactivate(target)

	owner.update_action_buttons()

/datum/discipline_power/proc/cooldown_expire()
	owner.update_action_buttons()

/datum/discipline_power/proc/can_deactivate_untargeted()
	SHOULD_CALL_PARENT(TRUE)

	if (target_type == NONE)
		if (!owner)
			return FALSE

	return TRUE

/datum/discipline_power/proc/can_deactivate(atom/target)
	SHOULD_CALL_PARENT(TRUE)

	var/signal_return = SEND_SIGNAL(src, COMSIG_POWER_TRY_DEACTIVATE, src, target) | SEND_SIGNAL(owner, COMSIG_POWER_TRY_DEACTIVATE, src, target)
	if (target)
		signal_return |= SEND_SIGNAL(target, COMSIG_POWER_TRY_DEACTIVATE_ON, src)
	if (signal_return & POWER_PREVENT_DEACTIVATE)
		//feedback is sent by the proc cancelling activation
		return FALSE

	if (!can_deactivate_untargeted())
		return FALSE

	if (target_type != NONE)
		if (!target)
			return FALSE

	return TRUE

/datum/discipline_power/proc/deactivate(atom/target, direct = FALSE)
	SHOULD_CALL_PARENT(TRUE)

	if (direct)
		deltimer(duration_timers[1])
		duration_timers.Cut(1, 2)

	SEND_SIGNAL(src, COMSIG_POWER_DEACTIVATE, src, target)
	SEND_SIGNAL(owner, COMSIG_POWER_DEACTIVATE, src, target)
	if (target)
		SEND_SIGNAL(target, COMSIG_POWER_DEACTIVATE_ON, src)

	if (!multi_activate)
		active = FALSE

	if (!cooldown_override)
		do_cooldown()

	if (deactivate_sound)
		owner.playsound_local(owner, deactivate_sound, 50, FALSE)

	owner.update_action_buttons()

/datum/discipline_power/proc/try_deactivate(atom/target, direct = FALSE)
	SHOULD_NOT_OVERRIDE(TRUE)

	if (can_deactivate(target))
		deactivate(target, direct)

/datum/discipline_power/proc/post_gain()
	return

/datum/discipline_power/proc/refresh(atom/target)
	if (!active)
		return
	if (!owner)
		return

	if (owner.bloodpool >= vitae_cost)
		owner.bloodpool = max(owner.bloodpool - vitae_cost, 0)
		to_chat(owner, span_warning("[src] consumes your blood to stay active."))
		if (!duration_override)
			do_duration(target)
	else
		to_chat(owner, "<span class='warning'>You don't have enough blood to keep [src] active!")
		try_deactivate(target, direct = TRUE)

