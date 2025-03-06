/mob/living/proc/create_blood_bond_to(mob/living/carbon/human/domitor)
	if(!can_be_blood_bonded_by(domitor))
		return
	
	var/bond_type = CONNECTION_BLOOD_BOND_1
	var/thrall_description = "You are bound by a first-stage blood bond to [domitor.true_real_name]."
	var/domitor_description = "You have put a first-stage blood bond upon [true_real_name]."
	
	var/datum/character_connection/existing_connection = get_existing_mutual_blood_bond(domitor)
	
	if(existing_connection)
		switch(existing_connection.group_id)
			if(CONNECTION_BLOOD_BOND_1)
				bond_type = CONNECTION_BLOOD_BOND_2
				thrall_description = "You are enraptured by a second-stage blood bond to [domitor.true_real_name]."
				domitor_description = "You have caught [true_real_name] in a second-stage blood bond."
			if(CONNECTION_BLOOD_BOND_2)
				bond_type = CONNECTION_BLOOD_BOND_3
				thrall_description = "You are a Thrall, transfixed by a third-stage blood bond to [domitor.true_real_name], your Domitor."
				domitor_description = "You have trapped [true_real_name] in a third-stage blood bond. You are their Domitor and they are your Thrall."
			if(CONNECTION_BLOOD_BOND_3)
				return //we don't need to deepen this blood bond!
		retire_character_connection_by_group_id(existing_connection.group_id)

	var/new_group_id = 
		insert_new_character_connection(
			bond_type, 
			MEMBER_TYPE_THRALL, 
			ckey, 
			true_real_name, 
			thrall_description)
	
	insert_new_character_connection(
		bond_type, 
		MEMBER_TYPE_DOMITOR, 
		domitor.ckey, 
		domitor.true_real_name, 
		domitor_description, 
		new_group_id)
