/datum/dominate_act/compel/break_it_down
	phrase = "Break it down!"
	activate_verb = "doubt yourself"
	linked_trait = TRAIT_COMPEL_THINK_TWICE

/datum/dominate_act/compel/break_it_down/apply(mob/living/target)
	..()
	target.set_resting(FALSE, TRUE, TRUE)
	dancefirst(target)

/datum/dominate_act/compel/break_it_down/remove(mob/living/target)
	. = ..()
	if(!.)
		return
	target.remove_movespeed_modifier(/datum/movespeed_modifier/dominate)