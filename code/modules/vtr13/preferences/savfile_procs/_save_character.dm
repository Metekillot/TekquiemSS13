/datum/preferences/proc/save_character()
	if(!path)
		return FALSE
	var/savefile/S = new /savefile(path)
	if(!S)
		return FALSE
	S.cd = "/character[default_slot]"

	WRITE_FILE(S["version"], SAVEFILE_VERSION_MAX)	//load_character will sanitize any bad data, so assume up-to-date.)

//===========CHOPPING BLOCK===========
/*
	WRITE_FILE(S["slotlocked"], slotlocked)
	WRITE_FILE(S["enlightement"], enlightenment)
	WRITE_FILE(S["exper"], exper)
	WRITE_FILE(S["exper_plus"], exper_plus)
	WRITE_FILE(S["true_experience"], true_experience)
	WRITE_FILE(S["dexterity"], dexterity)
	WRITE_FILE(S["social"], social)
	WRITE_FILE(S["mentality"], mentality)
	WRITE_FILE(S["lockpicking"], lockpicking)
	WRITE_FILE(S["athletics"], athletics)
	WRITE_FILE(S["blood"], blood)
	WRITE_FILE(S["archetype"], archetype)
	WRITE_FILE(S["discipline1type"], discipline1type)
	WRITE_FILE(S["discipline1level"], discipline1level)
	WRITE_FILE(S["discipline2type"], discipline2type)
	WRITE_FILE(S["discipline2level"], discipline2level)
	WRITE_FILE(S["discipline3type"], discipline3type)
	WRITE_FILE(S["discipline3level"], discipline3level)
	WRITE_FILE(S["discipline4type"], discipline4type)
	WRITE_FILE(S["discipline4level"], discipline4level)
	WRITE_FILE(S["friend"], friend)
	WRITE_FILE(S["enemy"], enemy)
	WRITE_FILE(S["lover"], lover)
	WRITE_FILE(S["friend_text"], friend_text)
	WRITE_FILE(S["enemy_text"], enemy_text)
	WRITE_FILE(S["lover_text"], lover_text)
	WRITE_FILE(S["generation"], generation)
	WRITE_FILE(S["generation_bonus"], generation_bonus)
	WRITE_FILE(S["body_model"], body_model)
	WRITE_FILE(S["torpor_count"], torpor_count)
	WRITE_FILE(S["total_age"], total_age)
	WRITE_FILE(S["randomise"], randomise)
	WRITE_FILE(S["jumpsuit_style"], jumpsuit_style)
	WRITE_FILE(S["uplink_loc"], uplink_spawn_loc)
	WRITE_FILE(S["playtime_reward_cloak"], playtime_reward_cloak)
	WRITE_FILE(S["phobia"], phobia)
	WRITE_FILE(S["feature_mcolor"]		, features["mcolor"])
	WRITE_FILE(S["feature_ethcolor"]		, features["ethcolor"])
	WRITE_FILE(S["feature_lizard_tail"], features["tail_lizard"])
	WRITE_FILE(S["feature_human_tail"]	, features["tail_human"])
	WRITE_FILE(S["feature_lizard_snout"], features["snout"])
	WRITE_FILE(S["feature_lizard_horns"], features["horns"])
	WRITE_FILE(S["feature_human_ears"]	, features["ears"])
	WRITE_FILE(S["feature_lizard_frills"], features["frills"])
	WRITE_FILE(S["feature_lizard_spines"], features["spines"])
	WRITE_FILE(S["feature_lizard_body_markings"], features["body_markings"])
	WRITE_FILE(S["feature_lizard_legs"], features["legs"])
	WRITE_FILE(S["feature_moth_wings"], features["moth_wings"])
	WRITE_FILE(S["feature_moth_antennae"], features["moth_antennae"])
	WRITE_FILE(S["feature_moth_markings"], features["moth_markings"])
	WRITE_FILE(S["dharma_type"], dharma_type)
	WRITE_FILE(S["dharma_level"], dharma_level)
	WRITE_FILE(S["po_type"], po_type)
	WRITE_FILE(S["po"], po)
	WRITE_FILE(S["hun"], hun)
	WRITE_FILE(S["yang"], yang)
	WRITE_FILE(S["yin"], yin)
	WRITE_FILE(S["chi_types"], chi_types)
	WRITE_FILE(S["chi_levels"], chi_levels)
	for(var/custom_name_id in GLOB.preferences_custom_names)
		var/savefile_slot_name = custom_name_id + "_name" //TODO remove this
		WRITE_FILE(S[savefile_slot_name],custom_names[custom_name_id])

	WRITE_FILE(S["preferred_ai_core_display"],  preferred_ai_core_display)
	WRITE_FILE(S["prefered_security_department"], prefered_security_department)
*/

