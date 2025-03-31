/datum/movespeed_modifier/vtr_dominate
	multiplicative_slowdown = 5

/datum/dominate_act/compel/think_twice
	phrase = "Think Twice!"
	activate_verb = "doubt yourself"
	linked_trait = TRAIT_COMPEL_THINK_TWICE

/datum/dominate_act/compel/think_twice/apply(mob/living/target)
	..()
	target.add_movespeed_modifier(/datum/movespeed_modifier/dominate)

/datum/dominate_act/compel/think_twice/remove(mob/living/target)
	. = ..()
	if(!.)
		return
	target.remove_movespeed_modifier(/datum/movespeed_modifier/dominate)