/**
 * x1, y1, x2, y2 - Represents the bounding box for the ID card's non-transparent portion of its various icon_states.
 * Used to crop the ID card's transparency away when chaching the icon for better use in tgui chat.
 */
#define ID_ICON_BORDERS 1, 9, 32, 24

/// Fallback time if none of the config entries are set for USE_LOW_LIVING_HOUR_INTERN
#define INTERN_THRESHOLD_FALLBACK_HOURS 15

/// Max time interval between projecting holopays
#define HOLOPAY_PROJECTION_INTERVAL 7 SECONDS

/* Cards
 * Contains:
 *		DATA CARD
 *		ID CARD
 *		FINGERPRINT CARD HOLDER
 *		FINGERPRINT CARD
 */



/*
 * DATA CARDS - Used for the IC data card reader
 */

/obj/item/card
	name = "card"
	desc = "Does card things."
	icon = 'icons/obj/card.dmi'
	w_class = WEIGHT_CLASS_TINY

	var/list/files = list()

/obj/item/card/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] begins to swipe [user.p_their()] neck with \the [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return BRUTELOSS

/obj/item/card/data
	name = "data card"
	desc = "A plastic magstripe card for simple and speedy data storage and transfer. This one has a stripe running down the middle."
	icon_state = "data_1"
	obj_flags = UNIQUE_RENAME
	var/function = "storage"
	var/data = "null"
	var/special = null
	inhand_icon_state = "card-id"
	lefthand_file = 'icons/mob/inhands/equipment/idcards_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/idcards_righthand.dmi'
	var/detail_color = COLOR_ASSEMBLY_ORANGE

/obj/item/card/data/Initialize()
	.=..()
	update_icon()

/obj/item/card/data/update_overlays()
	. = ..()
	if(detail_color == COLOR_FLOORTILE_GRAY)
		return
	var/mutable_appearance/detail_overlay = mutable_appearance('icons/obj/card.dmi', "[icon_state]-color")
	detail_overlay.color = detail_color
	. += detail_overlay

/obj/item/card/data/full_color
	desc = "A plastic magstripe card for simple and speedy data storage and transfer. This one has the entire card colored."
	icon_state = "data_2"

/obj/item/card/data/disk
	desc = "A plastic magstripe card for simple and speedy data storage and transfer. This one inexplicibly looks like a floppy disk."
	icon_state = "data_3"

/*
 * ID CARDS
 */

/obj/item/card/id
	name = "identification card"
	desc = "A card used to provide ID and determine access across the station."
	icon_state = "id"
	inhand_icon_state = "card-id"
	lefthand_file = 'icons/mob/inhands/equipment/idcards_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/idcards_righthand.dmi'
	slot_flags = ITEM_SLOT_ID
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 100, ACID = 100)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	var/id_type_name = "identification card"
	var/mining_points = 0 //For redeeming at mining equipment vendors
	///The stuff that makes you open doors and shit
	var/list/access = list()
	///Access that cannot be removed by the ID console. Do not add access levels that are actually visible in the console here if a HoP knowing what kind of ID he's modifying is a concern.
	var/list/sticky_access
	/// The name registered on the card (for example: Dr Bryan See)
	var/registered_name = null
	///The job name registered on the card (for example: Assistant)
	var/assignment = null
	/// mapping aid
	var/access_txt
	var/datum/bank_account/registered_account

	/// Linked holopay.
	var/datum/weakref/holopay_ref
	/// Cooldown between projecting holopays
	COOLDOWN_DECLARE(last_holopay_projection)
	/// List of logos available for holopay customization - via font awesome 5
	var/static/list/available_logos = list("angry", "ankh", "bacon", "band-aid", "cannabis", "cat", "cocktail", "coins", "comments-dollar",
	"cross", "cut", "dog", "donate", "dna", "fist-raised", "flask", "glass-cheers", "glass-martini-alt", "hamburger", "hand-holding-usd",
	"hat-wizard", "head-side-cough-slash", "heart", "heart-broken",  "laugh-beam", "leaf", "money-check-alt", "music", "piggy-bank",
	"pizza-slice", "prescription-bottle-alt", "radiation", "robot", "smile", "skull-crossbones", "smoking", "space-shuttle", "tram",
	"trash", "user-ninja", "utensils", "wrench")
	/// Replaces the "pay whatever" functionality with a set amount when non-zero.
	var/holopay_fee = 0
	/// The holopay icon chosen by the user
	var/holopay_logo = "donate"
	/// Maximum forced fee. It's unlikely for a user to encounter this type of money, much less pay it willingly.
	var/holopay_max_fee = 5000
	/// Minimum forced fee for holopay stations. Registers as "pay what you want."
	var/holopay_min_fee = 0
	/// The holopay name chosen by the user
	var/holopay_name = "holographic pay stand"

	/// Registered owner's age.
	var/registered_age = 30

	/// The job name registered on the card (for example: Assistant).
	var/assignment

	/// Trim datum associated with the card. Controls which job icon is displayed on the card and which accesses do not require wildcards.
	var/datum/id_trim/trim

	/// Access levels held by this card.
	var/list/access = list()

	/// List of wildcard slot names as keys with lists of wildcard data as values.
	var/list/wildcard_slots = list()

	/// Boolean value. If TRUE, the [Intern] tag gets prepended to this ID card when the label is updated.
	var/is_intern = FALSE

/obj/item/card/id/Initialize(mapload)
	. = ..()
	if(mapload && access_txt)
		access = text2access(access_txt)
	RegisterSignal(src, COMSIG_ATOM_UPDATED_ICON, PROC_REF(update_in_wallet))

/obj/item/card/id/Destroy()
	if (registered_account)
		registered_account.bank_cards -= src
	if (holopay_ref)
		QDEL_NULL(holopay_ref)
	return ..()

/obj/item/card/id/attack_self(mob/user)
	if(Adjacent(user))
		var/minor
		if(registered_name && registered_age && registered_age < AGE_MINOR)
			minor = " <b>(MINOR)</b>"
		user.visible_message("<span class='notice'>[user] shows you: [icon2html(src, viewers(user))] [src.name][minor].</span>", "<span class='notice'>You show \the [src.name][minor].</span>")
	add_fingerprint(user)

/obj/item/card/id/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	/// Sanity checks
	var/obj/structure/holopay/my_store = holopay_ref?.resolve()
	if(my_store)
		my_store.dissapate()
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(!COOLDOWN_FINISHED(src, last_holopay_projection))
		balloon_alert(user, "still recharging")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(!registered_account || !registered_account.account_job)
		balloon_alert(user, "no account")
		to_chat(user, span_warning("You need a valid bank account to do this."))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	/// Determines where the holopay will be placed based on tile contents
	var/turf/projection
	var/turf/step_ahead = get_step(user, user.dir)
	var/turf/user_loc = user.loc
	if(can_proj_holopay(step_ahead))
		projection = step_ahead
	else if(can_proj_holopay(user_loc))
		projection = user_loc
	if(!projection)
		balloon_alert(user, "no space")
		to_chat(user, span_warning("You need to be standing on or near an open tile to do this."))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	/// Success: Valid tile for holopay placement
	var/obj/structure/holopay/new_store = new(projection)
	if(new_store?.assign_card(projection, src))
		COOLDOWN_START(src, last_holopay_projection, HOLOPAY_PROJECTION_INTERVAL)
		playsound(projection, "sound/effects/empulse.ogg", 40, TRUE)
		holopay_ref = WEAKREF(new_store)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/**
 * Determines whether a new holopay can be placed on the given turf.
 * Checks if there are dense contents, too many contents, or another
 * holopay already exists on the turf.
 *
 * Arguments:
 * * turf/target - The target turf to be checked for dense contents
 * Returns:
 * * TRUE if the target is a valid holopay location, FALSE otherwise.
 */
/obj/item/card/id/proc/can_proj_holopay(turf/target)
	if(!isfloorturf(target))
		return FALSE
	if(target.density)
		return FALSE
	if(length(target.contents) > 5)
		return FALSE
	for(var/obj/checked_obj in target.contents)
		if(checked_obj.density)
			return FALSE
		if(istype(checked_obj, /obj/structure/holopay))
			return FALSE
	return TRUE

