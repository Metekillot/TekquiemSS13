/datum/discipline_power/vtr/dominate/the_lying_mind
	name = "The Lying Mind"
	desc = "Change a victim's memories."

	level = 5
	check_flags = DISC_CHECK_CAPABLE|DISC_CHECK_SPEAK|DISC_CHECK_SEE
	target_type = TARGET_PLAYER|TARGET_LIVING|TARGET_SELF

	cooldown_length = 5 MINUTES
	range = 7
	vitae_cost = 3
	var/max_retry_recursion = 15
	var/guidelines = "Elge write a guideline for using this mind erase-y ability, with disclaimer for it, ty. The string can be long, so for the purposes of this placeholder WORD WORD WORD WORD WORD WORD WORD WORD WORD WORD WORD WORD WORD WORD WORD WORD WORD WORD WORD WORD WORD WORD WORD WORD WORD WORD WORD WORD WORD WORD WORD WORD WORD WORD WORD WORD WORD WORD WORD WORD WORD WORD WORD WORD WORD WORD WORD WORD"
	var/player_consent = "Elge write a message that will display when the player is faced with their memory getting borked, thanks.  The string can be long, so for the purposes of this placeholder HEX HEX HEX HEX HEX HEX HEX HEX HEX HEX HEX HEX HEX HEX HEX HEX HEX HEX HEX HEX HEX HEX HEX HEX HEX HEX HEX HEX HEX HEX HEX HEX HEX HEX HEX HEX HEX HEX HEX HEX HEX HEX HEX HEX HEX HEX HEX HEX HEX HEX HEX HEX HEX HEX HEX HEX HEX HEX"
	var/current_command
	var/power_in_use = FALSE
	var/overlay_time = 5 SECONDS

/datum/discipline_power/vtr/dominate/the_lying_mind/pre_activation_check_no_spend(atom/target)
	if(power_in_use)
		to_chat(owner, span_warning("You are already attempting to dominate someone!"))
		return FALSE
	power_in_use = TRUE
	current_command = dominate_tgui_input_text(owner, guidelines, "Write an alteration to [target]'s memories:", "Dominate", null, null, FALSE, FALSE)
	power_in_use = FALSE
	if(!current_command)
		to_chat(owner, span_warning("You think better of dominating [target]."))
		return FALSE
	
	return TRUE

/datum/discipline_power/vtr/dominate/the_lying_mind/pre_activation_checks(mob/living/carbon/human/target)
	to_chat(owner, span_warning("You attempt to command [target] to do your bidding."))

	log_admin("[owner] attempted to use Dominate [level] on [target]. Alteration: '[current_command]'")
	if(!SSroll.opposed_roll(
		owner,
		target,
		dice_a = owner.get_total_social() + discipline.level,
		dice_b = target.get_total_social() + target.get_total_blood(), 
		alert_atom = target,
		show_player_a = FALSE,
		show_player_b = FALSE))
		current_command = null
		to_chat(owner, span_warning("[target] resists your command!"))
		do_cooldown(TRUE)
		owner.update_action_buttons()
		return FALSE
	return TRUE

/datum/discipline_power/vtr/dominate/the_lying_mind/activate(mob/living/carbon/human/target)
	. = ..()
	playsound(target, 'code/modules/wod13/sounds/general_good.ogg', 100, FALSE)

	var/the_command = current_command
	current_command = null
	if(!consent_prompt(target, "[owner] is trying to rewrite your memories! Their changes:", "Memory Alteration Consent Form", player_consent, the_command))
		log_admin("[target] rejected consent for Dominate [level] from [owner]. Command: '[the_command]'")
		to_chat(target, span_notice("You do not consent to domination."))
		return
	to_chat(target, span_notice("You consent to domination. Consent may be retracted at any time."))
	log_admin("[target] was affected by Dominate [level] from [owner]. Command: '[the_command]'")

	playsound(target, 'code/modules/wod13/sounds/dominate.ogg', 100, FALSE)
	target.remove_overlay(MUTATIONS_LAYER)
	var/mutable_appearance/dominate_overlay = mutable_appearance('code/modules/wod13/icons.dmi', "dominate", -MUTATIONS_LAYER)
	dominate_overlay.pixel_z = 2
	target.overlays_standing[MUTATIONS_LAYER] = dominate_overlay
	target.apply_overlay(MUTATIONS_LAYER)
	to_chat(target, span_userdanger("You are compelled to obey the following command: [the_command]"))
	addtimer(CALLBACK(src, PROC_REF(overlay_end_early),target),overlay_time)


/datum/discipline_power/vtr/dominate/the_lying_mind/proc/overlay_end_early(mob/living/carbon/human/target)
	if(!target)
		return
	target.remove_overlay(MUTATIONS_LAYER)
