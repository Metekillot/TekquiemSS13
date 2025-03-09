/datum/vampireclane/vtr/gangrel
	name = "Gangrel"
	desc = "The furry vampires. No longer explicitly furries, but we support them. Elgeon might want to write a better description for them tho"
	curse = "Start with lower humanity."
	clane_disciplines = list(
		/datum/discipline/vtr/animalism,
		/datum/discipline/fortitude,
		/datum/discipline/protean
	)
	start_humanity = 6
	male_clothes = /obj/item/clothing/under/vampire/gangrel
	female_clothes = /obj/item/clothing/under/vampire/gangrel/female
	current_accessory = "none"
	accessories = list("beast_legs", "beast_tail", "beast_tail_and_legs", "none")
	accessories_layers = list("beast_legs" = UNICORN_LAYER, "beast_tail" = UNICORN_LAYER, "beast_tail_and_legs" = UNICORN_LAYER, "none" = UNICORN_LAYER)
