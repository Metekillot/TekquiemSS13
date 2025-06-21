/obj/machinery/computer/cargo
	name = "supply console"
	desc = "Used to order supplies, approve requests, and control the shuttle."
	icon_screen = "supply"
	circuit = /obj/item/circuitboard/computer/cargo
	light_color = COLOR_BRIGHT_ORANGE

	///Can the supply console send the shuttle back and forth? Used in the UI backend.
	var/can_send = TRUE
	///Can this console only send requests?
	var/requestonly = FALSE
	///Can you approve requests placed for cargo? Works differently between the app and the computer.
	var/can_approve_requests = TRUE
	var/contraband = FALSE
	var/self_paid = FALSE
	var/safety_warning = "For safety reasons, the automated supply shuttle \
		cannot transport live organisms, human remains, classified nuclear weaponry, \
		homing beacons or machinery housing any form of artificial intelligence."
	var/blockade_warning = "Bluespace instability detected. Shuttle movement impossible."
	/// radio used by the console to send messages on supply channel
	var/obj/item/radio/headset/radio
	/// var that tracks message cooldown
	var/message_cooldown
	var/list/loaded_coupons
	/// var that makes express console use rockets
	var/is_express = FALSE


/obj/machinery/computer/cargo/request
	name = "supply request console"
	desc = "Used to request supplies from cargo."
	icon_screen = "request"
	circuit = /obj/item/circuitboard/computer/cargo/request
	can_send = FALSE
	can_approve_requests = FALSE
	requestonly = TRUE

/obj/machinery/computer/cargo/Initialize()
	. = ..()
	radio = new /obj/item/radio/headset/headset_cargo(src)

/obj/machinery/computer/cargo/Destroy()
	QDEL_NULL(radio)
	..()

/obj/machinery/computer/cargo/proc/get_export_categories()
	. = EXPORT_CARGO
	if(contraband)
		. |= EXPORT_CONTRABAND
	if(obj_flags & EMAGGED)
		. |= EXPORT_EMAG

/obj/machinery/computer/cargo/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	if(user)
		user.visible_message("<span class='warning'>[user] swipes a suspicious card through [src]!</span>",
		"<span class='notice'>You adjust [src]'s routing and receiver spectrum, unlocking special supplies and contraband.</span>")

	obj_flags |= EMAGGED
	contraband = TRUE

	// This also permanently sets this on the circuit board
	var/obj/item/circuitboard/computer/cargo/board = circuit
	board.contraband = TRUE
	board.obj_flags |= EMAGGED
	update_static_data(user)

/obj/machinery/computer/cargo/on_construction()
	. = ..()
	circuit.configure_machine(src)

/obj/machinery/computer/cargo/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Cargo", name)
		ui.open()

/obj/machinery/computer/cargo/ui_data()
	var/list/data = list()
	data["location"] = SSshuttle.supply.getStatusText()
	var/datum/bank_account/D = SSeconomy.get_dep_account(ACCOUNT_CAR)
	if(D)
		data["points"] = D.account_balance
	data["away"] = SSshuttle.supply.getDockedId() == "supply_away"
	data["self_paid"] = self_paid
	data["docked"] = SSshuttle.supply.mode == SHUTTLE_IDLE
	data["loan"] = !!SSshuttle.shuttle_loan
	data["loan_dispatched"] = SSshuttle.shuttle_loan && SSshuttle.shuttle_loan.dispatched
	data["can_send"] = can_send
	data["can_approve_requests"] = can_approve_requests
	var/message = "Remember to stamp and send back the supply manifests."
	if(SSshuttle.centcom_message)
		message = SSshuttle.centcom_message
	if(SSshuttle.supplyBlocked)
		message = blockade_warning
	data["message"] = message
	data["cart"] = list()
	for(var/datum/supply_order/SO in SSshuttle.shoppinglist)
		data["cart"] += list(list(
			"object" = SO.pack.name,
			"cost" = SO.pack.cost,
			"id" = SO.id,
			"orderer" = SO.orderer,
			"paid" = !isnull(SO.paying_account) //paid by requester
		))

	data["requests"] = list()
	for(var/datum/supply_order/SO in SSshuttle.requestlist)
		data["requests"] += list(list(
			"object" = SO.pack.name,
			"cost" = SO.pack.cost,
			"orderer" = SO.orderer,
			"reason" = SO.reason,
			"id" = SO.id
		))

	return data

/obj/machinery/computer/cargo/ui_static_data(mob/user)
	var/list/data = list()
	data["requestonly"] = requestonly
	data["supplies"] = list()
	for(var/pack in SSshuttle.supply_packs)
		var/datum/supply_pack/P = SSshuttle.supply_packs[pack]
		if(!data["supplies"][P.group])
			data["supplies"][P.group] = list(
				"name" = P.group,
				"packs" = list()
			)
		if((P.hidden && !(obj_flags & EMAGGED)) || (P.contraband && !contraband) || (P.special && !P.special_enabled) || P.DropPodOnly)
			continue
		data["supplies"][P.group]["packs"] += list(list(
			"name" = P.name,
			"cost" = P.cost,
			"id" = pack,
			"desc" = P.desc || P.name, // If there is a description, use it. Otherwise use the pack's name.
			"goody" = P.goody,
			"access" = P.access
		))
	return data

