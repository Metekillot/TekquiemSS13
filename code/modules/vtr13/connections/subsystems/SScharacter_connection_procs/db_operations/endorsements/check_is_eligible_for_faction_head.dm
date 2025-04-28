
//check if the user is eligable to be head of a different faction
//endorsements are only good for the last ENDORSEMENT_STALE_OFFSET_MONTHS months
/datum/controller/subsystem/character_connection/proc/check_is_eligible_for_faction_head(ckey, character_name, faction_head_connnection_type = null)
	if(!ckey || !character_name)
		return FALSE

	if(!faction_head_connnection_type)
		var/datum/db_query/query = SSdbcore.NewQuery(
			"SELECT \
				group_type\
			FROM [format_table_name("character_connection")] \
			WHERE \
				player_ckey = :ckey AND \
				character_name = :char_name AND \
				member_type = :mem_type AND \
				group_type IN ( :grp_type_1 , :grp_type_2 , :grp_type_3, :grp_type_4 ) AND \
				date_ended IS NULL AND \
				date_established >= DATE_SUB(NOW(), INTERVAL :stale_offset MONTH) \
			GROUP BY \
				group_type HAVING COUNT(*) >= :head_endorsement_min",
			list(
				"ckey" = ckey,
				"char_name" = character_name,
				"mem_type" = MEMBER_TYPE_CANDIDATE,
				"grp_type_1" = CONNECTION_ENDORSEMENT_HIEROPHANT,
				"grp_type_2" = CONNECTION_ENDORSEMENT_VOIVODE,
				"grp_type_3" = CONNECTION_ENDORSEMENT_BISHOP,
				"grp_type_4" = CONNECTION_ENDORSEMENT_REPRESENTATIVE,
				"stale_offset" = ENDORSEMENT_STALE_OFFSET_MONTHS,
				"head_endorsement_min" = FACTION_HEAD_ENDORSEMENT_MIN
			)
		)

		if(!query.Execute(async = TRUE) || !query.NextRow())
			qdel(query)
			return FALSE
		qdel(query)
	if(faction_head_connnection_type)
		if(!SScharacter_connection.get_character_connection_type(faction_head_connnection_type))
			return FALSE
		var/datum/db_query/query = SSdbcore.NewQuery(
			"SELECT \
				group_type\
			FROM [format_table_name("character_connection")] \
			WHERE \
				player_ckey = :ckey AND \
				character_name = :char_name AND \
				member_type = :mem_type AND \
				group_type = :grp_type AND \
				date_ended IS NULL AND \
				date_established >= DATE_SUB(NOW(), INTERVAL :stale_offset MONTH) \
			GROUP BY \
				group_type HAVING COUNT(*) >= :head_endorsement_min",
			list(
				"ckey" = ckey,
				"char_name" = character_name,
				"mem_type" = MEMBER_TYPE_CANDIDATE,
				"grp_type" = faction_head_connnection_type,
				"stale_offset" = ENDORSEMENT_STALE_OFFSET_MONTHS,
				"head_endorsement_min" = FACTION_HEAD_ENDORSEMENT_MIN
			)
		)
	
		if(!query.Execute(async = TRUE) || !query.NextRow())
			qdel(query)
			return FALSE
		qdel(query)

	return TRUE