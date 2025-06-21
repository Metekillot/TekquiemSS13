/**
 * Returns the HTML for the status UI for this song datum.
 */
/datum/song/proc/instrument_status_ui()
	. = list()
	. += "<div class='statusDisplay'>"
	. += "<b><a href='byond://?src=[REF(src)];switchinstrument=1'>Current instrument</a>:</b> "
	if(!using_instrument)
		. += "<span class='danger'>No instrument loaded!</span><br>"
	else
		. += "[using_instrument.name]<br>"
	. += "Playback Settings:<br>"
	if(can_noteshift)
		. += "<a href='byond://?src=[REF(src)];setnoteshift=1'>Note Shift/Note Transpose</a>: [note_shift] keys / [round(note_shift / 12, 0.01)] octaves<br>"
	var/smt
	var/modetext = ""
	switch(sustain_mode)
		if(SUSTAIN_LINEAR)
			smt = "Linear"
			modetext = "<a href='byond://?src=[REF(src)];setlinearfalloff=1'>Linear Sustain Duration</a>: [sustain_linear_duration / 10] seconds<br>"
		if(SUSTAIN_EXPONENTIAL)
			smt = "Exponential"
			modetext = "<a href='byond://?src=[REF(src)];setexpfalloff=1'>Exponential Falloff Factor</a>: [sustain_exponential_dropoff]% per decisecond<br>"
	. += "<a href='byond://?src=[REF(src)];setsustainmode=1'>Sustain Mode</a>: [smt]<br>"
	. += modetext
	. += using_instrument?.ready()? "Status: <span class='good'>Ready</span><br>" : "Status: <span class='bad'>!Instrument Definition Error!</span><br>"
	. += "Instrument Type: [legacy? "Legacy" : "Synthesized"]<br>"
	. += "<a href='byond://?src=[REF(src)];setvolume=1'>Volume</a>: [volume]<br>"
	. += "<a href='byond://?src=[REF(src)];setdropoffvolume=1'>Volume Dropoff Threshold</a>: [sustain_dropoff_volume]<br>"
	. += "<a href='byond://?src=[REF(src)];togglesustainhold=1'>Sustain indefinitely last held note</a>: [full_sustain_held_note? "Enabled" : "Disabled"].<br>"
	. += "</div>"

/datum/song/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "InstrumentEditor", parent.name)
		ui.open()

/**
 * Parses a song the user has input into lines and stores them.
 */
/datum/song/proc/ParseSong(text)
	set waitfor = FALSE
	//split into lines
	lines = splittext(text, "\n")
	if(lines.len)
		var/bpm_string = "BPM: "
		if(findtext(lines[1], bpm_string, 1, length(bpm_string) + 1))
			var/divisor = text2num(copytext(lines[1], length(bpm_string) + 1)) || 120 // default
			tempo = sanitize_tempo(600 / round(divisor, 1))
			lines.Cut(1, 2)
		else
			tempo = sanitize_tempo(5) // default 120 BPM
		if(lines.len > MUSIC_MAXLINES)
			to_chat(usr, "Too many lines!")
			lines.Cut(MUSIC_MAXLINES + 1)
		var/linenum = 1
		for(var/l in lines)
			if(length_char(l) > MUSIC_MAXLINECHARS)
				to_chat(usr, "Line [linenum] too long!")
				lines.Remove(l)
			else
				linenum++
		updateDialog(usr)		// make sure updates when complete

