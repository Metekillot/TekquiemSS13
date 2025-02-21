//Crude tools for converting skintone saves, hopefully I can destroy it later
/proc/convert_old_skintone(skin_tone)
	. = 0
	switch(skin_tone)
		if("caucasian1")
			. = CAUCASIAN_1
		if("caucasian2")
			. = CAUCASIAN_2
		if("caucasian3")
			. = CAUCASIAN_3
		if("latino")
			. = LATINO
		if("mediterranean")
			. = MEDITERRANEAN
		if("asian1")
			. = ASIAN_1
		if("asian2")
			. = ASIAN_2
		if("arab")
			. = ARAB
		if("indian")
			. = INDIAN
		if("african1")
			. = AFRICAN_1
		if("african2")
			. = AFRICAN_2
		if("albino")
			. = ALBINO
		if("orange")
			. = ORANGE
		if("vamp1")
			. = VAMP_1
		if("vamp2")
			. = VAMP_2
		if("vamp3")
			. = VAMP_3
		if("vamp4")
			. = VAMP_4
		if("vamp5")
			. = VAMP_5
		if("vamp6")
			. = VAMP_6
		if("vamp7")
			. = VAMP_7
		if("vamp8")
			. = VAMP_8
		if("vamp9")
			. = VAMP_9
		if("vamp10")
			. = VAMP_10
		if("vamp11")
			. = VAMP_11
		else
			. = skin_tone