//Command

/obj/item/circuitboard/computer/aiupload
	name = "AI Upload (Computer Board)"
	icon_state = "command"
	build_path = /obj/machinery/computer/upload/ai

/obj/item/circuitboard/computer/borgupload
	name = "Cyborg Upload (Computer Board)"
	icon_state = "command"
	build_path = /obj/machinery/computer/upload/borg

/obj/item/circuitboard/computer/card
	name = "ID Console (Computer Board)"
	icon_state = "command"
	build_path = /obj/machinery/computer/card

/obj/item/circuitboard/computer/card/centcom
	name = "CentCom ID Console (Computer Board)"
	build_path = /obj/machinery/computer/card/centcom

/obj/item/circuitboard/computer/card/minor
	name = "Department Management Console (Computer Board)"
	build_path = /obj/machinery/computer/card/minor
	var/target_dept = 1
	var/list/dept_list = list("General","Security","Medical","Science","Engineering")

/obj/item/circuitboard/computer/card/minor/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_SCREWDRIVER)
		target_dept = (target_dept == dept_list.len) ? 1 : (target_dept + 1)
		to_chat(user, "<span class='notice'>You set the board to \"[dept_list[target_dept]]\".</span>")
	else
		return ..()

/obj/item/circuitboard/computer/card/minor/examine(user)
	..()
	to_chat(user, "<span class='notice'>Currently set to \"[dept_list[target_dept]]\".</span>")


//obj/item/circuitboard/computer/shield
//	name = "Shield Control (Computer Board)"
//	icon_state = "command"
//	build_path = /obj/machinery/computer/stationshield

//Engineering

/obj/item/circuitboard/computer/apc_control
	name = "\improper Power Flow Control Console (Computer Board)"
	icon_state = "engineering"
	build_path = /obj/machinery/computer/apc_control

/obj/item/circuitboard/computer/atmos_alert
	name = "Atmospheric Alert (Computer Board)"
	icon_state = "engineering"
	build_path = /obj/machinery/computer/atmos_alert

/obj/item/circuitboard/computer/atmos_control
	name = "Atmospheric Monitor (Computer Board)"
	icon_state = "engineering"
	build_path = /obj/machinery/computer/atmos_control

/obj/item/circuitboard/computer/atmos_control/incinerator
	name = "Incinerator Air Control (Computer Board)"
	build_path = /obj/machinery/computer/atmos_control/incinerator

/obj/item/circuitboard/computer/atmos_control/toxinsmix
	name = "Toxins Mixing Air Control (Computer Board)"
	build_path = /obj/machinery/computer/atmos_control/toxinsmix

/obj/item/circuitboard/computer/atmos_control/tank
	name = "Tank Control (Computer Board)"
	build_path = /obj/machinery/computer/atmos_control/tank

/obj/item/circuitboard/computer/atmos_control/tank/oxygen_tank
	name = "Oxygen Supply Control (Computer Board)"
	build_path = /obj/machinery/computer/atmos_control/tank/oxygen_tank

/obj/item/circuitboard/computer/atmos_control/tank/toxin_tank
	name = "Plasma Supply Control (Computer Board)"
	build_path = /obj/machinery/computer/atmos_control/tank/toxin_tank

/obj/item/circuitboard/computer/atmos_control/tank/air_tank
	name = "Mixed Air Supply Control (Computer Board)"
	build_path = /obj/machinery/computer/atmos_control/tank/air_tank

/obj/item/circuitboard/computer/atmos_control/tank/mix_tank
	name = "Gas Mix Supply Control (Computer Board)"
	build_path = /obj/machinery/computer/atmos_control/tank/mix_tank

/obj/item/circuitboard/computer/atmos_control/tank/nitrous_tank
	name = "Nitrous Oxide Supply Control (Computer Board)"
	build_path = /obj/machinery/computer/atmos_control/tank/nitrous_tank

