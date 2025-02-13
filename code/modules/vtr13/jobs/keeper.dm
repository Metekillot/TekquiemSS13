/datum/job/vamp/keeper
	title = "Keeper of Elysium"
	department_head = list("Seneschal")
	faction = "Vampire"
	total_positions = 1
	spawn_positions = 1
	supervisors = " the Seneschal"
	selection_color = "#006eff"

	outfit = /datum/outfit/job/keeper

	access = list(ACCESS_HYDROPONICS, ACCESS_BAR, ACCESS_KITCHEN, ACCESS_MORGUE, ACCESS_WEAPONS, ACCESS_MINERAL_STOREROOM, ACCESS_THEATRE)
	minimal_access = list(ACCESS_BAR, ACCESS_MINERAL_STOREROOM, ACCESS_THEATRE)
	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_SRV
	display_order = JOB_DISPLAY_ORDER_VENTRUE
	exp_type_department = EXP_TYPE_COUNCIL

	allowed_species = list("Vampire")
	allowed_bloodlines = list("Ventrue", "Daeva", "Mekhet", "Nosferatu", "Gangrel")
	minimal_generation = 7	//Uncomment when players get exp enough

	v_duty = "An Elysuim is an important location in kindred society. Tonight, you will rule yours like the Devil rules Hell. Keep the peace in this den of secrets, no matter the cost. While in your Elysium, only the Seneschal and the Prince have authority over you."
	experience_addition = 20
	minimal_masquerade = 5
	my_contact_is_important = TRUE
	known_contacts = list("Ventrue", "Daeva", "Mekhet", "Nosferatu", "Gangrel")

/datum/outfit/job/keeper
	name = "Keeper of Elysium"
	jobtype = /datum/job/vamp/keeper

	id = /obj/item/card/id/keeper
	glasses = /obj/item/clothing/glasses/vampire/sun
	uniform = /obj/item/clothing/under/vampire/suit
	suit = /obj/item/clothing/suit/vampire/trench
	shoes = /obj/item/clothing/shoes/vampire
	l_pocket = /obj/item/vamp/phone/keeper
	r_pocket = /obj/item/cockclock
	backpack_contents = list(/obj/item/vamp/keys/keeper=1, /obj/item/passport=1, /obj/item/flashlight=1, /obj/item/vamp/creditcard/elder=1, /obj/item/card/id/whip, /obj/item/card/id/steward, /obj/item/card/id/myrmidon)

/datum/outfit/job/keeper/pre_equip(mob/living/carbon/human/H)
	..()
