#define OWNER 0
#define STRANGER 1

/datum/brain_trauma/severe/split_personality
	name = "Split Personality"
	desc = "Patient's brain is split into two personalities, which randomly switch control of the body."
	scan_desc = "complete lobe separation"
	gain_text = "<span class='warning'>You feel like your mind was split in two.</span>"
	lose_text = "<span class='notice'>You feel alone again.</span>"
	var/current_controller = OWNER
	var/initialized = FALSE //to prevent personalities deleting themselves while we wait for ghosts
	var/mob/living/split_personality/stranger_backseat //there's two so they can swap without overwriting
	var/mob/living/split_personality/owner_backseat

/datum/brain_trauma/severe/split_personality/on_gain()
	var/mob/living/M = owner
	if(M.stat == DEAD || !M.client)	//No use assigning people to a corpse or braindead
		qdel(src)
		return
	..()
	make_backseats()
	get_ghost()

/datum/brain_trauma/severe/split_personality/proc/make_backseats()
	stranger_backseat = new(owner, src)
	var/obj/effect/proc_holder/spell/targeted/personality_commune/stranger_spell = new(src)
	stranger_backseat.AddSpell(stranger_spell)

	owner_backseat = new(owner, src)
	var/obj/effect/proc_holder/spell/targeted/personality_commune/owner_spell = new(src)
	owner_backseat.AddSpell(owner_spell)

/// Attempts to get a ghost to play the personality
/datum/brain_trauma/severe/split_personality/proc/get_ghost()
	var/datum/callback/to_call = CALLBACK(src, PROC_REF(schism))
	owner.AddComponent(/datum/component/orbit_poll, \
		ignore_key = POLL_IGNORE_SPLITPERSONALITY, \
		job_bans = ROLE_PAI, \
		title = "[owner.real_name]'s [poll_role]", \
		to_call = to_call, \
	)

/// Ghost poll has concluded
/datum/brain_trauma/severe/split_personality/proc/schism(mob/dead/observer/ghost)
	if(isnull(ghost))
		qdel(src)
		return

	stranger_backseat.key = ghost.key
	stranger_backseat.log_message("became [key_name(owner)]'s split personality.", LOG_GAME)
	message_admins("[ADMIN_LOOKUPFLW(stranger_backseat)] became [ADMIN_LOOKUPFLW(owner)]'s split personality.")


/datum/brain_trauma/severe/split_personality/on_life()
	if(owner.stat == DEAD)
		if(current_controller != OWNER)
			switch_personalities()
		qdel(src)
	else if(prob(3))
		switch_personalities()
	..()

/datum/brain_trauma/severe/split_personality/on_lose()
	if(current_controller != OWNER) //it would be funny to cure a guy only to be left with the other personality, but it seems too cruel
		switch_personalities()
	QDEL_NULL(stranger_backseat)
	QDEL_NULL(owner_backseat)
	..()

/datum/brain_trauma/severe/split_personality/proc/switch_personalities()
	if(QDELETED(owner) || QDELETED(stranger_backseat) || QDELETED(owner_backseat))
		return

	var/mob/living/split_personality/current_backseat
	var/mob/living/split_personality/free_backseat
	if(current_controller == OWNER)
		current_backseat = stranger_backseat
		free_backseat = owner_backseat
	else
		current_backseat = owner_backseat
		free_backseat = stranger_backseat

	if(!current_backseat.client) //Make sure we never switch to a logged off mob.
		return

	log_game("[key_name(current_backseat)] assumed control of [key_name(owner)] due to [src]. (Original owner: [current_controller == OWNER ? owner.key : current_backseat.key])")
	to_chat(owner, "<span class='userdanger'>You feel your control being taken away... your other personality is in charge now!</span>")
	to_chat(current_backseat, "<span class='userdanger'>You manage to take control of your body!</span>")

	//Body to backseat

	var/h2b_id = owner.computer_id
	var/h2b_ip= owner.lastKnownIP
	owner.computer_id = null
	owner.lastKnownIP = null

	free_backseat.ckey = owner.ckey

	free_backseat.name = owner.name

	if(owner.mind)
		free_backseat.mind = owner.mind

	if(!free_backseat.computer_id)
		free_backseat.computer_id = h2b_id

	if(!free_backseat.lastKnownIP)
		free_backseat.lastKnownIP = h2b_ip

	//Backseat to body

	var/s2h_id = current_backseat.computer_id
	var/s2h_ip= current_backseat.lastKnownIP
	current_backseat.computer_id = null
	current_backseat.lastKnownIP = null

	owner.ckey = current_backseat.ckey
	owner.mind = current_backseat.mind

	if(!owner.computer_id)
		owner.computer_id = s2h_id

	if(!owner.lastKnownIP)
		owner.lastKnownIP = s2h_ip

	current_controller = !current_controller


