

/datum/action/select_compel_command
	name = "Compel Command Selection"
	desc = "Pick a command to say with Dominate 2."
	background_icon_state = "discipline"
	button_icon_state = "malk_speech"
	var/datum/discipline_power/vtr/dominate/compel/compel_discipline

/datum/action/select_compel_command/New(Target, datum/discipline_power/vtr/dominate/compel/compel_datum)
	..(Target)
	compel_discipline = compel_datum

/datum/action/select_compel_command/Trigger()
	var/selection = tgui_input_list(owner, "Select a command for Compel:", "Compel Selection", compel_discipline.commands, compel_discipline.selected_command)
	if(selection)
		compel_discipline.selected_command = compel_discipline.commands[selection]