//===========GENERAL===========
	WRITE_FILE(S["species"], pref_species.id)
	WRITE_FILE(S["info_known"], info_known)
	WRITE_FILE(S["gender"], gender)
	WRITE_FILE(S["real_name"], real_name)
	WRITE_FILE(S["body_type"], body_type)
	WRITE_FILE(S["age"], age)
	WRITE_FILE(S["flavor_text"], flavor_text)
	WRITE_FILE(S["ooc_notes"], ooc_notes)
	WRITE_FILE(S["headshot_link"], headshot_link) // TFN EDIT: headshot saving
	WRITE_FILE(S["hair_color"], hair_color)
	WRITE_FILE(S["facial_hair_color"], facial_hair_color)
	WRITE_FILE(S["hairstyle_name"], hairstyle)
	WRITE_FILE(S["facial_style_name"], facial_hairstyle)
	WRITE_FILE(S["eye_color"], eye_color)
	WRITE_FILE(S["skin_tone"], skin_tone)
	WRITE_FILE(S["underwear"], underwear)
	WRITE_FILE(S["underwear_color"], underwear_color)
	WRITE_FILE(S["undershirt"], undershirt)
	WRITE_FILE(S["socks"], socks)
	WRITE_FILE(S["backpack"], backpack)
	WRITE_FILE(S["persistent_scars"], persistent_scars)
	WRITE_FILE(S["reason_of_death"], reason_of_death)

	//Jobs
	WRITE_FILE(S["joblessrole"], joblessrole)

	//Write prefs
	WRITE_FILE(S["job_preferences"], job_preferences)
	WRITE_FILE(S["alt_titles_preferences"], alt_titles_preferences)

	//Quirks
	WRITE_FILE(S["all_quirks"], all_quirks)

	//STATS
	WRITE_FILE(S["physique"], physique)
	//-----------NEW ITEMS-----------
	WRITE_FILE(S["stamina"], stamina)
	WRITE_FILE(S["charisma"], charisma)
	WRITE_FILE(S["composure"], composure)
	WRITE_FILE(S["wits"], wits)
	WRITE_FILE(S["resolve"], resolve)

//===========GHOUL/VAMPS===========
	WRITE_FILE(S["clan"], clane.name)

	WRITE_FILE(S["humanity"], humanity)
	WRITE_FILE(S["diablerist"], diablerist)
	WRITE_FILE(S["masquerade"], masquerade)
	WRITE_FILE(S["clan_accessory"], clane_accessory)

	WRITE_FILE(S["discipline_types"], discipline_types)
	WRITE_FILE(S["discipline_levels"], discipline_levels)

	//-----------NEW ITEMS-----------
	WRITE_FILE(S["vamp_rank"], vamp_rank)
	WRITE_FILE(S["actual_age"], actual_age)
	WRITE_FILE(S["regent_clan"], regent_clan.name)
	WRITE_FILE(S["vamp_faction"], vamp_faction.name)

//===========WEREWOLVES===========
	WRITE_FILE(S["auspice"], auspice.name)
	WRITE_FILE(S["auspice_level"], auspice_level)
	WRITE_FILE(S["breed"], breed)
	WRITE_FILE(S["tribe"], tribe)
	WRITE_FILE(S["werewolf_color"], werewolf_color)
	WRITE_FILE(S["werewolf_scar"], werewolf_scar)
	WRITE_FILE(S["werewolf_hair"], werewolf_hair)
	WRITE_FILE(S["werewolf_hair_color"], werewolf_hair_color)
	WRITE_FILE(S["werewolf_eye_color"], werewolf_eye_color)
	WRITE_FILE(S["werewolf_name"], werewolf_name)
	return TRUE
