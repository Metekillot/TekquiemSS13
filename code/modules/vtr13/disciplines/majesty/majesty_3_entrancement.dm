/datum/discipline_power/vtr/majesty/entrancement
	name = "Entrancement"
	desc = "Place victims you are near into an artificial blood bond."
	level = 3

	duration_length = 2 HOURS
	var/entrancement_range = 1

/datum/discipline_power/vtr/majesty/entrancement/post_gain()
	if(discipline.level >= 5)
		entrancement_range = 2

/datum/discipline_power/vtr/majesty/entrancement/activate()
	. = ..()
	for(var/mob/living/target in oviewers(entrancement_range,owner))
		to_chat(target, "[owner] becomes immensely fascinating.")
		if(!SSroll.opposed_roll(
			owner,
			target,
			dice_a = owner.get_total_social() + discipline.level,
			dice_b = target.get_total_social() + target.get_total_blood(), 
			alert_atom = target,
			show_player_a = TRUE,
			show_player_b = FALSE))
			continue
		
		target.playsound_local(owner, activate_sound, 50, FALSE)
		target.create_blood_bond_to(owner, TRUE)