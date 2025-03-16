/mob/living/carbon/human/jump(atom/target)
	if(HAS_TRAIT(src, TRAIT_QUICK_JUMP) || do_after(src, 20 - (get_total_athletics()*2), src))
		..()
	return