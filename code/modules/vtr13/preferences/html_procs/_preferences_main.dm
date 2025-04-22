/datum/preferences/proc/ShowChoices(mob/user)
	if(!SSatoms.initialized)
		to_chat(user, span_warning("Please wait for the game to do a little more setup first...!"))
		return
	if(!user?.client) // Without a client in control, you can't do anything.
		return
	if(slot_randomized)
		load_character(default_slot) // Reloads the character slot. Prevents random features from overwriting the slot if saved.
		slot_randomized = FALSE
	update_preview_icon()
	var/list/dat = list("<center>")

	if(istype(user, /mob/dead/new_player))
		dat += "<a href='byond://?_src_=prefs;preference=tab;tab=0' [current_tab == 0 ? "class='linkOn'" : ""]>[make_font_cool("CHARACTER SETTINGS")]</a>"
		dat += "<a href='byond://?_src_=prefs;preference=tab;tab=1' [current_tab == 1 ? "class='linkOn'" : ""]>[make_font_cool("MERITS & FLAWS")]</a>"
		dat += "<a href='byond://?_src_=prefs;preference=tab;tab=2' [current_tab == 2 ? "class='linkOn'" : ""]>[make_font_cool("ATTRIBUTES")]</a>"
		dat += "<a href='byond://?_src_=prefs;preference=tab;tab=3' [current_tab == 3 ? "class='linkOn'" : ""]>[make_font_cool("OCCUPATION")]</a>"
		dat += "<br>"
	else if(current_tab < 4)
		current_tab = 4
	dat += "<a href='byond://?_src_=prefs;preference=tab;tab=4' [current_tab == 4 ? "class='linkOn'" : ""]>[make_font_cool("GAME PREFERENCES")]</a>"
	dat += "<a href='byond://?_src_=prefs;preference=tab;tab=5' [current_tab == 5 ? "class='linkOn'" : ""]>[make_font_cool("OOC PREFERENCES")]</a>"
	dat += "<a href='byond://?_src_=prefs;preference=tab;tab=6' [current_tab == 6 ? "class='linkOn'" : ""]>[make_font_cool("CUSTOM KEYBINDINGS")]</a>"

	if(!path)
		dat += "<div class='notice'>Please create an account to save your preferences</div>"

	dat += "</center>"

	dat += "<HR>"

	switch(current_tab)
		if (0)
			character_settings_page(user, dat)
		if (1)
			quirk_page(user, dat)
		if (2)
			attributes_page(user, dat)
		if (3)
			occupation_page(user, dat)
		if (4)
			game_preferences_page(user, dat)
		if(5)
			ooc_preferences_page(user, dat)
		if(6)
			custom_keybindings_page(user, dat)
	dat += "<hr><center>"

	if(!IsGuestKey(user.key))
		dat += "<a href='byond://?_src_=prefs;preference=load'>Undo</a> "
		dat += "<a href='byond://?_src_=prefs;preference=save'>Save Character</a> "

	if(istype(user, /mob/dead/new_player))
		dat += "<a href='byond://?_src_=prefs;preference=reset_all'>Reset Setup</a>"
	dat += "</center>"

	winshow(user, "preferences_window", TRUE)
	var/datum/browser/popup = new(user, "preferences_browser", "<div align='center'>[make_font_cool("CHARACTER")]</div>", 640, 770)
	popup.set_content(dat.Join())
	popup.open(FALSE)
	onclose(user, "preferences_window", src)