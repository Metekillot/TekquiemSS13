/mob/living/proc/retire_character_connection_by_group_id(group_id)
	var/datum/db_query/query = SSdbcore.NewQuery(
		"UPDATE [format_table_name("character_connection")] SET date_ended = Now() WHERE group_id = :group_id",
		list("group_id" = group_id)
	)
	query.Execute()
	qdel(query)


/mob/living/proc/retire_all_character_connection_blood_bonds()
	var/datum/db_query/query = SSdbcore.NewQuery(
		"UPDATE [format_table_name("character_connection")] \
			SET date_ended = Now() \
			WHERE \
				group_id IN ( \
					SELECT group_id \
					FROM [format_table_name("character_connection")] \
					WHERE \
						ckey = :ckey AND \
						character_name = :char_name AND \
						date_ended IS NULL AND \
						member_type = :m_type AND \
						group_type IN (:bb1,:bb2,:bb3)\
				)",
		list("ckey" = ckey, 
			"char_name" = true_real_name, 
			"m_type" = MEMBER_TYPE_THRALL, 
			"bb1" = CONNECTION_BLOOD_BOND_1, 
			"bb2" = CONNECTION_BLOOD_BOND_2, 
			"bb3" = CONNECTION_BLOOD_BOND_3)
	)
	query.Execute()
	qdel(query)