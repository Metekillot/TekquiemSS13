/datum/controller/subsystem/character_connection/proc/retire_connection(mob/living/target, deleting_group_id)
	if(!deleting_group_id || !target?.mind)
		return
	
	if(alert(target, "Are you sure?", "Delete Connection", "I'm Sure", "Cancel") == "Cancel")
		return

	for(var/datum/character_connection/connection in target.mind.character_connections)
		if(connection.group_id == deleting_group_id)
			message_admins("[ADMIN_LOOKUPFLW(target)] has ended their [connection.group_type] connection of group_id [connection.group_id]. (They were a [connection.member_type])")
			log_game("[key_name(target)] has ended their [connection.group_type] connection of group_id [connection.group_id]. (They were a [connection.member_type])")
			SScharacter_connection.update_retire_character_connection_by_group_id(target, connection.group_id)
			break
	
	target.mind.character_connections = get_character_connections(target.ckey, target.true_real_name)