#define AUTOLATHE_MAIN_MENU		1
#define AUTOLATHE_CATEGORY_MENU	2
#define AUTOLATHE_SEARCH_MENU	3

/obj/machinery/autolathe
	name = "autolathe"
	desc = "It produces items using metal and glass."
	icon_state = "autolathe"
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 100
	circuit = /obj/item/circuitboard/machine/autolathe
	layer = BELOW_OBJ_LAYER

	var/operating = FALSE
	var/list/L = list()
	var/list/LL = list()
	var/hacked = FALSE
	var/disabled = FALSE
	var/shocked = FALSE
	var/hack_wire
	var/disable_wire
	var/shock_wire

/obj/machinery/autolathe/Initialize(mapload)
	materials = AddComponent( \
		/datum/component/material_container, \
		DSmaterials.materials_by_category[MAT_CATEGORY_ITEM_MATERIAL], \
		0, \
		MATCONTAINER_EXAMINE, \
		container_signals = list(COMSIG_MATCONTAINER_ITEM_CONSUMED = TYPE_PROC_REF(/obj/machinery/autolathe, AfterMaterialInsert)) \
	)
	. = ..()

	wires = new /datum/wires/autolathe(src)
	stored_research = new /datum/techweb/specialized/autounlocking/autolathe
	matching_designs = list()

/obj/machinery/autolathe/Destroy()
	QDEL_NULL(wires)
	return ..()

/obj/machinery/autolathe/ui_interact(mob/user)
	. = ..()
	if(!is_operational)
		return

	if(shocked && !(machine_stat & NOPOWER))
		shock(user,50)

	var/dat

	switch(screen)
		if(AUTOLATHE_MAIN_MENU)
			dat = main_win(user)
		if(AUTOLATHE_CATEGORY_MENU)
			dat = category_win(user,selected_category)
		if(AUTOLATHE_SEARCH_MENU)
			dat = search_win(user)

	var/datum/browser/popup = new(user, "autolathe", name, 400, 500)
	popup.set_content(dat)
	popup.open()

/obj/machinery/autolathe/on_deconstruction()
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	materials.retrieve_all()

	var/list/output = list()

	var/datum/asset/spritesheet/research_designs/spritesheet = get_asset_datum(/datum/asset/spritesheet/research_designs)
	var/size32x32 = "[spritesheet.name]32x32"

	for(var/design_id in designs)
		var/datum/design/design = SSresearch.techweb_design_by_id(design_id)
		if(design.make_reagent)
			continue

		//compute cost & maximum number of printable items
		var/coeff = (ispath(design.build_path, /obj/item/stack) ? 1 : creation_efficiency)
		var/list/cost = list()
		var/customMaterials = FALSE
		for(var/i in design.materials)
			var/datum/material/mat = i

			var/design_cost = OPTIMAL_COST(design.materials[i] * coeff)
			if(istype(mat))
				cost[mat.name] = design_cost
				customMaterials = FALSE
			else
				cost[i] = design_cost
				customMaterials = TRUE

		//create & send ui data
		var/icon_size = spritesheet.icon_size_id(design.id)
		var/list/design_data = list(
			"name" = design.name,
			"desc" = design.get_description(),
			"cost" = cost,
			"id" = design.id,
			"categories" = design.category,
			"icon" = "[icon_size == size32x32 ? "" : "[icon_size] "][design.id]",
			"customMaterials" = customMaterials
		)

		output += list(design_data)

	return output

/obj/machinery/autolathe/ui_static_data(mob/user)
	var/list/data = materials.ui_static_data()

	data["designs"] = handle_designs(stored_research.researched_designs)
	if(imported_designs.len)
		data["designs"] += handle_designs(imported_designs)
	if(hacked)
		data["designs"] += handle_designs(stored_research.hacked_designs)

	return data


/obj/machinery/autolathe/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/sheetmaterials),
		get_asset_datum(/datum/asset/spritesheet/research_designs),
	)

/obj/machinery/autolathe/ui_data(mob/user)
	var/list/data = list()

	data["materials"] = list()
	data["materialtotal"] = materials.total_amount()
	data["materialsmax"] = materials.max_amount
	data["active"] = busy
	data["materials"] = materials.ui_data()

	return data

