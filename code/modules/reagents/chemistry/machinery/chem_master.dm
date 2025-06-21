/**
 * Machine that allows to identify and separate reagents in fitting container
 * as well as to create new containers with separated reagents in it.
 *
 * Contains logic for both ChemMaster and CondiMaster, switched by "condi".
 */
/obj/machinery/chem_master
	name = "ChemMaster 3000"
	desc = "Used to separate chemicals and distribute them in a variety of forms."
	density = TRUE
	layer = BELOW_OBJ_LAYER
	icon = 'icons/obj/chemical.dmi'
	icon_state = "mixer0"
	use_power = IDLE_POWER_USE
	idle_power_usage = 20
	resistance_flags = FIRE_PROOF | ACID_PROOF
	circuit = /obj/item/circuitboard/machine/chem_master

	/// Input reagents container
	var/obj/item/reagent_containers/beaker
	/// Pill bottle for newly created pills
	var/obj/item/storage/pill_bottle/bottle
	/// Whether separated reagents should be moved back to container or destroyed. 1 - move, 0 - destroy
	var/mode = 1
	/// Decides what UI to show. If TRUE shows UI of CondiMaster, if FALSE - ChemMaster
	var/condi = FALSE
	/// Currently selected pill style
	var/chosen_pill_style = 1
	/// Currently selected condiment bottle style
	var/chosen_condi_style = CONDIMASTER_STYLE_AUTO
	/// Current UI screen. On the moment of writing this comment there were two: 'home' - main screen, and 'analyze' - info about specific reagent
	var/screen = "home"
	/// Info to display on 'analyze' screen
	var/analyze_vars[0]
	/// List of available pill styles for UI
	var/list/pill_styles
	/// List of available condibottle styles for UI
	var/list/condi_styles

/obj/machinery/chem_master/Initialize()
	create_reagents(100)

	//Calculate the span tags and ids fo all the available pill icons
	var/datum/asset/spritesheet/simple/assets = get_asset_datum(/datum/asset/spritesheet/simple/pills)
	pill_styles = list()
	for (var/x in 1 to PILL_STYLE_COUNT)
		var/list/SL = list()
		SL["id"] = x
		SL["className"] = assets.icon_class_name("pill[x]")
		pill_styles += list(SL)

	condi_styles = strip_condi_styles_to_icons(get_condi_styles())

	. = ..()

/obj/machinery/chem_master/Destroy()
	QDEL_NULL(beaker)
	QDEL_NULL(bottle)
	return ..()

/obj/machinery/chem_master/RefreshParts()
	reagents.maximum_volume = 0
	for(var/obj/item/reagent_containers/glass/beaker/B in component_parts)
		reagents.maximum_volume += B.reagents.maximum_volume

/obj/machinery/chem_master/ex_act(severity, target)
	if(severity < 3)
		..()

/obj/machinery/chem_master/contents_explosion(severity, target)
	..()
	if(beaker)
		switch(severity)
			if(EXPLODE_DEVASTATE)
				SSexplosions.high_mov_atom += beaker
			if(EXPLODE_HEAVY)
				SSexplosions.med_mov_atom += beaker
			if(EXPLODE_LIGHT)
				SSexplosions.low_mov_atom += beaker
	if(bottle)
		switch(severity)
			if(EXPLODE_DEVASTATE)
				SSexplosions.high_mov_atom += bottle
			if(EXPLODE_HEAVY)
				SSexplosions.med_mov_atom += bottle
			if(EXPLODE_LIGHT)
				SSexplosions.low_mov_atom += bottle

/obj/machinery/chem_master/handle_atom_del(atom/A)
	..()
	if(A == beaker)
		beaker = null
		reagents.clear_reagents()
		update_icon()
	else if(A == bottle)
		bottle = null

/obj/machinery/chem_master/update_icon_state()
	if(beaker)
		icon_state = "mixer1"
	else
		icon_state = "mixer0"

/obj/machinery/chem_master/update_overlays()
	. = ..()
	if(machine_stat & BROKEN)
		. += "waitlight"

/obj/machinery/chem_master/blob_act(obj/structure/blob/B)
	if (prob(50))
		qdel(src)

