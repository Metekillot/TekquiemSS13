/*
	The monitoring computer for the messaging server.
	Lets you read PDA and request console messages.
*/

#define LINKED_SERVER_NONRESPONSIVE  (!linkedServer || (linkedServer.machine_stat & (NOPOWER|BROKEN)))

#define MSG_MON_SCREEN_MAIN 		0
#define MSG_MON_SCREEN_LOGS 		1
#define MSG_MON_SCREEN_HACKED 		2
#define MSG_MON_SCREEN_CUSTOM_MSG 	3
#define MSG_MON_SCREEN_REQUEST_LOGS 4

// The monitor itself.
/obj/machinery/computer/message_monitor
	name = "message monitor console"
	desc = "Used to monitor the crew's PDA messages, as well as request console messages."
	icon_screen = "comm_logs"
	circuit = /obj/item/circuitboard/computer/message_monitor
	light_color = LIGHT_COLOR_GREEN
	//Server linked to.
	var/obj/machinery/telecomms/message_server/linkedServer = null
	//Sparks effect - For emag
	var/datum/effect_system/spark_spread/spark_system = new /datum/effect_system/spark_spread
	//Messages - Saves me time if I want to change something.
	var/noserver = "<span class='alert'>ALERT: No server detected.</span>"
	var/incorrectkey = "<span class='warning'>ALERT: Incorrect decryption key!</span>"
	var/defaultmsg = "<span class='notice'>Welcome. Please select an option.</span>"
	var/rebootmsg = "<span class='warning'>%$&(£: Critical %$$@ Error // !RestArting! <lOadiNg backUp iNput ouTput> - ?pLeaSe wAit!</span>"
	//Computer properties
	var/screen = MSG_MON_SCREEN_MAIN 		// 0 = Main menu, 1 = Message Logs, 2 = Hacked screen, 3 = Custom Message
	var/hacking = FALSE		// Is it being hacked into by the AI/Cyborg
	var/message = "<span class='notice'>System bootup complete. Please select an option.</span>"	// The message that shows on the main menu.
	var/auth = FALSE // Are they authenticated?
	var/optioncount = 7
	// Custom Message Properties
	var/customsender = "System Administrator"
	var/obj/item/pda/customrecepient = null
	var/customjob		= "Admin"
	var/custommessage 	= "This is a test, please ignore."


/obj/machinery/computer/message_monitor/attackby(obj/item/O, mob/living/user, params)
	if(O.tool_behaviour == TOOL_SCREWDRIVER && (obj_flags & EMAGGED))
		//Stops people from just unscrewing the monitor and putting it back to get the console working again.
		to_chat(user, "<span class='warning'>It is too hot to mess with!</span>")
	else
		return ..()

/obj/machinery/computer/message_monitor/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	if(!isnull(linkedServer))
		obj_flags |= EMAGGED
		screen = MSG_MON_SCREEN_HACKED
		spark_system.set_up(5, 0, src)
		spark_system.start()
		var/obj/item/paper/monitorkey/MK = new(loc, linkedServer)
		// Will help make emagging the console not so easy to get away with.
		MK.add_raw_text("<br><br><font color='red'>£%@%(*$%&(£&?*(%&£/{}</font>")
		var/time = 100 * length(linkedServer.decryptkey)
		addtimer(CALLBACK(src, PROC_REF(UnmagConsole)), time)
		message = rebootmsg
	else
		to_chat(user, "<span class='notice'>A no server error appears on the screen.</span>")

/obj/machinery/computer/message_monitor/New()
	..()
	GLOB.telecomms_list += src

/obj/machinery/computer/message_monitor/Initialize()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/message_monitor/LateInitialize()
	//Is the server isn't linked to a server, and there's a server available, default it to the first one in the list.
	if(!linkedServer)
		for(var/obj/machinery/telecomms/message_server/S in GLOB.telecomms_list)
			linkedServer = S
			break

/obj/machinery/computer/message_monitor/Destroy()
	GLOB.telecomms_list -= src
	return ..()

/obj/machinery/computer/message_monitor/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "MessageMonitor", name)
		ui.open()

/obj/machinery/computer/message_monitor/proc/BruteForce(mob/user)
	if(isnull(linkedServer))
		to_chat(user, "<span class='warning'>Could not complete brute-force: Linked Server Disconnected!</span>")
	else
		var/currentKey = linkedServer.decryptkey
		to_chat(user, "<span class='warning'>Brute-force completed! The key is '[currentKey]'.</span>")
	hacking = FALSE
	screen = MSG_MON_SCREEN_MAIN // Return the screen back to normal

