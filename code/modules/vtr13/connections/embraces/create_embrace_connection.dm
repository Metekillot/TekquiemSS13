/mob/living/proc/create_embrace_connection(mob/living/carbon/human/sire)
	var/sire_description = "I am [sire.true_real_name]'s sire."
	var/childe_description = "I am [sire.true_real_name]'s childe."

	var/new_group_id = src.insert_character_connection(
			CONNECTION_EMBRACE, 
			MEMBER_TYPE_CHILDE,
			childe_description,
			null)
	mind.character_connections = get_character_connections()
	
	sire.insert_character_connection(
		CONNECTION_EMBRACE, 
		MEMBER_TYPE_SIRE,
		sire_description,
		new_group_id)
	sire.mind.character_connections = sire.get_character_connections()