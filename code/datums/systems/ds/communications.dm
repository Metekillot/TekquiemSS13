#define COMMUNICATION_COOLDOWN 300
#define COMMUNICATION_COOLDOWN_AI 300

DATASYSTEM_DEF(communications)
	name = "Communications"

	var/silicon_message_cooldown
	var/nonsilicon_message_cooldown

/datum/system/communications/proc/can_announce(mob/living/user, is_silicon)
	if(is_silicon && COOLDOWN_FINISHED(src, silicon_message_cooldown))
		return TRUE
	else if(!is_silicon && COOLDOWN_FINISHED(src, nonsilicon_message_cooldown))
		return TRUE
	else
		. = TRUE

/datum/system/communications/proc/make_announcement(mob/living/user, is_silicon, input, syndicate, list/players)
	if(!can_announce(user, is_silicon))
		return FALSE
	if(is_silicon)
		minor_announce(html_decode(input),"[user.name] Announces:")
		silicon_message_cooldown = world.time + COMMUNICATION_COOLDOWN_AI
	else
		priority_announce(html_decode(user.treat_message(input)), null, 'sound/misc/announce.ogg', "Captain")
		nonsilicon_message_cooldown = world.time + COMMUNICATION_COOLDOWN
	user.log_talk(input, LOG_SAY, tag="priority announcement")
	message_admins("[ADMIN_LOOKUPFLW(user)] has made a priority announcement.")

/datum/system/communications/proc/send_message(datum/comm_message/sending,print = TRUE,unique = FALSE)
	for(var/obj/machinery/computer/communications/C in GLOB.shuttle_caller_list)
		if(!(C.machine_stat & (BROKEN|NOPOWER)) && is_station_level(C.z))
			if(unique)
				C.add_message(sending)
			else //We copy the message for each console, answers and deletions won't be shared
				var/datum/comm_message/M = new(sending.title,sending.content,sending.possible_answers.Copy())
				C.add_message(M)
			if(print)
				var/obj/item/paper/P = new /obj/item/paper(C.loc)
				P.name = "paper - '[sending.title]'"
				P.add_raw_text(sending.content)
				P.update_icon()

#undef COMMUNICATION_COOLDOWN
#undef COMMUNICATION_COOLDOWN_AI
