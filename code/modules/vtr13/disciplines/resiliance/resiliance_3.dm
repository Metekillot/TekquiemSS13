/datum/discipline_power/vtr/resiliance/three
	name = "Resiliance 3"
	desc = "Look down upon those who would try to kill you. Shrug off grievous attacks."

	level = 3

	check_flags = DISC_CHECK_CONSCIOUS

	toggled = TRUE
	duration_length = 2 TURNS

	grouped_powers = list(
		/datum/discipline_power/vtr/resiliance/one,
		/datum/discipline_power/vtr/resiliance/two,
		/datum/discipline_power/vtr/resiliance/four,
		/datum/discipline_power/vtr/resiliance/five
	)

/datum/discipline_power/vtr/resiliance/three/activate()
	. = ..()
	owner.physiology.damage_resistance += 45

/datum/discipline_power/vtr/resiliance/three/deactivate()
	. = ..()
	owner.physiology.damage_resistance -= 45
