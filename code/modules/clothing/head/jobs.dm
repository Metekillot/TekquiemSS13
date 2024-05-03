//defines the drill hat's yelling setting
#define DRILL_DEFAULT	"default"
#define DRILL_SHOUTING	"shouting"
#define DRILL_YELLING	"yelling"
#define DRILL_CANADIAN	"canadian"

//Chef
/obj/item/clothing/head/chefhat
	name = "chef's hat"
	inhand_icon_state = "chef"
	icon_state = "chef"
	desc = "The commander in chef's head wear."
	strip_delay = 10
	equip_delay_other = 10
	dynamic_hair_suffix = ""
	pocket_storage_component_path = /datum/component/storage/concrete/pockets/chefhat
	dog_fashion = /datum/dog_fashion/head/chef
	///the chance that the movements of a mouse inside of this hat get relayed to the human wearing the hat
	var/mouse_control_probability = 20

/obj/item/clothing/head/chefhat/i_am_assuming_direct_control
	desc = "The commander in chef's head wear. Upon closer inspection, there seem to be dozens of tiny levers, buttons, dials, and screens inside of this hat. What the hell...?"
	mouse_control_probability = 100

/obj/item/clothing/head/chefhat/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is donning [src]! It looks like [user.p_theyre()] trying to become a chef.</span>")
	user.say("Bork Bork Bork!", forced = "chef hat suicide")
	sleep(20)
	user.visible_message("<span class='suicide'>[user] climbs into an imaginary oven!</span>")
	user.say("BOOORK!", forced = "chef hat suicide")
	playsound(user, 'sound/machines/ding.ogg', 50, TRUE)
	return(FIRELOSS)

/obj/item/clothing/head/chefhat/relaymove(mob/living/user, direction)
	if(!istype(user, /mob/living/simple_animal/mouse) || !isliving(loc) || !prob(mouse_control_probability))
		return
	var/mob/living/L = loc
	if(L.incapacitated(TRUE)) //just in case
		return
	step_towards(L, get_step(L, direction))

//Captain
/obj/item/clothing/head/caphat
	name = "captain's hat"
	desc = "It's good being the king."
	icon_state = "captain"
	inhand_icon_state = "that"
	flags_inv = 0
	armor = list(MELEE = 25, BULLET = 15, LASER = 25, ENERGY = 35, BOMB = 25, BIO = 0, RAD = 0, FIRE = 50, ACID = 50, WOUND = 5)
	strip_delay = 60
	dog_fashion = /datum/dog_fashion/head/captain

//Captain: This is no longer space-worthy
/obj/item/clothing/head/caphat/parade
	name = "captain's parade cap"
	desc = "Worn only by Captains with an abundance of class."
	icon_state = "capcap"

	dog_fashion = null


//Head of Personnel
/obj/item/clothing/head/hopcap
	name = "head of personnel's cap"
	icon_state = "hopcap"
	desc = "The symbol of true bureaucratic micromanagement."
	armor = list(MELEE = 25, BULLET = 15, LASER = 25, ENERGY = 35, BOMB = 25, BIO = 0, RAD = 0, FIRE = 50, ACID = 50)
	dog_fashion = /datum/dog_fashion/head/hop

//Chaplain
/obj/item/clothing/head/nun_hood
	name = "nun hood"
	desc = "Maximum piety in this star system."
	icon_state = "nun_hood"
	flags_inv = HIDEHAIR
	flags_cover = HEADCOVERSEYES

/obj/item/clothing/head/bishopmitre
	name = "bishop mitre"
	desc = "An opulent hat that functions as a radio to God. Or as a lightning rod, depending on who you ask."
	icon_state = "bishopmitre"

#define CANDY_CD_TIME 2 MINUTES

//Detective
/obj/item/clothing/head/fedora/det_hat
	name = "detective's fedora"
	desc = "There's only one man who can sniff out the dirty stench of crime, and he's likely wearing this hat."
	armor = list(MELEE = 25, BULLET = 5, LASER = 25, ENERGY = 35, BOMB = 0, BIO = 0, RAD = 0, FIRE = 30, ACID = 50, WOUND = 5)
	icon_state = "detective"
	inhand_icon_state = "det_hat"
	interaction_flags_click = NEED_DEXTERITY|NEED_HANDS|ALLOW_RESTING
	dog_fashion = /datum/dog_fashion/head/detective
	/// Path for the flask that spawns inside their hat roundstart
	var/flask_path = /obj/item/reagent_containers/cup/glass/flask/det
	/// Cooldown for retrieving precious candy corn with rmb
	COOLDOWN_DECLARE(candy_cooldown)


