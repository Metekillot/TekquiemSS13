/datum/movespeed_modifier/dance
	multiplicative_slowdown = 5

/datum/dominate_act/compel/think_twice
	phrase = "Break it down!"
	activate_verb = "doubt yourself"
	linked_trait = TRAIT_COMPEL_THINK_TWICE

/datum/dominate_act/compel/think_twice/apply(mob/living/target)
	..()
	target.set_resting(FALSE, TRUE, TRUE)
	dancefirst(target)

/datum/dominate_act/compel/think_twice/remove(mob/living/target)
	. = ..()
	if(!.)
		return
	target.remove_movespeed_modifier(/datum/movespeed_modifier/dominate)