/obj/machinery/autolathe/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	//sanity checks to start printing
	if(action != "make")
		stack_trace("unknown autolathe ui_act: [action]")
		return
	if(disabled)
		say("Unable to print, voltage mismatch in internal wiring.")
		return
	if(busy)
		say("currently printing.")
		return

	//validate design
	var/design_id = params["id"]
	if(!design_id)
		return
	var/valid_design = stored_research.researched_designs[design_id]
	valid_design ||= stored_research.hacked_designs[design_id]
	valid_design ||= imported_designs[design_id]
	if(!valid_design)
		return
	var/datum/design/design = SSresearch.techweb_design_by_id(design_id)
	if(isnull(design))
		stack_trace("got passed an invalid design id: [design_id] and somehow made it past all checks")
		return
	if(!(design.build_type & AUTOLATHE))
		say("This fabricator does not have the necessary keys to decrypt this design.")
		return

	//validate print quantity
	var/build_count = params["multiplier"]
	if(isnull(build_count))
		return
	build_count = text2num(build_count)
	if(isnull(build_count))
		return
	build_count = clamp(build_count, 1, 50)

	//check for materials required. For custom material items decode their required materials
	var/list/materials_needed = list()
	for(var/material in design.materials)
		var/amount_needed = design.materials[material]
		if(istext(material)) // category
			var/list/choices = list()
			for(var/datum/material/valid_candidate as anything in DSmaterials.materials_by_category[material])
				if(materials.get_material_amount(valid_candidate) < amount_needed)
					continue
				choices[valid_candidate.name] = valid_candidate
			if(!length(choices))
				say("No valid materials with applicable amounts detected for design.")
				return
			var/chosen = tgui_input_list(
				ui.user,
				"Select the material to use",
				"Material Selection",
				sort_list(choices),
			)
			if(isnull(chosen))
				return // user cancelled
			material = choices[chosen]

		if(isnull(material))
			stack_trace("got passed an invalid material id: [material]")
			return
		materials_needed[material] = amount_needed

	//checks for available materials
	var/material_cost_coefficient = ispath(design.build_path, /obj/item/stack) ? 1 : creation_efficiency
	if(!materials.has_materials(materials_needed, material_cost_coefficient, build_count))
		say("Not enough materials to begin production.")
		return

	//compute power & time to print 1 item
	var/charge_per_item = 0
	for(var/material in design.materials)
		charge_per_item += design.materials[material]
	charge_per_item = ROUND_UP((charge_per_item / (MAX_STACK_SIZE * SHEET_MATERIAL_AMOUNT)) * material_cost_coefficient * active_power_usage)
	var/build_time_per_item = (design.construction_time * design.lathe_time_factor) ** 0.8

	//do the printing sequentially
	busy = TRUE
	icon_state = "autolathe_n"
	SStgui.update_uis(src)
	var/turf/target_location
	if(drop_direction)
		target_location = get_step(src, drop_direction)
		if(isclosedturf(target_location))
			target_location = get_turf(src)
	else
		target_location = get_turf(src)
	addtimer(CALLBACK(src, PROC_REF(do_make_item), design, build_count, build_time_per_item, material_cost_coefficient, charge_per_item, materials_needed, target_location), build_time_per_item)

	return TRUE

/**
 * Callback for start_making, actually makes the item
 * Arguments
 *
 * * datum/design/design - the design we are trying to print
 * * items_remaining - the number of designs left out to print
 * * build_time_per_item - the time taken to print 1 item
 * * material_cost_coefficient - the cost efficiency to print 1 design
 * * charge_per_item - the amount of power to print 1 item
 * * list/materials_needed - the list of materials to print 1 item
 * * turf/target - the location to drop the printed item on
*/
/obj/machinery/autolathe/proc/do_make_item(datum/design/design, items_remaining, build_time_per_item, material_cost_coefficient, charge_per_item, list/materials_needed, turf/target)
	PROTECTED_PROC(TRUE)

	if(items_remaining <= 0) // how
		finalize_build()
		return

	if(!is_operational)
		say("Unable to continue production, power failure.")
		finalize_build()
		return

	if(!directly_use_energy(charge_per_item)) // provide the wait time until lathe is ready
		var/area/my_area = get_area(src)
		var/obj/machinery/power/apc/my_apc = my_area.apc
		var/charging_wait = my_apc.time_to_charge(charge_per_item)
		if(!isnull(charging_wait))
			say("Unable to continue production, APC overload. Wait [DisplayTimeText(charging_wait, round_seconds_to = 1)] and try again.")
		else
			say("Unable to continue production, power grid overload.")
		finalize_build()
		return

	var/is_stack = ispath(design.build_path, /obj/item/stack)
	if(!materials.has_materials(materials_needed, material_cost_coefficient, is_stack ? items_remaining : 1))
		say("Unable to continue production, missing materials.")
		return
	materials.use_materials(materials_needed, material_cost_coefficient, is_stack ? items_remaining : 1)

	var/atom/movable/created
	if(is_stack)
		created = new design.build_path(target, items_remaining)
	else
		created = new design.build_path(target)
		split_materials_uniformly(materials_needed, material_cost_coefficient, created)

	created.pixel_x = created.base_pixel_x + rand(-6, 6)
	created.pixel_y = created.base_pixel_y + rand(-6, 6)
	created.forceMove(target)

	if(is_stack)
		items_remaining = 0
	else
		items_remaining -= 1

	if(items_remaining <= 0)
		finalize_build()
		return
	addtimer(CALLBACK(src, PROC_REF(do_make_item), design, items_remaining, build_time_per_item, material_cost_coefficient, charge_per_item, materials_needed, target), build_time_per_item)