/**
 * Setter for the shop logo on linked holopays
 *
 * Arguments:
 * * new_logo - The new logo to be set.
 */
/obj/item/card/id/proc/set_holopay_logo(new_logo)
	if(!available_logos.Find(new_logo))
		CRASH("User input a holopay shop logo that didn't exist.")
	holopay_logo = new_logo

/**
 * Setter for changing the force fee on a holopay.
 *
 * Arguments:
 * * new_fee - The new fee to be set.
 */
/obj/item/card/id/proc/set_holopay_fee(new_fee)
	if(!isnum(new_fee))
		CRASH("User input a non number into the holopay fee field.")
	if(new_fee < holopay_min_fee || new_fee > holopay_max_fee)
		CRASH("User input a number outside of the valid range into the holopay fee field.")
	holopay_fee = new_fee

/**
 * Setter for changing the holopay name.
 *
 * Arguments:
 * * new_name - The new name to be set.
 */
/obj/item/card/id/proc/set_holopay_name(name)
	if(length(name) < 3 || length(name) > MAX_NAME_LEN)
		to_chat(usr, span_warning("Must be between 3 - 42 characters."))
	else
		holopay_name = html_encode(trim(name, MAX_NAME_LEN))


/obj/item/card/id/vv_edit_var(var_name, var_value)
	. = ..()
	if(.)
		switch(var_name)
			if(NAMEOF(src, assignment),NAMEOF(src, registered_name),NAMEOF(src, registered_age))
				update_label()

/obj/item/card/id/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/holochip))
		insert_money(W, user)
		return
	else if(istype(W, /obj/item/stack/spacecash))
		insert_money(W, user, TRUE)
		return
	else if(istype(W, /obj/item/coin))
		insert_money(W, user, TRUE)
		return
	else if(istype(W, /obj/item/storage/bag/money))
		var/obj/item/storage/bag/money/money_bag = W
		var/list/money_contained = money_bag.contents

		var/money_added = mass_insert_money(money_contained, user)

		if (money_added)
			to_chat(user, "<span class='notice'>You stuff the contents into the card! They disappear in a puff of bluespace smoke, adding [money_added] worth of credits to the linked account.</span>")
		return
	else
		return ..()

/obj/item/card/id/proc/insert_money(obj/item/I, mob/user, physical_currency)
	if(!registered_account)
		to_chat(user, "<span class='warning'>[src] doesn't have a linked account to deposit [I] into!</span>")
		return
	var/cash_money = I.get_item_credit_value()
	if(!cash_money)
		to_chat(user, "<span class='warning'>[I] doesn't seem to be worth anything!</span>")
		return
	registered_account.adjust_money(cash_money)
	SSblackbox.record_feedback("amount", "credits_inserted", cash_money)
	log_econ("[cash_money] credits were inserted into [src] owned by [src.registered_name]")
	if(physical_currency)
		to_chat(user, "<span class='notice'>You stuff [I] into [src]. It disappears in a small puff of bluespace smoke, adding [cash_money] credits to the linked account.</span>")
	else
		to_chat(user, "<span class='notice'>You insert [I] into [src], adding [cash_money] credits to the linked account.</span>")

	to_chat(user, "<span class='notice'>The linked account now reports a balance of [registered_account.account_balance] cr.</span>")
	qdel(I)

/obj/item/card/id/proc/mass_insert_money(list/money, mob/user)
	if(!registered_account)
		to_chat(user, "<span class='warning'>[src] doesn't have a linked account to deposit into!</span>")
		return FALSE

	if (!money || !length(money))
		return FALSE

	var/total = 0

	for (var/obj/item/physical_money in money)
		total += physical_money.get_item_credit_value()
		CHECK_TICK

	registered_account.adjust_money(total)
	SSblackbox.record_feedback("amount", "credits_inserted", total)
	log_econ("[total] credits were inserted into [src] owned by [src.registered_name]")
	QDEL_LIST(money)

	return total

/obj/item/card/id/proc/alt_click_can_use_id(mob/living/user)
	if(!isliving(user))
		return
	if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		return

	return TRUE

// Returns true if new account was set.
/obj/item/card/id/proc/set_new_account(mob/living/user)
	. = FALSE
	var/datum/bank_account/old_account = registered_account
	if(loc != user)
		to_chat(user, span_warning("You must be holding the ID to continue!"))
		return FALSE
	var/new_bank_id = tgui_input_number(user, "Enter your account ID number", "Account Reclamation", 111111, 999999, 111111)
	if(!new_bank_id || QDELETED(user) || QDELETED(src) || issilicon(user) || !alt_click_can_use_id(user) || loc != user)
		return FALSE
	if(registered_account?.account_id == new_bank_id)
		to_chat(user, span_warning("The account ID was already assigned to this card."))
		return FALSE
	var/datum/bank_account/account = SSeconomy.bank_accounts_by_id["[new_bank_id]"]
	if(isnull(account))
		to_chat(user, span_warning("The account ID number provided is invalid."))
		return FALSE
	if(old_account)
		old_account.bank_cards -= src
	account.bank_cards += src
	registered_account = account
	to_chat(user, span_notice("The provided account has been linked to this ID card."))
	return TRUE

/obj/item/card/id/AltClick(mob/living/user)
	return
	//[Lucia] - defunct code below commented out for error cleaning
	/*
	if(!alt_click_can_use_id(user))
		return
	if(!registered_account)
		set_new_account(user)
		return
	if (registered_account.being_dumped)
		registered_account.bank_card_talk("<span class='warning'>内部服务器错误</span>", TRUE)
		return
	if(loc != user)
		to_chat(user, span_warning("You must be holding the ID to continue!"))
		return
	var/amount_to_remove = tgui_input_number(user, "How much do you want to withdraw? (Max: [registered_account.account_balance] cr)", "Withdraw Funds", max_value = registered_account.account_balance)
	if(!amount_to_remove || QDELETED(user) || QDELETED(src) || issilicon(user) || loc != user)
		return
	if(!alt_click_can_use_id(user))
		return
	if(registered_account.adjust_money(-amount_to_remove))
		var/obj/item/holochip/holochip = new (user.drop_location(), amount_to_remove)
		user.put_in_hands(holochip)
		to_chat(user, "<span class='notice'>You withdraw [amount_to_remove] credits into a holochip.</span>")
		SSblackbox.record_feedback("amount", "credits_removed", amount_to_remove)
		log_econ("[amount_to_remove] credits were removed from [src] owned by [src.registered_name]")
		return
	else
		var/difference = amount_to_remove - registered_account.account_balance
		registered_account.bank_card_talk("<span class='warning'>ERROR: The linked account requires [difference] more credit\s to perform that withdrawal.</span>", TRUE)
	*/

/obj/item/card/id/examine(mob/user)
	. = ..()
	if(registered_account)
		. += "The account linked to the ID belongs to '[registered_account.account_holder]' and reports a balance of [registered_account.account_balance] cr."
	. += "<span class='notice'><i>There's more information below, you can look again to take a closer look...</i></span>"

