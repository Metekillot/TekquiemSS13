/obj/item/implantpad
	name = "implant pad"
	desc = "Used to modify implants."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "implantpad-0"
	inhand_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	interaction_flags_click = FORBID_TELEKINESIS_REACH

	///The implant case currently inserted into the pad.
	var/obj/item/implantcase/inserted_case

/obj/item/implantpad/update_icon_state()
	icon_state = "implantpad-[!QDELETED(case)]"

/obj/item/implantpad/examine(mob/user)
	. = ..()
	if(Adjacent(user))
		. += "It [case ? "contains \a [case]" : "is currently empty"]."
		if(case)
			. += "<span class='info'>Alt-click to remove [case].</span>"
	else
		if(case)
			. += "<span class='warning'>There seems to be something inside it, but you can't quite tell what from here...</span>"

/obj/item/implantpad/handle_atom_del(atom/A)
	if(A == case)
		case = null
	update_icon()
	updateSelfDialog()
	. = ..()

/obj/item/implantpad/click_alt(mob/user)
	remove_implant(user)
	return CLICK_ACTION_SUCCESS

/obj/item/implantpad/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "ImplantPad", name)
		ui.open()

/obj/item/implantpad/ui_static_data(mob/user)
	var/list/data = list()
	data["has_case"] = !!inserted_case
	if(!inserted_case)
		return data
	data["has_implant"] = !!inserted_case.imp
	if(inserted_case.imp)
		data["case_information"] = inserted_case.imp.get_data()
	return data

/obj/item/implantpad/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	var/mob/user = usr
	if(action == "eject_implant")
		remove_implant(user)
		return

	user.put_in_hands(case)

	add_fingerprint(user)
	case.add_fingerprint(user)
	case = null

	updateSelfDialog()
	update_icon()

/obj/item/implantpad/attackby(obj/item/implantcase/C, mob/user, params)
	if(istype(C, /obj/item/implantcase) && !case)
		if(!user.transferItemToLoc(C, src))
			return
		case = C
		updateSelfDialog()
		update_icon()
	else
		return ..()

/obj/item/implantpad/ui_interact(mob/user)
	if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		user.unset_machine(src)
		user << browse(null, "window=implantpad")
		return

	user.set_machine(src)
	var/dat = "<B>Implant Mini-Computer:</B><HR>"
	if(case)
		if(case.imp)
			if(istype(case.imp, /obj/item/implant))
				dat += case.imp.get_data()
		else
			dat += "The implant casing is empty."
	else
		dat += "Please insert an implant casing!"
	user << browse(HTML_SKELETON(dat), "window=implantpad")
	onclose(user, "implantpad")
