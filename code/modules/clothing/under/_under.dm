/obj/item/clothing/under
	name = "under"
	icon = 'icons/obj/clothing/under/default.dmi'
	worn_icon = 'icons/mob/clothing/under/default.dmi'
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	permeability_coefficient = 0.9
	slot_flags = ITEM_SLOT_ICLOTHING
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 0, ACID = 0, WOUND = 5)
	equip_sound = 'sound/items/equip/jumpsuit_equip.ogg'
	drop_sound = 'sound/items/handling/cloth_drop.ogg'
	pickup_sound =  'sound/items/handling/cloth_pickup.ogg'
	limb_integrity = 30
	interaction_flags_click = ALLOW_RESTING

	/// Has this undersuit been freshly laundered and, as such, imparts a mood bonus for wearing
	var/freshly_laundered = FALSE

/obj/item/clothing/under/worn_overlays(isinhands = FALSE)
	. = list()
	if(!isinhands)
		if(damaged_clothes)
			. += mutable_appearance('icons/effects/item_damage.dmi', "damageduniform")
		if(HAS_BLOOD_DNA(src))
			. += mutable_appearance('icons/effects/blood.dmi', "uniformblood")
		if(accessory_overlay)
			. += accessory_overlay

	// Sensor handling
	/// Does this undersuit have suit sensors in general
	var/has_sensor = HAS_SENSORS
	/// Does this undersuit spawn with a random sensor value
	var/random_sensor = TRUE
	/// What is the active sensor mode of this udnersuit
	var/sensor_mode = NO_SENSORS

	// Accessory handling (Can be componentized eventually)
	/// The max number of accessories we can have on this suit.
	var/max_number_of_accessories = 5
	/// A list of all accessories attached to us.
	var/list/obj/item/clothing/accessory/attached_accessories
	/// The overlay of the accessory we're demonstrating. Only index 1 will show up.
	/// This is the overlay on the MOB, not the item itself.
	var/mutable_appearance/accessory_overlay

/datum/armor/clothing_under
	bio = 10
	wound = 5

/obj/item/clothing/under/Initialize(mapload)
	. = ..()
	if(random_sensor)
		//make the sensor mode favor higher levels, except coords.
		sensor_mode = pick(SENSOR_VITALS, SENSOR_VITALS, SENSOR_VITALS, SENSOR_LIVING, SENSOR_LIVING, SENSOR_COORDS, SENSOR_COORDS, SENSOR_OFF)
	if(!unique_reskin) // Already registered via unique reskin
		register_context()
	AddElement(/datum/element/update_icon_updates_onmob, flags = ITEM_SLOT_ICLOTHING|ITEM_SLOT_OCLOTHING, body = TRUE)


/obj/item/clothing/under/add_context(atom/source, list/context, obj/item/held_item, mob/living/user)
	. = ..()

	var/changed = FALSE
	if(isnull(held_item) && has_sensor == HAS_SENSORS)
		context[SCREENTIP_CONTEXT_RMB] = "Toggle suit sensors"
		changed = TRUE

	if(istype(held_item, /obj/item/clothing/accessory) && length(attached_accessories) < max_number_of_accessories)
		context[SCREENTIP_CONTEXT_LMB] = "Attach accessory"
		changed = TRUE

	if(LAZYLEN(attached_accessories))
		context[SCREENTIP_CONTEXT_ALT_RMB] = "Remove accessory"
		changed = TRUE

	if(istype(held_item, /obj/item/stack/cable_coil) && has_sensor == BROKEN_SENSORS)
		context[SCREENTIP_CONTEXT_LMB] = "Repair suit sensors"
		changed = TRUE

	if(can_adjust && adjusted != DIGITIGRADE_STYLE)
		context[SCREENTIP_CONTEXT_ALT_LMB] =  "Wear [adjusted == ALT_STYLE ? "normally" : "casually"]"
		changed = TRUE

	return changed ? CONTEXTUAL_SCREENTIP_SET : NONE


