/**
 * If client have R_ADMIN flag, opens an admin fax panel.
 */
/client/proc/fax_panel()
	set category = "Admin.Events"
	set name = "Fax Panel"

	if(!check_rights(R_ADMIN))
		return

	var/datum/fax_panel_interface/ui = new(usr)
	ui.ui_interact(usr)

/// Admin Fax Panel. Tool for sending fax messages faster.
/datum/fax_panel_interface
	/// All faxes in from machinery list()
	var/available_faxes = list()
	/// List with available stamps
	var/stamp_list = list()

	/// Paper which admin edit and send.
	var/obj/item/paper/fax_paper = new /obj/item/paper(null)

	/// Default name of fax. Used when field with fax name not edited.
	var/sending_fax_name = "Secret"
	/// Default name of paper. paper - bluh-bluh. Used when field with paper name not edited.
	var/default_paper_name = "Standart Report"

/datum/fax_panel_interface/New()
	//Get all faxes, and save them to our list.
	for(var/obj/machinery/fax/fax in GLOB.machines)
		available_faxes += WEAKREF(fax)

	//Get all stamps
	for(var/stamp in subtypesof(/obj/item/stamp))
		var/obj/item/stamp/real_stamp = new stamp()
		if(!istype(real_stamp, /obj/item/stamp/chameleon))
			var/stamp_detail = real_stamp.get_writing_implement_details()
			stamp_list += list(list(real_stamp.name, real_stamp.icon_state, stamp_detail["stamp_class"]))

	//Give our paper special status, to read everywhere.
	fax_paper.request_state = TRUE

/**
 * Return fax if name exists
 * Arguments:
 * * name - Name of fax what we try to find.
 */
/datum/fax_panel_interface/proc/get_fax_by_name(name)
	if(!length(available_faxes))
		return null

	for(var/datum/weakref/weakrefed_fax as anything in available_faxes)
		var/obj/machinery/fax/potential_fax = weakrefed_fax.resolve()
		if(potential_fax && istype(potential_fax))
			if(potential_fax.fax_name == name)
				return potential_fax
	return null

/datum/fax_panel_interface/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AdminFax")
		ui.open()

/datum/fax_panel_interface/ui_state(mob/user)
	return ADMIN_STATE(R_ADMIN)

/datum/fax_panel_interface/ui_static_data(mob/user)
	var/list/data = list()

	data["faxes"] = list()
	data["stamps"] = list()

	for(var/stamp in stamp_list)
		data["stamps"] += list(stamp[1]) // send only names.

	for(var/datum/weakref/weakrefed_fax as anything in available_faxes)
		var/obj/machinery/fax/another_fax = weakrefed_fax.resolve()
		if(another_fax && istype(another_fax))
			data["faxes"] += list(another_fax.fax_name)

	return data

/datum/fax_panel_interface/ui_state(mob/user)
	return ADMIN_STATE(R_ADMIN)