/obj/item/card/id/examine_more(mob/user)
	var/list/msg = list("<span class='notice'><i>You examine [src] closer, and note the following...</i></span>")

	if(registered_age)
		msg += "The card indicates that the holder is [registered_age] years old. [(registered_age < AGE_MINOR) ? "There's a holographic stripe that reads <b><span class='danger'>'MINOR: DO NOT SERVE ALCOHOL OR TOBACCO'</span></b> along the bottom of the card." : ""]"
	if(mining_points)
		msg += "There's [mining_points] mining equipment redemption point\s loaded onto this card."
	if(registered_account)
		msg += "The account linked to the ID belongs to '[registered_account.account_holder]' and reports a balance of [registered_account.account_balance] cr."
		if(registered_account.account_job)
			var/datum/bank_account/D = SSeconomy.get_dep_account(registered_account.account_job.paycheck_department)
			if(D)
				msg += "The [D.account_holder] reports a balance of [D.account_balance] cr."
		msg += "<span class='info'>Alt-Click the ID to pull money from the linked account in the form of holochips.</span>"
		msg += "<span class='info'>You can insert credits into the linked account by pressing holochips, cash, or coins against the ID.</span>"
		if(registered_account.civilian_bounty)
			msg += "<span class='info'><b>There is an active civilian bounty.</b>"
			msg += "<span class='info'><i>[registered_account.bounty_text()]</i></span>"
			msg += "<span class='info'>Quantity: [registered_account.bounty_num()]</span>"
			msg += "<span class='info'>Reward: [registered_account.bounty_value()]</span>"
		if(registered_account.account_holder == user.real_name)
			msg += "<span class='boldnotice'>If you lose this ID card, you can reclaim your account by Alt-Clicking a blank ID card while holding it and entering your account ID number.</span>"
	else
		msg += "<span class='info'>There is no registered account linked to this card. Alt-Click to add one.</span>"

	return msg

/obj/item/card/id/GetAccess()
	return access

/obj/item/card/id/GetID()
	return src

/obj/item/card/id/RemoveID()
	return src

/obj/item/card/id/update_overlays()
	. = ..()
	if(!uses_overlays)
		return
	cached_flat_icon = null
	var/job = assignment ? ckey(GetJobName()) : null
	if(registered_name && registered_name != "Captain")
		. += mutable_appearance(icon, "assigned")
	if(job)
		. += mutable_appearance(icon, "id[job]")

/obj/item/card/id/proc/update_in_wallet()
	SIGNAL_HANDLER

	if(istype(loc, /obj/item/storage/wallet))
		var/obj/item/storage/wallet/powergaming = loc
		if(powergaming.front_id == src)
			powergaming.update_label()
			powergaming.update_icon()

/obj/item/card/id/proc/get_cached_flat_icon()
	if(!cached_flat_icon)
		cached_flat_icon = getFlatIcon(src)
	return cached_flat_icon


/obj/item/card/id/get_examine_string(mob/user, thats = FALSE)
	if(uses_overlays)
		return "[icon2html(get_cached_flat_icon(), user)] [thats? "That's ":""][get_examine_name(user)]" //displays all overlays in chat
	return ..()

/*
Usage:
update_label()
	Sets the id name to whatever registered_name and assignment is
*/

/obj/item/card/id/proc/update_label()
	var/blank = !registered_name
	name = "[blank ? id_type_name : "[registered_name]'s"] [initial(name)]"
	update_icon()

/obj/item/card/id/silver
	name = "silver identification card"
	id_type_name = "silver identification card"
	desc = "A silver card which shows honour and dedication."
	icon_state = "silver"
	inhand_icon_state = "silver_id"
	lefthand_file = 'icons/mob/inhands/equipment/idcards_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/idcards_righthand.dmi'

/obj/item/card/id/silver/reaper
	name = "Thirteen's ID Card (Reaper)"
	access = list(ACCESS_MAINT_TUNNELS)
	assignment = "Reaper"
	registered_name = "Thirteen"

/obj/item/card/id/gold
	name = "gold identification card"
	id_type_name = "gold identification card"
	desc = "A golden card which shows power and might."
	icon_state = "gold"
	inhand_icon_state = "gold_id"
	lefthand_file = 'icons/mob/inhands/equipment/idcards_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/idcards_righthand.dmi'

/obj/item/card/id/syndicate
	name = "agent card"
	access = list(ACCESS_MAINT_TUNNELS, ACCESS_SYNDICATE)
	sticky_access = list(ACCESS_SYNDICATE)
	///Can anyone forge the ID or just syndicate?
	var/anyone = FALSE
	///have we set a custom name and job assignment, or will we use what we're given when we chameleon change?
	var/forged = FALSE

/obj/item/card/id/syndicate/Initialize()
	. = ..()
	var/datum/action/item_action/chameleon/change/id/chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/card/id
	chameleon_action.chameleon_name = "ID Card"
	chameleon_action.initialize_disguises()

/obj/item/card/id/syndicate/afterattack(obj/item/O, mob/user, proximity)
	if(!proximity)
		return
	if(istype(O, /obj/item/card/id))
		var/obj/item/card/id/I = O
		src.access |= I.access
		if(isliving(user) && user.mind)
			if(user.mind.special_role || anyone)
				to_chat(usr, "<span class='notice'>The card's microscanners activate as you pass it over the ID, copying its access.</span>")

/obj/item/card/id/syndicate/attack_self(mob/user)
	if(isliving(user) && user.mind)
		var/first_use = registered_name ? FALSE : TRUE
		if(!(user.mind.special_role || anyone)) //Unless anyone is allowed, only syndies can use the card, to stop metagaming.
			if(first_use) //If a non-syndie is the first to forge an unassigned agent ID, then anyone can forge it.
				anyone = TRUE
			else
				return ..()

		var/popup_input = alert(user, "Choose Action", "Agent ID", "Show", "Forge/Reset", "Change Account ID")
		if(user.incapacitated())
			return
		if(popup_input == "Forge/Reset" && !forged)
			var/input_name = stripped_input(user, "What name would you like to put on this card? Leave blank to randomise.", "Agent card name", registered_name ? registered_name : (ishuman(user) ? user.real_name : user.name), MAX_NAME_LEN)
			input_name = sanitize_name(input_name)
			if(!input_name)
				// Invalid/blank names give a randomly generated one.
				if(user.gender == MALE)
					input_name = "[pick(GLOB.first_names_male)] [pick(GLOB.last_names)]"
				else if(user.gender == FEMALE)
					input_name = "[pick(GLOB.first_names_female)] [pick(GLOB.last_names)]"
				else
					input_name = "[pick(GLOB.first_names)] [pick(GLOB.last_names)]"

			var/target_occupation = stripped_input(user, "What occupation would you like to put on this card?\nNote: This will not grant any access levels other than Maintenance.", "Agent card job assignment", assignment ? assignment : "Assistant", MAX_MESSAGE_LEN)
			if(!target_occupation)
				return

			var/newAge = input(user, "Choose the ID's age:\n([AGE_MIN]-[AGE_MAX])", "Agent card age") as num|null
			if(newAge)
				registered_age = max(round(text2num(newAge)), 0)

			registered_name = input_name
			assignment = target_occupation
			update_label()
			forged = TRUE
			to_chat(user, "<span class='notice'>You successfully forge the ID card.</span>")
			log_game("[key_name(user)] has forged \the [initial(name)] with name \"[registered_name]\" and occupation \"[assignment]\".")

			// First time use automatically sets the account id to the user.
			if (first_use && !registered_account)
				if(ishuman(user))
					var/mob/living/carbon/human/accountowner = user

					var/datum/bank_account/account = SSeconomy.bank_accounts_by_id["[accountowner.account_id]"]
					if(account)
						account.bank_cards += src
						registered_account = account
						to_chat(user, "<span class='notice'>Your account number has been automatically assigned.</span>")
			return
		else if (popup_input == "Forge/Reset" && forged)
			registered_name = initial(registered_name)
			assignment = initial(assignment)
			log_game("[key_name(user)] has reset \the [initial(name)] named \"[src]\" to default.")
			update_label()
			forged = FALSE
			to_chat(user, "<span class='notice'>You successfully reset the ID card.</span>")
			return
		else if (popup_input == "Change Account ID")
			set_new_account(user)
			return
	return ..()

/obj/item/card/id/syndicate/anyone
	anyone = TRUE

/obj/item/card/id/syndicate/nuke_leader
	name = "lead agent card"
	access = list(ACCESS_MAINT_TUNNELS, ACCESS_SYNDICATE, ACCESS_SYNDICATE_LEADER)
	sticky_access = list(ACCESS_SYNDICATE, ACCESS_SYNDICATE_LEADER)

