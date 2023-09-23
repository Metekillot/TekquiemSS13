#define NUKE_RESULT_FLUKE 0
#define NUKE_RESULT_NUKE_WIN 1
#define NUKE_RESULT_CREW_WIN 2
#define NUKE_RESULT_CREW_WIN_SYNDIES_DEAD 3
#define NUKE_RESULT_DISK_LOST 4
#define NUKE_RESULT_DISK_STOLEN 5
#define NUKE_RESULT_NOSURVIVORS 6
#define NUKE_RESULT_WRONG_STATION 7
#define NUKE_RESULT_WRONG_STATION_DEAD 8

//fugitive end results
#define FUGITIVE_RESULT_BADASS_HUNTER 0
#define FUGITIVE_RESULT_POSTMORTEM_HUNTER 1
#define FUGITIVE_RESULT_MAJOR_HUNTER 2
#define FUGITIVE_RESULT_HUNTER_VICTORY 3
#define FUGITIVE_RESULT_MINOR_HUNTER 4
#define FUGITIVE_RESULT_STALEMATE 5
#define FUGITIVE_RESULT_MINOR_FUGITIVE 6
#define FUGITIVE_RESULT_FUGITIVE_VICTORY 7
#define FUGITIVE_RESULT_MAJOR_FUGITIVE 8

#define APPRENTICE_DESTRUCTION "destruction"
#define APPRENTICE_BLUESPACE "bluespace"
#define APPRENTICE_ROBELESS "robeless"
#define APPRENTICE_HEALING "healing"

//ERT Types
#define ERT_BLUE "Blue"
#define ERT_RED  "Red"
#define ERT_AMBER "Amber"
#define ERT_DEATHSQUAD "Deathsquad"

//ERT subroles
#define ERT_SEC "sec"
#define ERT_MED "med"
#define ERT_ENG "eng"
#define ERT_LEADER "leader"
#define DEATHSQUAD "ds"
#define DEATHSQUAD_LEADER "ds_leader"

//Shuttle elimination hijacking
/// Does not stop elimination hijacking but itself won't elimination hijack
#define ELIMINATION_NEUTRAL 0
/// Needs to be present for shuttle to be elimination hijacked
#define ELIMINATION_ENABLED 1
/// Prevents elimination hijack same way as non-antags
#define ELIMINATION_PREVENT 2

//Syndicate Contracts
#define CONTRACT_STATUS_INACTIVE 1
#define CONTRACT_STATUS_ACTIVE 2
#define CONTRACT_STATUS_BOUNTY_CONSOLE_ACTIVE 3
#define CONTRACT_STATUS_EXTRACTING 4
#define CONTRACT_STATUS_COMPLETE 5
#define CONTRACT_STATUS_ABORTED 6

#define CONTRACT_PAYOUT_LARGE 1
#define CONTRACT_PAYOUT_MEDIUM 2
#define CONTRACT_PAYOUT_SMALL 3

#define CONTRACT_UPLINK_PAGE_CONTRACTS "CONTRACTS"
#define CONTRACT_UPLINK_PAGE_HUB "HUB"

///It is faster as a macro than a proc
#define IS_HERETIC(mob) (mob.mind?.has_antag_datum(/datum/antagonist/heretic))
#define IS_HERETIC_MONSTER(mob) (mob.mind?.has_antag_datum(/datum/antagonist/heretic_monster))

GLOBAL_LIST_INIT(heretic_start_knowledge,list(/datum/eldritch_knowledge/spell/basic,/datum/eldritch_knowledge/living_heart,/datum/eldritch_knowledge/codex_cicatrix))


#define PATH_SIDE "Side"

#define PATH_ASH "Ash"
#define PATH_RUST "Rust"
#define PATH_FLESH "Flesh"
#define PATH_VOID "Void"


/// How many telecrystals a normal traitor starts with
#define TELECRYSTALS_DEFAULT 20
/// How many telecrystals mapper/admin only "precharged" uplink implant
#define TELECRYSTALS_PRELOADED_IMPLANT 10
/// The normal cost of an uplink implant; used for calcuating how many
/// TC to charge someone if they get a free implant through choice or
/// because they have nothing else that supports an implant.
#define UPLINK_IMPLANT_TELECRYSTAL_COST 4

/// Items with this stock key do not share stock with other items
#define UPLINK_SHARED_STOCK_UNIQUE "uplink_shared_stock_unique"
/// Stock keys for items that share inventory stock
#define UPLINK_SHARED_STOCK_KITS "uplink_shared_stock_kits"
#define UPLINK_SHARED_STOCK_SURPLUS "uplink_shared_stock_surplus"

// Used for traitor objectives
/// If the objective hasn't been taken yet
#define OBJECTIVE_STATE_INACTIVE 1
/// If the objective is active and ongoing
#define OBJECTIVE_STATE_ACTIVE 2
/// If the objective has been completed.
#define OBJECTIVE_STATE_COMPLETED 3
/// If the objective has failed.
#define OBJECTIVE_STATE_FAILED 4
/// If the objective is no longer valid
#define OBJECTIVE_STATE_INVALID 5

/// Weights for traitor objective categories
#define OBJECTIVE_WEIGHT_TINY 5
#define OBJECTIVE_WEIGHT_SMALL 7
#define OBJECTIVE_WEIGHT_DEFAULT 10
#define OBJECTIVE_WEIGHT_BIG 15
#define OBJECTIVE_WEIGHT_HUGE 20

#define REVENANT_NAME_FILE "revenant_names.json"

/// Antag panel groups
#define ANTAG_GROUP_ABDUCTORS "Abductors"
#define ANTAG_GROUP_ABOMINATIONS "Extradimensional Abominations"
#define ANTAG_GROUP_ARACHNIDS "Arachnid Infestation"
#define ANTAG_GROUP_ASHWALKERS "Ash Walkers"
#define ANTAG_GROUP_BIOHAZARDS "Biohazards"
#define ANTAG_GROUP_CLOWNOPS "Clown Operatives"
#define ANTAG_GROUP_CYBERAUTH "Cyber Authority"
#define ANTAG_GROUP_ERT "Emergency Response Team"
#define ANTAG_GROUP_HORRORS "Eldritch Horrors"
#define ANTAG_GROUP_LEVIATHANS "Spaceborne Leviathans"
#define ANTAG_GROUP_NINJAS "Ninja Clan"
#define ANTAG_GROUP_OVERGROWTH "Invasive Overgrowth"
#define ANTAG_GROUP_PIRATES "Pirate Crew"
#define ANTAG_GROUP_SYNDICATE "Syndicate"
#define ANTAG_GROUP_WIZARDS "Wizard Federation"
#define ANTAG_GROUP_XENOS "Xenomorph Infestation"
