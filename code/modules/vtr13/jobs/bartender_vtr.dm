/datum/job/vamp/vtr/bartender_vtr
	title = "Bartender"
	department_head = list("Seneschal")
	faction = "Vampire"
	total_positions = 4
	spawn_positions = 4
	supervisors = " the Seneschal"
	selection_color = "#00ffff"

	outfit = /datum/outfit/job/keeper

	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_SRV

	exp_type_department = EXP_TYPE_INVICTUS

	display_order = JOB_DISPLAY_ORDER_BARTENDER_VTR

	allowed_species = list("Vampire", "Ghoul", "Human")
	allowed_bloodlines = list("Ventrue", "Daeva", "Mekhet", "Nosferatu", "Gangrel")
	minimal_generation = 7	//Uncomment when players get exp enough

	v_duty = "An Elysuim is an important location in kindred society. Tonight, you're pouring drinks in one."
	duty = "You are working in a VERY NORMAL NIGHT CLUB. There is VIP section upstairs - you are not allowed up there. Elge might be able to put this desc better"
	experience_addition = 20
	minimal_masquerade = 5
	my_contact_is_important = TRUE
	known_contacts = list("Ventrue", "Daeva", "Mekhet", "Nosferatu", "Gangrel")

/datum/outfit/job/bartender_vtr
	name = "Bartender"
	jobtype = /datum/job/vamp/vtr/keeper

	id = /obj/item/card/id/bartender_vtr
	uniform = /obj/item/clothing/under/vampire/emo
	shoes = /obj/item/clothing/shoes/vampire
	l_pocket = /obj/item/vamp/phone/bartender_vtr
	r_pocket = /obj/item/cockclock
	backpack_contents = list(/obj/item/vamp/keys/bartender_vtr=1, /obj/item/passport=1, /obj/item/flashlight=1, /obj/item/vamp/creditcard=1)

/datum/outfit/job/bartender_vtr/pre_equip(mob/living/carbon/human/H)
	..()

/obj/effect/landmark/start/bartender
	name = "Bartender"
