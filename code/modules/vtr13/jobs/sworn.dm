/datum/job/vamp/sworn
	title = "Sworn"
	department_head = list("Voivode")
	faction = "Vampire"
	total_positions = 10
	spawn_positions = 10
	supervisors = "the Voivode"
	selection_color = "#df1ca4"

	outfit = /datum/outfit/job/sworn

	access = list(ACCESS_HYDROPONICS, ACCESS_BAR, ACCESS_KITCHEN, ACCESS_MORGUE, ACCESS_WEAPONS, ACCESS_MINERAL_STOREROOM, ACCESS_THEATRE)
	minimal_access = list(ACCESS_BAR, ACCESS_MINERAL_STOREROOM, ACCESS_THEATRE)
	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_SRV
	display_order = JOB_DISPLAY_ORDER_GIOVANNI
	exp_type_department = EXP_TYPE_GIOVANNI

	allowed_species = list("Vampire", "Ghoul")
	allowed_bloodlines = list("Ventrue", "Daeva", "Mekhet", "Nosferatu", "Gangrel")
	known_contacts = list("Hierophant")
	v_duty = "Uhh, research what to put here, elge. i am tired"
	minimal_masquerade = 0
	experience_addition = 10


/datum/outfit/job/sworn
	name = "Sworn"
	jobtype = /datum/job/vamp/sworn
	id = /obj/item/cockclock
	glasses = /obj/item/clothing/glasses/vampire/sun
	uniform = /obj/item/clothing/under/vampire/suit
	suit = /obj/item/clothing/suit/vampire/trench
	shoes = /obj/item/clothing/shoes/vampire
	l_pocket = /obj/item/vamp/phone/sworn
	r_pocket = /obj/item/vamp/keys/sworn
	backpack_contents = list(/obj/item/passport=1, /obj/item/flashlight=1, /obj/item/vamp/creditcard=1)

/datum/outfit/job/sworn/pre_equip(mob/living/carbon/human/H)
	..()
	if(H.clane)
		if(H.gender == MALE)
			if(H.clane.male_clothes)
				uniform = H.clane.male_clothes
		else
			if(H.clane.female_clothes)
				uniform = H.clane.female_clothes

/obj/effect/landmark/start/sworn
	name = "Sworn"