/obj/machinery/computer/cargo/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("send")
			if(!SSshuttle.supply.canMove())
				say(safety_warning)
				return
			if(SSshuttle.supply_blocked)
				say(blockade_warning)
				return

			if(SSshuttle.supply.getDockedId() == docking_home)
				SSshuttle.moveShuttle(cargo_shuttle, docking_away, TRUE)
				say("The supply shuttle is departing.")
				ui.user.investigate_log("sent the supply shuttle away.", INVESTIGATE_CARGO)
			else
				//create the paper from the SSshuttle.shopping_list
				if(length(SSshuttle.shopping_list))
					var/obj/item/paper/requisition/requisition_paper = new(get_turf(src))
					requisition_paper.name = "requisition form - [station_time_timestamp()]"
					var/requisition_text = "<h2>[station_name()] Supply Requisition</h2>"
					requisition_text += "<hr/>"
					requisition_text += "Time of Order: [station_time_timestamp()]<br/><br/>"
					for(var/datum/supply_order/order as anything in SSshuttle.shopping_list)
						requisition_text += "<b>[order.pack.name]</b></br>"
						requisition_text += "- Order ID: [order.id]</br>"
						var/restrictions = SSid_access.get_access_desc(order.pack.access)
						if(restrictions)
							requisition_text += "- Access Restrictions: [restrictions]</br>"
						requisition_text += "- Ordered by: [order.orderer] ([order.orderer_rank])</br>"
						var/paying_account = order.paying_account
						if(paying_account)
							requisition_text += "- Paid Privately by: [order.paying_account.account_holder]<br/>"
						var/reason = order.reason
						if(reason)
							requisition_text += "- Reason Given: [reason]</br>"
						requisition_text += "</br></br>"
					requisition_paper.add_raw_text(requisition_text)
					requisition_paper.color = "#9ef5ff"
					requisition_paper.update_appearance()

				ui.user.investigate_log("called the supply shuttle.", INVESTIGATE_CARGO)
				say("The supply shuttle has been called and will arrive in [SSshuttle.supply.timeLeft(600)] minutes.")
				SSshuttle.moveShuttle(cargo_shuttle, docking_home, TRUE)

			. = TRUE
		if("loan")
			if(!SSshuttle.shuttle_loan)
				return
			if(SSshuttle.supply_blocked)
				say(blockade_warning)
				return
			else if(SSshuttle.supply.mode != SHUTTLE_IDLE)
				return
			else if(SSshuttle.supply.getDockedId() != docking_away)
				return
			else if(stationcargo != TRUE)
				return
			else
				SSshuttle.shuttle_loan.loan_shuttle()
				say("The supply shuttle has been loaned to CentCom.")
				ui.user.investigate_log("accepted a shuttle loan event.", INVESTIGATE_CARGO)
				ui.user.log_message("accepted a shuttle loan event.", LOG_GAME)
				. = TRUE
		if("add")
			return add_item(ui.user, params["id"])
		if("add_by_name")
			var/supply_pack_id = name_to_id(params["order_name"])
			if(!supply_pack_id)
				return
			return add_item(ui.user, supply_pack_id)
		if("remove")
			var/order_name = params["order_name"]
			//try removing at least one item with the specified name. An order may not be removed if it was from the department
			for(var/datum/supply_order/order in SSshuttle.shopping_list)
				if(order.pack.name != order_name)
					continue
				if(remove_item(order.id))
					return TRUE

			return TRUE
		if("modify")
			var/order_name = params["order_name"]

			//clear out all orders with the above mentioned order_name name to make space for the new amount
			for(var/datum/supply_order/order in SSshuttle.shopping_list) //find corresponding order id for the order name
				if(order.pack.name == order_name)
					remove_item(order.id)

			//now add the new amount stuff
			var/amount = text2num(params["amount"])
			if(amount == 0)
				return TRUE
			if(amount > CARGO_MAX_ORDER)
				return
			var/supply_pack_id = name_to_id(order_name) //map order name to supply pack id for adding
			if(!supply_pack_id)
				return
			return add_item(ui.user, supply_pack_id, amount)
		if("clear")
			//create copy of list else we will get runtimes when iterating & removing items on the same list SSshuttle.shopping_list
			var/list/shopping_cart = SSshuttle.shopping_list.Copy()
			for(var/datum/supply_order/cancelled_order in shopping_cart)
				if(cancelled_order.department_destination || !cancelled_order.can_be_cancelled)
					continue //don't cancel other department's orders or orders that can't be cancelled
				remove_item(cancelled_order.id) //remove & properly refund any coupons attached with this order
		if("approve")
			var/id = text2num(params["id"])
			for(var/datum/supply_order/SO in SSshuttle.request_list)
				if(SO.id == id)
					SSshuttle.request_list -= SO
					SSshuttle.shopping_list += SO
					. = TRUE
					break
		if("deny")
			var/id = text2num(params["id"])
			for(var/datum/supply_order/SO in SSshuttle.request_list)
				if(SO.id == id)
					SSshuttle.request_list -= SO
					. = TRUE
					break
		if("denyall")
			SSshuttle.request_list.Cut()
			. = TRUE
		if("toggleprivate")
			self_paid = !self_paid
			. = TRUE
	if(.)
		post_signal(cargo_shuttle)

/obj/machinery/computer/cargo/proc/post_signal(command)

	var/datum/radio_frequency/frequency = SSradio.return_frequency(FREQ_STATUS_DISPLAYS)

	if(!frequency)
		return

	var/datum/signal/status_signal = new(list("command" = command))
	frequency.post_signal(src, status_signal)