/obj/machinery/chem_master/attackby(obj/item/I, mob/user, params)
	if(default_deconstruction_screwdriver(user, "mixer0_nopower", "mixer0", I))
		return

	else if(default_deconstruction_crowbar(I))
		return

	if(default_unfasten_wrench(user, I))
		return
	if(istype(I, /obj/item/reagent_containers) && !(I.item_flags & ABSTRACT) && I.is_open_container())
		. = TRUE // no afterattack
		if(panel_open)
			to_chat(user, "<span class='warning'>You can't use the [src.name] while its panel is opened!</span>")
			return
		var/obj/item/reagent_containers/B = I
		. = TRUE // no afterattack
		if(!user.transferItemToLoc(B, src))
			return
		replace_beaker(user, B)
		to_chat(user, "<span class='notice'>You add [B] to [src].</span>")
		updateUsrDialog()
		update_icon()
	else if(!condi && istype(I, /obj/item/storage/pill_bottle))
		if(bottle)
			to_chat(user, "<span class='warning'>A pill bottle is already loaded into [src]!</span>")
			return
		if(!user.transferItemToLoc(I, src))
			return
		bottle = I
		to_chat(user, "<span class='notice'>You add [I] into the dispenser slot.</span>")
		updateUsrDialog()
	else
		return ..()

/obj/machinery/chem_master/AltClick(mob/living/user)
	. = ..()
	if(!can_interact(user) || !user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		return
	replace_beaker(user)

/**
 * Handles process of moving input reagents containers in/from machine
 *
 * When called checks for previously inserted beaker and gives it to user.
 * Then, if new_beaker provided, places it into src.beaker.
 * Returns `boolean`. TRUE if user provided (ignoring whether threre was any beaker change) and FALSE if not.
 *
 * Arguments:
 * * user - Mob that initialized replacement, gets previously inserted beaker if there's any
 * * new_beaker - New beaker to insert. Optional
 */
/obj/machinery/chem_master/proc/replace_beaker(mob/living/user, obj/item/reagent_containers/new_beaker)
	if(!user)
		return FALSE
	if(beaker)
		try_put_in_hand(beaker, user)
		beaker = null
	if(new_beaker)
		beaker = new_beaker
	update_icon()
	return TRUE

/obj/machinery/chem_master/on_deconstruction()
	replace_beaker()
	if(bottle)
		bottle.forceMove(drop_location())
		adjust_item_drop_location(bottle)
		bottle = null
	return ..()

/obj/machinery/chem_master/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/simple/pills),
		get_asset_datum(/datum/asset/spritesheet/simple/condiments),
	)

/obj/machinery/chem_master/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ChemMaster", name)
		ui.open()

/obj/machinery/chem_master/ui_data(mob/user)
	var/list/data = list()
	data["isBeakerLoaded"] = beaker ? 1 : 0
	data["beakerCurrentVolume"] = beaker ? beaker.reagents.total_volume : null
	data["beakerMaxVolume"] = beaker ? beaker.volume : null
	data["mode"] = mode
	data["condi"] = condi
	data["screen"] = screen
	data["analyzeVars"] = analyze_vars
	data["chosenPillStyle"] = chosen_pill_style
	data["chosenCondiStyle"] = chosen_condi_style
	data["autoCondiStyle"] = CONDIMASTER_STYLE_AUTO
	data["isPillBottleLoaded"] = bottle ? 1 : 0
	if(bottle)
		var/datum/component/storage/STRB = bottle.GetComponent(/datum/component/storage)
		data["pillBottleCurrentAmount"] = bottle.contents.len
		data["pillBottleMaxAmount"] = STRB.max_items

	var/beaker_contents[0]
	if(beaker)
		for(var/datum/reagent/R in beaker.reagents.reagent_list)
			beaker_contents.Add(list(list("name" = R.name, "id" = ckey(R.name), "volume" = R.volume))) // list in a list because Byond merges the first list...
	data["beakerContents"] = beaker_contents

	var/buffer_contents[0]
	if(reagents.total_volume)
		for(var/datum/reagent/N in reagents.reagent_list)
			buffer_contents.Add(list(list("name" = N.name, "id" = ckey(N.name), "volume" = N.volume))) // ^
	data["bufferContents"] = buffer_contents

	//Calculated at init time as it never changes
	data["pillStyles"] = pill_styles
	data["condiStyles"] = condi_styles
	return data

