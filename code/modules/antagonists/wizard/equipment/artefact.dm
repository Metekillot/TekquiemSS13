
//Apprenticeship contract - moved to antag_spawner.dm

///////////////////////////Veil Render//////////////////////

/obj/item/veilrender
	name = "veil render"
	desc = "A wicked curved blade of alien origin, recovered from the ruins of a vast city."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "render"
	inhand_icon_state = "knife"
	lefthand_file = 'icons/mob/inhands/equipment/kitchen_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/kitchen_righthand.dmi'
	force = 15
	throwforce = 10
	w_class = WEIGHT_CLASS_NORMAL
	hitsound = 'sound/weapons/bladeslice.ogg'
	var/charges = 1
	var/spawn_type = /obj/tear_in_reality
	var/spawn_amt = 1
	var/activate_descriptor = "reality"
	var/rend_desc = "You should run now."
	var/spawn_fast = FALSE //if TRUE, ignores checking for mobs on loc before spawning

/obj/item/veilrender/attack_self(mob/user)
	if(charges > 0)
		new /obj/effect/rend(get_turf(user), spawn_type, spawn_amt, rend_desc, spawn_fast)
		charges--
		user.visible_message("<span class='boldannounce'>[src] hums with power as [user] deals a blow to [activate_descriptor] itself!</span>")
	else
		to_chat(user, "<span class='danger'>The unearthly energies that powered the blade are now dormant.</span>")

/obj/effect/rend
	name = "tear in the fabric of reality"
	desc = "You should run now."
	icon = 'icons/effects/effects.dmi'
	icon_state = "rift"
	density = TRUE
	anchored = TRUE
	var/spawn_path = /mob/living/simple_animal/cow //defaulty cows to prevent unintentional narsies
	var/spawn_amt_left = 20
	var/spawn_fast = FALSE

/obj/effect/rend/New(loc, spawn_type, spawn_amt, desc, spawn_fast)
	src.spawn_path = spawn_type
	src.spawn_amt_left = spawn_amt
	src.desc = desc
	src.spawn_fast = spawn_fast
	START_PROCESSING(SSobj, src)
	return

/obj/effect/rend/process()
	if(!spawn_fast)
		if(locate(/mob) in loc)
			return
	new spawn_path(loc)
	spawn_amt_left--
	if(spawn_amt_left <= 0)
		qdel(src)

/obj/effect/rend/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/nullrod))
		user.visible_message("<span class='danger'>[user] seals \the [src] with \the [I].</span>")
		qdel(src)
		return
	else
		return ..()

/obj/effect/rend/singularity_act()
	return

/obj/effect/rend/singularity_pull()
	return

/obj/item/veilrender/vealrender
	name = "veal render"
	desc = "A wicked curved blade of alien origin, recovered from the ruins of a vast farm."
	spawn_type = /mob/living/simple_animal/cow
	spawn_amt = 20
	activate_descriptor = "hunger"
	rend_desc = "Reverberates with the sound of ten thousand moos."

/obj/item/veilrender/honkrender
	name = "honk render"
	desc = "A wicked curved blade of alien origin, recovered from the ruins of a vast circus."
	spawn_type = /mob/living/simple_animal/hostile/retaliate/clown
	spawn_amt = 10
	activate_descriptor = "depression"
	rend_desc = "Gently wafting with the sounds of endless laughter."
	icon_state = "clownrender"

/obj/item/veilrender/honkrender/honkhulkrender
	name = "superior honk render"
	desc = "A wicked curved blade of alien origin, recovered from the ruins of a vast circus. This one gleams with a special light."
	spawn_type = /mob/living/simple_animal/hostile/retaliate/clown/clownhulk
	spawn_amt = 5
	activate_descriptor = "depression"
	rend_desc = "Gently wafting with the sounds of mirthful grunting."
	icon_state = "clownrender"

#define TEAR_IN_REALITY_CONSUME_RANGE 3
#define TEAR_IN_REALITY_SINGULARITY_SIZE STAGE_FOUR

/// Tear in reality, spawned by the veil render
/obj/tear_in_reality
	name = "tear in the fabric of reality"
	desc = "This isn't right."
	icon = 'icons/effects/224x224.dmi'
	icon_state = "reality"
	pixel_x = -96
	pixel_y = -96
	anchored = TRUE
	density = TRUE
	move_resist = INFINITY
	layer = MASSIVE_OBJ_LAYER
	light_range = 6
	appearance_flags = LONG_GLIDE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	obj_flags = CAN_BE_HIT | DANGEROUS_POSSESSION