/datum/armor/fedora_det_hat
	melee = 25
	bullet = 5
	laser = 25
	energy = 35
	fire = 30
	acid = 50
	wound = 5


/obj/item/clothing/head/fedora/det_hat/Initialize(mapload)
	. = ..()

	create_storage(storage_type = /datum/storage/pockets/small/fedora/detective)

	register_context()

	new flask_path(src)


/obj/item/clothing/head/fedora/det_hat/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Alt-click to take a candy corn.</span>"


/obj/item/clothing/head/fedora/det_hat/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()

	context[SCREENTIP_CONTEXT_ALT_LMB] = "Candy Time"

	return CONTEXTUAL_SCREENTIP_SET


/// Now to solve where all these keep coming from
/obj/item/clothing/head/fedora/det_hat/click_alt(mob/user)
	if(!COOLDOWN_FINISHED(src, candy_cooldown))
		to_chat(user, span_warning("You just took a candy corn! You should wait a couple minutes, lest you burn through your stash."))
		return CLICK_ACTION_BLOCKING

	var/obj/item/food/candy_corn/sweets = new /obj/item/food/candy_corn(src)
	user.put_in_hands(sweets)
	to_chat(user, span_notice("You slip a candy corn from your hat."))
	COOLDOWN_START(src, candy_cooldown, CANDY_CD_TIME)

	return CLICK_ACTION_SUCCESS


#undef CANDY_CD_TIME

/obj/item/clothing/head/fedora/det_hat/minor
	flask_path = /obj/item/reagent_containers/cup/glass/flask/det/minor

///Detectives Fedora, but like Inspector Gadget. Not a subtype to not inherit candy corn stuff
/obj/item/clothing/head/fedora/inspector_hat
	name = "inspector's fedora"
	desc = "There's only one man can try to stop an evil villian."
	armor_type = /datum/armor/fedora_det_hat
	icon_state = "detective"
	inhand_icon_state = "det_hat"
	dog_fashion = /datum/dog_fashion/head/detective
	interaction_flags_click = FORBID_TELEKINESIS_REACH
	///prefix our phrases must begin with
	var/prefix = "go go gadget"
	///an assoc list of phrase = item (like gun = revolver)
	var/list/items_by_phrase = list()
	///how many gadgets can we hold
	var/max_items = 4
	///items above this weight cannot be put in the hat
	var/max_weight = WEIGHT_CLASS_NORMAL

/obj/item/clothing/head/fedora/inspector_hat/Initialize(mapload)
	. = ..()
	become_hearing_sensitive(ROUNDSTART_TRAIT)
	QDEL_NULL(atom_storage)

/obj/item/clothing/head/fedora/inspector_hat/examine(mob/user)
	. = ..()
	. += span_notice("You can put items inside, and get them out by saying a phrase, or using it in-hand!")
	. += span_notice("The prefix is <b>[prefix]</b>, and you can change it with alt-click!\n")
	for(var/phrase in items_by_phrase)
		var/obj/item/item = items_by_phrase[phrase]
		. += span_notice("[icon2html(item, user)] You can remove [item] by saying <b>\"[prefix] [phrase]\"</b>!")

/obj/item/clothing/head/fedora/inspector_hat/Hear(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, list/message_mods = list(), message_range)
	. = ..()
	var/mob/living/carbon/wearer = loc
	if(!istype(wearer) || speaker != wearer) //if we are worn
		return FALSE

	raw_message = htmlrendertext(raw_message)
	var/prefix_index = findtext(raw_message, prefix)
	if(prefix_index != 1)
		return FALSE

	var/the_phrase = trim_left(replacetext(raw_message, prefix, ""))
	var/obj/item/result = items_by_phrase[the_phrase]
	if(!result)
		return FALSE

	if(wearer.put_in_active_hand(result))
		wearer.visible_message(span_warning("[src] drops [result] into the hands of [wearer]!"))
	else
		balloon_alert(wearer, "cant put in hands!")

	return TRUE

/obj/item/clothing/head/fedora/inspector_hat/attackby(obj/item/item, mob/user, params)
	. = ..()

	if(LAZYLEN(contents) >= max_items)
		balloon_alert(user, "full!")
		return
	if(item.w_class > max_weight)
		balloon_alert(user, "too big!")
		return

	var/input = tgui_input_text(user, "What is the activation phrase?", "Activation phrase", "gadget", max_length = 26)
	if(!input || !user.can_perform_action(src, FORBID_TELEKINESIS_REACH))
		return
	if(input in items_by_phrase)
		balloon_alert(user, "already used!")
		return

	if(item.loc != user || !user.transferItemToLoc(item, src))
		return

	to_chat(user, span_notice("You install [item] into the [thtotext(contents.len)] slot in [src]."))
	playsound(src, 'sound/machines/click.ogg', 30, TRUE)
	items_by_phrase[input] = item