/obj/machinery/chem_master/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("eject")
			if(is_printing)
				say("The buffer is locked while printing.")
				return

			replace_beaker(ui.user)
			return TRUE

		if("transfer")
			if(is_printing)
				say("The buffer is locked while printing.")
				return

			var/reagent_ref = params["reagentRef"]
			var/amount = params["amount"]
			var/target = params["target"]

			if(amount == -1) // Set custom amount
				var/mob/user = ui.user //Hold a reference of the user if the UI is closed
				amount = round(tgui_input_number(user, "Enter amount to transfer", "Transfer amount", round_value = FALSE), CHEMICAL_VOLUME_ROUNDING)
				if(!amount || !user.can_perform_action(src))
					return FALSE

			var/should_transfer = is_transfering || (target == "buffer") // we should always transfer if target is the buffer
			if(should_transfer && isnull(beaker)) // if there's no beaker, we cannot transfer
				say("No reagent container is inserted.")
				return FALSE

			var/reagents_from
			var/reagents_to = null
			if(target == "buffer")
				reagents_from = beaker.reagents
				reagents_to = reagents // buffer
			else if(target == "beaker")
				reagents_from = reagents // buffer
				if(should_transfer)
					reagents_to = beaker.reagents
			return transfer_reagent(reagents_from, reagents_to, reagent_ref, amount, should_transfer)

		if("toggleTransferMode")
			is_transfering = !is_transfering
			return TRUE

		if("stopPrinting")
			is_printing = FALSE
			update_appearance(UPDATE_OVERLAYS)
			return TRUE

		if ("setPillDuration")
			pill_layers = clamp(params["duration"], 0, PILL_MAX_PRINTABLE_LAYERS)
			return TRUE

		if("selectContainer")
			var/obj/item/reagent_containers/target = locate(params["ref"])

			//is this even a valid type path
			if(!ispath(target))
				return FALSE

			//are we printing a valid container
			var/container_found = FALSE
			for(var/category in printable_containers)
				//container found in previous iteration
				if(container_found)
					break

				//find for matching typepath
				for(var/obj/item/reagent_containers/container as anything in printable_containers[category])
					if(target == container)
						container_found = TRUE
						break
			if(!container_found)
				return FALSE

			//set the container
			selected_container = target
			return TRUE

		if("create")
			if(!reagents.total_volume || is_printing)
				return FALSE

			//validate print count
			var/item_count = params["itemCount"]
			if(isnull(item_count))
				return FALSE
			item_count = text2num(item_count)
			if(isnull(item_count) || item_count <= 0)
				return FALSE
			item_count = min(item_count, MAX_CONTAINER_PRINT_AMOUNT)
			var/volume_in_each = min(round(reagents.total_volume / item_count, CHEMICAL_VOLUME_ROUNDING), initial(selected_container.volume))

			// Generate item name
			var/item_name_default = initial(selected_container.name)
			var/datum/reagent/master_reagent = reagents.get_master_reagent()
			if(selected_container == default_container) // Tubes and bottles gain reagent name
				item_name_default = "[master_reagent.name] [item_name_default]"
			if(!(initial(selected_container.reagent_flags) & OPENCONTAINER)) // Closed containers get both reagent name and units in the name
				item_name_default = "[master_reagent.name] [item_name_default] ([volume_in_each]u)"
			var/item_name = tgui_input_text(
				usr,
				"Container name",
				"Name",
				item_name_default,
				max_length = MAX_NAME_LEN,
			)

			if(!item_name || is_printing)
				return FALSE

			//start printing
			is_printing = TRUE
			printing_progress = 0
			printing_total = item_count
			update_appearance(UPDATE_OVERLAYS)
			create_containers(ui.user, item_count, item_name, volume_in_each, selected_container)
			return TRUE

/obj/machinery/chem_master/adjust_item_drop_location(atom/movable/AM) // Special version for chemmasters and condimasters
	if (AM == beaker)
		AM.pixel_x = AM.base_pixel_x - 8
		AM.pixel_y = AM.base_pixel_y + 8
		return null
	else if (AM == bottle)
		if (length(bottle.contents))
			AM.pixel_x = AM.base_pixel_x - 13
		else
			AM.pixel_x = AM.base_pixel_x - 7
		AM.pixel_y = AM.base_pixel_y - 8
		return null
	else
		var/md5 = md5(AM.name)
		for (var/i in 1 to 32)
			. += hex2num(md5[i])
		. = . % 9
		AM.pixel_x = AM.base_pixel_x + ((.%3)*6)
		AM.pixel_y = AM.base_pixel_y - 8 + (round( . / 3)*8)