/obj/item/circuitboard/computer/atmos_control/tank/nitrogen_tank
	name = "Nitrogen Supply Control (Computer Board)"
	build_path = /obj/machinery/computer/atmos_control/tank/nitrogen_tank

/obj/item/circuitboard/computer/atmos_control/tank/carbon_tank
	name = "Carbon Dioxide Supply Control (Computer Board)"
	build_path = /obj/machinery/computer/atmos_control/tank/carbon_tank

/obj/item/circuitboard/computer/atmos_control/tank/bz_tank
	name = "BZ Supply Control (Computer Board)"
	build_path = /obj/machinery/computer/atmos_control/tank/bz_tank

/obj/item/circuitboard/computer/atmos_control/tank/freon_tank
	name = "Freon Supply Control (Computer Board)"
	build_path = /obj/machinery/computer/atmos_control/tank/freon_tank

/obj/item/circuitboard/computer/atmos_control/tank/halon_tank
	name = "Halon Supply Control (Computer Board)"
	build_path = /obj/machinery/computer/atmos_control/tank/halon_tank

/obj/item/circuitboard/computer/atmos_control/tank/healium_tank
	name = "Healium Supply Control (Computer Board)"
	build_path = /obj/machinery/computer/atmos_control/tank/healium_tank

/obj/item/circuitboard/computer/atmos_control/tank/hydrogen_tank
	name = "Hydrogen Supply Control (Computer Board)"
	build_path = /obj/machinery/computer/atmos_control/tank/hydrogen_tank

/obj/item/circuitboard/computer/atmos_control/tank/hypernoblium_tank
	name = "Hypernoblium Supply Control (Computer Board)"
	build_path = /obj/machinery/computer/atmos_control/tank/hypernoblium_tank

/obj/item/circuitboard/computer/atmos_control/tank/miasma_tank
	name = "Miasma Supply Control (Computer Board)"
	build_path = /obj/machinery/computer/atmos_control/tank/miasma_tank

/obj/item/circuitboard/computer/atmos_control/tank/nitryl_tank
	name = "Nitryl Supply Control (Computer Board)"
	build_path = /obj/machinery/computer/atmos_control/tank/nitryl_tank

/obj/item/circuitboard/computer/atmos_control/tank/pluoxium_tank
	name = "Pluoxium Supply Control (Computer Board)"
	build_path = /obj/machinery/computer/atmos_control/tank/pluoxium_tank

/obj/item/circuitboard/computer/atmos_control/tank/proto_nitrate_tank
	name = "Proto-Nitrate Supply Control (Computer Board)"
	build_path = /obj/machinery/computer/atmos_control/tank/proto_nitrate_tank

/obj/item/circuitboard/computer/atmos_control/tank/stimulum_tank
	name = "Stimulum Supply Control (Computer Board)"
	build_path = /obj/machinery/computer/atmos_control/tank/stimulum_tank

/obj/item/circuitboard/computer/atmos_control/tank/tritium_tank
	name = "Tritium Supply Control (Computer Board)"
	build_path = /obj/machinery/computer/atmos_control/tank/tritium_tank

/obj/item/circuitboard/computer/atmos_control/tank/water_vapor
	name = "Water Vapor Supply Control (Computer Board)"
	build_path = /obj/machinery/computer/atmos_control/tank/water_vapor

/obj/item/circuitboard/computer/atmos_control/tank/zauker_tank
	name = "Zauker Supply Control (Computer Board)"
	build_path = /obj/machinery/computer/atmos_control/tank/zauker_tank

/obj/item/circuitboard/computer/atmos_control/tank/helium_tank
	name = "Helium Supply Control (Computer Board)"
	build_path = /obj/machinery/computer/atmos_control/tank/helium_tank

/obj/item/circuitboard/computer/atmos_control/tank/antinoblium_tank
	name = "Antinoblium Supply Control (Computer Board)"
	build_path = /obj/machinery/computer/atmos_control/tank/antinoblium_tank