/obj/item/card/id/syndicate_command
	name = "syndicate ID card"
	id_type_name = "syndicate ID card"
	desc = "An ID straight from the Syndicate."
	registered_name = "Syndicate"
	assignment = "Syndicate Overlord"
	icon_state = "syndie"
	access = list(ACCESS_SYNDICATE)
	sticky_access = list(ACCESS_SYNDICATE)
	uses_overlays = FALSE
	registered_age = null

/obj/item/card/id/syndicate_command/crew_id
	name = "syndicate ID card"
	id_type_name = "syndicate ID card"
	desc = "An ID straight from the Syndicate."
	registered_name = "Syndicate"
	assignment = "Syndicate Operative"
	icon_state = "syndie"
	access = list(ACCESS_SYNDICATE, ACCESS_ROBOTICS)
	sticky_access = list(ACCESS_SYNDICATE)
	uses_overlays = FALSE

/obj/item/card/id/syndicate_command/captain_id
	name = "syndicate captain ID card"
	id_type_name = "syndicate captain ID card"
	desc = "An ID straight from the Syndicate."
	registered_name = "Syndicate"
	assignment = "Syndicate Ship Captain"
	icon_state = "syndie"
	access = list(ACCESS_SYNDICATE, ACCESS_ROBOTICS)
	sticky_access = list(ACCESS_SYNDICATE)
	uses_overlays = FALSE

/obj/item/card/id/captains_spare
	name = "captain's spare ID"
	id_type_name = "captain's spare ID"
	desc = "The spare ID of the High Lord himself."
	icon_state = "gold"
	inhand_icon_state = "gold_id"
	lefthand_file = 'icons/mob/inhands/equipment/idcards_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/idcards_righthand.dmi'
	registered_name = "Captain"
	assignment = "Captain"
	registered_age = null

/obj/item/card/id/captains_spare/Initialize()
	var/datum/job/captain/J = new/datum/job/captain
	access = J.get_access()
	. = ..()
	update_label()

/obj/item/card/id/captains_spare/update_label() //so it doesn't change to Captain's ID card (Captain) on a sneeze
	if(registered_name == "Captain")
		name = "[id_type_name][(!assignment || assignment == "Captain") ? "" : " ([assignment])"]"
		update_icon()
	else
		..()

/obj/item/card/id/centcom
	name = "\improper CentCom ID"
	id_type_name = "\improper CentCom ID"
	desc = "An ID straight from Central Command."
	icon_state = "centcom"
	registered_name = "Central Command"
	assignment = "Central Command"
	uses_overlays = FALSE
	registered_age = null

/obj/item/card/id/centcom/Initialize()
	access = get_all_centcom_access()
	. = ..()

/obj/item/card/id/ert
	name = "\improper CentCom ID"
	id_type_name = "\improper CentCom ID"
	desc = "An ERT ID card."
	icon_state = "ert_commander"
	registered_name = "Emergency Response Team Commander"
	assignment = "Emergency Response Team Commander"
	uses_overlays = FALSE
	registered_age = null

/obj/item/card/id/ert/Initialize()
	access = get_all_accesses()+get_ert_access("commander")-ACCESS_CHANGE_IDS
	. = ..()

/obj/item/card/id/ert/security
	registered_name = "Security Response Officer"
	assignment = "Security Response Officer"
	icon_state = "ert_security"

/obj/item/card/id/ert/security/Initialize()
	access = get_all_accesses()+get_ert_access("sec")-ACCESS_CHANGE_IDS
	. = ..()

/obj/item/card/id/ert/engineer
	registered_name = "Engineering Response Officer"
	assignment = "Engineering Response Officer"
	icon_state = "ert_engineer"

/obj/item/card/id/ert/engineer/Initialize()
	access = get_all_accesses()+get_ert_access("eng")-ACCESS_CHANGE_IDS
	. = ..()

/obj/item/card/id/ert/medical
	registered_name = "Medical Response Officer"
	assignment = "Medical Response Officer"
	icon_state = "ert_medic"

/obj/item/card/id/ert/medical/Initialize()
	access = get_all_accesses()+get_ert_access("med")-ACCESS_CHANGE_IDS
	. = ..()

/obj/item/card/id/ert/chaplain
	registered_name = "Religious Response Officer"
	assignment = "Religious Response Officer"
	icon_state = "ert_chaplain"

/obj/item/card/id/ert/chaplain/Initialize()
	access = get_all_accesses()+get_ert_access("sec")-ACCESS_CHANGE_IDS
	. = ..()

/obj/item/card/id/ert/janitor
	registered_name = "Janitorial Response Officer"
	assignment = "Janitorial Response Officer"
	icon_state = "ert_janitor"

/obj/item/card/id/ert/janitor/Initialize()
	access = get_all_accesses()
	. = ..()

/obj/item/card/id/ert/clown
	registered_name = "Entertainment Response Officer"
	assignment = "Entertainment Response Officer"
	icon_state = "ert_clown"

/obj/item/card/id/ert/clown/Initialize()
	access = get_all_accesses()
	. = ..()

/obj/item/card/id/ert/deathsquad
	name = "\improper Death Squad ID"
	id_type_name = "\improper Death Squad ID"
	desc = "A Death Squad ID card."
	icon_state = "deathsquad" //NO NO SIR DEATH SQUADS ARENT A PART OF NANOTRASEN AT ALL
	registered_name = "Death Commando"
	assignment = "Death Commando"
	uses_overlays = FALSE

/obj/item/card/id/debug
	name = "\improper Debug ID"
	desc = "A debug ID card. Has ALL the all access, you really shouldn't have this."
	icon_state = "ert_janitor"
	assignment = "Jannie"
	uses_overlays = FALSE

/obj/item/card/id/debug/Initialize()
	access = get_all_accesses()+get_all_centcom_access()+get_all_syndicate_access()
	registered_account = SSeconomy.get_dep_account(ACCOUNT_CAR)
	. = ..()

/obj/item/card/id/prisoner
	name = "prisoner ID card"
	id_type_name = "prisoner ID card"
	desc = "You are a number, you are not a free man."
	icon_state = "orange"
	inhand_icon_state = "orange-id"
	lefthand_file = 'icons/mob/inhands/equipment/idcards_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/idcards_righthand.dmi'
	assignment = "Prisoner"
	registered_name = "Scum"
	uses_overlays = FALSE
	var/goal = 0 //How far from freedom?
	var/points = 0
	registered_age = null

/obj/item/card/id/prisoner/attack_self(mob/user)
	to_chat(usr, "<span class='notice'>You have accumulated [points] out of the [goal] points you need for freedom.</span>")

/obj/item/card/id/prisoner/one
	name = "Prisoner #13-001"
	registered_name = "Prisoner #13-001"
	icon_state = "prisoner_001"

/obj/item/card/id/prisoner/two
	name = "Prisoner #13-002"
	registered_name = "Prisoner #13-002"
	icon_state = "prisoner_002"

/obj/item/card/id/prisoner/three
	name = "Prisoner #13-003"
	registered_name = "Prisoner #13-003"
	icon_state = "prisoner_003"

/obj/item/card/id/prisoner/four
	name = "Prisoner #13-004"
	registered_name = "Prisoner #13-004"
	icon_state = "prisoner_004"

/obj/item/card/id/prisoner/five
	name = "Prisoner #13-005"
	registered_name = "Prisoner #13-005"
	icon_state = "prisoner_005"

/obj/item/card/id/prisoner/six
	name = "Prisoner #13-006"
	registered_name = "Prisoner #13-006"
	icon_state = "prisoner_006"

/obj/item/card/id/prisoner/seven
	name = "Prisoner #13-007"
	registered_name = "Prisoner #13-007"
	icon_state = "prisoner_007"

/obj/item/card/id/mining
	name = "mining ID"
	access = list(ACCESS_MINING, ACCESS_MINING_STATION, ACCESS_MECH_MINING, ACCESS_MAILSORTING, ACCESS_MINERAL_STOREROOM)

/obj/item/card/id/away
	name = "\proper a perfectly generic identification card"
	desc = "A perfectly generic identification card. Looks like it could use some flavor."
	access = list(ACCESS_AWAY_GENERAL)
	icon_state = "retro"
	uses_overlays = FALSE
	registered_age = null

