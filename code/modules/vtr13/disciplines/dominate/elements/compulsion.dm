/datum/element/compulsion
	var/list/mob_deactivate_signals = list(
		COMSIG_MOB_ATTACKED_HAND,
		COMSIG_MOB_ATTACKED_BY_MELEE,
		COMSIG_LIVING_DEATH
	)

/datum/element/compulsion/Attach(datum/target, mob/living/aggressor, datum/dominate_act/act, custom_signals = null)
	..()
	if(!act || !istype(act, /datum/dominate_act))
		return COMPONENT_INCOMPATIBLE
	if(!isliving(target))
		return COMPONENT_INCOMPATIBLE
	act.apply(target, aggressor, src)
	RegisterSignal(target, mob_deactivate_signals, PROC_REF(Detach))

/datum/element/compulsion/Detach(datum/source, force)
	. = ..()
	UnregisterSignal(source, mob_deactivate_signals)