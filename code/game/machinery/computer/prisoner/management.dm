/obj/machinery/computer/prisoner/management
	name = "prisoner management console"
	desc = "Used to manage tracking implants placed inside criminals."
	icon_screen = "explosive"
	icon_keyboard = "security_key"
	req_access = list(ACCESS_BRIG)
	light_color = COLOR_SOFT_RED
	var/id = 0
	var/temp = null
	var/status = 0
	var/timeleft = 60
	var/stop = 0
	var/screen = 0 // 0 - No Access Denied, 1 - Access allowed
	circuit = /obj/item/circuitboard/computer/prisoner


/obj/machinery/computer/prisoner/management/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PrisonerManagement")
		ui.open()

/obj/machinery/computer/prisoner/management/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/card/id))
		if(screen)
			id_insert(user)
		else
			to_chat(user, "<span class='danger'>Unauthorized access.</span>")
	else
		return ..()

/obj/machinery/computer/prisoner/management/process()
	if(!..())
		src.updateDialog()
	return

/obj/machinery/computer/prisoner/management/Topic(href, href_list)
	if(..())
		return
	if(usr.contents.Find(src) || (in_range(src, usr) && isturf(loc)) || issilicon(usr))
		usr.set_machine(src)

		if(href_list["id"])
			if(href_list["id"] =="insert" && !contained_id)
				id_insert(usr)
			else if(contained_id)
				switch(href_list["id"])
					if("eject")
						id_eject(usr)
					if("reset")
						contained_id.points = 0
					if("setgoal")
						var/num = round(input(usr, "Choose prisoner's goal:", "Input an Integer", null) as num|null)
						if(num >= 0)
							num = min(num,1000) //Cap the quota to the equivilent of 10 minutes.
							contained_id.goal = num
		else if(href_list["inject1"])
			var/obj/item/implant/I = locate(href_list["inject1"]) in GLOB.tracked_chem_implants
			if(I && istype(I))
				I.activate(1)
		else if(href_list["inject5"])
			var/obj/item/implant/I = locate(href_list["inject5"]) in GLOB.tracked_chem_implants
			if(I && istype(I))
				I.activate(5)
		else if(href_list["inject10"])
			var/obj/item/implant/I = locate(href_list["inject10"]) in GLOB.tracked_chem_implants
			if(I && istype(I))
				I.activate(10)

		else if(href_list["lock"])
			if(allowed(usr))
				screen = !screen
				playsound(src, 'sound/machines/terminal_on.ogg', 50, FALSE)
			else
				to_chat(usr, "<span class='danger'>Unauthorized access.</span>")

		else if(href_list["warn"])
			var/warning = stripped_input(usr, "Message:", "Enter your message here!", "", MAX_MESSAGE_LEN)
			if(!warning)
				return
			var/obj/item/implant/I = locate(href_list["warn"]) in GLOB.tracked_implants
			if(I && istype(I) && I.imp_in)
				var/mob/living/R = I.imp_in
				to_chat(R, "<span class='hear'>You hear a voice in your head saying: '[warning]'</span>")
				log_directed_talk(usr, R, warning, LOG_SAY, "implant message")

		src.add_fingerprint(usr)
	src.updateUsrDialog()
	return