/**
 * Translates styles data into UI compatible format
 *
 * Expects to receive list of availables condiment styles in its complete format, and transforms them in simplified form with enough data to get UI going.
 * Returns list(list("id" = <key>, "className" = <icon class>, "title" = <name and desc>),..).
 *
 * Arguments:
 * * styles - List of styles for condiment bottles in internal format: [/obj/machinery/chem_master/proc/get_condi_styles]
 */
/obj/machinery/chem_master/proc/strip_condi_styles_to_icons(list/styles)
	var/list/icons = list()
	for (var/s in styles)
		if (styles[s] && styles[s]["class_name"])
			var/list/icon = list()
			var/list/style = styles[s]
			icon["id"] = s
			icon["className"] = style["class_name"]
			icon["title"] = "[style["name"]]\n[style["desc"]]"
			icons += list(icon)

	return icons

/**
 * Defines and provides list of available condiment bottle styles
 *
 * Uses typelist() for styles storage after initialization.
 * For fallback style must provide style with key (const) CONDIMASTER_STYLE_FALLBACK
 * Returns list(
 * 	<key> = list(
 * 		"icon_state" = <bottle icon_state>,
 * 		"name" = <bottle name>,
 * 		"desc" = <bottle desc>,
 * 		?"generate_name" = <if truthy, autogenerates default name from reagents instead of using "name">,
 * 		?"icon_empty" = <icon_state when empty>,
 * 		?"fill_icon_thresholds" = <list of thresholds for reagentfillings, no tresholds if not provided or falsy>,
 * 		?"inhand_icon_state" = <inhand icon_state, falsy - no icon, not provided - whatever is initial (currently "beer")>,
 * 		?"lefthand_file" = <file for inhand icon for left hand, ignored if "inhand_icon_state" not provided>,
 * 		?"righthand_file" = <same as "lefthand_file" but for right hand>,
 * 	),
 * 	..
 * )
 *
 */
/obj/machinery/chem_master/proc/get_condi_styles()
	var/list/styles = typelist("condi_styles")
	if (!styles.len)
		//Possible_states has the reagent type as key and a list of, in order, the icon_state, the name and the desc as values. Was used in the condiment/on_reagent_change(changetype) to change names, descs and sprites.
		styles += list(
			CONDIMASTER_STYLE_FALLBACK = list("icon_state" = "emptycondiment", "icon_empty" = "", "name" = "condiment bottle", "desc" = "Just your average condiment bottle.", "fill_icon_thresholds" = list(0, 10, 25, 50, 75, 100), "generate_name" = TRUE),
			"enzyme" = list("icon_state" = "enzyme", "icon_empty" = "", "name" = "universal enzyme bottle", "desc" = "Used in cooking various dishes."),
			"flour" = list("icon_state" = "flour", "icon_empty" = "", "name" = "flour sack", "desc" = "A big bag of flour. Good for baking!"),
			"mayonnaise" = list("icon_state" = "mayonnaise", "icon_empty" = "", "name" = "mayonnaise jar", "desc" = "An oily condiment made from egg yolks."),
			"milk" = list("icon_state" = "milk", "icon_empty" = "", "name" = "space milk", "desc" = "It's milk. White and nutritious goodness!"),
			"blackpepper" = list("icon_state" = "peppermillsmall", "inhand_icon_state" = "", "icon_empty" = "emptyshaker", "name" = "pepper mill", "desc" = "Often used to flavor food or make people sneeze."),
			"rice" = list("icon_state" = "rice", "icon_empty" = "", "name" = "rice sack", "desc" = "A big bag of rice. Good for cooking!"),
			"sodiumchloride" = list("icon_state" = "saltshakersmall", "inhand_icon_state" = "", "icon_empty" = "emptyshaker", "name" = "salt shaker", "desc" = "Salt. From dead crew, presumably."),
			"soymilk" = list("icon_state" = "soymilk", "icon_empty" = "", "name" = "soy milk", "desc" = "It's soy milk. White and nutritious goodness!"),
			"soysauce" = list("icon_state" = "soysauce", "inhand_icon_state" = "", "icon_empty" = "", "name" = "soy sauce bottle", "desc" = "A salty soy-based flavoring."),
			"sugar" = list("icon_state" = "sugar", "icon_empty" = "", "name" = "sugar sack", "desc" = "Tasty spacey sugar!"),
			"ketchup" = list("icon_state" = "ketchup", "icon_empty" = "", "name" = "ketchup bottle", "desc" = "You feel more American already."),
			"capsaicin" = list("icon_state" = "hotsauce", "icon_empty" = "", "name" = "hotsauce bottle", "desc" = "You can almost TASTE the stomach ulcers!"),
			"frostoil" = list("icon_state" = "coldsauce", "icon_empty" = "", "name" = "coldsauce bottle", "desc" = "Leaves the tongue numb from its passage."),
			"cornoil" = list("icon_state" = "oliveoil", "icon_empty" = "", "name" = "corn oil bottle", "desc" = "A delicious oil used in cooking. Made from corn."),
			"bbqsauce" = list("icon_state" = "bbqsauce", "icon_empty" = "", "name" = "bbq sauce bottle", "desc" = "Hand wipes not included.")
		)
		var/list/carton_in_hand = list(
			"inhand_icon_state" = "carton",
			"lefthand_file" = 'icons/mob/inhands/equipment/kitchen_lefthand.dmi',
			"righthand_file" = 'icons/mob/inhands/equipment/kitchen_righthand.dmi'
		)
		for (var/style_reagent in list("flour", "milk", "rice", "soymilk", "sugar"))
			if (style_reagent in styles)
				styles[style_reagent] += carton_in_hand
		var/datum/asset/spritesheet/simple/assets = get_asset_datum(/datum/asset/spritesheet/simple/condiments)
		for (var/reagent in styles)
			styles[reagent]["class_name"] = assets.icon_class_name(reagent)
	return styles