/obj/item/circuitboard/computer/auxiliary_base
	name = "Auxiliary Base Management Console (Computer Board)"
	icon_state = "engineering"
	build_path = /obj/machinery/computer/auxiliary_base

/obj/item/circuitboard/computer/base_construction
	name = "circuit board (Generic Base Construction Console)"
	icon_state = "engineering"
	build_path = /obj/machinery/computer/camera_advanced/base_construction

/obj/item/circuitboard/computer/base_construction/aux
	name = "circuit board (Aux Mining Base Construction Console)"
	icon_state = "engineering"
	build_path = /obj/machinery/computer/camera_advanced/base_construction/aux

/obj/item/circuitboard/computer/base_construction/centcom
	name = "circuit board (Centcom Base Construction Console)"
	icon_state = "engineering"
	build_path = /obj/machinery/computer/camera_advanced/base_construction/centcom

/obj/item/circuitboard/computer/comm_monitor
	name = "Telecommunications Monitor (Computer Board)"
	icon_state = "engineering"
	build_path = /obj/machinery/computer/telecomms/monitor

/obj/item/circuitboard/computer/comm_server
	name = "Telecommunications Server Monitor (Computer Board)"
	icon_state = "engineering"
	build_path = /obj/machinery/computer/telecomms/server

/obj/item/circuitboard/computer/communications
	name = "Communications (Computer Board)"
	icon_state = "engineering"
	build_path = /obj/machinery/computer/communications

/obj/item/circuitboard/computer/message_monitor
	name = "Message Monitor (Computer Board)"
	icon_state = "engineering"
	build_path = /obj/machinery/computer/message_monitor

/obj/item/circuitboard/computer/powermonitor
	name = "Power Monitor (Computer Board)"  //name fixed 250810
	icon_state = "engineering"
	build_path = /obj/machinery/computer/monitor

/obj/item/circuitboard/computer/powermonitor/secret
	name = "Outdated Power Monitor (Computer Board)" //Variant used on ruins to prevent them from showing up on PDA's.
	icon_state = "engineering"
	build_path = /obj/machinery/computer/monitor/secret

/obj/item/circuitboard/computer/solar_control
	name = "Solar Control (Computer Board)"  //name fixed 250810
	icon_state = "engineering"
	build_path = /obj/machinery/power/solar_control

/obj/item/circuitboard/computer/stationalert
	name = "Station Alerts (Computer Board)"
	icon_state = "engineering"
	build_path = /obj/machinery/computer/station_alert

/obj/item/circuitboard/computer/turbine_computer
	name = "Turbine Computer (Computer Board)"
	icon_state = "engineering"
	build_path = /obj/machinery/computer/turbine_computer

/obj/item/circuitboard/computer/turbine_control
	name = "Turbine control (Computer Board)"
	icon_state = "engineering"
	build_path = /obj/machinery/computer/turbine_computer

//Generic

/obj/item/circuitboard/computer/arcade/amputation
	name = "Mediborg's Amputation Adventure (Computer Board)"
	icon_state = "generic"
	build_path = /obj/machinery/computer/arcade/amputation

/obj/item/circuitboard/computer/arcade/battle
	name = "Arcade Battle (Computer Board)"
	icon_state = "generic"
	build_path = /obj/machinery/computer/arcade/battle

/obj/item/circuitboard/computer/arcade/orion_trail
	name = "Orion Trail (Computer Board)"
	icon_state = "generic"
	build_path = /obj/machinery/computer/arcade/orion_trail

/obj/item/circuitboard/computer/holodeck// Not going to let people get this, but it's just here for future
	name = "Holodeck Control (Computer Board)"
	icon_state = "generic"
	build_path = /obj/machinery/computer/holodeck

/obj/item/circuitboard/computer/libraryconsole
	name = "Library Visitor Console (Computer Board)"
	build_path = /obj/machinery/computer/libraryconsole