/obj/machinery/computer/message_monitor/proc/UnmagConsole()
	obj_flags &= ~EMAGGED

/obj/machinery/computer/message_monitor/proc/ResetMessage()
	customsender 	= "System Administrator"
	customrecepient = null
	custommessage 	= "This is a test, please ignore."
	customjob 		= "Admin"

/obj/machinery/computer/message_monitor/Topic(href, href_list)
	if(..())
		return

	if(usr.contents.Find(src) || (in_range(src, usr) && isturf(loc)) || issilicon(usr))
		//Authenticate
		if (href_list["auth"])
			if(LINKED_SERVER_NONRESPONSIVE)
				message = noserver
			else if(auth)
				auth = FALSE
				screen = MSG_MON_SCREEN_MAIN
			else
				var/dkey = trim(input(usr, "Please enter the decryption key.") as text|null)
				if(dkey && dkey != "")
					if(linkedServer.decryptkey == dkey)
						auth = TRUE
					else
						message = incorrectkey

		//Turn the server on/off.
		if (href_list["active"])
			if(LINKED_SERVER_NONRESPONSIVE)
				message = noserver
			else if(auth)
				linkedServer.toggled = !linkedServer.toggled
		//Find a server
		if (href_list["find"])
			var/list/message_servers = list()
			for (var/obj/machinery/telecomms/message_server/M in GLOB.telecomms_list)
				message_servers += M

			if(message_servers.len > 1)
				linkedServer = input(usr, "Please select a server.", "Select a server.", null) as null|anything in message_servers
				message = "<span class='alert'>NOTICE: Server selected.</span>"
			else if(message_servers.len > 0)
				linkedServer = message_servers[1]
				message =  "<span class='notice'>NOTICE: Only Single Server Detected - Server selected.</span>"
			else
				message = noserver

		//View the logs - KEY REQUIRED
		if (href_list["view_logs"])
			if(LINKED_SERVER_NONRESPONSIVE)
				message = noserver
			else if(auth)
				screen = MSG_MON_SCREEN_LOGS

		//Clears the logs - KEY REQUIRED
		if (href_list["clear_logs"])
			if(LINKED_SERVER_NONRESPONSIVE)
				message = noserver
			else if(auth)
				linkedServer.pda_msgs = list()
				message = "<span class='notice'>NOTICE: Logs cleared.</span>"
		//Clears the request console logs - KEY REQUIRED
		if (href_list["clear_requests"])
			if(LINKED_SERVER_NONRESPONSIVE)
				message = noserver
			else if(auth)
				linkedServer.rc_msgs = list()
				message = "<span class='notice'>NOTICE: Logs cleared.</span>"
		//Change the password - KEY REQUIRED
		if (href_list["pass"])
			if(LINKED_SERVER_NONRESPONSIVE)
				message = noserver
			else if(auth)
				var/dkey = stripped_input(usr, "Please enter the decryption key.")
				if(dkey && dkey != "")
					if(linkedServer.decryptkey == dkey)
						var/newkey = stripped_input(usr,"Please enter the new key (3 - 16 characters max):")
						if(length(newkey) <= 3)
							message = "<span class='notice'>NOTICE: Decryption key too short!</span>"
						else if(length(newkey) > 16)
							message = "<span class='notice'>NOTICE: Decryption key too long!</span>"
						else if(newkey && newkey != "")
							linkedServer.decryptkey = newkey
						message = "<span class='notice'>NOTICE: Decryption key set.</span>"
					else
						message = incorrectkey

		//Hack the Console to get the password
		if (href_list["hack"])
			var/mob/living/silicon/S = usr
			if(istype(S) && S.hack_software)
				hacking = TRUE
				screen = MSG_MON_SCREEN_HACKED
				//Time it takes to bruteforce is dependant on the password length.
				addtimer(CALLBACK(src, PROC_REF(finish_bruteforce), usr), 100*length(linkedServer.decryptkey))

		//Delete the log.
		if (href_list["delete_logs"])
			//Are they on the view logs screen?
			if(screen == MSG_MON_SCREEN_LOGS)
				if(LINKED_SERVER_NONRESPONSIVE)
					message = noserver
				else //if(istype(href_list["delete_logs"], /datum/data_pda_msg))
					linkedServer.pda_msgs -= locate(href_list["delete_logs"]) in linkedServer.pda_msgs
					message = "<span class='notice'>NOTICE: Log Deleted!</span>"
		//Delete the request console log.
		if (href_list["delete_requests"])
			//Are they on the view logs screen?
			if(screen == MSG_MON_SCREEN_REQUEST_LOGS)
				if(LINKED_SERVER_NONRESPONSIVE)
					message = noserver
				else //if(istype(href_list["delete_logs"], /datum/data_pda_msg))
					linkedServer.rc_msgs -= locate(href_list["delete_requests"]) in linkedServer.rc_msgs
					message = "<span class='notice'>NOTICE: Log Deleted!</span>"
		//Create a custom message
		if (href_list["msg"])
			if(LINKED_SERVER_NONRESPONSIVE)
				message = noserver
			else if(auth)
				screen = MSG_MON_SCREEN_CUSTOM_MSG
		//Fake messaging selection - KEY REQUIRED
		if (href_list["select"])
			if(LINKED_SERVER_NONRESPONSIVE)
				message = noserver
				screen = MSG_MON_SCREEN_MAIN
			else
				switch(href_list["select"])

					//Reset
					if("Reset")
						ResetMessage()

					//Select Your Name
					if("Sender")
						customsender = stripped_input(usr, "Please enter the sender's name.") || customsender

					//Select Receiver
					if("Recepient")
						//Get out list of viable PDAs
						var/list/obj/item/pda/sendPDAs = get_viewable_pdas()
						if(GLOB.PDAs && GLOB.PDAs.len > 0)
							customrecepient = input(usr, "Select a PDA from the list.") as null|anything in sendPDAs
						else
							customrecepient = null

					//Enter custom job
					if("RecJob")
						customjob = stripped_input(usr, "Please enter the sender's job.") || customjob

					//Enter message
					if("Message")
						custommessage = stripped_input(usr, "Please enter your message.") || custommessage

					//Send message
					if("Send")
						if(isnull(customsender) || customsender == "")
							customsender = "UNKNOWN"

						if(isnull(customrecepient))
							message = "<span class='notice'>NOTICE: No recepient selected!</span>"
							return attack_hand(usr)

						if(isnull(custommessage) || custommessage == "")
							message = "<span class='notice'>NOTICE: No message entered!</span>"
							return attack_hand(usr)

						var/datum/signal/subspace/messaging/pda/signal = new(src, list(
							"name" = "[customsender]",
							"job" = "[customjob]",
							"message" = custommessage,
							"targets" = list("[customrecepient.owner] ([customrecepient.ownjob])")
						))
						// this will log the signal and transmit it to the target
						linkedServer.receive_information(signal, null)
						usr.log_message("(PDA: [name] | [usr.real_name]) sent \"[custommessage]\" to [signal.format_target()]", LOG_PDA)


		//Request Console Logs - KEY REQUIRED
		if(href_list["view_requests"])
			if(LINKED_SERVER_NONRESPONSIVE)
				message = noserver
			else if(auth)
				screen = MSG_MON_SCREEN_REQUEST_LOGS

		if (href_list["back"])
			screen = MSG_MON_SCREEN_MAIN

	return attack_hand(usr)

