/obj/structure/vamptree/palmtree
	name = "palm tree"
	desc = "Radical."
	icon = 'icons/vtr13/structure/trees.dmi'
	icon_state = "palm1"

/obj/structure/vamptree/palmtree/Initialize()
	. = ..()
	icon_state = "palm[rand(1, 2)]"
	//winter sprite changes deliberately not included

/obj/structure/vamptree/palmtree/burnshit()
	if(!burned)
		burned = TRUE
		icon_state = "dead"