/obj/item/circuitboard/computer/libraryconsole/bookconsole
	name =  "Book Inventory Management Console (Machine Board)"
	build_path = /obj/machinery/computer/libraryconsole/bookmanagement

/obj/item/circuitboard/computer/libraryconsole/screwdriver_act(mob/living/user, obj/item/tool)
	if(build_path == /obj/machinery/computer/libraryconsole/bookmanagement)
		name = "Library Visitor Console (Computer Board)"
		build_path = /obj/machinery/computer/libraryconsole
		to_chat(user, span_notice("Defaulting access protocols."))
	else
		name = "Book Inventory Management Console (Computer Board)"
		build_path = /obj/machinery/computer/libraryconsole/bookmanagement
		to_chat(user, span_notice("Access protocols successfully updated."))
	return TRUE

/obj/item/circuitboard/computer/monastery_shuttle
	name = "Monastery Shuttle (Computer Board)"
	icon_state = "generic"
	build_path = /obj/machinery/computer/shuttle/monastery_shuttle

/obj/item/circuitboard/computer/olddoor
	name = "DoorMex (Computer Board)"
	icon_state = "generic"
	build_path = /obj/machinery/computer/pod/old

/obj/item/circuitboard/computer/pod
	name = "Massdriver control (Computer Board)"
	icon_state = "generic"
	build_path = /obj/machinery/computer/pod

/obj/item/circuitboard/computer/swfdoor
	name = "Magix (Computer Board)"
	icon_state = "generic"
	build_path = /obj/machinery/computer/pod/old/swf

/obj/item/circuitboard/computer/syndicate_shuttle
	name = "Syndicate Shuttle (Computer Board)"
	icon_state = "generic"
	build_path = /obj/machinery/computer/shuttle/syndicate
	var/challenge = FALSE
	var/moved = FALSE

/obj/item/circuitboard/computer/syndicate_shuttle/Initialize()
	. = ..()
	GLOB.syndicate_shuttle_boards += src

/obj/item/circuitboard/computer/syndicate_shuttle/Destroy()
	GLOB.syndicate_shuttle_boards -= src
	return ..()

/obj/item/circuitboard/computer/syndicatedoor
	name = "ProComp Executive (Computer Board)"
	icon_state = "generic"
	build_path = /obj/machinery/computer/pod/old/syndicate

/obj/item/circuitboard/computer/white_ship
	name = "White Ship (Computer Board)"
	icon_state = "generic"
	build_path = /obj/machinery/computer/shuttle/white_ship

/obj/item/circuitboard/computer/white_ship/bridge
	name = "White Ship Bridge (Computer Board)"
	icon_state = "generic"
	build_path = /obj/machinery/computer/shuttle/white_ship/bridge

/obj/item/circuitboard/computer/white_ship/pod
	name = "Salvage Pod (Computer Board)"
	build_path = /obj/machinery/computer/shuttle/white_ship/pod

/obj/item/circuitboard/computer/white_ship/pod/recall
	name = "Salvage Pod Recall (Computer Board)"
	build_path = /obj/machinery/computer/shuttle/white_ship/pod/recall

/obj/item/circuitboard/computer/bountypad
	name = "Bounty Pad (Computer Board)"
	build_path = /obj/machinery/computer/piratepad_control/civilian

//Medical

/obj/item/circuitboard/computer/crew
	name = "Crew Monitoring Console (Computer Board)"
	icon_state = "medical"
	build_path = /obj/machinery/computer/crew

/obj/item/circuitboard/computer/med_data
	name = "Medical Records Console (Computer Board)"
	icon_state = "medical"
	build_path = /obj/machinery/computer/med_data

/obj/item/circuitboard/computer/operating
	name = "Operating Computer (Computer Board)"
	icon_state = "medical"
	build_path = /obj/machinery/computer/operating

