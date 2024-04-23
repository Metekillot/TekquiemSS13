/proc/priority_announce(text, title = "", sound = 'sound/ai/attention.ogg', type , sender_override)
	if(!text)
		return

	var/announcement

	if(type == "Priority")
		announcement += "<h1 class='alert'>Priority Announcement</h1>"
		if (title && length(title) > 0)
			announcement += "<br><h2 class='alert'>[html_encode(title)]</h2>"
	else if(type == "Captain")
		announcement += "<h1 class='alert'>Captain Announces</h1>"
		GLOB.news_network.submit_article(text, "Captain's Announcement", "City Announcements", null)

	else
		if(!sender_override)
			announcement += "<h1 class='alert'>[command_name()] Update</h1>"
		else
			announcement += "<h1 class='alert'>[sender_override]</h1>"
		if (title && length(title) > 0)
			announcement += "<br><h2 class='alert'>[html_encode(title)]</h2>"

		if(!sender_override)
			if(title == "")
				GLOB.news_network.submit_article(text, "San Francisco City Council Update", "City Announcements", null)
			else
				GLOB.news_network.submit_article(title + "<br><br>" + text, "San Francisco City Council", "City Announcements", null)

	announcement += "<br><span class='alert'>[html_encode(text)]</span><br>"
	announcement += "<br>"

	var/s = sound(sound)
	for(var/mob/M in GLOB.player_list)
		if(!isnewplayer(M) && M.can_hear())
			to_chat(M, announcement)
			if(M.client.prefs.toggles & SOUND_ANNOUNCEMENTS)
				SEND_SOUND(M, s)

/proc/print_command_report(text = "", title = null, announce=TRUE)
	if(!title)
		title = "Classified [command_name()] Update"

	if(announce)
		priority_announce("A report has been downloaded and printed out at all communications consoles.", "Incoming Classified Message", 'sound/ai/commandreport.ogg')

	var/datum/comm_message/M  = new
	M.title = title
	M.content =  text

	DScommunications.send_message(message)

/**
 * Sends a minor annoucement to players.
 * Minor announcements are large text, with the title in red and message in white.
 * Only mobs that can hear can see the announcements.
 *
 * message - the message contents of the announcement.
 * title - the title of the announcement, which is often "who sent it".
 * alert - whether this announcement is an alert, or just a notice. Only changes the sound that is played by default.
 * html_encode - if TRUE, we will html encode our title and message before sending it, to prevent player input abuse.
 * players - optional, a list mobs to send the announcement to. If unset, sends to all palyers.
 * sound_override - optional, use the passed sound file instead of the default notice sounds.
 * should_play_sound - Whether the notice sound should be played or not.
 * color_override - optional, use the passed color instead of the default notice color.
 */
/proc/minor_announce(message, title = "Attention:", alert = FALSE, html_encode = TRUE, list/players, sound_override, should_play_sound = TRUE, color_override)
	if(!message)
		return

	if (html_encode)
		title = html_encode(title)
		message = html_encode(message)

	var/list/minor_announcement_strings = list()
	minor_announcement_strings += MINOR_ANNOUNCEMENT_TITLE(title)
	minor_announcement_strings += MINOR_ANNOUNCEMENT_TEXT(message)

	var/finalized_announcement
	if(color_override)
		finalized_announcement = CHAT_ALERT_COLORED_SPAN(color_override, jointext(minor_announcement_strings, "<br>"))
	else
		finalized_announcement = CHAT_ALERT_DEFAULT_SPAN(jointext(minor_announcement_strings, "<br>"))

	var/custom_sound = sound_override || (alert ? 'sound/misc/notice1.ogg' : 'sound/misc/notice2.ogg')
	dispatch_announcement_to_players(finalized_announcement, players, custom_sound, should_play_sound)

/// Sends an announcement about the level changing to players. Uses the passed in datum and the subsystem's previous security level to generate the message.
/proc/level_announce(datum/security_level/selected_level, previous_level_number)
	var/current_level_number = selected_level.number_level
	var/current_level_name = selected_level.name
	var/current_level_color = selected_level.announcement_color
	var/current_level_sound = selected_level.sound

	var/title
	var/message

	if(current_level_number > previous_level_number)
		title = "Attention! Security level elevated to [current_level_name]:"
		message = selected_level.elevating_to_announcement
	else
		title = "Attention! Security level lowered to [current_level_name]:"
		message = selected_level.lowering_to_announcement

	var/list/level_announcement_strings = list()
	level_announcement_strings += MINOR_ANNOUNCEMENT_TITLE(title)
	level_announcement_strings += MINOR_ANNOUNCEMENT_TEXT(message)

	var/finalized_announcement = CHAT_ALERT_COLORED_SPAN(current_level_color, jointext(level_announcement_strings, "<br>"))

	dispatch_announcement_to_players(finalized_announcement, GLOB.player_list, current_level_sound)

/// Proc that just generates a custom header based on variables fed into `priority_announce()`
/// Will return a string.
/proc/generate_unique_announcement_header(title, sender_override)
	var/list/returnable_strings = list()
	if(isnull(sender_override))
		returnable_strings += MAJOR_ANNOUNCEMENT_TITLE("[command_name()] Update")
	else
		returnable_strings += MAJOR_ANNOUNCEMENT_TITLE(sender_override)

	if(length(title) > 0)
		returnable_strings += MINOR_ANNOUNCEMENT_TITLE(title)

	return jointext(returnable_strings, "<br>")

/// Proc that just dispatches the announcement to our applicable audience. Only the announcement is a mandatory arg.
/proc/dispatch_announcement_to_players(announcement, list/players, sound_override = null, should_play_sound = TRUE)
	if(!players)
		players = GLOB.player_list

	var/sound_to_play = !isnull(sound_override) ? sound_override : 'sound/misc/notice2.ogg'

	for(var/mob/target in players)
		if(isnewplayer(target) || !target.can_hear())
			continue

		to_chat(target, announcement)
		if(!should_play_sound)
			continue

		if(target.client?.prefs.read_preference(/datum/preference/toggle/sound_announcements))
			SEND_SOUND(target, sound(sound_to_play))

#undef MAJOR_ANNOUNCEMENT_TITLE
#undef MAJOR_ANNOUNCEMENT_TEXT
#undef MINOR_ANNOUNCEMENT_TITLE
#undef MINOR_ANNOUNCEMENT_TEXT
#undef CHAT_ALERT_DEFAULT_SPAN
#undef CHAT_ALERT_COLORED_SPAN