/obj/item/clothing/head/fedora/inspector_hat/attack_self(mob/user)
	. = ..()
	var/phrase = tgui_input_list(user, "What item do you want to remove by phrase?", "Item Removal", items_by_phrase)
	if(!phrase || !user.can_perform_action(src, FORBID_TELEKINESIS_REACH))
		return
	user.put_in_inactive_hand(items_by_phrase[phrase])

/obj/item/clothing/head/fedora/inspector_hat/click_alt(mob/user)
	var/new_prefix = tgui_input_text(user, "What should be the new prefix?", "Activation prefix", prefix, max_length = 24)
	if(!new_prefix || !user.can_perform_action(src, FORBID_TELEKINESIS_REACH))
		return CLICK_ACTION_BLOCKING
	prefix = new_prefix
	return CLICK_ACTION_SUCCESS

/obj/item/clothing/head/fedora/inspector_hat/Exited(atom/movable/gone, direction)
	. = ..()
	for(var/phrase in items_by_phrase)
		var/obj/item/result = items_by_phrase[phrase]
		if(gone == result)
			items_by_phrase -= phrase
			return

/obj/item/clothing/head/fedora/inspector_hat/atom_destruction(damage_flag)
	for(var/phrase in items_by_phrase)
		var/obj/item/result = items_by_phrase[phrase]
		result.forceMove(drop_location())
	items_by_phrase = null
	return ..()

/obj/item/clothing/head/fedora/inspector_hat/Destroy()
	QDEL_LIST_ASSOC(items_by_phrase)
	return ..()

//Mime
/obj/item/clothing/head/beret
	name = "beret"
	desc = "A beret, a mime's favorite headwear."
	icon_state = "beret"
	dog_fashion = /datum/dog_fashion/head/beret
	dynamic_hair_suffix = ""

/obj/item/clothing/head/beret/vintage
	name = "vintage beret"
	desc = "A well-worn beret."
	icon_state = "vintageberet"
	dog_fashion = null

/obj/item/clothing/head/beret/archaic
	name = "archaic beret"
	desc = "An absolutely ancient beret, allegedly worn by the first mime to ever step foot on a Nanotrasen station."
	icon_state = "archaicberet"
	dog_fashion = null

/obj/item/clothing/head/beret/black
	name = "black beret"
	desc = "A black beret, perfect for war veterans and dark, brooding, anti-hero mimes."
	icon_state = "beretblack"

/obj/item/clothing/head/beret/highlander
	desc = "That was white fabric. <i>Was.</i>"
	dog_fashion = null //THIS IS FOR SLAUGHTER, NOT PUPPIES

/obj/item/clothing/head/beret/highlander/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, HIGHLANDER)

/obj/item/clothing/head/beret/durathread
	name = "durathread beret"
	desc =  "A beret made from durathread, its resilient fibres provide some protection to the wearer."
	icon_state = "beretdurathread"
	armor = list(MELEE = 15, BULLET = 5, LASER = 15, ENERGY = 25, BOMB = 10, BIO = 0, RAD = 0, FIRE = 30, ACID = 5, WOUND = 4)

//Security

/obj/item/clothing/head/hos
	name = "head of security cap"
	desc = "The robust standard-issue cap of the Head of Security. For showing the officers who's in charge."
	icon_state = "hoscap"
	armor = list(MELEE = 40, BULLET = 30, LASER = 25, ENERGY = 35, BOMB = 25, BIO = 10, RAD = 0, FIRE = 50, ACID = 60, WOUND = 10)
	strip_delay = 80
	dynamic_hair_suffix = ""

/obj/item/clothing/head/hos/syndicate
	name = "syndicate cap"
	desc = "A black cap fit for a high ranking syndicate officer."

/obj/item/clothing/head/hos/beret
	name = "head of security beret"
	desc = "A robust beret for the Head of Security, for looking stylish while not sacrificing protection."
	icon_state = "hosberetblack"

/obj/item/clothing/head/hos/beret/syndicate
	name = "syndicate beret"
	desc = "A black beret with thick armor padding inside. Stylish and robust."

/obj/item/clothing/head/warden
	name = "warden's police hat"
	desc = "It's a special armored hat issued to the Warden of a security force. Protects the head from impacts."
	icon_state = "policehelm"
	armor = list(MELEE = 40, BULLET = 30, LASER = 30, ENERGY = 40, BOMB = 25, BIO = 0, RAD = 0, FIRE = 30, ACID = 60, WOUND = 6)
	strip_delay = 60
	dog_fashion = /datum/dog_fashion/head/warden