/obj/item/clothing/under/worn_overlays(mutable_appearance/standing, isinhands = FALSE)
	. = ..()
	if(isinhands)
		return

	if(damaged_clothes)
		. += mutable_appearance('icons/effects/item_damage.dmi', "damageduniform")
	if(GET_ATOM_BLOOD_DNA_LENGTH(src))
		. += mutable_appearance('icons/effects/blood.dmi', "uniformblood")
	if(accessory_overlay)
		. += accessory_overlay

/obj/item/clothing/under/attackby(obj/item/attacking_item, mob/user, params)
	if(has_sensor == BROKEN_SENSORS && istype(attacking_item, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/cabling = attacking_item
		to_chat(user, span_notice("You repair the suit sensors on [src] with [cabling]."))
		cabling.use(1)
		has_sensor = HAS_SENSORS
		to_chat(user,"<span class='notice'>You repair the suit sensors on [src] with [C].</span>")
		return 1
	if(!attach_accessory(I, user))
		return ..()

/obj/item/clothing/under/update_clothes_damaged_state(damaged_state = CLOTHING_DAMAGED)
	..()
	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_w_uniform()
	if(damaged_state == CLOTHING_SHREDDED && has_sensor > NO_SENSORS)
		has_sensor = BROKEN_SENSORS
	else if(damaged_state == CLOTHING_PRISTINE && has_sensor == BROKEN_SENSORS)
		has_sensor = HAS_SENSORS

/obj/item/clothing/under/Initialize()
	. = ..()
	if(random_sensor)
		//make the sensor mode favor higher levels, except coords.
		sensor_mode = pick(SENSOR_OFF, SENSOR_LIVING, SENSOR_LIVING, SENSOR_VITALS, SENSOR_VITALS, SENSOR_VITALS, SENSOR_COORDS, SENSOR_COORDS)

/obj/item/clothing/under/emp_act()
	. = ..()
	if(has_sensor > NO_SENSORS)
		sensor_mode = pick(SENSOR_OFF, SENSOR_OFF, SENSOR_OFF, SENSOR_LIVING, SENSOR_LIVING, SENSOR_VITALS, SENSOR_VITALS, SENSOR_COORDS)
		if(ismob(loc))
			var/mob/M = loc
			to_chat(M,"<span class='warning'>The sensors on the [src] change rapidly!</span>")

/obj/item/clothing/under/equipped(mob/user, slot)
	..()
	if(adjusted)
		adjusted = NORMAL_STYLE
		fitted = initial(fitted)
		if(!alt_covers_chest)
			body_parts_covered |= CHEST

	if(mutantrace_variation && ishuman(user))
		var/mob/living/carbon/human/H = user
		if(DIGITIGRADE in H.dna.species.species_traits)
			adjusted = DIGITIGRADE_STYLE
		H.update_inv_w_uniform()

	if(slot == ITEM_SLOT_ICLOTHING && freshly_laundered)
		freshly_laundered = FALSE
		SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "fresh_laundry", /datum/mood_event/fresh_laundry)

	if(attached_accessory && slot != ITEM_SLOT_HANDS && ishuman(user))
		var/mob/living/carbon/human/H = user
		attached_accessory.on_uniform_equip(src, user)
		H.fan_hud_set_fandom()
		if(attached_accessory.above_suit)
			H.update_inv_wear_suit()

/obj/item/clothing/under/dropped(mob/user)
	. = ..()
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.back && istype(H.back, /obj/item/storage/backpack/satchel))
			var/obj/item/storage/backpack/satchel/S = H.back
			if(S.icon_hidden)
				S.icon_hidden = FALSE
				S.worn_icon_state = initial(S.worn_icon_state)
				H.update_inv_back()

	if(attached_accessory)
		attached_accessory.on_uniform_dropped(src, user)
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			H.fan_hud_set_fandom()
			if(attached_accessory.above_suit)
				H.update_inv_wear_suit()
	..()

/mob/living/carbon/human/update_suit_sensors()
	. = ..()
	update_sensor_list()

