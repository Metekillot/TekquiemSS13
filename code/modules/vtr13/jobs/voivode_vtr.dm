/datum/job/vamp/voivode_vtr
	title = "Voivode"
	department_head = list("Seneschal")
	faction = "Vampire"
	total_positions = 1
	spawn_positions = 1
	supervisors = "Vlad Dracula"
	selection_color = "#953d2d"

	outfit = /datum/outfit/job/voivode_vtr

	access = list(ACCESS_HYDROPONICS, ACCESS_BAR, ACCESS_KITCHEN, ACCESS_MORGUE, ACCESS_WEAPONS, ACCESS_MINERAL_STOREROOM, ACCESS_THEATRE)
	minimal_access = list(ACCESS_BAR, ACCESS_MINERAL_STOREROOM, ACCESS_THEATRE)
	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_SRV
	display_order = JOB_DISPLAY_ORDER_VOIVODE
	exp_type_department = EXP_TYPE_TZIMISCE

	allowed_species = list("Vampire")
	allowed_bloodlines = list("Ventrue", "Daeva", "Mekhet", "Nosferatu", "Gangrel")
	minimal_generation = 7

	v_duty = "uhh, elge, say something"
	experience_addition = 20
	minimal_masquerade = 2
	my_contact_is_important = TRUE
	known_contacts = list("Seneschal", "Keeper of Elysium", "Sheriff")



/datum/outfit/job/voivode_vtr
	name = "Voivode"
	jobtype = /datum/job/vamp/voivode
	id = /obj/item/card/id/voivode_vtr
	//glasses = /obj/item/clothing/glasses/vampire/yellow
	uniform = /obj/item/clothing/under/vampire/voivode
	suit = /obj/item/clothing/suit/vampire/trench/voivode
	shoes = /obj/item/clothing/shoes/vampire/jackboots
	belt = /obj/item/storage/belt/vampire/sheathe/longsword
	l_pocket = /obj/item/vamp/phone
	//r_pocket =
	backpack_contents = list(/obj/item/melee/vampirearms/eguitar=1, /obj/item/passport=1, /obj/item/flashlight=1, /obj/item/vamp/creditcard/elder=1)

/obj/effect/landmark/start/voivode_vtr
	name = "Voivode"
