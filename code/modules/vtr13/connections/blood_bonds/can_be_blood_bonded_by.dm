/mob/living/proc/can_be_blood_bonded_by(mob/living/carbon/human/domitor)

	if(!ckey || !mind)
		return FALSE

	if(!domitor || !domitor.mind)
		return FALSE

	if(!iskindred(domitor))
		return FALSE

	//is the thrall already in a level three blood bond?
	if(check_character_level_three_blood_bonds(domitor))
		to_chat(src, "<span class='warning'>Your deep devotion to your Regent prevents a blood bond from forming.</span>")
		return FALSE
	
	if(check_mutual_blood_bonds_made_this_round(domitor))
		return FALSE

	return TRUE
