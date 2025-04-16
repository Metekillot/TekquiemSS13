/mob/living/proc/retire_connection(deleting_group_id)
	if(!deleting_group_id || !mind)
		return
	if(alert(src, "Are you sure?", "Delete Connection", "I'm Sure", "Cancel") == "Cancel")
		return
	for(var/datum/character_connection/connection in src.mind.character_connections)
		if(connection.group_id == deleting_group_id)
			message_admins("[ADMIN_LOOKUPFLW(src)] has ended their [connection.group_type] connection of group_id [connection.group_id]. (They were a [connection.member_type])")
			log_game("[key_name(src)] has ended their [connection.group_type] connection of group_id [connection.group_id]. (They were a [connection.member_type])")
			src.retire_character_connection_by_group_id(connection.group_id)
			break
	mind.character_connections = src.get_character_connections()