/obj/item/circuitboard/computer/pandemic
	name = "PanD.E.M.I.C. 2200 (Computer Board)"
	icon_state = "medical"
	build_path = /obj/machinery/computer/pandemic

//Science

/obj/item/circuitboard/computer/aifixer
	name = "AI Integrity Restorer (Computer Board)"
	icon_state = "science"
	build_path = /obj/machinery/computer/aifixer

/obj/item/circuitboard/computer/launchpad_console
	name = "Launchpad Control Console (Computer Board)"
	icon_state = "science"
	build_path = /obj/machinery/computer/launchpad

/obj/item/circuitboard/computer/mech_bay_power_console
	name = "Mech Bay Power Control Console (Computer Board)"
	icon_state = "science"
	build_path = /obj/machinery/computer/mech_bay_power_console

/obj/item/circuitboard/computer/mecha_control
	name = "Exosuit Control Console (Computer Board)"
	icon_state = "science"
	build_path = /obj/machinery/computer/mecha

/obj/item/circuitboard/computer/nanite_chamber_control
	name = "Nanite Chamber Control (Computer Board)"
	icon_state = "science"
	build_path = /obj/machinery/computer/nanite_chamber_control

/obj/item/circuitboard/computer/nanite_cloud_controller
	name = "Nanite Cloud Control (Computer Board)"
	icon_state = "science"
	build_path = /obj/machinery/computer/nanite_cloud_controller

/obj/item/circuitboard/computer/rdconsole
	name = "R&D Console (Computer Board)"
	icon_state = "science"
	build_path = /obj/machinery/computer/rdconsole

/obj/item/circuitboard/computer/rdservercontrol
	name = "R&D Server Control (Computer Board)"
	icon_state = "science"
	build_path = /obj/machinery/computer/rdservercontrol

/obj/item/circuitboard/computer/research
	name = "Research Monitor (Computer Board)"
	icon_state = "science"
	build_path = /obj/machinery/computer/security/research

/obj/item/circuitboard/computer/robotics
	name = "Robotics Control (Computer Board)"
	icon_state = "science"
	build_path = /obj/machinery/computer/robotics

/obj/item/circuitboard/computer/teleporter
	name = "Teleporter (Computer Board)"
	icon_state = "science"
	build_path = /obj/machinery/computer/teleporter

/obj/item/circuitboard/computer/xenobiology
	name = "Xenobiology Console (Computer Board)"
	icon_state = "science"
	build_path = /obj/machinery/computer/camera_advanced/xenobio

/obj/item/circuitboard/computer/scan_consolenew
	name = "DNA Console (Computer Board)"
	icon_state = "science"
	build_path = /obj/machinery/computer/scan_consolenew

/obj/item/circuitboard/computer/mechpad
	name = "Mecha Orbital Pad Console (Computer Board)"
	icon_state = "science"
	build_path = /obj/machinery/computer/mechpad

//Security

/obj/item/circuitboard/computer/labor_shuttle
	name = "Labor Shuttle (Computer Board)"
	icon_state = "security"
	build_path = /obj/machinery/computer/shuttle/labor

/obj/item/circuitboard/computer/labor_shuttle/one_way
	name = "Prisoner Shuttle Console (Computer Board)"
	icon_state = "security"
	build_path = /obj/machinery/computer/shuttle/labor/one_way

/obj/item/circuitboard/computer/gulag_teleporter_console
	name = "Labor Camp teleporter console (Computer Board)"
	icon_state = "security"
	build_path = /obj/machinery/computer/prisoner/gulag_teleporter_computer

/obj/item/circuitboard/computer/prisoner
	name = "Prisoner Management Console (Computer Board)"
	icon_state = "security"
	build_path = /obj/machinery/computer/prisoner/management

/obj/item/circuitboard/computer/secure_data
	name = "Security Records Console (Computer Board)"
	icon_state = "security"
	build_path = /obj/machinery/computer/secure_data