/obj/item/card/id/away/hotel
	name = "Staff ID"
	desc = "A staff ID used to access the hotel's doors."
	access = list(ACCESS_AWAY_GENERAL, ACCESS_AWAY_MAINT)

/obj/item/card/id/away/hotel/securty
	name = "Officer ID"
	access = list(ACCESS_AWAY_GENERAL, ACCESS_AWAY_MAINT, ACCESS_AWAY_SEC)

/obj/item/card/id/away/old
	name = "\proper a perfectly generic identification card"
	desc = "A perfectly generic identification card. Looks like it could use some flavor."

/obj/item/card/id/away/old/sec
	name = "Charlie Station Security Officer's ID card"
	desc = "A faded Charlie Station ID card. You can make out the rank \"Security Officer\"."
	assignment = "Charlie Station Security Officer"
	access = list(ACCESS_AWAY_GENERAL, ACCESS_AWAY_SEC)

/obj/item/card/id/away/old/sci
	name = "Charlie Station Scientist's ID card"
	desc = "A faded Charlie Station ID card. You can make out the rank \"Scientist\"."
	assignment = "Charlie Station Scientist"
	access = list(ACCESS_AWAY_GENERAL)

/obj/item/card/id/away/old/eng
	name = "Charlie Station Engineer's ID card"
	desc = "A faded Charlie Station ID card. You can make out the rank \"Station Engineer\"."
	assignment = "Charlie Station Engineer"
	access = list(ACCESS_AWAY_GENERAL, ACCESS_AWAY_ENGINE)

/obj/item/card/id/away/old/apc
	name = "APC Access ID"
	desc = "A special ID card that allows access to APC terminals."
	access = list(ACCESS_ENGINE_EQUIP)

/obj/item/card/id/away/deep_storage //deepstorage.dmm space ruin
	name = "bunker access ID"

/obj/item/card/id/departmental_budget
	name = "departmental card (FUCK)"
	desc = "Provides access to the departmental budget."
	icon_state = "budgetcard"
	uses_overlays = FALSE
	var/department_ID = ACCOUNT_CIV
	var/department_name = ACCOUNT_CIV_NAME
	registered_age = null

/obj/item/card/id/departmental_budget/Initialize()
	. = ..()
	var/datum/bank_account/B = SSeconomy.get_dep_account(department_ID)
	if(B)
		registered_account = B
		if(!B.bank_cards.Find(src))
			B.bank_cards += src
		name = "departmental card ([department_name])"
		desc = "Provides access to the [department_name]."
	SSeconomy.dep_cards += src

/obj/item/card/id/departmental_budget/Destroy()
	SSeconomy.dep_cards -= src
	return ..()

/obj/item/card/id/departmental_budget/update_label()
	return

/obj/item/card/id/departmental_budget/car
	department_ID = ACCOUNT_CAR
	department_name = ACCOUNT_CAR_NAME
	icon_state = "car_budget" //saving up for a new tesla

/obj/item/card/id/departmental_budget/AltClick(mob/living/user)
	registered_account.bank_card_talk(span_warning("Withdrawing is not compatible with this card design."), TRUE) //prevents the vault bank machine being useless and putting money from the budget to your card to go over personal crates

/obj/item/card/id/advanced
	name = "identification card"
	desc = "A card used to provide ID and determine access across the station. Has an integrated digital display and advanced microchips."
	icon_state = "card_grey"
	worn_icon_state = "card_grey"

	wildcard_slots = WILDCARD_LIMIT_GREY

	/// An overlay icon state for when the card is assigned to a name. Usually manifests itself as a little scribble to the right of the job icon.
	var/assigned_icon_state = "assigned"

	/// If this is set, will manually override the icon file for the trim. Intended for admins to VV edit and chameleon ID cards.
	var/trim_icon_override
	/// If this is set, will manually override the icon state for the trim. Intended for admins to VV edit and chameleon ID cards.
	var/trim_state_override
	/// If this is set, will manually override the trim's assignmment for SecHUDs. Intended for admins to VV edit and chameleon ID cards.
	var/trim_assignment_override

/obj/item/card/id/advanced/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_ITEM_EQUIPPED, .proc/update_intern_status)
	RegisterSignal(src, COMSIG_ITEM_DROPPED, .proc/remove_intern_status)

/obj/item/card/id/advanced/Destroy()
	UnregisterSignal(src, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED))

	return ..()

/obj/item/card/id/advanced/proc/update_intern_status(datum/source, mob/user)
	SIGNAL_HANDLER

	if(!user?.client)
		return
	if(!CONFIG_GET(flag/use_exp_tracking))
		return
	if(!CONFIG_GET(flag/use_low_living_hour_intern))
		return
	if(!SSdbcore.Connect())
		return

	var/intern_threshold = (CONFIG_GET(number/use_low_living_hour_intern_hours) * 60) || (CONFIG_GET(number/use_exp_restrictions_heads_hours) * 60) || INTERN_THRESHOLD_FALLBACK_HOURS * 60
	var/playtime = user.client.get_exp_living(pure_numeric = TRUE)

	if((intern_threshold >= playtime) && (user.mind?.assigned_role.title in SSjob.station_jobs))
		is_intern = TRUE
		update_label()
		return

	if(!is_intern)
		return

	is_intern = FALSE
	update_label()

/obj/item/card/id/advanced/proc/remove_intern_status(datum/source, mob/user)
	SIGNAL_HANDLER

	if(!is_intern)
		return

	is_intern = FALSE
	update_label()

/obj/item/card/id/advanced/proc/on_holding_card_slot_moved(obj/item/computer_hardware/card_slot/source, atom/old_loc, dir, forced)
	SIGNAL_HANDLER
	if(istype(old_loc, /obj/item/modular_computer/tablet))
		UnregisterSignal(old_loc, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED))

	if(istype(source.loc, /obj/item/modular_computer/tablet))
		RegisterSignal(source.loc, COMSIG_ITEM_EQUIPPED, .proc/update_intern_status)
		RegisterSignal(source.loc, COMSIG_ITEM_DROPPED, .proc/remove_intern_status)

/obj/item/card/id/advanced/Moved(atom/OldLoc, Dir)
	. = ..()

	if(istype(OldLoc, /obj/item/pda) || istype(OldLoc, /obj/item/storage/wallet))
		UnregisterSignal(OldLoc, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED))

	if(istype(OldLoc, /obj/item/computer_hardware/card_slot))
		var/obj/item/computer_hardware/card_slot/slot = OldLoc

		UnregisterSignal(OldLoc, COMSIG_MOVABLE_MOVED)

		if(istype(slot.holder, /obj/item/modular_computer/tablet))
			var/obj/item/modular_computer/tablet/slot_holder = slot.holder
			UnregisterSignal(slot_holder, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED))

	if(istype(loc, /obj/item/pda) || istype(loc, /obj/item/storage/wallet))
		RegisterSignal(loc, COMSIG_ITEM_EQUIPPED, .proc/update_intern_status)
		RegisterSignal(loc, COMSIG_ITEM_DROPPED, .proc/remove_intern_status)

	if(istype(loc, /obj/item/computer_hardware/card_slot))
		var/obj/item/computer_hardware/card_slot/slot = loc

		RegisterSignal(loc, COMSIG_MOVABLE_MOVED, .proc/on_holding_card_slot_moved)

		if(istype(slot.holder, /obj/item/modular_computer/tablet))
			var/obj/item/modular_computer/tablet/slot_holder = slot.holder
			RegisterSignal(slot_holder, COMSIG_ITEM_EQUIPPED, .proc/update_intern_status)
			RegisterSignal(slot_holder, COMSIG_ITEM_DROPPED, .proc/remove_intern_status)

