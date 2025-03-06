/mob/living/proc/retire_character_connection_by_group_id(group_id)
	var/datum/db_query/query = SSdbcore.NewQuery(
		"UPDATE [format_table_name("character_connection")] SET date_ended = Now() WHERE group_id = :group_id",
		list("group_id" = group_id)
	)
	query.Execute()
	qdel(query)