/obj/item/circuitboard/computer/warrant
	name = "Security Warrant Viewer (Computer Board)"
	icon_state = "security"
	build_path = /obj/machinery/computer/warrant

/obj/item/circuitboard/computer/security
	name = "Security Cameras (Computer Board)"
	icon_state = "security"
	build_path = /obj/machinery/computer/security

/obj/item/circuitboard/computer/advanced_camera
	name = "Advanced Camera Console (Computer Board)"
	icon_state = "security"
	build_path = /obj/machinery/computer/camera_advanced/syndie

//Service

//Supply

/obj/item/circuitboard/computer/cargo
	name = "Supply Console (Computer Board)"
	icon_state = "supply"
	build_path = /obj/machinery/computer/cargo
	var/contraband = FALSE

/obj/item/circuitboard/computer/cargo/multitool_act(mob/living/user)
	. = ..()
	if(!(obj_flags & EMAGGED))
		contraband = !contraband
		to_chat(user, "<span class='notice'>Receiver spectrum set to [contraband ? "Broad" : "Standard"].</span>")
	else
		to_chat(user, "<span class='alert'>The spectrum chip is unresponsive.</span>")

/obj/item/circuitboard/computer/cargo/emag_act(mob/living/user)
	if(!(obj_flags & EMAGGED))
		contraband = TRUE
		obj_flags |= EMAGGED
		to_chat(user, "<span class='notice'>You adjust [src]'s routing and receiver spectrum, unlocking special supplies and contraband.</span>")

/obj/item/circuitboard/computer/cargo/configure_machine(obj/machinery/computer/cargo/machine)
	if(!istype(machine))
		CRASH("Cargo board attempted to configure incorrect machine type: [machine] ([machine?.type])")

	machine.contraband = contraband
	if (obj_flags & EMAGGED)
		machine.obj_flags |= EMAGGED
	else
		machine.obj_flags &= ~EMAGGED

/obj/item/circuitboard/computer/cargo/express
	name = "Express Supply Console (Computer Board)"
	build_path = /obj/machinery/computer/cargo/express

/obj/item/circuitboard/computer/cargo/express/emag_act(mob/living/user)
	if(!(obj_flags & EMAGGED))
		contraband = TRUE
		obj_flags |= EMAGGED
		to_chat(user, "<span class='notice'>You change the routing protocols, allowing the Drop Pod to land anywhere on the station.</span>")

/obj/item/circuitboard/computer/cargo/express/multitool_act(mob/living/user)
	if (!(obj_flags & EMAGGED))
		contraband = !contraband
		to_chat(user, "<span class='notice'>Receiver spectrum set to [contraband ? "Broad" : "Standard"].</span>")
	else
		to_chat(user, "<span class='notice'>You reset the destination-routing protocols and receiver spectrum to factory defaults.</span>")
		contraband = FALSE
		obj_flags &= ~EMAGGED

/obj/item/circuitboard/computer/cargo/request
	name = "Supply Request Console (Computer Board)"
	build_path = /obj/machinery/computer/cargo/request

/obj/item/circuitboard/computer/ferry
	name = "Transport Ferry (Computer Board)"
	icon_state = "supply"
	build_path = /obj/machinery/computer/shuttle/ferry

/obj/item/circuitboard/computer/ferry/request
	name = "Transport Ferry Console (Computer Board)"
	icon_state = "supply"
	build_path = /obj/machinery/computer/shuttle/ferry/request

/obj/item/circuitboard/computer/mining
	name = "Outpost Status Display (Computer Board)"
	icon_state = "supply"
	build_path = /obj/machinery/computer/security/mining

/obj/item/circuitboard/computer/mining_shuttle
	name = "Elevator (Computer Board)"
	icon_state = "supply"
	build_path = /obj/machinery/computer/shuttle/mining

/obj/item/circuitboard/computer/mining_shuttle/common
	name = "Lavaland Shuttle (Computer Board)"
	build_path = /obj/machinery/computer/shuttle/mining/common