/**
 * Resets the icon state and busy flag
 * Called at the end of do_make_item's timer loop
*/
/obj/machinery/autolathe/proc/finalize_build()
	PROTECTED_PROC(TRUE)

	icon_state = initial(icon_state)
	busy = FALSE
	SStgui.update_uis(src)

/obj/machinery/autolathe/MouseDrop(atom/over, src_location, over_location, src_control, over_control, params)
	. = ..()
	if(!can_interact(usr) || (!HAS_SILICON_ACCESS(usr) && !isAdminGhostAI(usr)) && !Adjacent(usr))
		return
	if(busy)
		balloon_alert(usr, "printing started!")
		return
	var/direction = get_dir(src, over_location)
	if(!direction)
		return
	drop_direction = direction
	balloon_alert(usr, "dropping [dir2text(drop_direction)]")

/obj/machinery/autolathe/click_alt(mob/user)
	if(!drop_direction)
		return CLICK_ACTION_BLOCKING
	if(busy)
		balloon_alert(user, "busy printing!")
		return CLICK_ACTION_SUCCESS
	balloon_alert(user, "drop direction reset")
	drop_direction = 0
	return CLICK_ACTION_SUCCESS

/obj/machinery/autolathe/attackby(obj/item/attacking_item, mob/living/user, params)
	if(user.combat_mode) //so we can hit the machine
		return ..()

	if(busy)
		balloon_alert(user, "it's busy!")
		return TRUE

	if(default_deconstruction_screwdriver(user, "autolathe_t", "autolathe", O))
		updateUsrDialog()
		return TRUE

	if(default_deconstruction_crowbar(O))
		return TRUE

	if(panel_open && is_wire_tool(O))
		wires.interact(user)
		return TRUE

	if(user.a_intent == INTENT_HARM) //so we can hit the machine
		return ..()

	if(machine_stat)
		return TRUE

	if(istype(O, /obj/item/disk/design_disk))
		user.visible_message("<span class='notice'>[user] begins to load \the [O] in \the [src]...</span>",
			"<span class='notice'>You begin to load a design from \the [O]...</span>",
			"<span class='hear'>You hear the chatter of a floppy drive.</span>")
		busy = TRUE
		var/obj/item/disk/design_disk/D = O
		if(do_after(user, 14.4, target = src))
			for(var/B in D.blueprints)
				if(B)
					stored_research.add_design(B)
		busy = FALSE
		return TRUE

	return ..()


/obj/machinery/autolathe/proc/AfterMaterialInsert(obj/item/item_inserted, id_inserted, amount_inserted)
	if(istype(item_inserted, /obj/item/stack/ore/bluespace_crystal))
		use_power(MINERAL_MATERIAL_AMOUNT / 10)
	else if(item_inserted.has_material_type(/datum/material/glass))
		flick("autolathe_r", src)//plays glass insertion animation by default otherwise
	else
		flick("autolathe_o", src)//plays metal insertion animation

		use_power(min(1000, amount_inserted / 100))
	updateUsrDialog()