/obj/tear_in_reality/Initialize(mapload)
	. = ..()

	AddComponent(
		/datum/component/singularity, \
		consume_range = TEAR_IN_REALITY_CONSUME_RANGE, \
		notify_admins = !mapload, \
		roaming = FALSE, \
		singularity_size = TEAR_IN_REALITY_SINGULARITY_SIZE, \
	)

/obj/tear_in_reality/attack_tk(mob/user)
	if(!iscarbon(user))
		return
	. = COMPONENT_CANCEL_ATTACK_CHAIN
	var/mob/living/carbon/jedi = user
	var/datum/component/mood/insaneinthemembrane = jedi.GetComponent(/datum/component/mood)
	if(insaneinthemembrane.sanity < 15)
		return //they've already seen it and are about to die, or are just too insane to care
	to_chat(jedi, "<span class='userdanger'>OH GOD! NONE OF IT IS REAL! NONE OF IT IS REEEEEEEEEEEEEEEEEEEEEEEEAL!</span>")
	insaneinthemembrane.sanity = 0
	for(var/lore in typesof(/datum/brain_trauma/severe))
		jedi.gain_trauma(lore)
	addtimer(CALLBACK(src, PROC_REF(deranged), jedi), 10 SECONDS)

/obj/tear_in_reality/proc/deranged(mob/living/carbon/C)
	if(!C || C.stat == DEAD)
		return
	C.vomit(0, TRUE, TRUE, 3, TRUE)
	C.spew_organ(3, 2)
	C.death()

#undef TEAR_IN_REALITY_CONSUME_RANGE
#undef TEAR_IN_REALITY_SINGULARITY_SIZE

/////////////////////////////////////////Scrying///////////////////

/obj/item/scrying
	name = "scrying orb"
	desc = "An incandescent orb of otherworldly energy, merely holding it gives you vision and hearing beyond mortal means, and staring into it lets you see the entire universe."
	icon = 'icons/obj/projectiles.dmi'
	icon_state ="bluespace"
	throw_speed = 3
	throw_range = 7
	throwforce = 15
	damtype = BURN
	force = 15
	hitsound = 'sound/items/welder2.ogg'

	var/mob/current_owner

/obj/item/scrying/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/scrying/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/scrying/process()
	var/mob/holder = get(loc, /mob)
	if(current_owner && current_owner != holder)

		to_chat(current_owner, "<span class='notice'>Your otherworldly vision fades...</span>")

		REMOVE_TRAIT(current_owner, TRAIT_SIXTHSENSE, SCRYING_ORB)
		REMOVE_TRAIT(current_owner, TRAIT_XRAY_VISION, SCRYING_ORB)
		current_owner.update_sight()

		current_owner = null

	if(!current_owner && holder)
		current_owner = holder

		to_chat(current_owner, "<span class='notice'>You can see...everything!</span>")

		ADD_TRAIT(current_owner, TRAIT_SIXTHSENSE, SCRYING_ORB)
		ADD_TRAIT(current_owner, TRAIT_XRAY_VISION, SCRYING_ORB)
		current_owner.update_sight()

/obj/item/scrying/attack_self(mob/user)
	visible_message("<span class='danger'>[user] stares into [src], their eyes glazing over.</span>")
	user.ghostize(1)

/////////////////////////////////////////Necromantic Stone///////////////////

/obj/item/necromantic_stone
	name = "necromantic stone"
	desc = "A shard capable of resurrecting humans as skeleton thralls."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "necrostone"
	inhand_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_TINY
	var/list/spooky_scaries = list()
	var/unlimited = 0

/obj/item/necromantic_stone/unlimited
	unlimited = 1

