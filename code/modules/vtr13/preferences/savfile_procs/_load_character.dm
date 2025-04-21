/datum/preferences/proc/load_character(slot)
	if(!path)
		return FALSE
	if(!fexists(path))
		return FALSE
	var/savefile/S = new /savefile(path)
	if(!S)
		return FALSE
	S.cd = "/"
	if(!slot)
		slot = default_slot
	slot = sanitize_integer(slot, 1, max_save_slots, initial(default_slot))
	if(slot != default_slot)
		default_slot = slot
		WRITE_FILE(S["default_slot"], slot)

	S.cd = "/character[slot]"
	var/needs_update = savefile_needs_update(S)
	if(needs_update == -2)		//fatal, can't load any data
		return FALSE



//===========PREFS TO REMOVE===========
/*
	READ_FILE(S["slotlocked"], slotlocked)
	slotlocked = sanitize_integer(slotlocked, 0, 1, initial(slotlocked))

	READ_FILE(S["enlightement"], enlightenment)
	READ_FILE(S["exper"], exper)
	READ_FILE(S["exper_plus"], exper_plus)
	READ_FILE(S["true_experience"], true_experience)
	READ_FILE(S["dexterity"], dexterity)
	READ_FILE(S["social"], social)
	READ_FILE(S["mentality"], mentality)
	READ_FILE(S["lockpicking"], lockpicking)
	READ_FILE(S["athletics"], athletics)
	READ_FILE(S["blood"], blood)
	READ_FILE(S["archetype"], archetype)
	READ_FILE(S["discipline1type"], discipline1type)
	discipline1type = sanitize_discipline(discipline1type, subtypesof(/datum/discipline))
	READ_FILE(S["discipline1level"], discipline1level)
	discipline1level = sanitize_integer(discipline1level, 1, 5, 1)

	READ_FILE(S["discipline2type"], discipline2type)
	discipline2type = sanitize_discipline(discipline2type, subtypesof(/datum/discipline))
	READ_FILE(S["discipline2level"], discipline2level)
	discipline2level = sanitize_integer(discipline2level, 1, 5, 1)

	READ_FILE(S["discipline3type"], discipline3type)
	discipline3type = sanitize_discipline(discipline3type, subtypesof(/datum/discipline))
	READ_FILE(S["discipline3level"], discipline3level)
	discipline3level = sanitize_integer(discipline3level, 1, 5, 1)

	READ_FILE(S["discipline4type"], discipline4type)
	discipline4type = sanitize_discipline(discipline4type, subtypesof(/datum/discipline))
	READ_FILE(S["discipline4level"], discipline4level)
	discipline4level = sanitize_integer(discipline4level, 1, 5, 1)
	READ_FILE(S["generation"], generation)
	READ_FILE(S["generation_bonus"], generation_bonus)
	READ_FILE(S["friend"], friend)
	READ_FILE(S["enemy"], enemy)
	READ_FILE(S["lover"], lover)
	
	READ_FILE(S["friend_text"], friend_text)
	friend_text = sanitize_text(friend_text)
	
	READ_FILE(S["enemy_text"], enemy_text)
	enemy_text = sanitize_text(enemy_text)
	
	READ_FILE(S["lover_text"], lover_text)
	lover_text = sanitize_text(lover_text)

	READ_FILE(S["body_model"], body_model)
	body_model = sanitize_integer(body_model, 1, 3, initial(body_model))
	
	READ_FILE(S["torpor_count"], torpor_count)
	torpor_count = sanitize_integer(torpor_count, 0, 6, initial(torpor_count))

	READ_FILE(S["total_age"], total_age)
	total_age = sanitize_integer(total_age, 18, 1120, initial(total_age))

	READ_FILE(S["uplink_loc"], uplink_spawn_loc)
	READ_FILE(S["jumpsuit_style"], jumpsuit_style)
	READ_FILE(S["playtime_reward_cloak"], playtime_reward_cloak)
	READ_FILE(S["phobia"], phobia)
	
	READ_FILE(S["randomise"],  randomise)
	randomise = SANITIZE_LIST(randomise)
	
	READ_FILE(S["feature_mcolor"], features["mcolor"])
	if(!features["mcolor"] || features["mcolor"] == "#000")
		features["mcolor"] = pick("FFFFFF","7F7F7F", "7FFF7F", "7F7FFF", "FF7F7F", "7FFFFF", "FF7FFF", "FFFF7F")

	READ_FILE(S["feature_ethcolor"], features["ethcolor"])
	if(!features["ethcolor"] || features["ethcolor"] == "#000")
		features["ethcolor"] = GLOB.color_list_ethereal[pick(GLOB.color_list_ethereal)]

	READ_FILE(S["feature_lizard_tail"], features["tail_lizard"])
	READ_FILE(S["feature_lizard_snout"], features["snout"])
	READ_FILE(S["feature_lizard_horns"], features["horns"])
	READ_FILE(S["feature_lizard_frills"], features["frills"])
	READ_FILE(S["feature_lizard_spines"], features["spines"])
	READ_FILE(S["feature_lizard_body_markings"], features["body_markings"])
	READ_FILE(S["feature_lizard_legs"], features["legs"])
	READ_FILE(S["feature_moth_wings"], features["moth_wings"])
	READ_FILE(S["feature_moth_antennae"], features["moth_antennae"])
	READ_FILE(S["feature_moth_markings"], features["moth_markings"])
	READ_FILE(S["feature_human_tail"], features["tail_human"])
	READ_FILE(S["feature_human_ears"], features["ears"])


	READ_FILE(S["dharma_type"], dharma_type)
	READ_FILE(S["dharma_level"], dharma_level)
	if(dharma_level <= 0)
		dharma_level = 1

	READ_FILE(S["po_type"], po_type)
	READ_FILE(S["po"], po)
	READ_FILE(S["hun"], hun)
	READ_FILE(S["yang"], yang)
	READ_FILE(S["yin"], yin)
	READ_FILE(S["chi_types"], chi_types)
	READ_FILE(S["chi_levels"], chi_levels)

	READ_FILE(S["preferred_ai_core_display"], preferred_ai_core_display)
	READ_FILE(S["prefered_security_department"], prefered_security_department)

	//Custom names
	for(var/custom_name_id in GLOB.preferences_custom_names)
		var/savefile_slot_name = custom_name_id + "_name" //TODO remove this
		READ_FILE(S[savefile_slot_name], custom_names[custom_name_id])
	
	for(var/custom_name_id in GLOB.preferences_custom_names)
		var/namedata = GLOB.preferences_custom_names[custom_name_id]
		custom_names[custom_name_id] = reject_bad_name(custom_names[custom_name_id],namedata["allow_numbers"])
		if(!custom_names[custom_name_id])
			custom_names[custom_name_id] = get_default_name(custom_name_id)

	//sanitization fuck-it-bucket
	enlightenment = sanitize_integer(enlightenment, 0, 1, initial(enlightenment))
	exper = sanitize_integer(exper, 0, 99999999, initial(exper))
	exper_plus = sanitize_integer(exper_plus, 0, 99999999, initial(exper_plus))
	true_experience = sanitize_integer(true_experience, 0, 99999999, initial(true_experience))
	dexterity = sanitize_integer(dexterity, 1, 10, initial(dexterity))
	social = sanitize_integer(social, 1, 10, initial(social))
	mentality = sanitize_integer(mentality, 1, 10, initial(mentality))
	lockpicking = sanitize_integer(lockpicking, 1, 10, initial(lockpicking))
	athletics = sanitize_integer(athletics, 1, 10, initial(athletics))
	blood = sanitize_integer(blood, 1, 10, initial(blood))
	discipline_types = sanitize_islist(discipline_types, list())
	discipline_levels = sanitize_islist(discipline_levels, list())
	dharma_level = sanitize_integer(dharma_level, 0, 6, initial(dharma_level))
	dharma_type = sanitize_inlist(dharma_type, subtypesof(/datum/dharma))
	po_type = sanitize_inlist(po_type, list("Rebel", "Legalist", "Demon", "Monkey", "Fool"))
	po = sanitize_integer(po, 1, 12, initial(po))
	hun = sanitize_integer(hun, 1, 12, initial(hun))
	yang = sanitize_integer(yang, 1, 12, initial(yang))
	yin = sanitize_integer(yin, 1, 12, initial(yin))
	chi_types = sanitize_islist(chi_types, list())
	chi_levels = sanitize_islist(chi_levels, list())
	friend = sanitize_integer(friend, 0, 1, initial(friend))
	enemy = sanitize_integer(enemy, 0, 1, initial(enemy))
	lover = sanitize_integer(lover, 0, 1, initial(lover))
	generation = sanitize_integer(generation, 3, 13, initial(generation))
	generation_bonus = sanitize_integer(generation_bonus, 0, 6, initial(generation_bonus))
	jumpsuit_style = sanitize_inlist(jumpsuit_style, GLOB.jumpsuitlist, initial(jumpsuit_style))
	uplink_spawn_loc = sanitize_inlist(uplink_spawn_loc, GLOB.uplink_spawn_loc_list, initial(uplink_spawn_loc))
	playtime_reward_cloak = sanitize_integer(playtime_reward_cloak)
	features["mcolor"] = sanitize_hexcolor(features["mcolor"], 3, 0)
	features["ethcolor"] = copytext_char(features["ethcolor"], 1, 7)
	features["tail_lizard"] = sanitize_inlist(features["tail_lizard"], GLOB.tails_list_lizard)
	features["tail_human"]  = sanitize_inlist(features["tail_human"], GLOB.tails_list_human, "None")
	features["snout"] = sanitize_inlist(features["snout"], GLOB.snouts_list)
	features["horns"]  = sanitize_inlist(features["horns"], GLOB.horns_list)
	features["ears"] = sanitize_inlist(features["ears"], GLOB.ears_list, "None")
	features["frills"]  = sanitize_inlist(features["frills"], GLOB.frills_list)
	features["spines"]  = sanitize_inlist(features["spines"], GLOB.spines_list)
	features["body_markings"]  = sanitize_inlist(features["body_markings"], GLOB.body_markings_list)
	features["feature_lizard_legs"] = sanitize_inlist(features["legs"], GLOB.legs_list, "Normal Legs")
	features["moth_wings"]  = sanitize_inlist(features["moth_wings"], GLOB.moth_wings_list, "Plain")
	features["moth_antennae"]  = sanitize_inlist(features["moth_antennae"], GLOB.moth_antennae_list, "Plain")
	features["moth_markings"]  = sanitize_inlist(features["moth_markings"], GLOB.moth_markings_list, "None")
	archetype  = sanitize_inlist(archetype, subtypesof(/datum/archetype))
	
	//repair some damage done by an exploit by resetting
	if ((true_experience > 1000) && !check_rights_for(parent, R_ADMIN))
		message_admins("[ADMIN_LOOKUPFLW(parent)] loaded a character slot with [true_experience] experience. The slot has been reset.")
		log_game("[key_name(parent)] loaded a character slot with [true_experience] experience. The slot has been reset.")
		to_chat(parent, "<span class='userdanger'>You tried to load a character slot with [true_experience] experience. It has been reset.</span>")
		reset_character()
*/
//===========GENERAL===========
	//Species
	var/species_id
	READ_FILE(S["species"], species_id)
	if(species_id)
		var/newtype = GLOB.species_list[species_id]
		if(newtype)
			pref_species = new newtype

	READ_FILE(S["info_known"], info_known)
	
	READ_FILE(S["gender"], gender)
	gender = sanitize_gender(gender)

	READ_FILE(S["real_name"], real_name)
	real_name = reject_bad_name(real_name)
	if(!real_name)
		real_name = random_unique_name(gender)

	READ_FILE(S["body_type"], body_type)
	body_type = sanitize_gender(body_type, FALSE, FALSE, gender)

	READ_FILE(S["age"], age)
	age = sanitize_integer(age, AGE_MIN, AGE_MAX, initial(age))
	
	//PROFILE
	READ_FILE(S["flavor_text"], flavor_text)
	flavor_text = sanitize_text(flavor_text)

	READ_FILE(S["ooc_notes"], ooc_notes)
	ooc_notes = sanitize_text(ooc_notes)
	
	READ_FILE(S["headshot_link"], headshot_link)
	if(!valid_headshot_link(null, headshot_link, TRUE))
		headshot_link = null
	
	//ICON FEATURES
	READ_FILE(S["hair_color"], hair_color)
	hair_color = sanitize_hexcolor(hair_color, 3, 0)
	READ_FILE(S["facial_hair_color"], facial_hair_color)
	facial_hair_color = sanitize_hexcolor(facial_hair_color, 3, 0)
	READ_FILE(S["hairstyle_name"], hairstyle)
	hairstyle = sanitize_inlist(hairstyle, GLOB.hairstyles_list)
	READ_FILE(S["facial_style_name"], facial_hairstyle)
	facial_hairstyle = sanitize_inlist(facial_hairstyle, GLOB.facial_hairstyles_list)

	READ_FILE(S["eye_color"], eye_color)
	eye_color = sanitize_hexcolor(eye_color, 3, 0)
	READ_FILE(S["skin_tone"], skin_tone)
	skin_tone = sanitize_hexcolor(convert_old_skintone(skin_tone), 3, 0)

	//UNDERCLOTHES
	READ_FILE(S["underwear_color"], underwear_color)
	underwear_color = sanitize_hexcolor(underwear_color, 3, 0)

	READ_FILE(S["underwear"], underwear)
	underwear = sanitize_inlist(underwear, GLOB.underwear_list)
	
	READ_FILE(S["undershirt"], undershirt)
	undershirt = sanitize_inlist(undershirt, GLOB.undershirt_list)

	READ_FILE(S["socks"], socks)
	socks = sanitize_inlist(socks, GLOB.socks_list)

	READ_FILE(S["backpack"], backpack)
	backpack = sanitize_inlist(backpack, GLOB.backpacklist, initial(backpack))

	//PERSISTANCE
	READ_FILE(S["persistent_scars"], persistent_scars)
	persistent_scars = sanitize_integer(persistent_scars)
	
	READ_FILE(S["reason_of_death"], reason_of_death)
	reason_of_death = sanitize_text(reason_of_death)

	//JOBS
	READ_FILE(S["joblessrole"], joblessrole)
	joblessrole	= sanitize_integer(joblessrole, 1, 3, initial(joblessrole))

	READ_FILE(S["job_preferences"], job_preferences)
	for(var/j in job_preferences)
		if(job_preferences[j] != JP_LOW && job_preferences[j] != JP_MEDIUM && job_preferences[j] != JP_HIGH)
			job_preferences -= j
	
	READ_FILE(S["alt_titles_preferences"], alt_titles_preferences)
	alt_titles_preferences = SANITIZE_LIST(alt_titles_preferences)
	if(SSjob)
		for(var/datum/job/job in sortList(SSjob.occupations, /proc/cmp_job_display_asc))
			if(alt_titles_preferences[job.title])
				if(!(alt_titles_preferences[job.title] in job.alt_titles))
					alt_titles_preferences.Remove(job.title)
	
	//QUIRKS
	READ_FILE(S["all_quirks"], all_quirks)
	all_quirks = SANITIZE_LIST(all_quirks)
	validate_quirks()


	//STATS
	READ_FILE(S["physique"], physique)
	physique = sanitize_integer(physique, 1, 5, 1)
	//-----------NEW ITEMS-----------
	READ_FILE(S["stamina"], stamina)
	stamina = sanitize_integer(stamina, 1, 5, 1)

	READ_FILE(S["charisma"], charisma)
	charisma = sanitize_integer(charisma, 1, 5, 1)

	READ_FILE(S["composure"], composure)
	composure = sanitize_integer(composure, 1, 5, 1)

	READ_FILE(S["wits"], wits)
	wits = sanitize_integer(wits, 1, 5, 1)

	READ_FILE(S["resolve"], resolve)
	resolve = sanitize_integer(resolve, 1, 5, 1)

