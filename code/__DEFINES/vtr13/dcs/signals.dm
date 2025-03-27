///called in /datum/mind/proc/transfer_to (brain, new_mob)
#define COMSIG_MIND_TRANSFERRED "mind_transferred"

///called in /datum/element/memories/Detach
#define COMSIG_MEMORY_DELETE "memory_delete"

//called in /datum/component/base_memory/get_memory_data (mob/living/carbon/human/owner, is_own_memories)
#define COMSIG_MEMORY_NAME_OVERRIDE "memory_name_override"
	#define COMPONENT_MEMORY_OVERRIDE (1<<0)

//called in /datum/component/base_memory/get_memory_data (mob/living/carbon/human/owner, is_own_memories)
#define COMSIG_MEMORY_SPLAT_TEXT "memory_splat_text"

//called in /datum/discipline_power/vtr/auspex/major_telepathy/proc/ask_memories (datum/mind, mob/living/carbon/human/invader)
#define COMSIG_MEMORY_AUSPEX_INVADE "memory_auspex_invade"

#define COMSIG_MEMORY_DISCIPLINE_TEXT "memory_discipline_text"
	