/datum/song/Topic(href, href_list)
	if(!usr.canUseTopic(parent, TRUE, FALSE, FALSE, FALSE))
		usr << browse(null, "window=instrument")
		usr.unset_machine()
		return

	parent.add_fingerprint(usr)

	if(href_list["newsong"])
		lines = new()
		tempo = sanitize_tempo(5) // default 120 BPM
		name = ""

	else if(href_list["import"])
		var/t = ""
		do
			t = html_encode(input(usr, "Please paste the entire song, formatted:", text("[]", name), t)  as message)
			if(!in_range(parent, usr))
				return

			if(length_char(t) >= MUSIC_MAXLINES * MUSIC_MAXLINECHARS)
				var/cont = input(usr, "Your message is too long! Would you like to continue editing it?", "", "yes") in list("yes", "no")
				if(cont == "no")
					break
		while(length_char(t) > MUSIC_MAXLINES * MUSIC_MAXLINECHARS)
		ParseSong(t)

	else if(href_list["help"])
		help = text2num(href_list["help"]) - 1

	else if(href_list["edit"])
		editing = text2num(href_list["edit"]) - 1

	if(href_list["repeat"]) //Changing this from a toggle to a number of repeats to avoid infinite loops.
		if(playing)
			return //So that people cant keep adding to repeat. If the do it intentionally, it could result in the server crashing.
		repeat += round(text2num(href_list["repeat"]))
		if(repeat < 0)
			repeat = 0
		if(repeat > max_repeats)
			repeat = max_repeats

	else if(href_list["tempo"])
		tempo = sanitize_tempo(tempo + text2num(href_list["tempo"]))

	else if(href_list["play"])
		INVOKE_ASYNC(src, PROC_REF(start_playing), usr)

	else if(href_list["newline"])
		var/newline = html_encode(input("Enter your line: ", parent.name) as text|null)
		if(!newline || !in_range(parent, usr))
			return
		if(lines.len > MUSIC_MAXLINES)
			return
		if(length(newline) > MUSIC_MAXLINECHARS)
			newline = copytext(newline, 1, MUSIC_MAXLINECHARS)
		lines.Add(newline)

	else if(href_list["deleteline"])
		var/num = round(text2num(href_list["deleteline"]))
		if(num > lines.len || num < 1)
			return
		lines.Cut(num, num+1)

	else if(href_list["modifyline"])
		var/num = round(text2num(href_list["modifyline"]),1)
		var/content = stripped_input(usr, "Enter your line: ", parent.name, lines[num], MUSIC_MAXLINECHARS)
		if(!content || !in_range(parent, usr))
			return
		if(num > lines.len || num < 1)
			return
		lines[num] = content

	else if(href_list["stop"])
		stop_playing()

	else if(href_list["setlinearfalloff"])
		var/amount = input(usr, "Set linear sustain duration in seconds", "Linear Sustain Duration") as null|num
		if(!isnull(amount))
			set_linear_falloff_duration(round(amount * 10, world.tick_lag))

	else if(href_list["setexpfalloff"])
		var/amount = input(usr, "Set exponential sustain factor", "Exponential sustain factor") as null|num
		if(!isnull(amount))
			set_exponential_drop_rate(round(amount, 0.00001))

	else if(href_list["setvolume"])
		var/amount = input(usr, "Set volume", "Volume") as null|num
		if(!isnull(amount))
			set_volume(round(amount, 1))

	else if(href_list["setdropoffvolume"])
		var/amount = input(usr, "Set dropoff threshold", "Dropoff Threshold Volume") as null|num
		if(!isnull(amount))
			set_dropoff_volume(round(amount, 0.01))

	else if(href_list["switchinstrument"])
		if(!length(allowed_instrument_ids))
			return
		else if(length(allowed_instrument_ids) == 1)
			set_instrument(allowed_instrument_ids[1])
			return
		var/list/categories = list()
		for(var/i in allowed_instrument_ids)
			var/datum/instrument/I = SSinstruments.get_instrument(i)
			if(I)
				LAZYSET(categories[I.category || "ERROR CATEGORY"], I.name, I.id)
		var/cat = input(usr, "Select Category", "Instrument Category") as null|anything in categories
		if(!cat)
			return
		var/list/instruments = categories[cat]
		var/choice = input(usr, "Select Instrument", "Instrument Selection") as null|anything in instruments
		if(!choice)
			return
		choice = instruments[choice]		//get id
		if(choice)
			set_instrument(choice)

	else if(href_list["setnoteshift"])
		var/amount = input(usr, "Set note shift", "Note Shift") as null|num
		if(!isnull(amount))
			note_shift = clamp(amount, note_shift_min, note_shift_max)

	else if(href_list["setsustainmode"])
		var/choice = input(usr, "Choose a sustain mode", "Sustain Mode") as null|anything in list("Linear", "Exponential")
		switch(choice)
			if("Linear")
				sustain_mode = SUSTAIN_LINEAR
			if("Exponential")
				sustain_mode = SUSTAIN_EXPONENTIAL

	else if(href_list["togglesustainhold"])
		full_sustain_held_note = !full_sustain_held_note

	updateDialog()

