/datum/preferences/proc/reset_character()
//===========CHOPPING BLOCK===========
	/*
	slotlocked = 0
	torpor_count = 0
	generation_bonus = 0
	dexterity = 1
	mentality = 1
	social = 1
	blood = 1
	lockpicking = 0
	athletics = 0
	generation = initial(generation)
	dharma_level = initial(dharma_level)
	hun = initial(hun)
	po = initial(po)
	yin = initial(yin)
	yang = initial(yang)
	chi_types = list()
	chi_levels = list()
	archetype = pick(subtypesof(/datum/archetype))
	var/datum/archetype/A = new archetype()
	physique = A.start_physique
	dexterity = A.start_dexterity
	social = A.start_social
	mentality = A.start_mentality
	blood = A.start_blood
	lockpicking = A.start_lockpicking
	athletics = A.start_athletics
	enlightenment = clane.enlightenment
	body_model = rand(1, 3)
	true_experience = 50
	*/
//===========GENERAL===========
	real_name = random_unique_name(gender)
	ooc_notes = null
	flavor_text = null
	headshot_link = null // TFN EDIT
	info_known = INFO_KNOWN_UNKNOWN
	physique = 1
	stamina = 1
	charisma = 1
	composure = 1
	wits = 1
	resolve = 1

	qdel(clane)
	clane = new /datum/vampireclane/vtr/daeva()
	humanity = clane.start_humanity
	diablerist = 0
	masquerade = initial(masquerade)
	for (var/i in 1 to clane.clane_disciplines.len)
		discipline_types += clane.clane_disciplines[i]
		discipline_levels += 1

	random_species()
	random_character()
	save_character()