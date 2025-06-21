/obj/machinery/computer/warrant//TODO:SANITY
	name = "security warrant console"
	desc = "Used to view crewmember security records"
	icon_screen = "security"
	icon_keyboard = "security_key"
	circuit = /obj/item/circuitboard/computer/warrant
	light_color = COLOR_SOFT_RED
	var/screen = null
	var/datum/data/record/current = null

/obj/machinery/computer/warrant/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "WarrantConsole", name)
		ui.set_autoupdate(FALSE)
		ui.open()

/obj/machinery/computer/warrant/Topic(href, href_list)
	if(..())
		return
	var/mob/M = usr
	switch(href_list["choice"])
		if("Login")
			if(isliving(M))
				var/mob/living/L = M
				var/obj/item/card/id/scan = L.get_idcard(TRUE)
				authenticated = scan.registered_name
				if(authenticated)
					for(var/datum/data/record/R in GLOB.data_core.security)
						if(R.fields["name"] == authenticated)
							current = R
					playsound(src, 'sound/machines/terminal_on.ogg', 50, FALSE)
		if("Logout")
			current = null
			authenticated = null
			playsound(src, 'sound/machines/terminal_off.ogg', 50, FALSE)

		if("Pay")
			for(var/datum/data/crime/p in current.fields["citation"])
				if(p.dataId == text2num(href_list["cdataid"]))
					var/obj/item/holochip/C = M.is_holding_item_of_type(/obj/item/holochip)
					if(C && istype(C))
						var/pay = C.get_item_credit_value()
						if(!pay)
							to_chat(M, "<span class='warning'>[C] doesn't seem to be worth anything!</span>")
						else
							var/diff = p.fine - p.paid
							GLOB.data_core.payCitation(current.fields["id"], text2num(href_list["cdataid"]), pay)
							to_chat(M, "<span class='notice'>You have paid [pay] credit\s towards your fine.</span>")
							if (pay == diff || pay > diff || pay >= diff)
								investigate_log("Citation Paid off: <strong>[p.crimeName]</strong> Fine: [p.fine] | Paid off by [key_name(usr)]", INVESTIGATE_RECORDS)
								to_chat(M, "<span class='notice'>The fine has been paid in full.</span>")
							qdel(C)
							playsound(src, "terminal_type", 25, FALSE)
					else
						to_chat(M, "<span class='warning'>Fines can only be paid with holochips!</span>")
	updateUsrDialog()
	add_fingerprint(M)