/obj/item/clothing/head/warden/drill
	name = "warden's campaign hat"
	desc = "A special armored campaign hat with the security insignia emblazoned on it. Uses reinforced fabric to offer sufficient protection."
	icon_state = "wardendrill"
	inhand_icon_state = "wardendrill"
	dog_fashion = null
	var/mode = DRILL_DEFAULT

/obj/item/clothing/head/warden/drill/screwdriver_act(mob/living/carbon/human/user, obj/item/I)
	if(..())
		return TRUE
	switch(mode)
		if(DRILL_DEFAULT)
			to_chat(user, "<span class='notice'>You set the voice circuit to the middle position.</span>")
			mode = DRILL_SHOUTING
		if(DRILL_SHOUTING)
			to_chat(user, "<span class='notice'>You set the voice circuit to the last position.</span>")
			mode = DRILL_YELLING
		if(DRILL_YELLING)
			to_chat(user, "<span class='notice'>You set the voice circuit to the first position.</span>")
			mode = DRILL_DEFAULT
		if(DRILL_CANADIAN)
			to_chat(user, "<span class='danger'>You adjust voice circuit but nothing happens, probably because it's broken.</span>")
	return TRUE

/obj/item/clothing/head/warden/drill/wirecutter_act(mob/living/user, obj/item/I)
	..()
	if(mode != DRILL_CANADIAN)
		to_chat(user, "<span class='danger'>You broke the voice circuit!</span>")
		mode = DRILL_CANADIAN
	return TRUE

/obj/item/clothing/head/warden/drill/equipped(mob/M, slot)
	. = ..()
	if (slot == ITEM_SLOT_HEAD)
		RegisterSignal(M, COMSIG_MOB_SAY, PROC_REF(handle_speech))
	else
		UnregisterSignal(M, COMSIG_MOB_SAY)

/obj/item/clothing/head/warden/drill/dropped(mob/M)
	. = ..()
	UnregisterSignal(M, COMSIG_MOB_SAY)

/obj/item/clothing/head/warden/drill/proc/handle_speech(datum/source, mob/speech_args)
	var/message = speech_args[SPEECH_MESSAGE]
	if(message[1] != "*")
		switch (mode)
			if(DRILL_SHOUTING)
				message += "!"
			if(DRILL_YELLING)
				message += "!!"
			if(DRILL_CANADIAN)
				message = " [message]"
				var/list/canadian_words = strings("canadian_replacement.json", "canadian")

				for(var/key in canadian_words)
					var/value = canadian_words[key]
					if(islist(value))
						value = pick(value)

					message = replacetextEx(message, " [uppertext(key)]", " [uppertext(value)]")
					message = replacetextEx(message, " [capitalize(key)]", " [capitalize(value)]")
					message = replacetextEx(message, " [key]", " [value]")

				if(prob(30))
					message += pick(", eh?", ", EH?")
		speech_args[SPEECH_MESSAGE] = message

/obj/item/clothing/head/beret/sec
	name = "security beret"
	desc = "A robust beret with the security insignia emblazoned on it. Uses reinforced fabric to offer sufficient protection."
	icon_state = "beret_badge"
	armor = list(MELEE = 40, BULLET = 30, LASER = 30, ENERGY = 40, BOMB = 25, BIO = 0, RAD = 0, FIRE = 20, ACID = 50, WOUND = 4)
	strip_delay = 60
	dog_fashion = null

/obj/item/clothing/head/beret/sec/navyhos
	name = "head of security's beret"
	desc = "A special beret with the Head of Security's insignia emblazoned on it. A symbol of excellence, a badge of courage, a mark of distinction."
	icon_state = "hosberet"

/obj/item/clothing/head/beret/sec/navywarden
	name = "warden's beret"
	desc = "A special beret with the Warden's insignia emblazoned on it. For wardens with class."
	icon_state = "wardenberet"
	armor = list(MELEE = 40, BULLET = 30, LASER = 30, ENERGY = 40, BOMB = 25, BIO = 0, RAD = 0, FIRE = 30, ACID = 50, WOUND = 6)
	strip_delay = 60

/obj/item/clothing/head/beret/sec/navyofficer
	desc = "A special beret with the security insignia emblazoned on it. For officers with class."
	icon_state = "officerberet"

//Science

/obj/item/clothing/head/beret/science
	name = "science beret"
	desc = "A science-themed beret for our hardworking scientists."
	icon_state = "sciberet"

//Curator
/obj/item/clothing/head/fedora/curator
	name = "treasure hunter's fedora"
	desc = "You got red text today kid, but it doesn't mean you have to like it."
	icon_state = "curator"

#undef DRILL_DEFAULT
#undef DRILL_SHOUTING
#undef DRILL_YELLING
#undef DRILL_CANADIAN
