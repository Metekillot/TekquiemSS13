/datum/vampireclane/vtr/nosferatu
	name = "Nosferatu"
	desc = "The Nosferatu wear their curse on the outside. Elgeon wears her curse on the inside."
	curse = "Masquerade-violating appearance."
	alt_sprite = "nosferatu"
	clane_disciplines = list(
		/datum/discipline/animalism,
		/datum/discipline/potence,
		/datum/discipline/obfuscate
	)
	violating_appearance = TRUE
	male_clothes = /obj/item/clothing/under/vampire/nosferatu
	female_clothes = /obj/item/clothing/under/vampire/nosferatu/female
	accessories = list("nosferatu_ears")
	accessories_layers = list("nosferatu_ears" = UPPER_EARS_LAYER)
	current_accessory = "nosferatu_ears"
	clan_keys = /obj/item/vamp/keys/nosferatu

/datum/vampireclane/vtr/nosferatu/on_gain(mob/living/carbon/human/H)
	..()
	var/obj/item/organ/eyes/night_vision/NV = new()
	NV.Insert(H, TRUE, FALSE)
	H.ventcrawler = VENTCRAWLER_ALWAYS
