/mob/living/proc/create_blood_bond_to(mob/living/carbon/human/domitor)
	
	if(!can_be_blood_bonded_by(domitor))
		return 0
	
	var/bond_type = CONNECTION_BLOOD_BOND_1
	var/thrall_description = "I am bound by a first-stage blood bond to [domitor.true_real_name]."
	var/domitor_description = "I have put a first-stage blood bond upon [true_real_name]."
	var/resulting_bond = 1
	var/datum/character_connection/existing_connection = get_existing_mutual_blood_bond(domitor)
	
	if(existing_connection)
		switch(existing_connection.group_id)
			if(CONNECTION_BLOOD_BOND_1)
				bond_type = CONNECTION_BLOOD_BOND_2
				thrall_description = "I am enraptured by a second-stage blood bond to [domitor.true_real_name]."
				domitor_description = "I have caught [true_real_name] in a second-stage blood bond."
				resulting_bond = 2
			if(CONNECTION_BLOOD_BOND_2)
				bond_type = CONNECTION_BLOOD_BOND_3
				thrall_description = "I am a Thrall, transfixed by a third-stage blood bond to [domitor.true_real_name], my Regent."
				domitor_description = "I have trapped [true_real_name] in a third-stage blood bond. I am their Regent and they are my Thrall."
				resulting_bond = 3
			if(CONNECTION_BLOOD_BOND_3)
				return 3
		retire_character_connection_by_group_id(existing_connection.group_id)

	//purge any non lvl 3 blood bonds from the player & db
	if(bond_type == CONNECTION_BLOOD_BOND_3)
		retire_all_character_connection_blood_bonds()

	var/new_group_id = insert_character_connection(
			bond_type, 
			MEMBER_TYPE_THRALL,
			thrall_description)
	mind.character_connections = get_character_connections()
	
	domitor.insert_character_connection(
		bond_type, 
		MEMBER_TYPE_DOMITOR,
		domitor_description,
		new_group_id)
	domitor.mind.character_connections = domitor.get_character_connections()

	return resulting_bond