/obj/item/necromantic_stone/attack(mob/living/carbon/human/M, mob/living/carbon/human/user)
	if(!istype(M))
		return ..()

	if(!istype(user) || !user.canUseTopic(M, BE_CLOSE))
		return

	if(M.stat != DEAD)
		to_chat(user, "<span class='warning'>This artifact can only affect the dead!</span>")
		return

	for(var/mob/dead/observer/ghost in GLOB.dead_mob_list) //excludes new players
		if(ghost.mind && ghost.mind.current == M && ghost.client)  //the dead mobs list can contain clientless mobs
			ghost.reenter_corpse()
			break

	if(!M.mind || !M.client)
		to_chat(user, "<span class='warning'>There is no soul connected to this body...</span>")
		return

	check_spooky()//clean out/refresh the list
	if(spooky_scaries.len >= 3 && !unlimited)
		to_chat(user, "<span class='warning'>This artifact can only affect three undead at a time!</span>")
		return

	M.set_species(/datum/species/skeleton, icon_update=0)
	M.revive(full_heal = TRUE, admin_revive = TRUE)
	spooky_scaries |= M
	to_chat(M, "<span class='userdanger'>You have been revived by </span><B>[user.real_name]!</B>")
	to_chat(M, "<span class='userdanger'>[user.p_theyre(TRUE)] your master now, assist [user.p_them()] even if it costs you your new life!</span>")

	equip_roman_skeleton(M)

	desc = "A shard capable of resurrecting humans as skeleton thralls[unlimited ? "." : ", [spooky_scaries.len]/3 active thralls."]"

/obj/item/necromantic_stone/proc/check_spooky()
	if(unlimited) //no point, the list isn't used.
		return

	for(var/X in spooky_scaries)
		if(!ishuman(X))
			spooky_scaries.Remove(X)
			continue
		var/mob/living/carbon/human/H = X
		if(H.stat == DEAD)
			H.dust(TRUE)
			spooky_scaries.Remove(X)
			continue
	listclearnulls(spooky_scaries)

//Funny gimmick, skeletons always seem to wear roman/ancient armour
/obj/item/necromantic_stone/proc/equip_roman_skeleton(mob/living/carbon/human/H)
	for(var/obj/item/I in H)
		H.dropItemToGround(I)

	var/hat = pick(/obj/item/clothing/head/helmet/roman, /obj/item/clothing/head/helmet/roman/legionnaire)
	H.equip_to_slot_or_del(new hat(H), ITEM_SLOT_HEAD)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/costume/roman(H), ITEM_SLOT_ICLOTHING)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/roman(H), ITEM_SLOT_FEET)
	H.put_in_hands(new /obj/item/shield/riot/roman(H), TRUE)
	H.put_in_hands(new /obj/item/claymore(H), TRUE)
	H.equip_to_slot_or_del(new /obj/item/spear(H), ITEM_SLOT_BACK)


/obj/item/voodoo
	name = "wicker doll"
	desc = "Something creepy about it."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "voodoo"
	inhand_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	var/mob/living/carbon/human/target = null
	var/list/mob/living/carbon/human/possible = list()
	var/obj/item/voodoo_link = null
	var/cooldown_time = 30 //3s
	var/cooldown = 0
	max_integrity = 10
	resistance_flags = FLAMMABLE

/obj/item/voodoo/attackby(obj/item/I, mob/user, params)
	if(target && cooldown < world.time)
		if(I.get_temperature())
			to_chat(target, "<span class='userdanger'>You suddenly feel very hot!</span>")
			target.adjust_bodytemperature(50)
			GiveHint(target)
		else if(I.get_sharpness() == SHARP_POINTY)
			to_chat(target, "<span class='userdanger'>You feel a stabbing pain in [parse_zone(user.zone_selected)]!</span>")
			target.Paralyze(40)
			GiveHint(target)
		else if(istype(I, /obj/item/bikehorn))
			to_chat(target, "<span class='userdanger'>HONK</span>")
			SEND_SOUND(target, 'sound/items/airhorn.ogg')
			var/obj/item/organ/ears/ears = user.getorganslot(ORGAN_SLOT_EARS)
			if(ears)
				ears.adjustEarDamage(0, 3)
			GiveHint(target)
		cooldown = world.time +cooldown_time
		return

	if(!voodoo_link)
		if(I.loc == user && istype(I) && I.w_class <= WEIGHT_CLASS_SMALL)
			if (user.transferItemToLoc(I,src))
				voodoo_link = I
				to_chat(user, "You attach [I] to the doll.")
				update_targets()

/obj/item/voodoo/check_eye(mob/user)
	if(loc != user)
		user.reset_perspective(null)
		user.unset_machine()

