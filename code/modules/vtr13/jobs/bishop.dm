
/datum/job/vamp/vtr/bishop
	title = "Bishop"
	department_head = list("God")
	faction = "Vampire"
	total_positions = 1
	spawn_positions = 1
	supervisors = "God"
	selection_color = "#fff700"

	outfit = /datum/outfit/job/bishop

	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_SRV

	exp_type = EXP_TYPE_CREW
	exp_type_department = EXP_TYPE_LANCEA

	display_order = JOB_DISPLAY_ORDER_BISHOP

	allowed_species = list("Vampire")
	allowed_bloodlines = list("Ventrue", "Daeva", "Mekhet", "Nosferatu", "Gangrel")
	
	minimal_generation = 13

	duty = "Be the shepherd of the jerks, or something more poetic elge needs to come up with"
	v_duty = "Something, something lance figure it out elge."
	minimal_masquerade = 0
	known_contacts = list("Seneschal", "Keeper of Elysium", "Sheriff")
	my_contact_is_important = TRUE

/datum/outfit/job/bishop
	name = "Bishop"
	jobtype = /datum/job/vamp/vtr/bishop

	uniform = /obj/item/clothing/under/vampire/graveyard
	shoes = /obj/item/clothing/shoes/vampire/jackboots
	id = /obj/item/card/id/hunter
	l_pocket = /obj/item/vamp/phone/bishop
	r_pocket = /obj/item/flashlight
	l_hand = /obj/item/vamp/keys/bishop
	back = /obj/item/storage/backpack/satchel
	backpack_contents = list(/obj/item/passport=1, /obj/item/vamp/creditcard=1)

/datum/outfit/job/bishop/pre_equip(mob/living/carbon/human/H)
	..()
	H.mind.holy_role = HOLY_ROLE_PRIEST
	H.resistant_to_disciplines = TRUE
	to_chat(H, "<span class='alertsyndie'>Your faith in God is made of iron. None could shake it, and even in the darkest moments it holds you up.</span>")

/obj/effect/landmark/start/bishop
	name = "Bishop"
	icon_state = "Clerk"