/mob/living/carbon/human/proc/update_sensor_list()
	var/obj/item/clothing/under/U = w_uniform
	if(istype(U) && U.has_sensor > 0 && U.sensor_mode)
		GLOB.suit_sensors_list |= src
	else
		GLOB.suit_sensors_list -= src

/mob/living/carbon/human/dummy/update_sensor_list()
	return

/obj/item/clothing/under/proc/attach_accessory(obj/item/I, mob/user, notifyAttach = 1)
	. = FALSE
	if(istype(I, /obj/item/clothing/accessory))
		var/obj/item/clothing/accessory/A = I
		if(attached_accessory)
			if(user)
				to_chat(user, "<span class='warning'>[src] already has an accessory.</span>")
			return
		else

			if(!A.can_attach_accessory(src, user)) //Make sure the suit has a place to put the accessory.
				return
			if(user && !user.temporarilyRemoveItemFromInventory(I))
				return
			if(!A.attach(src, user))
				return

			if(user && notifyAttach)
				to_chat(user, "<span class='notice'>You attach [I] to [src].</span>")

			var/accessory_color = attached_accessory.icon_state
			accessory_overlay = mutable_appearance('icons/mob/clothing/accessories.dmi', "[accessory_color]")
			accessory_overlay.alpha = attached_accessory.alpha
			accessory_overlay.color = attached_accessory.color

			if(ishuman(loc))
				var/mob/living/carbon/human/H = loc
				H.update_inv_w_uniform()
				H.update_inv_wear_suit()
				H.fan_hud_set_fandom()

			return TRUE

/obj/item/clothing/under/proc/remove_accessory(mob/user)
	if(!isliving(user))
		return
	if(!can_use(user))
		return

	if(attached_accessory)
		var/obj/item/clothing/accessory/A = attached_accessory
		attached_accessory.detach(src, user)
		if(user.put_in_hands(A))
			to_chat(user, "<span class='notice'>You detach [A] from [src].</span>")
		else
			to_chat(user, "<span class='notice'>You detach [A] from [src] and it falls on the floor.</span>")

		if(ishuman(loc))
			var/mob/living/carbon/human/H = loc
			H.update_inv_w_uniform()
			H.update_inv_wear_suit()
			H.fan_hud_set_fandom()


/obj/item/clothing/under/examine(mob/user)
	. = ..()
	if(freshly_laundered)
		. += "It looks fresh and clean."
	if(can_adjust)
		if(adjusted == ALT_STYLE)
			. += "Alt-click on [src] to wear it normally."
		else
			. += "Alt-click on [src] to wear it casually."
	if (has_sensor == BROKEN_SENSORS)
		. += "Its sensors appear to be shorted out."
	else if(has_sensor > NO_SENSORS)
		switch(sensor_mode)
			if(SENSOR_OFF)
				. += "Its sensors appear to be disabled."
			if(SENSOR_LIVING)
				. += "Its binary life sensors appear to be enabled."
			if(SENSOR_VITALS)
				. += "Its vital tracker appears to be enabled."
			if(SENSOR_COORDS)
				. += "Its vital tracker and tracking beacon appear to be enabled."
	if(attached_accessory)
		. += "\A [attached_accessory] is attached to it."

/obj/item/clothing/under/verb/toggle()
	set name = "Adjust Suit Sensors"
	set category = "Object"
	set src in usr
	var/mob/M = usr
	if (istype(M, /mob/dead/))
		return
	if (!can_use(M))
		return
	if(has_sensor == LOCKED_SENSORS)
		to_chat(usr, "The controls are locked.")
		return
	if(has_sensor == BROKEN_SENSORS)
		to_chat(usr, "The sensors have shorted out!")
		return
	if(has_sensor <= NO_SENSORS)
		to_chat(usr, "This suit does not have any sensors.")
		return

	var/list/modes = list("Off", "Binary vitals", "Exact vitals", "Tracking beacon")
	var/switchMode = tgui_input_list(M, "Select a sensor mode", "Suit Sensors", modes, modes[sensor_mode + 1])
	if(isnull(switchMode))
		return
	if(get_dist(usr, src) > 1)
		to_chat(usr, "<span class='warning'>You have moved too far away!</span>")
		return
	sensor_mode = modes.Find(switchMode) - 1
	if (loc == usr)
		switch(sensor_mode)
			if(0)
				to_chat(usr, "<span class='notice'>You disable your suit's remote sensing equipment.</span>")
			if(1)
				to_chat(usr, "<span class='notice'>Your suit will now only report whether you are alive or dead.</span>")
			if(2)
				to_chat(usr, "<span class='notice'>Your suit will now only report your exact vital lifesigns.</span>")
			if(3)
				to_chat(usr, "<span class='notice'>Your suit will now report your exact vital lifesigns as well as your coordinate position.</span>")

	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		if(H.w_uniform == src)
			H.update_suit_sensors()

