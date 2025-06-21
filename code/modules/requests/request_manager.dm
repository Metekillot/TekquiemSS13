GLOBAL_DATUM_INIT(requests, /datum/request_manager, new)

/**
 * # Request Manager
 *
 * Handles all player requests (prayers, centcom requests, syndicate requests)
 * that occur in the duration of a round.
 */
/datum/request_manager
	/// Associative list of ckey -> list of requests
	var/list/requests = list()
	/// List where requests can be accessed by ID
	var/list/requests_by_id = list()

/datum/request_manager/Destroy(force, ...)
	QDEL_LIST(requests)
	return ..()

/**
 * Used in the new client pipeline to catch when clients are reconnecting and need to have their
 * reference re-assigned to the 'owner' variable of any requests
 *
 * Arguments:
 * * C - The client who is logging in
 */
/datum/request_manager/proc/client_login(client/C)
	if (!requests[C.ckey])
		return
	for (var/datum/request/request as anything in requests[C.ckey])
		request.owner = C

/**
 * Used in the destroy client pipeline to catch when clients are disconnecting and need to have their
 * reference nulled on the 'owner' variable of any requests
 *
 * Arguments:
 * * C - The client who is logging out
 */
/datum/request_manager/proc/client_logout(client/C)
	if (!requests[C.ckey])
		return
	for (var/datum/request/request as anything in requests[C.ckey])
		request.owner = null

/**
 * Creates a request for a prayer, and notifies admins who have the sound notifications enabled when appropriate
 *
 * Arguments:
 * * C - The client who is praying
 * * message - The prayer
 * * is_chaplain - Boolean operator describing if the prayer is from a chaplain
 */
/datum/request_manager/proc/pray(client/C, message, is_chaplain)
	request_for_client(C, REQUEST_PRAYER, message)
	for(var/client/admin in GLOB.admins)
		if(is_chaplain && admin.prefs.chat_toggles & CHAT_PRAYER && admin.prefs.toggles & SOUND_PRAYERS)
			SEND_SOUND(admin, sound('sound/effects/pray.ogg'))

/**
 * Creates a request for a Centcom message
 *
 * Arguments:
 * * C - The client who is sending the request
 * * message - The message
 */
/datum/request_manager/proc/message_centcom(client/C, message)
	request_for_client(C, REQUEST_CENTCOM, message)

/**
 * Creates a request for a Syndicate message
 *
 * Arguments:
 * * C - The client who is sending the request
 * * message - The message
 */
/datum/request_manager/proc/message_syndicate(client/C, message)
	request_for_client(C, REQUEST_SYNDICATE, message)

/**
 * Creates a request for the nuclear self destruct codes
 *
 * Arguments:
 * * C - The client who is sending the request
 * * message - The message
 */
/datum/request_manager/proc/nuke_request(client/C, message)
	request_for_client(C, REQUEST_NUKE, message)

/**
 * Creates a request and registers the request with all necessary internal tracking lists
 *
 * Arguments:
 * * C - The client who is sending the request
 * * type - The type of request, see defines
 * * message - The message
 */
/datum/request_manager/proc/request_for_client(client/C, type, message)
	var/datum/request/request = new(C, type, message)
	if (!requests[C.ckey])
		requests[C.ckey] = list()
	requests[C.ckey] += request
	requests_by_id.len++
	requests_by_id[request.id] = request

/datum/request_manager/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "RequestManager")
		ui.open()

/datum/request_manager/ui_state(mob/user)
	return ADMIN_STATE(R_ADMIN)

/datum/request_manager/ui_state(mob/user)
	return ADMIN_STATE(R_ADMIN)

/datum/request_manager/ui_data(mob/user)
	. = list(
		"requests" = list()
	)
	for (var/ckey in requests)
		for (var/datum/request/request as anything in requests[ckey])
			var/list/data = list(
				"id" = request.id,
				"req_type" = request.req_type,
				"owner" = request.owner ? "[REF(request.owner)]" : null,
				"owner_ckey" = request.owner_ckey,
				"owner_name" = request.owner_name,
				"message" = request.message,
				"timestamp" = request.timestamp,
				"timestamp_str" = gameTimestamp(wtime = request.timestamp)
			)
			.["requests"] += list(data)

