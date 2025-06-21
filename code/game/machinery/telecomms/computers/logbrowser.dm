

/obj/machinery/computer/telecomms/server
	name = "telecommunications server monitoring console"
	icon_screen = "comm_logs"
	desc = "Has full access to all details and record of the telecommunications network it's monitoring."

	var/screen = 0				// the screen number:
	var/list/servers = list()	// the servers located by the computer
	var/obj/machinery/telecomms/server/SelectedServer

	var/network = "NULL"		// the network to probe
	var/temp = ""				// temporary feedback messages

	var/universal_translate = 0 // set to 1 if it can translate nonhuman speech

	req_access = list(ACCESS_TCOMSAT)
	circuit = /obj/item/circuitboard/computer/comm_server

/obj/machinery/computer/telecomms/server/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "ServerMonitor", name)
		ui.open()

/obj/machinery/computer/telecomms/server/Topic(href, href_list)
	if(..())
		return


	add_fingerprint(usr)
	usr.set_machine(src)

	if(href_list["viewserver"])
		screen = 1
		for(var/obj/machinery/telecomms/T in servers)
			if(T.id == href_list["viewserver"])
				SelectedServer = T
				break

	if(href_list["operation"])
		switch(href_list["operation"])

			if("release")
				servers = list()
				screen = 0

			if("mainmenu")
				screen = 0

			if("scan")
				if(servers.len > 0)
					temp = "<font color = #D70B00>- FAILED: CANNOT PROBE WHEN BUFFER FULL -</font color>"

				else
					for(var/obj/machinery/telecomms/server/T in urange(25, src))
						if(T.network == network)
							servers.Add(T)

					if(!servers.len)
						temp = "<font color = #D70B00>- FAILED: UNABLE TO LOCATE SERVERS IN \[[network]\] -</font color>"
					else
						temp = "<font color = #336699>- [servers.len] SERVERS PROBED & BUFFERED -</font color>"

					screen = 0

	if(href_list["delete"])

		if(!src.allowed(usr) && !(obj_flags & EMAGGED))
			to_chat(usr, "<span class='danger'>ACCESS DENIED.</span>")
			return

		if(SelectedServer)

			var/datum/comm_log_entry/D = SelectedServer.log_entries[text2num(href_list["delete"])]

			temp = "<font color = #336699>- DELETED ENTRY: [D.name] -</font color>"

			SelectedServer.log_entries.Remove(D)
			qdel(D)

		else
			temp = "<font color = #D70B00>- FAILED: NO SELECTED MACHINE -</font color>"

	if(href_list["network"])

		var/newnet = stripped_input(usr, "Which network do you want to view?", "Comm Monitor", network)

		if(newnet && ((usr in range(1, src)) || issilicon(usr)))
			if(length(newnet) > 15)
				temp = "<font color = #D70B00>- FAILED: NETWORK TAG STRING TOO LENGHTLY -</font color>"

			else

				network = newnet
				screen = 0
				servers = list()
				temp = "<font color = #336699>- NEW NETWORK TAG SET IN ADDRESS \[[network]\] -</font color>"

	updateUsrDialog()
	return

/obj/machinery/computer/telecomms/server/attackby()
	. = ..()
	updateUsrDialog()

