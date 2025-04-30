//This is the lowest supported version, anything below this is completely obsolete and the entire savefile will be wiped.
#define SAVEFILE_VERSION_MIN	41

//This is the current version, anything below this will attempt to update (if it's not obsolete)
//	You do not need to raise this if you are adding new values that have sane defaults.
//	Only raise this value when changing the meaning/format/name/layout of an existing value
//	where you would want the updater procs below to run
#define SAVEFILE_VERSION_MAX	41


#define APPEARANCE_CATEGORY_COLUMN "<td valign='top' width='25%' border='1px solid white'>"
#define MAX_MUTANT_ROWS 4
#define ATTRIBUTE_BASE_LIMIT 5 //Highest level that a base attribute can be upgraded to. Bonus attributes can increase the actual amount past the limit.


#define VAMP_RANK_GHOUL 1
#define VAMP_RANK_HALF_DAMNED 2
#define VAMP_RANK_FLEDGLING 3
#define VAMP_RANK_NEONATE 4
#define VAMP_RANK_ANCILLAE 5
#define VAMP_RANK_ELDER 6

GLOBAL_LIST_INIT(vampire_rank_list, list(
	"Fledgling" = VAMP_RANK_FLEDGLING,
	"Neonate" = VAMP_RANK_NEONATE, 
	"Ancillae" = VAMP_RANK_ANCILLAE,
	"Elder" = VAMP_RANK_ELDER))

GLOBAL_LIST_INIT(vampire_rank_names, list(
	VAMP_RANK_GHOUL = "Ghoul",
	VAMP_RANK_HALF_DAMNED = "Half-Damned",
	VAMP_RANK_FLEDGLING = "Fledgling",
	VAMP_RANK_NEONATE = "Neonate", 
	VAMP_RANK_ANCILLAE = "Ancillae",
	VAMP_RANK_ELDER = "Elder"))

GLOBAL_LIST_INIT(vampire_rank_desc_list, list(
	VAMP_RANK_GHOUL = "Elge write a description for a Ghoul's place in vampire society",
	VAMP_RANK_HALF_DAMNED = "Elge write a description for a Half-Damned's place in vampire society",
	VAMP_RANK_FLEDGLING = "Elge write a description for a Fledgling's place in vampire society",
	VAMP_RANK_NEONATE = "Elge write a description for a Neonates's place in vampire society",
	VAMP_RANK_ANCILLAE = "Elge write a description for an Ancillae's place in vampire society",
	VAMP_RANK_ELDER = "Elge write a description for an Elder's place in vampire society"))

#define CHARACTER_DOTS_DEFAULT 12
#define CHARACTER_DOTS_GHOUL 12
#define CHARACTER_DOTS_FLEDGLING 12
#define CHARACTER_DOTS_HALF_DAMNED 12
#define CHARACTER_DOTS_NEONATE 12
#define CHARACTER_DOTS_ANCILLAE 12
#define CHARACTER_DOTS_ELDER 12

#define DISCIPLINE_DOTS_DEFAULT 0
#define DISCIPLINE_DOTS_GHOUL 3
#define DISCIPLINE_DOTS_HALF_DAMNED 5
#define DISCIPLINE_DOTS_FLEDGLING 5
#define DISCIPLINE_DOTS_NEONATE 5
#define DISCIPLINE_DOTS_ANCILLAE 8
#define DISCIPLINE_DOTS_ELDER 11

#define PHYSIQUE_DESCRIPTION "Elge write a description for physique"
#define STAMINA_DESCRIPTION "Elge write a description for stamina"
#define WITS_DESCRIPTION "Elge write a description for wits"
#define RESOLVE_DESCRIPTION "Elge write a description for resolve"
#define CHARISMA_DESCRIPTION "Elge write a description for charisma"
#define COMPOSURE_DESCRIPTION "Elge write a description for composure"

GLOBAL_LIST_INIT(vampire_faction_list, list(
	"Invictus",
	"Lancea et Sanctum",
	"Ordo Dracul",
	"Circle of the Crone",
	"Carthian Movement",
	"Unaligned"))