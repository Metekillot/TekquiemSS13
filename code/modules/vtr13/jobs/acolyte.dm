/datum/job/vamp/acolyte
	title = "Acolyte"
	department_head = list("Hierophant")
	faction = "Vampire"
	total_positions = 20
	spawn_positions = 20
	supervisors = "your own beliefs"
	selection_color = "#ab2508"

	outfit = /datum/outfit/job/acolyte

	access = list(ACCESS_LIBRARY, ACCESS_AUX_BASE, ACCESS_MINING_STATION)
	minimal_access = list(ACCESS_LIBRARY, ACCESS_AUX_BASE, ACCESS_MINING_STATION)
	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_SRV
	exp_type_department = EXP_TYPE_TREMERE

	display_order = JOB_DISPLAY_ORDER_ARCHIVIST

	v_duty = "feed bodies to the cursed queen lillith, elge think up more things for them to do"
	minimal_masquerade = 3
	allowed_species = list("Vampire", "Ghoul")
	allowed_bloodlines = list("Ventrue", "Daeva", "Mekhet", "Nosferatu", "Gangrel")
	known_contacts = list("Hierophant")
	experience_addition = 15

/datum/outfit/job/acolyte
	name = "Acolyte"
	jobtype = /datum/job/vamp/acolyte

	id = /obj/item/card/id/acolyte
	glasses = /obj/item/clothing/glasses/vampire/perception
	shoes = /obj/item/clothing/shoes/vampire
	gloves = /obj/item/clothing/gloves/vampire/latex
	uniform = /obj/item/clothing/under/vampire/archivist
	r_pocket = /obj/item/vamp/keys/acolyte
	l_pocket = /obj/item/vamp/phone/acolyte
	backpack_contents = list(/obj/item/passport=1, /obj/item/cockclock=1, /obj/item/flashlight=1, /obj/item/arcane_tome=1, /obj/item/vamp/creditcard=1, /obj/item/melee/vampirearms/katana/kosa=1)

/datum/outfit/job/acolyte/pre_equip(mob/living/carbon/human/H)
	..()
	if(H.clane)
		if(H.gender == MALE)
			if(H.clane.male_clothes)
				uniform = H.clane.male_clothes
		else
			if(H.clane.female_clothes)
				uniform = H.clane.female_clothes

/obj/effect/landmark/start/acolyte
	name = "Acolyte"
	icon_state = "Archivist"
