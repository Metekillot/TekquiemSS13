/datum/job/vamp/hound_vtr
	title = "Hound"
	auto_deadmin_role_flags = DEADMIN_POSITION_SECURITY
	department_head = list("Seneschal")
	faction = "Vampire"
	total_positions = 7
	spawn_positions = 7
	supervisors = "the Sheriff"
	selection_color = "#bd3327"
	minimal_player_age = 7
	exp_requirements = 300
	exp_type = EXP_TYPE_CREW

	outfit = /datum/outfit/job/hound_vtr

	access = list(ACCESS_MAINT_TUNNELS, ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_COURT, ACCESS_MAINT_TUNNELS, ACCESS_MECH_SECURITY, ACCESS_MORGUE, ACCESS_WEAPONS, ACCESS_FORENSICS_LOCKERS, ACCESS_MINERAL_STOREROOM)
	minimal_access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_COURT, ACCESS_WEAPONS, ACCESS_MECH_SECURITY, ACCESS_MINERAL_STOREROOM) // See /datum/job/officer/get_access()
	paycheck = PAYCHECK_HARD
	paycheck_department = ACCOUNT_SEC

	mind_traits = list(TRAIT_DONUT_LOVER)
	liver_traits = list(TRAIT_LAW_ENFORCEMENT_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_HOUND
	bounty_types = CIV_JOB_SEC
	known_contacts = list("Prince", "Keeper of Elysium", "Sheriff")

	v_duty = "You got that dawg in you, Elge fixx pls"
	minimal_masquerade = 4
	experience_addition = 10
	allowed_bloodlines = list("Ventrue", "Daeva", "Mekhet", "Nosferatu", "Gangrel")
	

/datum/outfit/job/hound_vtr
	name = "Hound"
	jobtype = /datum/job/vamp/hound_vtr

	ears = /obj/item/p25radio
	id = /obj/item/card/id/invictus
	uniform = /obj/item/clothing/under/vampire/hound
	gloves = /obj/item/clothing/gloves/vampire/work
	suit = /obj/item/clothing/suit/vampire/trench
	shoes = /obj/item/clothing/shoes/vampire
	r_pocket = /obj/item/vamp/keys/invictus
	l_pocket = /obj/item/vamp/phone/invictus
	backpack_contents = list(/obj/item/passport=1, /obj/item/cockclock=1, /obj/item/vampire_stake=3, /obj/item/flashlight=1, /obj/item/masquerade_contract=1, /obj/item/vamp/keys/hack=1, /obj/item/vamp/creditcard=1)

	backpack = /obj/item/storage/backpack
	satchel = /obj/item/storage/backpack/satchel
	duffelbag = /obj/item/storage/backpack/duffelbag


/datum/outfit/job/hound/pre_equip(mob/living/carbon/human/H)
	..()

/obj/effect/landmark/start/hound_vtr
	name = "Hound"
	icon_state = "Hound"
