/datum/dominate_act/compel/be_quiet
	phrase = "Be Quiet!"
	activate_verb = "silence yourself"
	linked_trait = TRAIT_COMMAND_BE_QUIET
	duration = 1 MINUTES

/datum/dominate_act/compel/be_quiet/apply(mob/living/carbon/target)
	..()
	ADD_TRAIT(target, TRAIT_MUTE, DOMINATE_ACT_TRAIT)

/datum/dominate_act/compel/be_quiet/remove(mob/living/target)
	. = ..()
	if(!.)
		return
	REMOVE_TRAIT(target, TRAIT_MUTE, DOMINATE_ACT_TRAIT)