/mob/living/carbon/human/proc/examine_beast(mob/user, temp_gender = null)
	var/notify_beast = FALSE
	if(iskindred(user))
		notify_beast = TRUE
	else if(isghoul(user))
		if(HAS_TRAIT(user, TRAIT_USING_AUSPEX))
			notify_beast = TRUE
	
	if(notify_beast && iskindred(src))
		var/t_He = p_they(TRUE, temp_gender)
		var/t_him = p_them(FALSE, temp_gender)
		var/t_is = p_are(temp_gender)
		return span_danger("You sense the beast within [t_him] - [t_He] [t_is] Kindred.")