/datum/job/vamp/vtr/representative
	title = "Carthian Representative"
	department_head = list("The People")
	faction = "Vampire"
	total_positions = 1
	spawn_positions = 1
	supervisors = "Democracy - and the Seneschal (for now)."
	selection_color = "#85251d"
	outfit = /datum/outfit/job/representative

	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_CAR

	exp_type = EXP_TYPE_CREW
	exp_type_department = EXP_TYPE_CARTHIAN

	display_order = JOB_DISPLAY_ORDER_REPRESENTATIVE
	bounty_types = CIV_JOB_RANDOM

//	minimal_generation = 12	//Uncomment when players get exp enough

	my_contact_is_important = TRUE

	allowed_bloodlines = list("True Brujah", "Brujah", "Nosferatu", "Gangrel", "Toreador", "Malkavian", "Banu Haqim", "Tzimisce", "Caitiff", "Ventrue", "Ministry", "Kiasyd", "Cappadocian")

	v_duty = "Carthians are great, vote now (for elge to write something better)"
	minimal_masquerade = 3
	allowed_species = list("Vampire")
	allowed_bloodlines = list("Ventrue", "Daeva", "Mekhet", "Nosferatu", "Gangrel")
	experience_addition = 20
	known_contacts = list("Seneschal", "Keeper of Elysium", "Sheriff")

/datum/outfit/job/representative
	name = "Carthian Representative"
	jobtype = /datum/job/vamp/vtr/representative

	id = /obj/item/card/id/representative
	uniform = /obj/item/clothing/under/vampire/suit
	shoes = /obj/item/clothing/shoes/vampire/brown
	glasses = /obj/item/clothing/glasses/vampire/sun
	l_pocket = /obj/item/vamp/phone/representative
	r_pocket = /obj/item/vamp/keys/representative
	backpack_contents = list(/obj/item/passport=1, /obj/item/cockclock=1, /obj/item/flashlight=1, /obj/item/vamp/creditcard/rich=1)

/datum/outfit/job/representative/pre_equip(mob/living/carbon/human/H)
	..()

/obj/effect/landmark/start/representative
	name = "Carthian Representative"
	icon_state = "Supply Technician"