/obj/item/voodoo/attack_self(mob/user)
	if(!target && possible.len)
		target = input(user, "Select your victim!", "Voodoo") as null|anything in sortNames(possible)
		return

	if(user.zone_selected == BODY_ZONE_CHEST)
		if(voodoo_link)
			target = null
			voodoo_link.forceMove(drop_location())
			to_chat(user, "<span class='notice'>You remove the [voodoo_link] from the doll.</span>")
			voodoo_link = null
			update_targets()
			return

	if(target && cooldown < world.time)
		switch(user.zone_selected)
			if(BODY_ZONE_PRECISE_MOUTH)
				var/wgw =  sanitize(input(user, "What would you like the victim to say", "Voodoo", null)  as text)
				target.say(wgw, forced = "voodoo doll")
				log_game("[key_name(user)] made [key_name(target)] say [wgw] with a voodoo doll.")
			if(BODY_ZONE_PRECISE_EYES)
				user.set_machine(src)
				user.reset_perspective(target)
				addtimer(CALLBACK(src, PROC_REF(reset), user), 10 SECONDS)
			if(BODY_ZONE_R_LEG,BODY_ZONE_L_LEG)
				to_chat(user, "<span class='notice'>You move the doll's legs around.</span>")
				var/turf/T = get_step(target,pick(GLOB.cardinals))
				target.Move(T)
			if(BODY_ZONE_R_ARM,BODY_ZONE_L_ARM)
				target.click_random_mob()
				GiveHint(target)
			if(BODY_ZONE_HEAD)
				to_chat(user, "<span class='notice'>You smack the doll's head with your hand.</span>")
				target.Dizzy(10)
				to_chat(target, "<span class='warning'>You suddenly feel as if your head was hit with a hammer!</span>")
				GiveHint(target,user)
		cooldown = world.time + cooldown_time

/obj/item/voodoo/proc/reset(mob/user)
	if(QDELETED(user))
		return
	user.reset_perspective(null)
	user.unset_machine()

/obj/item/voodoo/proc/update_targets()
	possible = list()
	if(!voodoo_link)
		return
	var/list/prints = voodoo_link.return_fingerprints()
	if(!length(prints))
		return FALSE
	for(var/mob/living/carbon/human/H in GLOB.alive_mob_list)
		if(prints[md5(H.dna.uni_identity)])
			possible |= H

/obj/item/voodoo/proc/GiveHint(mob/victim,force=0)
	if(prob(50) || force)
		var/way = dir2text(get_dir(victim,get_turf(src)))
		to_chat(victim, "<span class='notice'>You feel a dark presence from [way].</span>")
	if(prob(20) || force)
		var/area/A = get_area(src)
		to_chat(victim, "<span class='notice'>You feel a dark presence from [A.name].</span>")

/obj/item/voodoo/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] links the voodoo doll to [user.p_them()]self and sits on it, infinitely crushing [user.p_them()]self! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	user.gib()
	return(BRUTELOSS)

/obj/item/voodoo/fire_act(exposed_temperature, exposed_volume)
	if(target)
		target.adjust_fire_stacks(20)
		target.IgniteMob()
		GiveHint(target,1)
	return ..()

//Provides a decent heal, need to pump every 6 seconds
/obj/item/organ/heart/cursed/wizard
	pump_delay = 60
	heal_brute = 25
	heal_burn = 25
	heal_oxy = 25

//Warp Whistle: Provides uncontrolled long distance teleportation.
/obj/item/warpwhistle
	name = "warp whistle"
	desc = "One toot on this whistle will send you to a far away land!"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "whistle"
	var/on_cooldown = 0 //0: usable, 1: in use, 2: on cooldown
	var/mob/living/carbon/last_user

/obj/item/warpwhistle/proc/interrupted(mob/living/carbon/user)
	if(!user || QDELETED(src) || user.notransform)
		on_cooldown = FALSE
		return TRUE
	return FALSE

/obj/item/warpwhistle/proc/end_effect(mob/living/carbon/user)
	user.invisibility = initial(user.invisibility)
	user.status_flags &= ~GODMODE
	REMOVE_TRAIT(user, TRAIT_IMMOBILIZED, WARPWHISTLE_TRAIT)