/obj/machinery/autolathe/Topic(href, href_list)
	if(..())
		return
	if (!busy)
		if(href_list["menu"])
			screen = text2num(href_list["menu"])
			updateUsrDialog()

		if(href_list["category"])
			selected_category = href_list["category"]
			updateUsrDialog()

		if(href_list["make"])

			/////////////////
			//href protection
			being_built = stored_research.isDesignResearchedID(href_list["make"])
			if(!being_built)
				return

			var/multiplier = text2num(href_list["multiplier"])
			var/is_stack = ispath(being_built.build_path, /obj/item/stack)
			multiplier = clamp(multiplier,1,50)

			/////////////////

			var/coeff = (is_stack ? 1 : prod_coeff) //stacks are unaffected by production coefficient
			var/total_amount = 0

			for(var/MAT in being_built.materials)
				total_amount += being_built.materials[MAT]

			var/power = max(2000, (total_amount)*multiplier/5) //Change this to use all materials

			var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)

			var/list/materials_used = list()
			var/list/custom_materials = list() //These will apply their material effect, This should usually only be one.

			for(var/MAT in being_built.materials)
				var/datum/material/used_material = MAT
				var/amount_needed = being_built.materials[MAT] * coeff * multiplier
				if(istext(used_material)) //This means its a category
					var/list/list_to_show = list()
					for(var/i in SSmaterials.materials_by_category[used_material])
						if(materials.materials[i] > 0)
							list_to_show += i

					used_material = tgui_input_list(usr, "Choose [used_material]", "Custom Material", sort_list(list_to_show, /proc/cmp_typepaths_asc))
					if(isnull(used_material))
						return //Didn't pick any material, so you can't build shit either.
					custom_materials[used_material] += amount_needed

				materials_used[used_material] = amount_needed

			if(materials.has_materials(materials_used))
				busy = TRUE
				use_power(power)
				icon_state = "autolathe_n"
				var/time = is_stack ? 32 : (32 * coeff * multiplier) ** 0.8
				addtimer(CALLBACK(src, PROC_REF(make_item), power, materials_used, custom_materials, multiplier, coeff, is_stack, usr), time)
			else
				to_chat(usr, "<span class=\"alert\">Not enough materials for this operation.</span>")

		if(href_list["search"])
			matching_designs.Cut()

/obj/machinery/autolathe/attackby(obj/item/O, mob/living/user, params)
	if(busy)
		balloon_alert(user, "it's busy!")
		return TRUE

	if(default_deconstruction_crowbar(O))
		return TRUE

	if(panel_open && is_wire_tool(O))
		wires.interact(user)
		return TRUE

	if(user.combat_mode) //so we can hit the machine
		return ..()

	if(machine_stat)
		return TRUE

	if(istype(O, /obj/item/disk/design_disk))
		user.visible_message(span_notice("[user] begins to load \the [O] in \the [src]..."),
			balloon_alert(user, "uploading design..."),
			span_hear("You hear the chatter of a floppy drive."))
		busy = TRUE
		if(do_after(user, 14.4, target = src))
			var/obj/item/disk/design_disk/disky = O
			var/list/not_imported
			for(var/datum/design/blueprint as anything in disky.blueprints)
				if(!blueprint)
					continue
				if(blueprint.build_type & AUTOLATHE)
					stored_research.add_design(blueprint)
				else
					LAZYADD(not_imported, blueprint.name)
			if(not_imported)
				to_chat(user, span_warning("The following design[length(not_imported) > 1 ? "s" : ""] couldn't be imported: [english_list(not_imported)]"))
		busy = FALSE
		return TRUE

	if(panel_open)
		balloon_alert(user, "close the panel first!")
		return FALSE

	return ..()

/obj/machinery/autolathe/attackby_secondary(obj/item/weapon, mob/living/user, params)
	. = SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(busy)
		balloon_alert(user, "it's busy!")
		return

	if(default_deconstruction_screwdriver(user, "autolathe_t", "autolathe", weapon))
		return

	if(machine_stat)
		return SECONDARY_ATTACK_CALL_NORMAL

	if(panel_open)
		balloon_alert(user, "close the panel first!")
		return

	return SECONDARY_ATTACK_CALL_NORMAL

/obj/machinery/autolathe/proc/AfterMaterialInsert(obj/item/item_inserted, id_inserted, amount_inserted)
	if(istype(item_inserted, /obj/item/stack/ore/bluespace_crystal))
		use_power(MINERAL_MATERIAL_AMOUNT / 10)
	else if(item_inserted.has_material_type(/datum/material/glass))
		flick("autolathe_r", src)//plays glass insertion animation by default otherwise
	else
		to_chat(usr, "<span class=\"alert\">The autolathe is busy. Please wait for completion of previous operation.</span>")

	updateUsrDialog()

	return

