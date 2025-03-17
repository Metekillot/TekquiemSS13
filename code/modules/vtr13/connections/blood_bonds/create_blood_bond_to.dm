/mob/living/proc/create_blood_bond_to(mob/living/carbon/human/domitor)
	
	if(!can_be_blood_bonded_by(domitor))
		return 0
	
	var/bond_type = CONNECTION_BLOOD_BOND_1
	var/thrall_description = "I am bound by a first-stage blood bond to [domitor.true_real_name]."
	var/domitor_description = "I have put a first-stage blood bond upon [true_real_name]."
	var/resulting_bond = 1
	var/datum/character_connection/existing_connection = get_existing_mutual_blood_bond(domitor)
	
	var/retire_existing_connection = FALSE
	if(existing_connection)
		switch(existing_connection.group_type)
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
		retire_existing_connection = TRUE

	message_admins("[ADMIN_LOOKUPFLW(domitor)] has bloodbonded [ADMIN_LOOKUPFLW(src)] with [bond_type].")
	log_game("[key_name(domitor)] has bloodbonded [key_name(src)] with [bond_type].")

	var/purge_other_blood_bonds = FALSE
	switch(bond_type)
		if(CONNECTION_BLOOD_BOND_1)
			to_chat(src, "<span class='userlove'>You feel a deep sense of familiarity with [domitor].</span>")
		
		if(CONNECTION_BLOOD_BOND_2)
			to_chat(src, "<span class='userlove'>You begin to long for [domitor]'s presence.</span>")

		if(CONNECTION_BLOOD_BOND_3)
			var/response_g = input(src, "Do you wish to enter into a third stage blood bond? This will remove all lower level blood bonds.") in list("Yes", "No")
			if(response_g == "No")
				return 0
			purge_other_blood_bonds = TRUE
			to_chat(src, "<span class='userlove'>You lose yourself in your devotion to [domitor]!</span>")

	if(!iskindred(src) && !isghoul(src) && !isnpc(src))

		var/mob/living/carbon/human/blood_bonded_human = src
		var/save_data_g = FALSE
		blood_bonded_human.set_species(/datum/species/ghoul)
		blood_bonded_human.clane = null
		blood_bonded_human.roundstart_vampire = FALSE
		var/datum/species/ghoul/g_species = blood_bonded_human.dna.species
		g_species.master = domitor
		g_species.last_vitae = world.time

		var/response_g = input(blood_bonded_human, "Do you wish to keep being a ghoul on your save slot?") in list("Yes", "No")
		if(response_g == "Yes")
			save_data_g = TRUE
		else
			save_data_g = FALSE
		
		if(save_data_g)
			var/datum/preferences/BLOODBONDED_prefs_g = blood_bonded_human.client.prefs
			if(BLOODBONDED_prefs_g.discipline_types.len == 3)
				for (var/i in 1 to 3)
					var/removing_discipline = BLOODBONDED_prefs_g.discipline_types[1]
					if (removing_discipline)
						var/index = BLOODBONDED_prefs_g.discipline_types.Find(removing_discipline)
						BLOODBONDED_prefs_g.discipline_types.Cut(index, index + 1)
						BLOODBONDED_prefs_g.discipline_levels.Cut(index, index + 1)
			BLOODBONDED_prefs_g.pref_species.name = "Ghoul"
			BLOODBONDED_prefs_g.pref_species.id = "ghoul"
			BLOODBONDED_prefs_g.save_character()
		if(response_g == "No")
			return 0

	if(retire_existing_connection)
		retire_character_connection_by_group_id(existing_connection.group_id)

	if(purge_other_blood_bonds)
		retire_all_character_connection_blood_bonds()

	var/new_group_id = src.insert_character_connection(
			bond_type, 
			MEMBER_TYPE_THRALL,
			thrall_description,
			null)
	mind.character_connections = get_character_connections()
	
	domitor.insert_character_connection(
		bond_type, 
		MEMBER_TYPE_DOMITOR,
		domitor_description,
		new_group_id)
	domitor.mind.character_connections = domitor.get_character_connections()

	return resulting_bond