/obj/item/card/id/advanced/update_overlays()
	. = ..()

	if(registered_name && registered_name != "Captain")
		. += mutable_appearance(icon, assigned_icon_state)

	var/trim_icon_file = trim_icon_override ? trim_icon_override : trim?.trim_icon
	var/trim_icon_state = trim_state_override ? trim_state_override : trim?.trim_state

	if(!trim_icon_file || !trim_icon_state)
		return

	. += mutable_appearance(trim_icon_file, trim_icon_state)

/obj/item/card/id/advanced/get_trim_assignment()
	if(trim_assignment_override)
		return trim_assignment_override
	else if(ispath(trim))
		var/datum/id_trim/trim_singleton = SSid_access.trim_singletons_by_path[trim]
		return trim_singleton.assignment

	return ..()

/obj/item/card/id/advanced/silver
	name = "silver identification card"
	desc = "A silver card which shows honour and dedication."
	icon_state = "card_silver"
	worn_icon_state = "card_silver"
	inhand_icon_state = "silver_id"
	wildcard_slots = WILDCARD_LIMIT_SILVER

/datum/id_trim/maint_reaper
	access = list(ACCESS_MAINT_TUNNELS)
	trim_state = "trim_janitor"
	assignment = "Reaper"

/obj/item/card/id/advanced/silver/reaper
	name = "Thirteen's ID Card (Reaper)"
	trim = /datum/id_trim/maint_reaper
	registered_name = "Thirteen"

/obj/item/card/id/advanced/gold
	name = "gold identification card"
	desc = "A golden card which shows power and might."
	icon_state = "card_gold"
	worn_icon_state = "card_gold"
	inhand_icon_state = "gold_id"
	wildcard_slots = WILDCARD_LIMIT_GOLD

/obj/item/card/id/advanced/gold/captains_spare
	name = "captain's spare ID"
	desc = "The spare ID of the High Lord himself."
	registered_name = "Captain"
	trim = /datum/id_trim/job/captain
	registered_age = null

/obj/item/card/id/advanced/gold/captains_spare/update_label() //so it doesn't change to Captain's ID card (Captain) on a sneeze
	if(registered_name == "Captain")
		name = "[initial(name)][(!assignment || assignment == "Captain") ? "" : " ([assignment])"]"
		update_appearance(UPDATE_ICON)
	else
		..()

/obj/item/card/id/advanced/centcom
	name = "\improper CentCom ID"
	desc = "An ID straight from Central Command."
	icon_state = "card_centcom"
	worn_icon_state = "card_centcom"
	assigned_icon_state = "assigned_centcom"
	registered_name = "Central Command"
	registered_age = null
	trim = /datum/id_trim/centcom
	wildcard_slots = WILDCARD_LIMIT_CENTCOM

/obj/item/card/id/advanced/centcom/ert
	name = "\improper CentCom ID"
	desc = "An ERT ID card."
	registered_age = null
	registered_name = "Emergency Response Intern"
	trim = /datum/id_trim/centcom/ert

/obj/item/card/id/advanced/centcom/ert
	registered_name = "Emergency Response Team Commander"
	trim = /datum/id_trim/centcom/ert/commander

/obj/item/card/id/advanced/centcom/ert/security
	registered_name = "Security Response Officer"
	trim = /datum/id_trim/centcom/ert/security

/obj/item/card/id/advanced/centcom/ert/engineer
	registered_name = "Engineering Response Officer"
	trim = /datum/id_trim/centcom/ert/engineer

/obj/item/card/id/advanced/centcom/ert/medical
	registered_name = "Medical Response Officer"
	trim = /datum/id_trim/centcom/ert/medical

/obj/item/card/id/advanced/centcom/ert/chaplain
	registered_name = "Religious Response Officer"
	trim = /datum/id_trim/centcom/ert/chaplain

/obj/item/card/id/advanced/centcom/ert/janitor
	registered_name = "Janitorial Response Officer"
	trim = /datum/id_trim/centcom/ert/janitor

/obj/item/card/id/advanced/centcom/ert/clown
	registered_name = "Entertainment Response Officer"
	trim = /datum/id_trim/centcom/ert/clown

/obj/item/card/id/advanced/black
	name = "black identification card"
	desc = "This card is telling you one thing and one thing alone. The person holding this card is an utter badass."
	icon_state = "card_black"
	worn_icon_state = "card_black"
	assigned_icon_state = "assigned_syndicate"
	wildcard_slots = WILDCARD_LIMIT_GOLD

/obj/item/card/id/advanced/black/deathsquad
	name = "\improper Death Squad ID"
	desc = "A Death Squad ID card."
	registered_name = "Death Commando"
	trim = /datum/id_trim/centcom/deathsquad
	wildcard_slots = WILDCARD_LIMIT_DEATHSQUAD

/obj/item/card/id/advanced/black/syndicate_command
	name = "syndicate ID card"
	desc = "An ID straight from the Syndicate."
	registered_name = "Syndicate"
	registered_age = null
	trim = /datum/id_trim/syndicom
	wildcard_slots = WILDCARD_LIMIT_SYNDICATE

/obj/item/card/id/advanced/black/syndicate_command/crew_id
	name = "syndicate ID card"
	desc = "An ID straight from the Syndicate."
	registered_name = "Syndicate"
	trim = /datum/id_trim/syndicom/crew

/obj/item/card/id/advanced/black/syndicate_command/captain_id
	name = "syndicate captain ID card"
	desc = "An ID straight from the Syndicate."
	registered_name = "Syndicate"
	trim = /datum/id_trim/syndicom/captain

/obj/item/card/id/advanced/debug
	name = "\improper Debug ID"
	desc = "A debug ID card. Has ALL the all access, you really shouldn't have this."
	icon_state = "card_centcom"
	worn_icon_state = "card_centcom"
	assigned_icon_state = "assigned_centcom"
	trim = /datum/id_trim/admin
	wildcard_slots = WILDCARD_LIMIT_ADMIN

/obj/item/card/id/advanced/debug/Initialize(mapload)
	. = ..()
	registered_account = SSeconomy.get_dep_account(ACCOUNT_CAR)

/obj/item/card/id/advanced/prisoner
	name = "prisoner ID card"
	desc = "You are a number, you are not a free man."
	icon_state = "card_prisoner"
	worn_icon_state = "card_prisoner"
	inhand_icon_state = "orange-id"
	lefthand_file = 'icons/mob/inhands/equipment/idcards_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/idcards_righthand.dmi'
	registered_name = "Scum"
	registered_age = null
	trim = /datum/id_trim/job/prisoner

	wildcard_slots = WILDCARD_LIMIT_PRISONER

	/// Number of gulag points required to earn freedom.
	var/goal = 0
	/// Number of gulag points earned.
	var/points = 0
	/// If the card has a timer set on it for temporary stay.
	var/timed = FALSE
	/// Time to assign to the card when they pass through the security gate.
	var/time_to_assign
	/// Time left on a card till they can leave.
	var/time_left = 0

/obj/item/card/id/advanced/prisoner/attackby(obj/item/card/id/C, mob/user)
	..()
	var/list/id_access = C.GetAccess()
	if(!(ACCESS_BRIG in id_access))
		return FALSE
	if(loc != user)
		to_chat(user, span_warning("You must be holding the ID to continue!"))
		return FALSE
	if(timed)
		timed = FALSE
		time_to_assign = initial(time_to_assign)
		registered_name = initial(registered_name)
		STOP_PROCESSING(SSobj, src)
		to_chat(user, "Restating prisoner ID to default parameters.")
		return
	var/choice = tgui_input_number(user, "Sentence time in seconds", "Sentencing")
	if(!choice || QDELETED(user) || QDELETED(src) || !usr.canUseTopic(src, BE_CLOSE, FALSE, NO_TK) || loc != user)
		return FALSE
	time_to_assign = choice
	to_chat(user, "You set the sentence time to [time_to_assign] seconds.")
	timed = TRUE

/obj/item/card/id/advanced/prisoner/proc/start_timer()
	say("Sentence started, welcome to the corporate rehabilitation center!")
	START_PROCESSING(SSobj, src)