/mob/living/split_personality
	name = "split personality"
	real_name = "unknown conscience"
	var/mob/living/carbon/body
	var/datum/brain_trauma/severe/split_personality/trauma

/mob/living/split_personality/Initialize(mapload, _trauma)
	if(iscarbon(loc))
		body = loc
		name = body.real_name
		real_name = body.real_name
		trauma = _trauma
	return ..()

/mob/living/split_personality/Life()
	if(QDELETED(body))
		qdel(src) //in case trauma deletion doesn't already do it

	if((body.stat == DEAD && trauma.owner_backseat == src))
		trauma.switch_personalities()
		qdel(trauma)

	//if one of the two ghosts, the other one stays permanently
	if(!body.client && trauma.initialized)
		trauma.switch_personalities()
		qdel(trauma)

	..()

/mob/living/split_personality/Login()
	. = ..()
	if(!. || !client)
		return FALSE
	to_chat(src, "<span class='notice'>As a split personality, you cannot do anything but observe. However, you will eventually gain control of your body, switching places with the current personality.</span>")
	to_chat(src, "<span class='warning'><b>Do not commit suicide or put the body in a deadly position. Behave like you care about it as much as the owner.</b></span>")

/mob/living/split_personality/say(message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null)
	to_chat(src, "<span class='warning'>You cannot speak, your other self is controlling your body!</span>")
	return FALSE

/mob/living/split_personality/emote(act, m_type = null, message = null, intentional = FALSE)
	return FALSE

///////////////BRAINWASHING////////////////////

/datum/brain_trauma/severe/split_personality/brainwashing
	name = "Split Personality"
	desc = "Patient's brain is split into two personalities, which randomly switch control of the body."
	scan_desc = "complete lobe separation"
	gain_text = ""
	lose_text = "<span class='notice'>You are free of your brainwashing.</span>"
	can_gain = FALSE
	var/codeword
	var/objective

/datum/brain_trauma/severe/split_personality/brainwashing/New(obj/item/organ/brain/B, _permanent, _codeword, _objective)
	..()
	if(_codeword)
		codeword = _codeword
	else
		codeword = pick(strings("ion_laws.json", "ionabstract")\
			| strings("ion_laws.json", "ionobjects")\
			| strings("ion_laws.json", "ionadjectives")\
			| strings("ion_laws.json", "ionthreats")\
			| strings("ion_laws.json", "ionfood")\
			| strings("ion_laws.json", "iondrinks"))

/datum/brain_trauma/severe/split_personality/brainwashing/on_gain()
	..()
	var/mob/living/split_personality/traitor/traitor_backseat = stranger_backseat
	traitor_backseat.codeword = codeword
	traitor_backseat.objective = objective

/datum/brain_trauma/severe/split_personality/brainwashing/make_backseats()
	stranger_backseat = new /mob/living/split_personality/traitor(owner, src, codeword, objective)
	owner_backseat = new(owner, src)

/datum/brain_trauma/severe/split_personality/brainwashing/get_ghost()
	set waitfor = FALSE
	var/list/mob/dead/observer/candidates = pollCandidatesForMob("Do you want to play as [owner.real_name]'s brainwashed mind?", null, null, null, 75, stranger_backseat)
	if(LAZYLEN(candidates))
		var/mob/dead/observer/C = pick(candidates)
		stranger_backseat.key = C.key
	else
		qdel(src)

/datum/brain_trauma/severe/split_personality/brainwashing/on_life()
	return //no random switching

/datum/brain_trauma/severe/split_personality/brainwashing/handle_hearing(datum/source, list/hearing_args)
	if(HAS_TRAIT(owner, TRAIT_DEAF) || owner == hearing_args[HEARING_SPEAKER])
		return
	var/message = hearing_args[HEARING_RAW_MESSAGE]
	if(findtext(message, codeword))
		hearing_args[HEARING_RAW_MESSAGE] = replacetext(message, codeword, "<span class='warning'>[codeword]</span>")
		addtimer(CALLBACK(src, TYPE_PROC_REF(/datum/brain_trauma/severe/split_personality, switch_personalities)), 10)

/datum/brain_trauma/severe/split_personality/brainwashing/handle_speech(datum/source, list/speech_args)
	if(findtext(speech_args[SPEECH_MESSAGE], codeword))
		speech_args[SPEECH_MESSAGE] = "" //oh hey did you want to tell people about the secret word to bring you back?