/obj/item/warpwhistle/attack_self(mob/living/carbon/user)
	if(!istype(user) || on_cooldown)
		return
	on_cooldown = TRUE
	last_user = user
	var/turf/T = get_turf(user)
	playsound(T,'sound/magic/warpwhistle.ogg', 200, TRUE)
	ADD_TRAIT(user, TRAIT_IMMOBILIZED, WARPWHISTLE_TRAIT)
	new /obj/effect/temp_visual/tornado(T)
	sleep(20)
	if(interrupted(user))
		REMOVE_TRAIT(user, TRAIT_IMMOBILIZED, WARPWHISTLE_TRAIT)
		return
	user.invisibility = INVISIBILITY_MAXIMUM
	user.status_flags |= GODMODE
	sleep(20)
	if(interrupted(user))
		end_effect(user)
		return
	var/breakout = 0
	while(breakout < 50)
		var/turf/potential_T = find_safe_turf()
		if(T.z != potential_T.z || abs(get_dist_euclidian(potential_T,T)) > 50 - breakout)
			do_teleport(user, potential_T, channel = TELEPORT_CHANNEL_MAGIC)
			T = potential_T
			break
		breakout += 1
	new /obj/effect/temp_visual/tornado(T)
	sleep(20)
	end_effect(user)
	if(interrupted(user))
		return
	on_cooldown = 2
	addtimer(VARSET_CALLBACK(src, on_cooldown, 0), 4 SECONDS)

/obj/item/warpwhistle/Destroy()
	if(on_cooldown == 1 && last_user) //Flute got dunked somewhere in the teleport
		end_effect(last_user)
	return ..()

/obj/effect/temp_visual/tornado
	icon = 'icons/obj/wizard.dmi'
	icon_state = "tornado"
	name = "tornado"
	desc = "This thing sucks!"
	layer = FLY_LAYER
	randomdir = 0
	duration = 40
	pixel_x = 500

/obj/effect/temp_visual/tornado/Initialize()
	. = ..()
	src.whistle = whistle
	if(!whistle)
		qdel(src)
		return
	RegisterSignal(src, COMSIG_MOVABLE_CROSS_OVER, PROC_REF(check_teleport))
	DSmove_manager.move_towards(src, get_turf(whistle.whistler))

/// Check if anything the tornado crosses is the creator.
/obj/effect/temp_visual/teleporting_tornado/proc/check_teleport(datum/source, atom/movable/crossed)
	SIGNAL_HANDLER
	if(crossed != whistle.whistler || (crossed in pickedup_mobs))
		return

	pickedup_mobs += crossed
	buckle_mob(crossed, TRUE, FALSE)
	ADD_TRAIT(crossed, TRAIT_INCAPACITATED, WARPWHISTLE_TRAIT)
	animate(src, alpha = 20, pixel_y = 400, time = 3 SECONDS)
	animate(crossed, pixel_y = 400, time = 3 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(send_away)), 2 SECONDS)

/obj/effect/temp_visual/teleporting_tornado/proc/send_away()
	var/turf/ending_turfs = find_safe_turf()
	for(var/mob/stored_mobs as anything in pickedup_mobs)
		do_teleport(stored_mobs, ending_turfs, channel = TELEPORT_CHANNEL_MAGIC)
		animate(stored_mobs, pixel_y = null, time = 1 SECONDS)
		stored_mobs.log_message("warped with [whistle].", LOG_ATTACK, color = "red")
		REMOVE_TRAIT(stored_mobs, TRAIT_INCAPACITATED, WARPWHISTLE_TRAIT)

/// Destroy the tornado and teleport everyone on it away.
/obj/effect/temp_visual/teleporting_tornado/Destroy()
	if(whistle)
		whistle.whistler = null
		whistle = null
	return ..()

/////////////////////////////////////////Scepter of Vendormancy///////////////////
#define RUNIC_SCEPTER_MAX_CHARGES 3
#define RUNIC_SCEPTER_MAX_RANGE 7

/obj/item/runic_vendor_scepter
	name = "scepter of runic vendormancy"
	desc = "This scepter allows you to conjure, force push and detonate Runic Vendors. It can hold up to 3 charges that can be recovered with a simple magical channeling. A modern spin on the old Geomancy spells."
	icon_state = "vendor_staff"
	inhand_icon_state = "vendor_staff"
	lefthand_file = 'icons/mob/inhands/weapons/staves_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/staves_righthand.dmi'
	icon = 'icons/obj/weapons/guns/magic.dmi'
	slot_flags = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_NORMAL
	force = 10
	damtype = BRUTE
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	attack_verb_continuous = list("smacks", "clubs", "wacks")
	attack_verb_simple = list("smack", "club", "wacks")

	/// Range cap on where you can summon vendors.
	var/max_summon_range = RUNIC_SCEPTER_MAX_RANGE
	/// Channeling time to summon a vendor.
	var/summoning_time = 1 SECONDS
	/// Checks if the scepter is channeling a vendor already.
	var/scepter_is_busy_summoning = FALSE
	/// Checks if the scepter is busy channeling recharges
	var/scepter_is_busy_recharging = FALSE
	///Number of summoning charges left.
	var/summon_vendor_charges = RUNIC_SCEPTER_MAX_CHARGES

