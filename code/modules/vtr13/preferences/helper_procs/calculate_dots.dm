/datum/preferences/proc/calculate_dots()
	calculate_character_dots()
	calculate_discipline_dots()


/datum/preferences/proc/calculate_character_dots()
	character_dots = 0
	switch(vamp_rank)
		if(VAMP_RANK_GHOUL)
			character_dots = CHARACTER_DOTS_GHOUL
		if(VAMP_RANK_FLEDGLING)
			character_dots = CHARACTER_DOTS_FLEDGLING
		if(VAMP_RANK_HALF_DAMNED)
			character_dots = CHARACTER_DOTS_HALF_DAMNED
		if(VAMP_RANK_NEONATE)
			character_dots = CHARACTER_DOTS_NEONATE
		if(VAMP_RANK_ANCILLAE)
			character_dots = CHARACTER_DOTS_ANCILLAE
		if(VAMP_RANK_ELDER)
			character_dots = CHARACTER_DOTS_ELDER
		else
			character_dots = CHARACTER_DOTS_DEFAULT
	
	character_dots -= clamp(physique-1, 5, 0)
	character_dots -= clamp(stamina-1, 5, 0)
	character_dots -= clamp(charisma-1, 5, 0)
	character_dots -= clamp(composure-1, 5, 0)
	character_dots -= clamp(wits-1, 5, 0)
	character_dots -= clamp(resolve-1, 5, 0)
	character_dots -= max(auspice_level - 1, 0)
	if(character_dots < 0)
		CRASH("Error - More character dots have been taken than there are dots to have!")


/datum/preferences/proc/calculate_discipline_dots()
	discipline_dots = 0
	switch(vamp_rank)
		if(VAMP_RANK_GHOUL)
			discipline_dots = DISCIPLINE_DOTS_GHOUL
		if(VAMP_RANK_HALF_DAMNED)
			discipline_dots = DISCIPLINE_DOTS_HALF_DAMNED
		if(VAMP_RANK_FLEDGLING)
			discipline_dots = DISCIPLINE_DOTS_FLEDGLING
		if(VAMP_RANK_NEONATE)
			discipline_dots = DISCIPLINE_DOTS_NEONATE
		if(VAMP_RANK_ANCILLAE)
			discipline_dots = DISCIPLINE_DOTS_ANCILLAE
		if(VAMP_RANK_ELDER)
			discipline_dots = DISCIPLINE_DOTS_ELDER
		else
			discipline_dots = DISCIPLINE_DOTS_DEFAULT
	for(var/discipline_level in discipline_levels)
		discipline_dots -= discipline_level
	
	if(discipline_dots < 0)
		CRASH("Error - More discipline dots have been taken than there are dots to have!")