/obj/machinery/autolathe/proc/make_item(power, list/materials_used, list/picked_materials, multiplier, coeff, is_stack, mob/user)
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	var/atom/A = drop_location()
	use_power(power)

	materials.use_materials(materials_used)

	if(is_stack)
		var/obj/item/stack/N = new being_built.build_path(A, multiplier, FALSE)
		N.update_icon()
		N.autolathe_crafted(src)
	else
		for(var/i=1, i<=multiplier, i++)
			var/obj/item/new_item = new being_built.build_path(A)
			new_item.autolathe_crafted(src)

			if(length(picked_materials))
				new_item.set_custom_materials(picked_materials, 1 / multiplier) //Ensure we get the non multiplied amount
				for(var/x in picked_materials)
					var/datum/material/M = x
					if(!istype(M, /datum/material/glass) && !istype(M, /datum/material/iron))
						user.client.give_award(/datum/award/achievement/misc/getting_an_upgrade, user)


	icon_state = "autolathe"
	busy = FALSE
	updateDialog()

/obj/machinery/autolathe/RefreshParts()
	var/T = 0
	for(var/obj/item/stock_parts/matter_bin/MB in component_parts)
		T += MB.rating*75000
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	materials.max_amount = T
	T=1.2
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		T -= M.rating*0.2
	prod_coeff = min(1,max(0,T)) // Coeff going 1 -> 0,8 -> 0,6 -> 0,4

/obj/machinery/autolathe/examine(mob/user)
	. += ..()
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	if(in_range(user, src) || isobserver(user))
		. += "<span class='notice'>The status display reads: Storing up to <b>[materials.max_amount]</b> material units.<br>Material consumption at <b>[prod_coeff*100]%</b>.</span>"

/obj/machinery/autolathe/proc/main_win(mob/user)
	var/dat = "<div class='statusDisplay'><h3>Autolathe Menu:</h3><br>"
	dat += materials_printout()

	dat += "<form name='search' action='byond://?src=[REF(src)]'>\
	<input type='hidden' name='src' value='[REF(src)]'>\
	<input type='hidden' name='search' value='to_search'>\
	<input type='hidden' name='menu' value='[AUTOLATHE_SEARCH_MENU]'>\
	<input type='text' name='to_search'>\
	<input type='submit' value='Search'>\
	</form><hr>"

	var/line_length = 1
	dat += "<table style='width:100%' align='center'><tr>"

	for(var/C in categories)
		if(line_length > 2)
			dat += "</tr><tr>"
			line_length = 1

		dat += "<td><A href='byond://?src=[REF(src)];category=[C];menu=[AUTOLATHE_CATEGORY_MENU]'>[C]</A></td>"
		line_length++

	dat += "</tr></table></div>"
	return dat

/obj/machinery/autolathe/proc/category_win(mob/user,selected_category)
	var/dat = "<A href='byond://?src=[REF(src)];menu=[AUTOLATHE_MAIN_MENU]'>Return to main menu</A>"
	dat += "<div class='statusDisplay'><h3>Browsing [selected_category]:</h3><br>"
	dat += materials_printout()

	for(var/v in stored_research.researched_designs)
		var/datum/design/D = SSresearch.techweb_design_by_id(v)
		if(!(selected_category in D.category))
			continue

		if(disabled || !can_build(D))
			dat += "<span class='linkOff'>[D.name]</span>"
		else
			dat += "<a href='byond://?src=[REF(src)];make=[D.id];multiplier=1'>[D.name]</a>"

		if(ispath(D.build_path, /obj/item/stack))
			var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
			var/max_multiplier
			for(var/datum/material/mat in D.materials)
				max_multiplier = min(D.maxstack, round(materials.get_material_amount(mat)/D.materials[mat]))
			if (max_multiplier>10 && !disabled)
				dat += " <a href='byond://?src=[REF(src)];make=[D.id];multiplier=10'>x10</a>"
			if (max_multiplier>25 && !disabled)
				dat += " <a href='byond://?src=[REF(src)];make=[D.id];multiplier=25'>x25</a>"
			if(max_multiplier > 0 && !disabled)
				dat += " <a href='byond://?src=[REF(src)];make=[D.id];multiplier=[max_multiplier]'>x[max_multiplier]</a>"
		else
			if(!disabled && can_build(D, 5))
				dat += " <a href='byond://?src=[REF(src)];make=[D.id];multiplier=5'>x5</a>"
			if(!disabled && can_build(D, 10))
				dat += " <a href='byond://?src=[REF(src)];make=[D.id];multiplier=10'>x10</a>"

		dat += "[get_design_cost(D)]<br>"

	dat += "</div>"
	return dat

