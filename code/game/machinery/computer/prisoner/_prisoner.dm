/obj/machinery/computer/prisoner
	interaction_flags_machine = INTERACT_MACHINE_ALLOW_SILICON|INTERACT_MACHINE_REQUIRES_LITERACY
	/// ID card currently inserted into the computer.
	VAR_FINAL/obj/item/card/id/advanced/prisoner/contained_id
	interaction_flags_click = ALLOW_SILICON_REACH

/obj/machinery/computer/prisoner/on_deconstruction(disassembled)
	contained_id?.forceMove(drop_location())

/obj/machinery/computer/prisoner/Destroy()
	if(contained_id)
		contained_id.forceMove(get_turf(src))
	return ..()
	

/obj/machinery/computer/prisoner/examine(mob/user)
	. = ..()
	if(contained_id)
		. += "<span class='notice'><b>Alt-click</b> to eject the ID card.</span>"



/obj/machinery/computer/prisoner/click_alt(mob/user)
	id_eject(user)
	return CLICK_ACTION_SUCCESS

/obj/machinery/computer/prisoner/proc/id_insert(mob/user, obj/item/card/id/prisoner/P)
	if(istype(P))
		if(contained_id)
			to_chat(user, "<span class='warning'>There's already an ID card in the console!</span>")
			return
		if(!user.transferItemToLoc(P, src))
			return
		contained_id = P
		user.visible_message("<span class='notice'>[user] inserts an ID card into the console.</span>", \
							"<span class='notice'>You insert the ID card into the console.</span>")
		playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, FALSE)
		updateUsrDialog()

/obj/machinery/computer/prisoner/proc/id_eject(mob/user)
	if(!contained_id)
		to_chat(user, "<span class='warning'>There's no ID card in the console!</span>")
		return
	else
		contained_id.forceMove(drop_location())
		if(!issilicon(user) && Adjacent(user))
			user.put_in_hands(contained_id)
		contained_id = null
		user.visible_message("<span class='notice'>[user] gets an ID card from the console.</span>", \
							"<span class='notice'>You get the ID card from the console.</span>")
		playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, FALSE)
		updateUsrDialog()

/obj/machinery/computer/prisoner/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/card/id/prisoner))
		id_insert(user, I)
	else
		return ..()
