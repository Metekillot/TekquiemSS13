/datum/movespeed_modifier/vtr/celerity2
	multiplicative_slowdown = -0.75

/datum/discipline_power/vtr/celerity/two
	name = "Celerity 2"
	desc = "Significantly improves your speed and reaction time."

	check_flags = DISC_CHECK_LYING | DISC_CHECK_IMMOBILE

	toggled = TRUE
	duration_length = 2 TURNS

	grouped_powers = list(
		/datum/discipline_power/vtr/celerity/one,
		/datum/discipline_power/vtr/celerity/three,
		/datum/discipline_power/vtr/celerity/four,
		/datum/discipline_power/vtr/celerity/five
	)

/datum/discipline_power/vtr/celerity/two/activate()
	. = ..()
	to_chat(owner, span_notice("You feel yourself become faster."))
	ADD_TRAIT(owner, TRAIT_QUICK_JUMP, CELERITY_TRAIT)
	owner.add_movespeed_modifier(/datum/movespeed_modifier/vtr/celerity2)

/datum/discipline_power/vtr/celerity/two/deactivate()
	. = ..()
	to_chat(owner, span_notice("Your reflexes return to normal."))
	REMOVE_TRAIT(owner, TRAIT_QUICK_JUMP, CELERITY_TRAIT)
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/vtr/celerity2)