/obj/machinery/autolathe/proc/search_win(mob/user)
	var/dat = "<A href='byond://?src=[REF(src)];menu=[AUTOLATHE_MAIN_MENU]'>Return to main menu</A>"
	dat += "<div class='statusDisplay'><h3>Search results:</h3><br>"
	dat += materials_printout()

	for(var/v in matching_designs)
		var/datum/design/D = v
		if(disabled || !can_build(D))
			dat += "<span class='linkOff'>[D.name]</span>"
		else
			dat += "<a href='byond://?src=[REF(src)];make=[D.id];multiplier=1'>[D.name]</a>"

		if(ispath(D.build_path, /obj/item/stack))
			var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
			var/max_multiplier
			for(var/datum/material/mat in D.materials)
				max_multiplier = min(D.maxstack, round(materials.get_material_amount(mat)/D.materials[mat]))
			if (max_multiplier>10 && !disabled)
				dat += " <a href='byond://?src=[REF(src)];make=[D.id];multiplier=10'>x10</a>"
			if (max_multiplier>25 && !disabled)
				dat += " <a href='byond://?src=[REF(src)];make=[D.id];multiplier=25'>x25</a>"
			if(max_multiplier > 0 && !disabled)
				dat += " <a href='byond://?src=[REF(src)];make=[D.id];multiplier=[max_multiplier]'>x[max_multiplier]</a>"
		else
			if(!disabled && can_build(D, 5))
				dat += " <a href='byond://?src=[REF(src)];make=[D.id];multiplier=5'>x5</a>"
			if(!disabled && can_build(D, 10))
				dat += " <a href='byond://?src=[REF(src)];make=[D.id];multiplier=10'>x10</a>"

		dat += "[get_design_cost(D)]<br>"

	dat += "</div>"
	return dat

/obj/machinery/autolathe/proc/materials_printout()
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	var/dat = "<b>Total amount:</b> [materials.total_amount] / [materials.max_amount] cm<sup>3</sup><br>"
	for(var/mat_id in materials.materials)
		var/datum/material/M = mat_id
		var/mineral_amount = materials.materials[mat_id]
		if(mineral_amount > 0)
			dat += "<b>[M.name] amount:</b> [mineral_amount] cm<sup>3</sup><br>"
	return dat

/obj/machinery/autolathe/proc/can_build(datum/design/D, amount = 1)
	if(length(D.make_reagents))
		return FALSE

	var/coeff = (ispath(D.build_path, /obj/item/stack) ? 1 : prod_coeff)

	var/list/required_materials = list()

	for(var/i in D.materials)
		required_materials[i] = D.materials[i] * coeff * amount

	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)

	return materials.has_materials(required_materials)


/obj/machinery/autolathe/proc/get_design_cost(datum/design/D)
	var/coeff = (ispath(D.build_path, /obj/item/stack) ? 1 : prod_coeff)
	var/dat
	for(var/i in D.materials)
		if(istext(i)) //Category handling
			dat += "[D.materials[i] * coeff] [i]"
		else
			var/datum/material/M = i
			dat += "[D.materials[i] * coeff] [M.name] "
	return dat

/obj/machinery/autolathe/proc/reset(wire)
	switch(wire)
		if(WIRE_HACK)
			if(!wires.is_cut(wire))
				adjust_hacked(FALSE)
		if(WIRE_SHOCK)
			if(!wires.is_cut(wire))
				shocked = FALSE
		if(WIRE_DISABLE)
			if(!wires.is_cut(wire))
				disabled = FALSE

/obj/machinery/autolathe/proc/shock(mob/user, prb)
	if(machine_stat & (BROKEN|NOPOWER))		// unpowered, no shock
		return FALSE
	if(!prob(prb))
		return FALSE
	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(5, 1, src)
	s.start()
	if (electrocute_mob(user, get_area(src), src, 0.7, TRUE))
		return TRUE
	else
		return FALSE

/obj/machinery/autolathe/proc/adjust_hacked(state)
	hacked = state
	for(var/id in SSresearch.techweb_designs)
		var/datum/design/D = SSresearch.techweb_design_by_id(id)
		if((D.build_type & AUTOLATHE) && ("hacked" in D.category))
			if(hacked)
				stored_research.add_design(D)
			else
				stored_research.remove_design(D)

/obj/machinery/autolathe/hacked/Initialize()
	. = ..()
	adjust_hacked(TRUE)

//Called when the object is constructed by an autolathe
//Has a reference to the autolathe so you can do !!FUN!! things with hacked lathes
/obj/item/proc/autolathe_crafted(obj/machinery/autolathe/A)
	return