/obj/item/card/id/advanced/prisoner/examine(mob/user)
	. = ..()
	if(timed)
		if(time_left <= 0)
			. += span_notice("The digital timer on the card has zero seconds remaining. You leave a changed man, but a free man nonetheless.")
		else
			. += span_notice("The digital timer on the card has [time_left] seconds remaining. Don't do the crime if you can't do the time.")

/obj/item/card/id/advanced/prisoner/process(delta_time)
	if(!timed)
		return
	time_left -= delta_time
	if(time_left <= 0)
		say("Sentence time has been served. Thank you for your cooperation in our corporate rehabilitation program!")
		STOP_PROCESSING(SSobj, src)

/obj/item/card/id/advanced/prisoner/attack_self(mob/user)
	to_chat(usr, span_notice("You have accumulated [points] out of the [goal] points you need for freedom."))

/obj/item/card/id/advanced/prisoner/one
	name = "Prisoner #13-001"
	registered_name = "Prisoner #13-001"
	trim = /datum/id_trim/job/prisoner/one

/obj/item/card/id/advanced/prisoner/two
	name = "Prisoner #13-002"
	registered_name = "Prisoner #13-002"
	trim = /datum/id_trim/job/prisoner/two

/obj/item/card/id/advanced/prisoner/three
	name = "Prisoner #13-003"
	registered_name = "Prisoner #13-003"
	trim = /datum/id_trim/job/prisoner/three

/obj/item/card/id/advanced/prisoner/four
	name = "Prisoner #13-004"
	registered_name = "Prisoner #13-004"
	trim = /datum/id_trim/job/prisoner/four

/obj/item/card/id/advanced/prisoner/five
	name = "Prisoner #13-005"
	registered_name = "Prisoner #13-005"
	trim = /datum/id_trim/job/prisoner/five

/obj/item/card/id/advanced/prisoner/six
	name = "Prisoner #13-006"
	registered_name = "Prisoner #13-006"
	trim = /datum/id_trim/job/prisoner/six

/obj/item/card/id/advanced/prisoner/seven
	name = "Prisoner #13-007"
	registered_name = "Prisoner #13-007"
	trim = /datum/id_trim/job/prisoner/seven

/obj/item/card/id/advanced/mining
	name = "mining ID"
	trim = /datum/id_trim/job/shaft_miner/spare

/obj/item/card/id/advanced/highlander
	name = "highlander ID"
	registered_name = "Highlander"
	desc = "There can be only one!"
	icon_state = "card_black"
	worn_icon_state = "card_black"
	assigned_icon_state = "assigned_syndicate"
	trim = /datum/id_trim/highlander
	wildcard_slots = WILDCARD_LIMIT_ADMIN

/obj/item/card/id/advanced/chameleon
	name = "agent card"
	desc = "A highly advanced chameleon ID card. Touch this card on another ID card or player to choose which accesses to copy. Has special magnetic properties which force it to the front of wallets."
	trim = /datum/id_trim/chameleon
	wildcard_slots = WILDCARD_LIMIT_CHAMELEON

	/// Have we set a custom name and job assignment, or will we use what we're given when we chameleon change?
	var/forged = FALSE
	/// Anti-metagaming protections. If TRUE, anyone can change the ID card's details. If FALSE, only syndicate agents can.
	var/anyone = FALSE
	/// Weak ref to the ID card we're currently attempting to steal access from.
	var/datum/weakref/theft_target

/obj/item/card/id/advanced/chameleon/Initialize(mapload)
	. = ..()

	var/datum/action/item_action/chameleon/change/id/chameleon_card_action = new(src)
	chameleon_card_action.chameleon_type = /obj/item/card/id/advanced
	chameleon_card_action.chameleon_name = "ID Card"
	chameleon_card_action.initialize_disguises()

/obj/item/card/id/advanced/chameleon/Destroy()
	theft_target = null
	. = ..()

/obj/item/card/id/advanced/chameleon/afterattack(atom/target, mob/user, proximity)
	if(!proximity)
		return

	if(istype(target, /obj/item/card/id))
		theft_target = WEAKREF(target)
		ui_interact(user)
		return

	return ..()

/obj/item/card/id/advanced/chameleon/pre_attack_secondary(atom/target, mob/living/user, params)
	// If we're attacking a human, we want it to be covert. We're not ATTACKING them, we're trying
	// to sneakily steal their accesses by swiping our agent ID card near them. As a result, we
	// return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN to cancel any part of the following the attack chain.
	if(istype(target, /mob/living/carbon/human))
		to_chat(user, "<span class='notice'>You covertly start to scan [target] with \the [src], hoping to pick up a wireless ID card signal...</span>")

		if(!do_mob(user, target, 2 SECONDS))
			to_chat(user, "<span class='notice'>The scan was interrupted.</span>")
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

		var/mob/living/carbon/human/human_target = target

		var/list/target_id_cards = human_target.get_all_contents_type(/obj/item/card/id)

		if(!length(target_id_cards))
			to_chat(user, "<span class='notice'>The scan failed to locate any ID cards.</span>")
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

		var/selected_id = pick(target_id_cards)
		to_chat(user, "<span class='notice'>You successfully sync your [src] with \the [selected_id].</span>")
		theft_target = WEAKREF(selected_id)
		ui_interact(user)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	if(istype(target, /obj/item))
		var/obj/item/target_item = target

		to_chat(user, "<span class='notice'>You covertly start to scan [target] with your [src], hoping to pick up a wireless ID card signal...</span>")

		var/list/target_id_cards = target_item.get_all_contents_type(/obj/item/card/id)

		var/target_item_id = target_item.GetID()

		if(target_item_id)
			target_id_cards |= target_item_id

		if(!length(target_id_cards))
			to_chat(user, "<span class='notice'>The scan failed to locate any ID cards.</span>")
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

		var/selected_id = pick(target_id_cards)
		to_chat(user, "<span class='notice'>You successfully sync your [src] with \the [selected_id].</span>")
		theft_target = WEAKREF(selected_id)
		ui_interact(user)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	return ..()

/obj/item/card/id/advanced/chameleon/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ChameleonCard", name)
		ui.open()

/obj/item/card/id/advanced/chameleon/ui_static_data(mob/user)
	var/list/data = list()
	data["wildcardFlags"] = SSid_access.wildcard_flags_by_wildcard
	data["accessFlagNames"] = SSid_access.access_flag_string_by_flag
	data["accessFlags"] = SSid_access.flags_by_access
	return data

/obj/item/card/id/advanced/chameleon/ui_host(mob/user)
	// Hook our UI to the theft target ID card for UI state checks.
	return theft_target?.resolve()

/obj/item/card/id/advanced/chameleon/ui_state(mob/user)
	return GLOB.always_state

/obj/item/card/id/advanced/chameleon/ui_status(mob/user)
	var/target = theft_target?.resolve()

	if(!target)
		return UI_CLOSE

	var/status = min(
		ui_status_user_strictly_adjacent(user, target),
		ui_status_user_is_advanced_tool_user(user),
		max(
			ui_status_user_is_conscious_and_lying_down(user),
			ui_status_user_is_abled(user, target),
		),
	)

	if(status < UI_INTERACTIVE)
		return UI_CLOSE

	return status

/obj/item/card/id/advanced/chameleon/ui_data(mob/user)
	var/list/data = list()

	data["showBasic"] = FALSE

	var/list/regions = list()

	var/obj/item/card/id/target_card = theft_target.resolve()
	if(target_card)
		var/list/tgui_region_data = SSid_access.all_region_access_tgui
		for(var/region in SSid_access.station_regions)
			regions += tgui_region_data[region]

	data["accesses"] = regions
	data["ourAccess"] = access
	data["ourTrimAccess"] = trim ? trim.access : list()
	data["theftAccess"] = target_card.access.Copy()
	data["wildcardSlots"] = wildcard_slots
	data["selectedList"] = access
	data["trimAccess"] = list()

	return data

