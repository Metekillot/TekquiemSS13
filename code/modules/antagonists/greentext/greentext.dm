/datum/antagonist/greentext
	name = "winner"
	show_in_antagpanel = FALSE
	show_name_in_check_antagonists = TRUE //Not that it will be there for long

/datum/antagonist/greentext/forge_objectives()
	var/datum/objective/succeed_objective = new /datum/objective("Succeed")
	succeed_objective.completed = TRUE //YES!
	succeed_objective.owner = owner
	objectives += succeed_objective

/datum/antagonist/greentext/on_gain()
	forge_objectives()
	. = ..()
