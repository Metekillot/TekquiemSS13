/datum/action/memory_button
	name = "About Me"
	desc = "Check things that you know about yourself."
	button_icon_state = "masquerade"
	check_flags = NONE
	var/datum/component/base_memory/parent_component

/datum/action/memory_button/New(Target, datum/component/base_memory/parent_component)
	..(Target)
	src.parent_component = parent_component

/datum/action/memory_button/Trigger()
	var/list/memory_data = parent_component.get_memory_data(src, TRUE)
	var/mob/living/living_owner = owner
	if(living_owner?.mind)
		living_owner.mind.character_connections = SScharacter_connection.get_character_connections(living_owner.ckey, living_owner.true_real_name)

	owner << browse(memory_data.Join("<br>"), "window=vampire;size=500x600;border=1;can_resize=1;can_minimize=0")

/datum/action/memory_button/Topic(href, href_list)
	if(href_list["delete_connection"])
		
		var/mob/living/living_owner = owner
		if(!living_owner)
			return

		if(!SScharacter_connection.retire_connection(living_owner, living_owner.ckey, living_owner.true_real_name, text2num(href_list["delete_connection"])))
			return
		Trigger()