/obj/item/card/id/advanced/chameleon/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	var/obj/item/card/id/target_card = theft_target?.resolve()
	if(QDELETED(target_card))
		to_chat(usr, span_notice("The ID card you were attempting to scan is no longer in range."))
		target_card = null
		return TRUE

	// Wireless ID theft!
	var/turf/our_turf = get_turf(src)
	var/turf/target_turf = get_turf(target_card)
	if(!our_turf.Adjacent(target_turf))
		to_chat(usr, span_notice("The ID card you were attempting to scan is no longer in range."))
		target_card = null
		return TRUE

	switch(action)
		if("mod_access")
			var/access_type = params["access_target"]
			var/try_wildcard = params["access_wildcard"]
			if(access_type in access)
				remove_access(list(access_type))
				LOG_ID_ACCESS_CHANGE(usr, src, "removed [SSid_access.get_access_desc(access_type)]")
				return TRUE

			if(!(access_type in target_card.access))
				to_chat(usr, span_notice("ID error: ID card rejected your attempted access modification."))
				LOG_ID_ACCESS_CHANGE(usr, src, "failed to add [SSid_access.get_access_desc(access_type)][try_wildcard ? " with wildcard [try_wildcard]" : ""]")
				return TRUE

			if(!can_add_wildcards(list(access_type), try_wildcard))
				to_chat(usr, span_notice("ID error: ID card rejected your attempted access modification."))
				LOG_ID_ACCESS_CHANGE(usr, src, "failed to add [SSid_access.get_access_desc(access_type)][try_wildcard ? " with wildcard [try_wildcard]" : ""]")
				return TRUE

			if(!add_access(list(access_type), try_wildcard))
				to_chat(usr, span_notice("ID error: ID card rejected your attempted access modification."))
				LOG_ID_ACCESS_CHANGE(usr, src, "failed to add [SSid_access.get_access_desc(access_type)][try_wildcard ? " with wildcard [try_wildcard]" : ""]")
				return TRUE

			if(access_type in ACCESS_ALERT_ADMINS)
				message_admins("[ADMIN_LOOKUPFLW(usr)] just added [SSid_access.get_access_desc(access_type)] to an ID card [ADMIN_VV(src)] [(registered_name) ? "belonging to [registered_name]." : "with no registered name."]")
			LOG_ID_ACCESS_CHANGE(usr, src, "added [SSid_access.get_access_desc(access_type)]")
			return TRUE

/obj/item/card/id/advanced/chameleon/attack_self(mob/user)
	if(isliving(user) && user.mind)
		var/popup_input = tgui_input_list(user, "Choose Action", "Agent ID", list("Show", "Forge/Reset", "Change Account ID"))
		if(user.incapacitated())
			return
		if(!user.is_holding(src))
			return
		if(popup_input == "Forge/Reset")
			if(!forged)
				var/input_name = tgui_input_text(user, "What name would you like to put on this card? Leave blank to randomise.", "Agent card name", registered_name ? registered_name : (ishuman(user) ? user.real_name : user.name), MAX_NAME_LEN)
				input_name = sanitize_name(input_name)
				if(!input_name)
					// Invalid/blank names give a randomly generated one.
					if(user.gender == MALE)
						input_name = "[pick(GLOB.first_names_male)] [pick(GLOB.last_names)]"
					else if(user.gender == FEMALE)
						input_name = "[pick(GLOB.first_names_female)] [pick(GLOB.last_names)]"
					else
						input_name = "[pick(GLOB.first_names)] [pick(GLOB.last_names)]"

				registered_name = input_name

				var/change_trim = tgui_alert(user, "Adjust the appearance of your card's trim?", "Modify Trim", list("Yes", "No"))
				if(change_trim == "Yes")
					var/list/blacklist = typecacheof(type) + typecacheof(/obj/item/card/id/advanced/simple_bot)
					var/list/trim_list = list()
					for(var/trim_path in typesof(/datum/id_trim))
						if(blacklist[trim_path])
							continue

						var/datum/id_trim/trim = SSid_access.trim_singletons_by_path[trim_path]

						if(trim && trim.trim_state && trim.assignment)
							var/fake_trim_name = "[trim.assignment] ([trim.trim_state])"
							trim_list[fake_trim_name] = trim_path

					var/selected_trim_path = tgui_input_list(user, "Select trim to apply to your card.\nNote: This will not grant any trim accesses.", "Forge Trim", sort_list(trim_list, /proc/cmp_typepaths_asc))
					if(selected_trim_path)
						SSid_access.apply_trim_to_chameleon_card(src, trim_list[selected_trim_path])

				var/target_occupation = tgui_input_text(user, "What occupation would you like to put on this card?\nNote: This will not grant any access levels.", "Agent card job assignment", assignment ? assignment : "Assistant")
				if(target_occupation)
					assignment = target_occupation

				var/new_age = tgui_input_number(user, "Choose the ID's age", "Agent card age", AGE_MIN, AGE_MAX, AGE_MIN)
				if(QDELETED(user) || QDELETED(src) || !user.canUseTopic(user, BE_CLOSE, NO_DEXTERITY, NO_TK))
					return
				if(new_age)
					registered_age = new_age

				if(tgui_alert(user, "Activate wallet ID spoofing, allowing this card to force itself to occupy the visible ID slot in wallets?", "Wallet ID Spoofing", list("Yes", "No")) == "Yes")
					ADD_TRAIT(src, TRAIT_MAGNETIC_ID_CARD, CHAMELEON_ITEM_TRAIT)

				update_label()
				update_icon()
				forged = TRUE
				to_chat(user, span_notice("You successfully forge the ID card."))
				log_game("[key_name(user)] has forged \the [initial(name)] with name \"[registered_name]\", occupation \"[assignment]\" and trim \"[trim?.assignment]\".")

				if(!registered_account)
					if(ishuman(user))
						var/mob/living/carbon/human/accountowner = user

						var/datum/bank_account/account = SSeconomy.bank_accounts_by_id["[accountowner.account_id]"]
						if(account)
							account.bank_cards += src
							registered_account = account
							to_chat(user, span_notice("Your account number has been automatically assigned."))
				return
			if(forged)
				registered_name = initial(registered_name)
				assignment = initial(assignment)
				SSid_access.remove_trim_from_chameleon_card(src)
				REMOVE_TRAIT(src, TRAIT_MAGNETIC_ID_CARD, CHAMELEON_ITEM_TRAIT)
				log_game("[key_name(user)] has reset \the [initial(name)] named \"[src]\" to default.")
				update_label()
				update_icon()
				forged = FALSE
				to_chat(user, span_notice("You successfully reset the ID card."))
				return
		if (popup_input == "Change Account ID")
			set_new_account(user)
			return
	return ..()

/// A special variant of the classic chameleon ID card which accepts all access.
/obj/item/card/id/advanced/chameleon/black
	icon_state = "card_black"
	worn_icon_state = "card_black"
	assigned_icon_state = "assigned_syndicate"
	wildcard_slots = WILDCARD_LIMIT_GOLD

/obj/item/card/id/advanced/engioutpost
	registered_name = "George 'Plastic' Miller"
	desc = "A card used to provide ID and determine access across the station. There's blood dripping from the corner. Ew."
	trim = /datum/id_trim/engioutpost
	registered_age = 47

/obj/item/card/id/advanced/simple_bot
	name = "simple bot ID card"
	desc = "An internal ID card used by the station's non-sentient bots. You should report this to a coder if you're holding it."
	wildcard_slots = WILDCARD_LIMIT_ADMIN

/obj/item/card/id/red
	name = "Red Team identification card"
	desc = "A card used to identify members of the red team for CTF"
	icon_state = "ctf_red"

/obj/item/card/id/blue
	name = "Blue Team identification card"
	desc = "A card used to identify members of the blue team for CTF"
	icon_state = "ctf_blue"

/obj/item/card/id/yellow
	name = "Yellow Team identification card"
	desc = "A card used to identify members of the yellow team for CTF"
	icon_state = "ctf_yellow"

/obj/item/card/id/green
	name = "Green Team identification card"
	desc = "A card used to identify members of the green team for CTF"
	icon_state = "ctf_green"

#undef INTERN_THRESHOLD_FALLBACK_HOURS
#undef ID_ICON_BORDERS
