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
	owner << browse(memory_data.Join("<br>"), "window=vampire;size=500x450;border=1;can_resize=1;can_minimize=0")

/datum/action/memory_button/Topic(href, href_list)
	if(href_list["delete_connection"])
		SScharacter_connection.retire_connection(owner, text2num(href_list["delete_connection"]))
		Trigger()