//===========GHOUL/VAMPS===========
	var/clane_id
	READ_FILE(S["clan"], clane_id)
	if(clane_id)
		var/newtype = GLOB.clanes_list[clane_id]
		if(newtype)
			clane = new newtype

	READ_FILE(S["humanity"], humanity)
	humanity = sanitize_integer(humanity, 0, 10, initial(humanity))

	//Prevent Wighting upon joining a round
	if(humanity <= 0)
		humanity = 1

	READ_FILE(S["diablerist"], diablerist)
	diablerist = sanitize_integer(diablerist, 0, 1, initial(diablerist))

	READ_FILE(S["masquerade"], masquerade)
	masquerade = sanitize_integer(masquerade, 0, 5, initial(masquerade))

	READ_FILE(S["clan_accessory"], clane_accessory)	
	clane_accessory = sanitize_inlist(clane_accessory, clane.accessories, null)

	//Disciplines
	READ_FILE(S["discipline_types"], discipline_types)
	discipline_types = sanitize_islist(discipline_types, list())
	
	READ_FILE(S["discipline_levels"], discipline_levels)
	discipline_levels = sanitize_islist(discipline_levels, list())
	
	//-----------NEW ITEMS-----------
	READ_FILE(S["vamp_rank"], vamp_rank)
	vamp_rank = sanitize_integer(vamp_rank, VAMP_RANK_GHOUL, VAMP_RANK_ELDER, VAMP_RANK_GHOUL)

	READ_FILE(S["actual_age"], actual_age)
	actual_age = sanitize_integer(actual_age, age, 6000, age)

	var/regent_clan_id
	READ_FILE(S["regent_clan"], regent_clan_id)
	if(clane_id)
		var/newtype = GLOB.clanes_list[clane_id]
		if(newtype)
			regent_clan = new newtype
	
	var/vampire_faction_id
	READ_FILE(S["vamp_faction"], vampire_faction_id)
	if(vampire_faction_id)
		var/faction = GLOB.factions_list[clane_id]
		if(faction && istype(faction, /datum/vtr_faction/vamp_faction))
			vamp_faction = new faction()
		else
			vamp_faction = new /datum/vtr_faction/vamp_faction/unaligned()

