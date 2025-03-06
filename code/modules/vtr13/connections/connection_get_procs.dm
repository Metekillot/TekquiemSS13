
//Get all active connection datums for a single character
/client/proc/get_connections_by_ckey_char_name(ckey, char_name)
	if(!ckey || !char_name)
		return null
	var/connection_list = null
	var/datum/db_query/query = SSdbcore.NewQuery(
		"SELECT \
			id, group_id, group_type, member_type, \
			player_ckey, character_name, connection_desc, \
			date_established, date_ended \
		FROM [format_table_name("character_connection")] \
		WHERE \
			player_ckey = :ckey AND \
			character_name = :char_name AND\
			date_ended = NULL)", 
		list("ckey" = ckey, "char_name" = char_name)
	)

	if(!query.Execute(async = TRUE))
		qdel(query)
		return null

	while(query.NextRow())
		var/datum/character_connection/connection = new(
			query.item[1],
			query.item[2],
			query.item[3],
			query.item[4],
			query.item[5],
			query.item[6],
			query.item[7],
			query.item[8],
			query.item[9]
		)
		LAZYADD(connection_list, connection)
	qdel(query)
	
	return connection_list

//Get all active connection descriptions for a single character
/client/proc/get_connection_descriptions_by_ckey_char_name(ckey, char_name)
	if(!ckey || !char_name)
		return null
	var/connection_description_list = null
	var/datum/db_query/query = SSdbcore.NewQuery(
		"SELECT \
			connection_desc\
		FROM [format_table_name("character_connection")] \
		WHERE \
			player_ckey = :ckey AND \
			character_name = :char_name AND\
			date_ended = NULL)", 
		list("ckey" = ckey, "char_name" = char_name)
	)

	if(!query.Execute(async = TRUE))
		qdel(query)
		return null

	while(query.NextRow())
		LAZYADD(connection_description_list, query.item[1])
	qdel(query)
	
	return connection_description_list


/client/proc/get_connections_mutual(ckey_a, char_name_a, ckey_b, char_name_b)
	if(!ckey_a || !char_name_a || !ckey_b || !char_name_b)
		return null
	var/connection_list_a = null
	var/datum/db_query/query_char_a = SSdbcore.NewQuery(
		"SELECT \
			id, group_id, group_type, member_type, \
			player_ckey, character_name, connection_desc, \
			date_established, date_ended \
		FROM [format_table_name("character_connection")] \
		WHERE \
			group_id IN ( \
				SELECT group_id \
				FROM [format_table_name("character_connection")] \
				WHERE \
					ckey IN (:ckey_a, :ckey_b) AND \
					character_name IN (:char_name_a, :char_name_b) AND \
					date_ended = NULL \
				GROUP_BY group_id \
				HAVING COUNT(id) > 1 \
			) \
			AND date_ended = NULL \
			AND ckey = :ckey_a \
			AND character_name = :char_name_a",
		list("ckey_a" = ckey_a, "ckey_b" = ckey_b, "char_name_a" = char_name_a, "char_name_b" = char_name_b)
	)

	if(!query_char_a.Execute(async = TRUE))
		qdel(query)
		return null

	while(query_char_a.NextRow())
		var/datum/character_connection/connection = new(
			query.item[1],
			query.item[2],
			query.item[3],
			query.item[4],
			query.item[5],
			query.item[6],
			query.item[7],
			query.item[8],
			query.item[9]
		)
		LAZYADD(connection_list, connection)
	qdel(query)
	
	return connection_list


/client/proc/get_connections_mutual_of_group_type(ckey_a, char_name_a, ckey_b, char_name_b, group_type)
	if(!ckey_a || !char_name_a || !ckey_b || !char_name_b || !group_type)
		return null
	var/connection_list_a = null
	var/datum/db_query/query_char_a = SSdbcore.NewQuery(
		"SELECT \
			id, group_id, group_type, member_type, \
			player_ckey, character_name, connection_desc, \
			date_established, date_ended \
		FROM [format_table_name("character_connection")] \
		WHERE \
			group_id IN ( \
				SELECT group_id \
				FROM [format_table_name("character_connection")] \
				WHERE \
					ckey IN (:ckey_a, :ckey_b) AND \
					character_name IN (:char_name_a, :char_name_b) AND \
					date_ended = NULL \
				GROUP_BY group_id \
				HAVING COUNT(id) > 1 \
			) \
			AND date_ended = NULL \
			AND ckey = :ckey_a \
			AND character_name = :char_name_a \
			AND group_type = :group_type",
		list("ckey_a" = ckey_a, "ckey_b" = ckey_b, "char_name_a" = char_name_a, "char_name_b" = char_name_b, "group_type" = group_type)
	)

	if(!query_char_a.Execute(async = TRUE))
		qdel(query)
		return null

	while(query_char_a.NextRow())
		var/datum/character_connection/connection = new(
			query.item[1],
			query.item[2],
			query.item[3],
			query.item[4],
			query.item[5],
			query.item[6],
			query.item[7],
			query.item[8],
			query.item[9]
		)
		LAZYADD(connection_list, connection)
	qdel(query)
	
	return connection_list

/client/proc/get_connections_for_character_by_ckey_char_name_group_type(ckey, char_name, group_type)
	if(!ckey || !char_name || !group_type)
		return null
	var/connection_list = null
	var/datum/db_query/query = SSdbcore.NewQuery(
		"SELECT \
			id, group_id, group_type, member_type, \
			player_ckey, character_name, connection_desc, \
			date_established, date_ended \
		FROM [format_table_name("character_connection")] \
		WHERE \
			player_ckey = :ckey AND \
			character_name = :char_name AND\
			date_ended = NULL AND \
			AND group_type = :group_type", 
		list("ckey" = ckey, "char_name" = char_name, "group_type" = group_type)
	)

	if(!query.Execute(async = TRUE))
		qdel(query)
		return null

	while(query.NextRow())
		var/datum/character_connection/connection = new(
			query.item[1],
			query.item[2],
			query.item[3],
			query.item[4],
			query.item[5],
			query.item[6],
			query.item[7],
			query.item[8],
			query.item[9]
		)
		LAZYADD(connection_list, connection)
	qdel(query)
	return connection_list