/obj/item/runic_vendor_scepter/Initialize(mapload)
	. = ..()

	RegisterSignal(src, COMSIG_ITEM_MAGICALLY_CHARGED, PROC_REF(on_magic_charge))
	var/static/list/loc_connections = list(
		COMSIG_ITEM_MAGICALLY_CHARGED = PROC_REF(on_magic_charge),
	)

/obj/item/runic_vendor_scepter/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(scepter_is_busy_recharging)
		user.balloon_alert(user, "busy!")
		return
	if(!check_allowed_items(target, not_inside = TRUE))
		return
	. |= AFTERATTACK_PROCESSED_ITEM
	var/turf/afterattack_turf = get_turf(target)
	if(istype(target, /obj/machinery/vending/runic_vendor))
		var/obj/machinery/vending/runic_vendor/runic_explosion_target = target
		runic_explosion_target.runic_explosion()
		return
	var/obj/machinery/vending/runic_vendor/vendor_on_turf = locate() in afterattack_turf
	if(vendor_on_turf)
		vendor_on_turf.runic_explosion()
		return
	if(!summon_vendor_charges)
		user.balloon_alert(user, "no charges!")
		return
	if(get_dist(afterattack_turf,src) > max_summon_range)
		user.balloon_alert(user, "too far!")
		return
	if(get_turf(src) == afterattack_turf)
		user.balloon_alert(user, "too close!")
		return
	if(scepter_is_busy_summoning)
		user.balloon_alert(user, "already summoning!")
		return
	if(afterattack_turf.is_blocked_turf(TRUE))
		user.balloon_alert(user, "blocked!")
		return
	if(summoning_time)
		scepter_is_busy_summoning = TRUE
		user.balloon_alert(user, "summoning...")
		if(!do_after(user, summoning_time, target = target))
			scepter_is_busy_summoning = FALSE
			return
		scepter_is_busy_summoning = FALSE
	if(summon_vendor_charges)
		playsound(src,'sound/weapons/resonator_fire.ogg',50,TRUE)
		user.visible_message(span_warning("[user] summons a runic vendor!"))
		new /obj/machinery/vending/runic_vendor(afterattack_turf)
		summon_vendor_charges--
		user.changeNext_move(CLICK_CD_MELEE)
		return
	return ..()

/obj/item/runic_vendor_scepter/attack_self(mob/user, modifiers)
	. = ..()
	user.balloon_alert(user, "recharging...")
	scepter_is_busy_recharging = TRUE
	if(!do_after(user, 5 SECONDS))
		scepter_is_busy_recharging = FALSE
		return
	user.balloon_alert(user, "fully charged")
	scepter_is_busy_recharging = FALSE
	summon_vendor_charges = RUNIC_SCEPTER_MAX_CHARGES

/obj/item/runic_vendor_scepter/afterattack_secondary(atom/target, mob/user, proximity_flag, click_parameters)
	var/turf/afterattack_secondary_turf = get_turf(target)
	var/obj/machinery/vending/runic_vendor/vendor_on_turf = locate() in afterattack_secondary_turf
	if(istype(target, /obj/machinery/vending/runic_vendor))
		var/obj/machinery/vending/runic_vendor/vendor_being_throw = target
		vendor_being_throw.throw_at(get_edge_target_turf(target, get_cardinal_dir(src, target)), 4, 20, user)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(vendor_on_turf)
		vendor_on_turf.throw_at(get_edge_target_turf(target, get_cardinal_dir(src, target)), 4, 20, user)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/runic_vendor_scepter/proc/on_magic_charge(datum/source, datum/action/cooldown/spell/charge/spell, mob/living/caster)
	SIGNAL_HANDLER

	if(!ismovable(loc))
		return

	. = COMPONENT_ITEM_CHARGED

	summon_vendor_charges = RUNIC_SCEPTER_MAX_CHARGES
	return .

#undef RUNIC_SCEPTER_MAX_CHARGES
#undef RUNIC_SCEPTER_MAX_RANGE