/**
 * Provides condiment bottle style based on reagents.
 *
 * Gets style from available by key, using last part of main reagent type (eg. "rice" for /datum/reagent/consumable/rice) as key.
 * If not available returns fallback style, or null if no such thing.
 * Returns list that is one of condibottle styles from [/obj/machinery/chem_master/proc/get_condi_styles]
 */
/obj/machinery/chem_master/proc/guess_condi_style(datum/reagents/reagents)
	var/list/styles = get_condi_styles()
	if (reagents.reagent_list.len > 0)
		var/main_reagent = reagents.get_master_reagent_id()
		if (main_reagent)
			var/list/path = splittext("[main_reagent]", "/")
			main_reagent = path[path.len]
		if(main_reagent in styles)
			return styles[main_reagent]
	return styles[CONDIMASTER_STYLE_FALLBACK]

/**
 * Applies style to condiment bottle.
 *
 * Applies props provided in "style" assuming that "container" is freshly created with no styles applied before.
 * User specified name for bottle applied after this method during bottle creation,
 * so container.name overwritten here for consistency rather than with some purpose in mind.
 *
 * Arguments:
 * * container - condiment bottle that gets style applied to it
 * * style - assoc list, must probably one from [/obj/machinery/chem_master/proc/get_condi_styles]
 */
/obj/machinery/chem_master/proc/apply_condi_style(obj/item/reagent_containers/food/condiment/container, list/style)
	container.name = style["name"]
	container.desc = style["desc"]
	container.icon_state = style["icon_state"]
	container.icon_empty = style["icon_empty"]
	container.fill_icon_thresholds = style["fill_icon_thresholds"]
	if ("inhand_icon_state" in style)
		container.inhand_icon_state = style["inhand_icon_state"]
		if (style["lefthand_file"] || style["righthand_file"])
			container.lefthand_file = style["lefthand_file"]
			container.righthand_file = style["righthand_file"]

/**
 * Machine that allows to identify and separate reagents in fitting container
 * as well as to create new containers with separated reagents in it.
 *
 * All logic related to this is in [/obj/machinery/chem_master] and condimaster specific UI enabled by "condi = TRUE"
 */
/obj/machinery/chem_master/condimaster
	name = "CondiMaster 3000"
	desc = "Used to create condiments and other cooking supplies."
	condi = TRUE