/// Checks if the toggler is allowed to toggle suit sensors currently
/obj/item/clothing/under/proc/can_toggle_sensors(mob/toggler)
	if(!can_use(toggler) || toggler.stat == DEAD) //make sure they didn't hold the window open.
		return FALSE
	if(get_dist(toggler, src) > 1)
		balloon_alert(toggler, "too far!")
		return FALSE

	switch(has_sensor)
		if(LOCKED_SENSORS)
			balloon_alert(toggler, "sensor controls locked!")
			return FALSE
		if(BROKEN_SENSORS)
			balloon_alert(toggler, "sensors shorted!")
			return FALSE
		if(NO_SENSORS)
			balloon_alert(toggler, "no sensors to ajdust!")
			return FALSE

	return TRUE

/obj/item/clothing/under/click_alt(mob/user)
	if(!can_adjust)
		balloon_alert(user, "can't be adjusted!")
		return CLICK_ACTION_BLOCKING
	if(!can_use(user))
		return NONE
	rolldown()
	return CLICK_ACTION_SUCCESS

/obj/item/clothing/under/alt_click_secondary(mob/user)
	. = ..()
	if(.)
		return

	if(!LAZYLEN(attached_accessories))
		balloon_alert(user, "no accessories to remove!")
		return
	if(!user.can_perform_action(src, NEED_DEXTERITY))
		return

	pop_accessory(user)

/obj/item/clothing/under/verb/jumpsuit_adjust()
	set name = "Adjust Jumpsuit Style"
	set category = null
	set src in usr
	rolldown()

/obj/item/clothing/under/proc/rolldown()
	if(!can_use(usr))
		return
	if(!can_adjust)
		to_chat(usr, "<span class='warning'>You cannot wear this suit any differently!</span>")
		return
	if(toggle_jumpsuit_adjust())
		to_chat(usr, "<span class='notice'>You adjust the suit to wear it more casually.</span>")
	else
		to_chat(usr, "<span class='notice'>You adjust the suit back to normal.</span>")
	if(ishuman(usr))
		var/mob/living/carbon/human/H = usr
		H.update_inv_w_uniform()
		H.update_body()

/obj/item/clothing/under/proc/toggle_jumpsuit_adjust()
	if(adjusted == DIGITIGRADE_STYLE)
		return
	adjusted = !adjusted
	if(adjusted)
		if(fitted != FEMALE_UNIFORM_TOP)
			fitted = NO_FEMALE_UNIFORM
		if(!alt_covers_chest) // for the special snowflake suits that expose the chest when adjusted (and also the arms, realistically)
			body_parts_covered &= ~CHEST
			body_parts_covered &= ~ARMS
	else
		fitted = initial(fitted)
		if(!alt_covers_chest)
			body_parts_covered |= CHEST
			body_parts_covered |= ARMS
			if(!LAZYLEN(damage_by_parts))
				return adjusted
			for(var/zone in list(BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)) // ugly check to make sure we don't reenable protection on a disabled part
				if(damage_by_parts[zone] > limb_integrity)
					for(var/part in zone2body_parts_covered(zone))
						body_parts_covered &= part
	return adjusted

/obj/item/clothing/under/rank
	dying_key = DYE_REGISTRY_UNDER