/mob/living/split_personality/traitor
	name = "split personality"
	real_name = "unknown conscience"
	var/objective
	var/codeword

/mob/living/split_personality/traitor/Login()
	. = ..()
	if(!. || !client)
		return FALSE
	to_chat(src, "<span class='notice'>As a brainwashed personality, you cannot do anything yet but observe. However, you may gain control of your body if you hear the special codeword, switching places with the current personality.</span>")
	to_chat(src, "<span class='notice'>Your activation codeword is: <b>[codeword]</b></span>")
	if(objective)
		to_chat(src, span_notice("Your master left you an objective: <b>[objective]</b>. Follow it at all costs when in control."))

/datum/brain_trauma/severe/split_personality/blackout
	name = "Alcohol-Induced CNS Impairment"
	desc = "Patient's CNS has been temporarily impaired by imbibed alcohol, blocking memory formation, and causing reduced cognition and stupefaction."
	scan_desc = "alcohol-induced CNS impairment"
	gain_text = span_warning("Crap, that was one drink too many. You black out...")
	lose_text = "You wake up very, very confused and hungover. All you can remember is drinking a lot of alcohol... what happened?"
	poll_role = "blacked out drunkard"
	random_gain = FALSE
	/// Duration of effect, tracked in seconds, not deciseconds. qdels when reaching 0.
	var/duration_in_seconds = 180

/datum/brain_trauma/severe/split_personality/blackout/on_gain()
	. = ..()
	RegisterSignal(owner, COMSIG_ATOM_SPLASHED, PROC_REF(on_splashed))
	notify_ghosts(
		"[owner] is blacking out!",
		source = owner,
		header = "Bro I'm not even drunk right now",
		notify_flags = NOTIFY_CATEGORY_NOFLASH,
	)

/datum/brain_trauma/severe/split_personality/blackout/on_lose()
	. = ..()
	owner.add_mood_event("hang_over", /datum/mood_event/hang_over)
	UnregisterSignal(owner, COMSIG_ATOM_SPLASHED)

/datum/brain_trauma/severe/split_personality/blackout/proc/on_splashed()
	SIGNAL_HANDLER
	if(prob(20))//we don't want every single splash to wake them up now do we
		qdel(src)

/datum/brain_trauma/severe/split_personality/blackout/on_life(seconds_per_tick, times_fired)
	if(current_controller == OWNER && stranger_backseat)//we should only start transitioning after the other personality has entered
		owner.overlay_fullscreen("fade_to_black", /atom/movable/screen/fullscreen/blind)
		owner.clear_fullscreen("fade_to_black", animated = 4 SECONDS)
		switch_personalities()
	if(owner.stat == DEAD)
		if(current_controller != OWNER)
			switch_personalities(TRUE)
		qdel(src)
		return
	if(duration_in_seconds <= 0)
		qdel(src)
		return
	else if(duration_in_seconds <= 50)
		to_chat(owner, span_warning("You have 50 seconds left before sobering up!"))
	if(prob(10) && !HAS_TRAIT(owner, TRAIT_DISCOORDINATED_TOOL_USER))
		ADD_TRAIT(owner, TRAIT_DISCOORDINATED_TOOL_USER, TRAUMA_TRAIT)
		owner.balloon_alert(owner, "dexterity reduced temporarily!")
		//We then send a callback to automatically re-add the trait
		addtimer(TRAIT_CALLBACK_REMOVE(owner, TRAIT_DISCOORDINATED_TOOL_USER, TRAUMA_TRAIT), 10 SECONDS)
		addtimer(CALLBACK(owner, TYPE_PROC_REF(/atom, balloon_alert), owner, "dexterity regained!"), 10 SECONDS)
	if(prob(15))
		playsound(owner,'sound/effects/sf_hiccup_male_01.ogg', 50)
		owner.emote("hiccup")
	owner.adjustStaminaLoss(-5) //too drunk to feel anything
	duration_in_seconds -= seconds_per_tick

/mob/living/split_personality/blackout
	name = "blacked-out drunkard"
	real_name = "drunken consciousness"

/mob/living/split_personality/blackout/Login()
	. = ..()
	if(!. || !client)
		return FALSE
	to_chat(src, span_notice("You're the incredibly inebriated leftovers of your host's consciousness! Make sure to act the part and leave a trail of confusion and chaos in your wake."))
	to_chat(src, span_boldwarning("Do not commit suicide or put the body in danger, you have a minor liscense to grief just like a clown, do not kill anyone or create a situation leading to the body being in danger or in harm ways. While you're drunk, you're not suicidal."))

#undef OWNER
#undef STRANGER