/obj/machinery/computer/message_monitor/proc/finish_bruteforce(mob/user)
	if(!QDELETED(user))
		BruteForce(user)
		return
	hacking = FALSE
	screen = MSG_MON_SCREEN_MAIN

#undef MSG_MON_SCREEN_MAIN
#undef MSG_MON_SCREEN_LOGS
#undef MSG_MON_SCREEN_HACKED
#undef MSG_MON_SCREEN_CUSTOM_MSG
#undef MSG_MON_SCREEN_REQUEST_LOGS

#undef LINKED_SERVER_NONRESPONSIVE

/obj/item/paper/monitorkey
	name = "monitor decryption key"

/obj/item/paper/monitorkey/Initialize(mapload, obj/machinery/telecomms/message_server/server)
	..()
	if (server)
		print(server)
		return INITIALIZE_HINT_NORMAL
	else
		return INITIALIZE_HINT_LATELOAD

/obj/item/paper/monitorkey/proc/print(obj/machinery/telecomms/message_server/server)
	default_raw_text = "<center><h2>Daily Key Reset</h2></center><br>The new message monitor key is '[server.decryptkey]'.<br>Please keep this a secret and away from the clown.<br>If necessary, change the password to a more secure one."
	add_overlay("paper_words")

/obj/item/paper/monitorkey/LateInitialize()
	for (var/obj/machinery/telecomms/message_server/preset/server in GLOB.telecomms_list)
		if (server.decryptkey)
			print(server)
			break