//===========WEREWOLVES===========
	var/auspice_id
	READ_FILE(S["auspice"], auspice_id)
	if(auspice_id)
		var/newtype = GLOB.auspices_list[auspice_id]
		if(newtype)
			auspice = new newtype

	READ_FILE(S["auspice_level"], auspice_level)
	auspice_level = sanitize_integer(auspice_level, 1, 5, initial(auspice_level))

	READ_FILE(S["breed"], breed)
	breed = sanitize_inlist(breed, list("Homid", "Lupus", "Metis"))
	
	READ_FILE(S["tribe"], tribe)
	tribe = sanitize_inlist(tribe, list("Wendigo", "Glasswalkers", "Black Spiral Dancers"))
	
	READ_FILE(S["werewolf_color"], werewolf_color)
	werewolf_color = sanitize_inlist(werewolf_color, list("black", "gray", "red", "white", "ginger", "brown"))
	
	READ_FILE(S["werewolf_scar"], werewolf_scar)
	werewolf_scar = sanitize_integer(werewolf_scar, 0, 7, initial(werewolf_scar))

	READ_FILE(S["werewolf_hair"], werewolf_hair)
	werewolf_hair = sanitize_integer(werewolf_hair, 0, 4, initial(werewolf_hair))

	READ_FILE(S["werewolf_hair_color"], werewolf_hair_color)
	werewolf_hair_color = sanitize_ooccolor(werewolf_hair_color, 3, 0)

	READ_FILE(S["werewolf_eye_color"], werewolf_eye_color)
	werewolf_eye_color = sanitize_ooccolor(werewolf_eye_color, 3, 0)

	READ_FILE(S["werewolf_name"], werewolf_name)
	werewolf_name = reject_bad_name(werewolf_name)

	//try to fix any outdated data if necessary
	//preference updating will handle saving the updated data for us.
	if(needs_update >= 0)
		update_character(needs_update, S)		//needs_update == savefile_version if we need an update (positive integer)

	return TRUE