//========================================QUERIES I'M ACTUALLY USING BELOW=====================================

/mob/living/proc/check_character_level_three_blood_bonds()
	if(!group_type)
		return null
	var/datum/db_query/query = SSdbcore.NewQuery(
		"SELECT \
			id \
		FROM [format_table_name("character_connection")] \
		WHERE \
			player_ckey = :ckey AND \
			character_name = :char_name AND\
			date_ended = NULL AND \
			group_type = :bb3 \
		LIMIT 1", 
		list(
			"ckey" = ckey,
			"char_name" = true_real_name,
			"bb3" = CONNECTION_BLOOD_BOND_3
		)
	)
	if(!query.Execute(async = TRUE))
		qdel(query)
		return FALSE
	if(query.NextRow())
		return FALSE
	return TRUE

/mob/living/proc/check_character_level_three_blood_bonds(mob/living/carbon/human/domitor)
	var/datum/db_query/query = SSdbcore.NewQuery(
		"SELECT \
			id \
		FROM [format_table_name("character_connection")] \
		WHERE \
			player_ckey = :ckey AND \
			character_name = :char_name AND \
			date_ended = NULL AND \
			group_type = :bb3 AND \
			group_id NOT IN ( \
				SELECT group_id \
				FROM [format_table_name("character_connection")] \
				WHERE \
					player_ckey = :domitor_ckey AND \
					character_name = :domitor_name AND \
					date_ended = NULL ) \
		LIMIT 1",
		list(
			"ckey" = ckey,
			"char_name" = true_real_name,
			"bb3" = CONNECTION_BLOOD_BOND_3,
			"domitor_ckey" = domitor.ckey,
			"domitor_name" = domitor.true_real_name
		)
	)
	if(!query.Execute(async = TRUE))
		qdel(query)
		return FALSE
	if(query.NextRow())
		return TRUE
	return FALSE

/mob/living/proc/check_mutual_blood_bonds_made_this_round(mob/living/carbon/human/domitor)
	if(!domitor)
		return FALSE
	var/datum/db_query/query = SSdbcore.NewQuery(
		"SELECT \
			id \
		FROM [format_table_name("character_connection")] \
		WHERE \
			player_ckey = :ckey AND \
			character_name = :char_name AND \
			date_ended = NULL AND \
			group_type IN ( :bb2 , :bb1 ) AND \
			round_id_established = :round_id AND \
			group_id IN ( \
				SELECT group_id \
				FROM [format_table_name("character_connection")] \
				WHERE \
					player_ckey = :domitor_ckey AND \
					character_name = :domitor_name AND \
					date_ended = NULL ) \
		LIMIT 1",
		list(
			"ckey" = ckey,
			"char_name" = true_real_name,
			"bb2" = CONNECTION_BLOOD_BOND_2,
			"bb1" = CONNECTION_BLOOD_BOND_1,
			"domitor_ckey" = domitor.ckey,
			"domitor_name" = domitor.true_real_name,
			"round_id" = GLOB.round_id
		)
	)
	if(!query.Execute(async = TRUE))
		qdel(query)
		return FALSE
	if(query.NextRow())
		return TRUE
	return FALSE


/mob/living/proc/get_existing_mutual_blood_bond(mob/living/carbon/human/domitor)
	if(!domitor)
		return null
	var/datum/db_query/query = SSdbcore.NewQuery(
		"SELECT \
			id, group_id, group_type, member_type, \
			player_ckey, character_name, connection_desc, \
			round_id_established, date_established, date_ended \
		FROM [format_table_name("character_connection")] \
		WHERE \
			player_ckey = :ckey AND \
			character_name = :char_name AND \
			date_ended = NULL AND \
			group_type IN ( :bb3 , :bb2 , :bb1 ) AND \
			round_id_established = :round_id AND \
			group_id IN ( \
				SELECT group_id \
				FROM [format_table_name("character_connection")] \
				WHERE \
					player_ckey = :domitor_ckey AND \
					character_name = :domitor_name AND \
					date_ended = NULL ) \
		LIMIT 1",
		list(
			"ckey" = ckey,
			"char_name" = true_real_name,
			"bb3" = CONNECTION_BLOOD_BOND_3,
			"bb2" = CONNECTION_BLOOD_BOND_2,
			"bb1" = CONNECTION_BLOOD_BOND_1,
			"domitor_ckey" = domitor.ckey,
			"domitor_name" = domitor.true_real_name,
			"round_id" = GLOB.round_id
		)
	)

	if(!query.Execute(async = TRUE))
		qdel(query)
		return null

	var/datum/character_connection/connection = null
	if(query.NextRow())
		connection = new(
			query.item[1],
			query.item[2],
			query.item[3],
			query.item[4],
			query.item[5],
			query.item[6],
			query.item[7],
			query.item[8],
			query.item[9],
			query.item[10])
	qdel(query)
	return connection

/mob/living/proc/get_next_character_connection_group_id()
	var/datum/db_query/query = SSdbcore.NewQuery(
		"SELECT MAX(group_id) FROM [format_table_name("character_connection")]")
	if(!query.Execute(async = TRUE))
		qdel(query)
		return null
	var/group_id = 1
	if(query.NextRow())
		group_id = query.item[1] + 1
	qdel(query)
	return connection
