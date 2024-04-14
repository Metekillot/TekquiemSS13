// BEGIN TRAIT DEFINES
//mob traits
/// Forces the user to stay unconscious.
#define TRAIT_KNOCKEDOUT		"knockedout"
/// Prevents voluntary movement.
#define TRAIT_IMMOBILIZED		"immobilized"
/// Prevents voluntary standing or staying up on its own.
#define TRAIT_FLOORED			"floored"
/// Forces user to stay standing
#define TRAIT_FORCED_STANDING	"forcedstanding"
/// Prevents usage of manipulation appendages (picking, holding or using items, manipulating storage).
#define TRAIT_HANDS_BLOCKED		"handsblocked"
/// Inability to access UI hud elements. Turned into a trait from [MOBILITY_UI] to be able to track sources.
#define TRAIT_UI_BLOCKED		"uiblocked"
/// Inability to pull things. Turned into a trait from [MOBILITY_PULL] to be able to track sources.
#define TRAIT_PULL_BLOCKED		"pullblocked"
/// Abstract condition that prevents movement if being pulled and might be resisted against. Handcuffs and straight jackets, basically.
#define TRAIT_RESTRAINED		"restrained"
/// Doesn't miss attacks
#define TRAIT_PERFECT_ATTACKER "perfect_attacker"
#define TRAIT_INCAPACITATED		"incapacitated"
#define TRAIT_CRITICAL_CONDITION	"critical-condition" //In some kind of critical condition. Is able to succumb.
#define TRAIT_BLIND 			"blind"
#define TRAIT_MUTE				"mute"
#define TRAIT_EMOTEMUTE			"emotemute"
#define TRAIT_DEAF				"deaf"
#define TRAIT_NEARSIGHT			"nearsighted"
#define TRAIT_FAT				"fat"
#define TRAIT_HUSK				"husk"
#define TRAIT_BADDNA			"baddna"
#define TRAIT_CLUMSY			"clumsy"
#define TRAIT_CHUNKYFINGERS		"chunkyfingers" //means that you can't use weapons with normal trigger guards.
#define TRAIT_DUMB				"dumb"
#define TRAIT_ADVANCEDTOOLUSER	"advancedtooluser" //Whether a mob is dexterous enough to use machines and certain items or not.
#define TRAIT_MONKEYLIKE		"monkeylike" //Antagonizes the above.
#define TRAIT_PACIFISM			"pacifism"
#define TRAIT_ELYSIUM			"elysium"
#define TRAIT_IGNORESLOWDOWN	"ignoreslow"
#define TRAIT_IGNOREDAMAGESLOWDOWN "ignoredamageslowdown"
#define TRAIT_DEATHCOMA			"deathcoma" //Causes death-like unconsciousness
#define TRAIT_FAKEDEATH			"fakedeath" //Makes the owner appear as dead to most forms of medical examination
#define TRAIT_TORPOR			"torpor" //A special form of fakedeath that vampires go into rather than dying above -200 health
#define TRAIT_DISFIGURED		"disfigured"
#define TRAIT_XENO_HOST			"xeno_host"	//Tracks whether we're gonna be a baby alien's mummy.
#define TRAIT_STUNIMMUNE		"stun_immunity"
#define TRAIT_STUNRESISTANCE    "stun_resistance"
#define TRAIT_IWASBATONED    	"iwasbatoned" //Anti Dual-baton cooldown bypass exploit.
#define TRAIT_SLEEPIMMUNE		"sleep_immunity"
#define TRAIT_PUSHIMMUNE		"push_immunity"
#define TRAIT_SHOCKIMMUNE		"shock_immunity"
#define TRAIT_TESLA_SHOCKIMMUNE	"tesla_shock_immunity"
#define TRAIT_STABLEHEART		"stable_heart"
#define TRAIT_STABLELIVER		"stable_liver"
#define TRAIT_RESISTHEAT		"resist_heat"
#define TRAIT_RESISTHEATHANDS	"resist_heat_handsonly" //For when you want to be able to touch hot things, but still want fire to be an issue.
#define TRAIT_RESISTCOLD		"resist_cold"
#define TRAIT_RESISTHIGHPRESSURE	"resist_high_pressure"
#define TRAIT_RESISTLOWPRESSURE	"resist_low_pressure"
#define TRAIT_BOMBIMMUNE		"bomb_immunity"
#define TRAIT_RADIMMUNE			"rad_immunity"
#define TRAIT_GENELESS  		"geneless"
#define TRAIT_VIRUSIMMUNE		"virus_immunity"
#define TRAIT_PIERCEIMMUNE		"pierce_immunity"
#define TRAIT_NODISMEMBER		"dismember_immunity"
#define TRAIT_NOFIRE			"nonflammable"
#define TRAIT_NOGUNS			"no_guns"
#define TRAIT_NOHUNGER			"no_hunger"
#define TRAIT_NOMETABOLISM		"no_metabolism"
#define TRAIT_NOCLONELOSS		"no_cloneloss"
#define TRAIT_TOXIMMUNE			"toxin_immune"
#define TRAIT_EASYDISMEMBER		"easy_dismember"
#define TRAIT_LIMBATTACHMENT 	"limb_attach"
#define TRAIT_NOLIMBDISABLE		"no_limb_disable"
#define TRAIT_EASILY_WOUNDED		"easy_limb_wound"
#define TRAIT_HARDLY_WOUNDED		"hard_limb_wound"
#define TRAIT_NEVER_WOUNDED		"never_wounded"
#define TRAIT_TOXINLOVER		"toxinlover"
#define TRAIT_NOBREATH			"no_breath"
#define TRAIT_ANTIMAGIC			"anti_magic"
#define TRAIT_HOLY				"holy"
#define TRAIT_DEPRESSION		"depression"
#define TRAIT_JOLLY				"jolly"
#define TRAIT_NOCRITDAMAGE		"no_crit"
#define TRAIT_NOSLIPWATER		"noslip_water"
#define TRAIT_NOSLIPALL			"noslip_all"
#define TRAIT_NODEATH			"nodeath"
#define TRAIT_NOHARDCRIT		"nohardcrit"
#define TRAIT_NOSOFTCRIT		"nosoftcrit"
#define TRAIT_MINDSHIELD		"mindshield"
#define TRAIT_DISSECTED			"dissected"
#define TRAIT_SIXTHSENSE		"sixth_sense" //I can hear dead people
#define TRAIT_FEARLESS			"fearless"
#define TRAIT_PARALYSIS_L_ARM	"para-l-arm" //These are used for brain-based paralysis, where replacing the limb won't fix it
#define TRAIT_PARALYSIS_R_ARM	"para-r-arm"
#define TRAIT_PARALYSIS_L_LEG	"para-l-leg"
#define TRAIT_PARALYSIS_R_LEG	"para-r-leg"
#define TRAIT_CANNOT_OPEN_PRESENTS "cannot-open-presents"
#define TRAIT_PRESENT_VISION    "present-vision"
#define TRAIT_DISK_VERIFIER     "disk-verifier"
#define TRAIT_NOMOBSWAP         "no-mob-swap"
#define TRAIT_XRAY_VISION       "xray_vision"
#define TRAIT_THERMAL_VISION    "thermal_vision"
#define TRAIT_ABDUCTOR_TRAINING "abductor-training"
#define TRAIT_ABDUCTOR_SCIENTIST_TRAINING "abductor-scientist-training"
#define TRAIT_SURGEON           "surgeon"
#define	TRAIT_STRONG_GRABBER	"strong_grabber"
#define	TRAIT_MAGIC_CHOKE		"magic_choke"
#define TRAIT_SOOTHED_THROAT    "soothed-throat"
#define TRAIT_BOOZE_SLIDER      "booze-slider"
#define TRAIT_QUICK_CARRY		"quick-carry" //We place people into a fireman carry quicker than standard
#define TRAIT_QUICKER_CARRY		"quicker-carry" //We place people into a fireman carry especially quickly compared to quick_carry
#define TRAIT_QUICK_BUILD		"quick-build"
#define TRAIT_UNINTELLIGIBLE_SPEECH "unintelligible-speech"
#define TRAIT_UNSTABLE			"unstable"
#define TRAIT_OIL_FRIED			"oil_fried"
#define TRAIT_MEDICAL_HUD		"med_hud"
#define TRAIT_SECURITY_HUD		"sec_hud"
#define TRAIT_DIAGNOSTIC_HUD	"diag_hud" //for something granting you a diagnostic hud
#define TRAIT_MEDIBOTCOMINGTHROUGH "medbot" //Is a medbot healing you
#define TRAIT_PASSTABLE			"passtable"
#define TRAIT_NOFLASH			"noflash" //Makes you immune to flashes
#define TRAIT_XENO_IMMUNE		"xeno_immune"//prevents xeno huggies implanting skeletons
#define TRAIT_FLASH_SENSITIVE	"flash_sensitive"//Makes you flashable from any direction
#define TRAIT_NAIVE				"naive"
#define TRAIT_PRIMITIVE			"primitive"
#define TRAIT_GUNFLIP			"gunflip"
#define TRAIT_SPECIAL_TRAUMA_BOOST	"special_trauma_boost" ///Increases chance of getting special traumas, makes them harder to cure
#define TRAIT_BLOODCRAWL_EAT	"bloodcrawl_eat"
#define TRAIT_SPACEWALK			"spacewalk"
#define TRAIT_GAMERGOD			"gamer-god" //double arcade prizes
#define TRAIT_GIANT				"giant"
#define TRAIT_DWARF				"dwarf"
#define TRAIT_SILENT_FOOTSTEPS	"silent_footsteps" //makes your footsteps completely silent
#define TRAIT_NICE_SHOT			"nice_shot" //hnnnnnnnggggg..... you're pretty good....
#define TRAIT_TUMOR_SUPPRESSED	"brain_tumor_suppressed" //prevents the damage done by a brain tumor
#define TRAIT_PERMANENTLY_ONFIRE	"permanently_onfire" //overrides the update_fire proc to always add fire (for lava)
#define TRAIT_SIGN_LANG				"sign_language" //Galactic Common Sign Language
#define TRAIT_NANITE_MONITORING	"nanite_monitoring" //The mob's nanites are sending a monitoring signal visible on diag HUD
#define TRAIT_MARTIAL_ARTS_IMMUNE "martial_arts_immune" // nobody can use martial arts on this mob
#define TRAIT_DUFFEL_CURSED "duffel_cursed" //You've been cursed with a living duffelbag, and can't have more added
/// Prevents mob from riding mobs when buckled onto something
#define TRAIT_CANT_RIDE			"cant_ride"
#define TRAIT_BLOODY_MESS		"bloody_mess" //from heparin, makes open bleeding wounds rapidly spill more blood
#define TRAIT_COAGULATING		"coagulating" //from coagulant reagents, this doesn't affect the bleeding itself but does affect the bleed warning messages
/// The holder of this trait has antennae or whatever that hurt a ton when noogied
#define TRAIT_ANTENNAE	"antennae"

/// Trait that tracks if something has been renamed. Typically holds a REF() to the object itself (AKA src) for wide addition/removal.
#define TRAIT_WAS_RENAMED "was_renamed"

/// A transforming item that is actively extended / transformed
#define TRAIT_TRANSFORM_ACTIVE "active_transform"

#define TRAIT_NOBLEED "nobleed" //This carbon doesn't bleed


#define TRAIT_DANCER			"dancer"
#define TRAIT_EXP_DRIVER		"experienced_driver"
#define TRAIT_BONE_KEY			"bone_key"
#define TRAIT_BLOODY_LOVER		"bloody_lover"
#define TRAIT_TOUGH_FLESH		"tough_flesh"
#define TRAIT_BLOODY_SUCKER		"bloody_sucker"
#define TRAIT_NON_INT			"non_intellectual"
#define TRAIT_COFFIN_THERAPY	"coffin_therapy"
#define TRAIT_RUBICON			"rubicon"
#define TRAIT_HUNGRY			"hungry"
#define TRAIT_STAKE_RESISTANT	"stake_resistant"
#define TRAIT_LAZY				"lazy"
#define TRAIT_HOMOSEXUAL		"homosexual"
#define TRAIT_HUNTED			"hunted"
#define TRAIT_VIOLATOR			"violator"
#define TRAIT_DIABLERIE			"diablerie"
#define TRAIT_GULLET			"gullet"
#define TRAIT_CHARMER			"charmer"
#define TRAIT_UNMASQUERADE		"unmasquerade"	//For tzi clothing
#define TRAIT_NONMASQUERADE		"nonmasquerade"	//For tzi mods
#define TRAIT_GUNFIGHTER        "gunfighter"    //Halves firing delay and cooldown between burst fire shots
/// Makes gambling incredibly effective, and causes random beneficial events to happen for the mob.
#define TRAIT_SUPERNATURAL_LUCK	"supernatural_luck"
/// Lets the mob block projectiles like bullets using only their hands.
#define TRAIT_HANDS_BLOCK_PROJECTILES "hands_block_projectiles"
/// The mob always dodges melee attacks
#define TRAIT_ENHANCED_MELEE_DODGE "enhanced_melee_dodge"
/// The mob can easily swim and jump very far.
#define TRAIT_SUPERNATURAL_DEXTERITY "supernatural_dexterity"
/// Can pass through walls so long as it doesn't move the mob into a new area
#define TRAIT_PASS_THROUGH_WALLS "pass_through_walls"

// You can stare into the abyss, but it does not stare back.
// You're immune to the hallucination effect of the supermatter, either
// through force of will, or equipment. Present on /mob or /datum/mind
#define TRAIT_SUPERMATTER_MADNESS_IMMUNE "supermatter_madness_immune"

// You can stare into the abyss, and it turns pink.
// Being close enough to the supermatter makes it heal at higher temperatures
// and emit less heat. Present on /mob or /datum/mind
#define TRAIT_SUPERMATTER_SOOTHER "supermatter_soother"
/*
* Trait granted by various security jobs, and checked by [/obj/item/food/donut]
* When present in the mob's mind, they will always love donuts.
*/
#define TRAIT_DONUT_LOVER "donut_lover"

// METABOLISMS
// Various jobs on the station have historically had better reactions
// to various drinks and foodstuffs. Security liking donuts is a classic
// example. Through years of training/abuse, their livers have taken
// a liking to those substances. Steal a sec officer's liver, eat donuts good.

// These traits are applied to /obj/item/organ/liver
#define TRAIT_LAW_ENFORCEMENT_METABOLISM "law_enforcement_metabolism"
#define TRAIT_CULINARY_METABOLISM "culinary_metabolism"
#define TRAIT_COMEDY_METABOLISM "comedy_metabolism"
#define TRAIT_MEDICAL_METABOLISM "medical_metabolism"
#define TRAIT_GREYTIDE_METABOLISM "greytide_metabolism"
#define TRAIT_ENGINEER_METABOLISM "engineer_metabolism"
#define TRAIT_ROYAL_METABOLISM "royal_metabolism"
#define TRAIT_PRETENDER_ROYAL_METABOLISM "pretender_royal_metabolism"

// If present on a mob or mobmind, allows them to "suplex" an immovable rod
// turning it into a glorified potted plant, and giving them an
// achievement. Can also be used on rod-form wizards.
// Normally only present in the mind of a Research Director.
#define TRAIT_ROD_SUPLEX "rod_suplex"

//SKILLS
#define TRAIT_UNDERWATER_BASKETWEAVING_KNOWLEDGE "underwater_basketweaving"
#define TRAIT_WINE_TASTER "wine_taster"
#define TRAIT_BONSAI "bonsai"
#define TRAIT_LIGHTBULB_REMOVER "lightbulb_remover"
#define TRAIT_KNOW_CYBORG_WIRES "know_cyborg_wires"
#define TRAIT_KNOW_ENGI_WIRES "know_engi_wires"
#define TRAIT_ENTRAILS_READER "entrails_reader"

///Movement type traits for movables. See elements/movetype_handler.dm
#define TRAIT_MOVE_GROUND		"move_ground"
#define TRAIT_MOVE_FLYING		"move_flying"
#define TRAIT_MOVE_VENTCRAWLING	"move_ventcrawling"
#define TRAIT_MOVE_FLOATING		"move_floating"
#define TRAIT_MOVE_PHASING		"move_phasing"
/// Disables the floating animation. See above.
#define TRAIT_NO_FLOATING_ANIM		"no-floating-animation"

//non-mob traits
/// Used for limb-based paralysis, where replacing the limb will fix it.
#define TRAIT_PARALYSIS				"paralysis"
/// Used for limbs.
#define TRAIT_DISABLED_BY_WOUND		"disabled-by-wound"

///Used for managing KEEP_TOGETHER in [/atom/var/appearance_flags]
#define TRAIT_KEEP_TOGETHER 	"keep-together"

///Marks the item as having been transmuted. Functionally blacklists the item from being recycled or sold for materials.
#define TRAIT_MAT_TRANSMUTED	"transmuted"

// item traits
#define TRAIT_NODROP			"nodrop"
#define TRAIT_NO_STORAGE_INSERT	"no_storage_insert" //cannot be inserted in a storage.
#define TRAIT_T_RAY_VISIBLE		"t-ray-visible" // Visible on t-ray scanners if the atom/var/level == 1
#define TRAIT_NO_TELEPORT		"no-teleport" //you just can't
#define TRAIT_FOOD_GRILLED 		"food_grilled"
#define TRAIT_NEEDS_TWO_HANDS	"needstwohands" //The items needs two hands to be carried
#define TRAIT_FISH_SAFE_STORAGE "fish_case" //Fish in this won't die
#define TRAIT_FISH_CASE_COMPATIBILE "fish_case_compatibile" //Stuff that can go inside fish cases

//quirk traits
#define TRAIT_ALCOHOL_TOLERANCE	"alcohol_tolerance"
#define TRAIT_AGEUSIA			"ageusia"
#define TRAIT_HEAVY_SLEEPER		"heavy_sleeper"
#define TRAIT_NIGHT_VISION		"night_vision"
#define TRAIT_LIGHT_STEP		"light_step"
#define TRAIT_SPIRITUAL			"spiritual"
#define TRAIT_FAN_CLOWN			"fan_clown"
#define TRAIT_FAN_MIME			"fan_mime"
#define TRAIT_VORACIOUS			"voracious"
#define TRAIT_SELF_AWARE		"self_aware"
#define TRAIT_FREERUNNING		"freerunning"
#define TRAIT_SKITTISH			"skittish"
#define TRAIT_POOR_AIM			"poor_aim"
#define TRAIT_PROSOPAGNOSIA		"prosopagnosia"
#define TRAIT_DRUNK_HEALING		"drunk_healing"
#define TRAIT_TAGGER			"tagger"
#define TRAIT_PHOTOGRAPHER		"photographer"
#define TRAIT_MUSICIAN			"musician"
#define TRAIT_LIGHT_DRINKER		"light_drinker"
#define TRAIT_EMPATH			"empath"
#define TRAIT_FRIENDLY			"friendly"
#define TRAIT_GRABWEAKNESS		"grab_weakness"
#define TRAIT_SNOB				"snob"
#define TRAIT_BALD				"bald"
#define TRAIT_BADTOUCH			"bad_touch"
#define TRAIT_EXTROVERT			"extrovert"
#define TRAIT_INTROVERT			"introvert"
#define TRAIT_FLOWER_LANGUAGE			"floriography"
#define TRAIT_FLOWER_LANGUAGE_JAPANESE	"hanakotoba"

///Trait for dryable items
#define TRAIT_DRYABLE "trait_dryable"
///Trait for dried items
#define TRAIT_DRIED "trait_dried"
//Trait for customizable reagent holder
#define TRAIT_CUSTOMIZABLE_REAGENT_HOLDER "customizable_reagent_holder"
/// Trait for allowing an item that isn't food into the customizable reagent holder
#define TRAIT_ODD_CUSTOMIZABLE_FOOD_INGREDIENT "odd_customizable_food_ingredient"

/// Used to prevent multiple floating blades from triggering over the same target
#define TRAIT_BEING_BLADE_SHIELDED "being_blade_shielded"

/// This mob doesn't count as looking at you if you can only act while unobserved
#define TRAIT_UNOBSERVANT "trait_unobservant"

/* Traits for ventcrawling.
 * Both give access to ventcrawling, but *_NUDE requires the user to be
 * wearing no clothes and holding no items. If both present, *_ALWAYS
 * takes precedence.
 */
#define TRAIT_VENTCRAWLER_ALWAYS "ventcrawler_always"
#define TRAIT_VENTCRAWLER_NUDE "ventcrawler_nude"

/// Trait put on [/mob/living/carbon/human]. If that mob has a crystal core, also known as an ethereal heart, it will not try to revive them if the mob dies.
#define TRAIT_CANNOT_CRYSTALIZE "cannot_crystalize"

///Trait applied to turfs when an atmos holosign is placed on them. It will stop firedoors from closing.
#define TRAIT_FIREDOOR_STOP "firedoor_stop"

///Trait applied to turf blocked by a containment field
#define TRAIT_CONTAINMENT_FIELD "containment_field"

/// Trait applied when the MMI component is added to an [/obj/item/integrated_circuit]
#define TRAIT_COMPONENT_MMI "component_mmi"

/// Trait applied when an integrated circuit/module becomes undupable
#define TRAIT_CIRCUIT_UNDUPABLE "circuit_undupable"

/// Trait applied when an integrated circuit opens a UI on a player (see list pick component)
#define TRAIT_CIRCUIT_UI_OPEN "circuit_ui_open"

/// PDA/ModPC Traits. This one makes PDAs explode if the user opens the messages menu
#define TRAIT_PDA_MESSAGE_MENU_RIGGED "pda_message_menu_rigged"
/// This one denotes a PDA has received a rigged message and will explode when the user tries to reply to a rigged PDA message
#define TRAIT_PDA_CAN_EXPLODE "pda_can_explode"
///The download speeds of programs from the dowloader is halved.
#define TRAIT_MODPC_HALVED_DOWNLOAD_SPEED "modpc_halved_download_speed"
///Dictates whether a user (source) is interacting with the frame of a stationary modular computer or the pc inside it. Needed for circuits I guess.
#define TRAIT_MODPC_INTERACTING_WITH_FRAME "modpc_interacting_with_frame"

/// If present on a [/mob/living/carbon], will make them appear to have a medium level disease on health HUDs.
#define TRAIT_DISEASELIKE_SEVERITY_MEDIUM "diseaselike_severity_medium"

/// trait denoting someone will crawl faster in soft crit
#define TRAIT_TENACIOUS "tenacious"

/// trait denoting someone will sometimes recover out of crit
#define TRAIT_UNBREAKABLE "unbreakable"

/// trait that prevents AI controllers from planning detached from ai_status to prevent weird state stuff.
#define TRAIT_AI_PAUSED "TRAIT_AI_PAUSED"

/// this is used to bypass tongue language restrictions but not tongue disabilities
#define TRAIT_TOWER_OF_BABEL "tower_of_babel"

/// This target has recently been shot by a marksman coin and is very briefly immune to being hit by one again to prevent recursion
#define TRAIT_RECENTLY_COINED "recently_coined"

/// Receives echolocation images.
#define TRAIT_ECHOLOCATION_RECEIVER "echolocation_receiver"
/// Echolocation has a higher range.
#define TRAIT_ECHOLOCATION_EXTRA_RANGE "echolocation_extra_range"

/// Trait given to a living mob and any observer mobs that stem from them if they suicide.
/// For clarity, this trait should always be associated/tied to a reference to the mob that suicided- not anything else.
#define TRAIT_SUICIDED "committed_suicide"

/// Trait given to a living mob to prevent wizards from making it immortal
#define TRAIT_PERMANENTLY_MORTAL "permanently_mortal"

///Trait given to a mob with a ckey currently in a temporary body, allowing people to know someone will re-enter the round later.
#define TRAIT_MIND_TEMPORARILY_GONE "temporarily_gone"

/// Similar trait given to temporary bodies inhabited by players
#define TRAIT_TEMPORARY_BODY "temporary_body"

/// Trait given to objects with the wallmounted component
#define TRAIT_WALLMOUNTED "wallmounted"

/// Trait given to mechs that can have orebox functionality on movement
#define TRAIT_OREBOX_FUNCTIONAL "orebox_functional"

///A trait for mechs that were created through the normal construction process, and not spawned by map or other effects.
#define TRAIT_MECHA_CREATED_NORMALLY "trait_mecha_created_normally"

///fish traits
#define TRAIT_RESIST_EMULSIFY "resist_emulsify"
#define TRAIT_FISH_SELF_REPRODUCE "fish_self_reproduce"
#define TRAIT_FISH_NO_MATING "fish_no_mating"
#define TRAIT_YUCKY_FISH "yucky_fish"
#define TRAIT_FISH_TOXIN_IMMUNE "fish_toxin_immune"
#define TRAIT_FISH_CROSSBREEDER "fish_crossbreeder"
#define TRAIT_FISH_AMPHIBIOUS "fish_amphibious"
///Trait needed for the lubefish evolution
#define TRAIT_FISH_FED_LUBE "fish_fed_lube"
#define TRAIT_FISH_NO_HUNGER "fish_no_hunger"
///It comes from a fish case. Relevant for bounties so far.
#define TRAIT_FISH_FROM_CASE "fish_from_case"

/// Trait given to angelic constructs to let them purge cult runes
#define TRAIT_ANGELIC "angelic"

/// Trait given to a dreaming carbon when they are currently doing dreaming stuff
#define TRAIT_DREAMING "currently_dreaming"

/// Whether bots will salute this mob.
#define TRAIT_COMMISSIONED "commissioned"

///generic atom traits
/// Trait from [/datum/element/rust]. Its rusty and should be applying a special overlay to denote this.
#define TRAIT_RUSTY "rust_trait"
/// Stops someone from splashing their reagent_container on an object with this trait
#define TRAIT_DO_NOT_SPLASH "do_not_splash"
/// Marks an atom when the cleaning of it is first started, so that the cleaning overlay doesn't get removed prematurely
#define TRAIT_CURRENTLY_CLEANING "currently_cleaning"
/// Objects with this trait are deleted if they fall into chasms, rather than entering abstract storage
#define TRAIT_CHASM_DESTROYED "chasm_destroyed"
/// Trait from being under the floor in some manner
#define TRAIT_UNDERFLOOR "underfloor"
/// If the movable shouldn't be reflected by mirrors.
#define TRAIT_NO_MIRROR_REFLECTION "no_mirror_reflection"
/// If this movable is currently treading in a turf with the immerse element.
#define TRAIT_IMMERSED "immersed"
/// From [/datum/element/elevation_core] for purpose of checking if the turf has the trait from an instance of the element
#define TRAIT_ELEVATED_TURF "elevated_turf"
/**
 * With this, the immerse overlay will give the atom its own submersion visual overlay
 * instead of one that's also shared with other movables, thus making editing its appearance possible.
 */
#define TRAIT_UNIQUE_IMMERSE "unique_immerse"

/// This item is currently under the control of telekinesis
#define TRAIT_TELEKINESIS_CONTROLLED "telekinesis_controlled"

/// changelings with this trait can no longer talk over the hivemind
#define TRAIT_CHANGELING_HIVEMIND_MUTE "ling_mute"
#define TRAIT_HULK "hulk"
/// Isn't attacked harmfully by blob structures
#define TRAIT_BLOB_ALLY "blob_ally"

///Traits given by station traits
#define STATION_TRAIT_ASSISTANT_GIMMICKS "station_trait_assistant_gimmicks"
#define STATION_TRAIT_BANANIUM_SHIPMENTS "station_trait_bananium_shipments"
#define STATION_TRAIT_BIGGER_PODS "station_trait_bigger_pods"
#define STATION_TRAIT_BIRTHDAY "station_trait_birthday"
#define STATION_TRAIT_BOTS_GLITCHED "station_trait_bot_glitch"
#define STATION_TRAIT_CARP_INFESTATION "station_trait_carp_infestation"
#define STATION_TRAIT_CYBERNETIC_REVOLUTION "station_trait_cybernetic_revolution"
#define STATION_TRAIT_EMPTY_MAINT "station_trait_empty_maint"
#define STATION_TRAIT_FILLED_MAINT "station_trait_filled_maint"
#define STATION_TRAIT_FORESTED "station_trait_forested"
#define STATION_TRAIT_HANGOVER "station_trait_hangover"
#define STATION_TRAIT_HUMAN_AI "station_trait_human_ai"
#define STATION_TRAIT_LATE_ARRIVALS "station_trait_late_arrivals"
#define STATION_TRAIT_LOANER_SHUTTLE "station_trait_loaner_shuttle"
#define STATION_TRAIT_MEDBOT_MANIA "station_trait_medbot_mania"
#define STATION_TRAIT_PDA_GLITCHED "station_trait_pda_glitched"
#define STATION_TRAIT_PREMIUM_INTERNALS "station_trait_premium_internals"
#define STATION_TRAIT_RADIOACTIVE_NEBULA "station_trait_radioactive_nebula"
#define STATION_TRAIT_RANDOM_ARRIVALS "station_trait_random_arrivals"
#define STATION_TRAIT_REVOLUTIONARY_TRASHING "station_trait_revolutionary_trashing"
#define STATION_TRAIT_SHUTTLE_SALE "station_trait_shuttle_sale"
#define STATION_TRAIT_SMALLER_PODS "station_trait_smaller_pods"
#define STATION_TRAIT_SPIDER_INFESTATION "station_trait_spider_infestation"
#define STATION_TRAIT_UNIQUE_AI "station_trait_unique_ai"
#define STATION_TRAIT_UNNATURAL_ATMOSPHERE "station_trait_unnatural_atmosphere"
#define STATION_TRAIT_VENDING_SHORTAGE "station_trait_vending_shortage"

///Deathmatch traits
#define TRAIT_DEATHMATCH_EXPLOSIVE_IMPLANTS "deathmath_explosive_implants"

/// This atom is currently spinning.
#define TRAIT_SPINNING "spinning"

/// This limb can't be torn open anymore
#define TRAIT_IMMUNE_TO_CRANIAL_FISSURE "immune_to_cranial_fissure"
/// Trait given if the mob has a cranial fissure.
#define TRAIT_HAS_CRANIAL_FISSURE "has_cranial_fissure"

/// Denotes that this id card was given via the job outfit, aka the first ID this player got.
#define TRAIT_JOB_FIRST_ID_CARD "job_first_id_card"
/// ID cards with this trait will attempt to forcibly occupy the front-facing ID card slot in wallets.
#define TRAIT_MAGNETIC_ID_CARD "magnetic_id_card"
/// ID cards with this trait have special appraisal text.
#define TRAIT_TASTEFULLY_THICK_ID_CARD "impressive_very_nice"
/// things with this trait are treated as having no access in /atom/movable/proc/check_access(obj/item)
#define TRAIT_ALWAYS_NO_ACCESS "alwaysnoaccess"

/// This human wants to see the color of their glasses, for some reason
#define TRAIT_SEE_GLASS_COLORS "see_glass_colors"

// Radiation defines

/// Marks that this object is irradiated
#define TRAIT_IRRADIATED "iraddiated"

/// Harmful radiation effects, the toxin damage and the burns, will not occur while this trait is active
#define TRAIT_HALT_RADIATION_EFFECTS "halt_radiation_effects"

/// This clothing protects the user from radiation.
/// This should not be used on clothing_traits, but should be applied to the clothing itself.
#define TRAIT_RADIATION_PROTECTED_CLOTHING "radiation_protected_clothing"

/// Whether or not this item will allow the radiation SS to go through standard
/// radiation processing as if this wasn't already irradiated.
/// Basically, without this, COMSIG_IN_RANGE_OF_IRRADIATION won't fire once the object is irradiated.
#define TRAIT_BYPASS_EARLY_IRRADIATED_CHECK "radiation_bypass_early_irradiated_check"

/// Simple trait that just holds if we came into growth from a specific mob type. Should hold a REF(src) to the type of mob that caused the growth, not anything else.
#define TRAIT_WAS_EVOLVED "was_evolved_from_the_mob_we_hold_a_textref_to"

// Traits to heal for

/// This mob heals from carp rifts.
#define TRAIT_HEALS_FROM_CARP_RIFTS "heals_from_carp_rifts"

/// This mob heals from cult pylons.
#define TRAIT_HEALS_FROM_CULT_PYLONS "heals_from_cult_pylons"

/// Ignore Crew monitor Z levels
#define TRAIT_MULTIZ_SUIT_SENSORS "multiz_suit_sensors"

/// Ignores body_parts_covered during the add_fingerprint() proc. Works both on the person and the item in the glove slot.
#define TRAIT_FINGERPRINT_PASSTHROUGH "fingerprint_passthrough"

/// this object has been frozen
#define TRAIT_FROZEN "frozen"

/// Currently fishing
#define TRAIT_GONE_FISHING "fishing"

/// Makes a species be better/worse at tackling depending on their wing's status
#define TRAIT_TACKLING_WINGED_ATTACKER "tacking_winged_attacker"

/// Makes a species be frail and more likely to roll bad results if they hit a wall
#define TRAIT_TACKLING_FRAIL_ATTACKER "tackling_frail_attacker"

/// Makes a species be better/worse at defending against tackling depending on their tail's status
#define TRAIT_TACKLING_TAILED_DEFENDER "tackling_tailed_defender"

/// Is runechat for this atom/movable currently disabled, regardless of prefs or anything?
#define TRAIT_RUNECHAT_HIDDEN "runechat_hidden"

/// the object has a label applied
#define TRAIT_HAS_LABEL "labeled"

/// Trait given to a mob that is currently thinking (giving off the "thinking" icon), used in an IC context
#define TRAIT_THINKING_IN_CHARACTER "currently_thinking_IC"

///without a human having this trait, they speak as if they have no tongue.
#define TRAIT_SPEAKS_CLEARLY "speaks_clearly"

// specific sources for TRAIT_SPEAKS_CLEARLY

///Trait given by /datum/component/germ_sensitive
#define TRAIT_GERM_SENSITIVE "germ_sensitive"

/// This atom can have spells cast from it if a mob is within it
/// This means the "caster" of the spell is changed to the mob's loc
/// Note this doesn't mean all spells are guaranteed to work or the mob is guaranteed to cast
#define TRAIT_CASTABLE_LOC "castable_loc"

///Trait given by /datum/element/relay_attacker
#define TRAIT_RELAYING_ATTACKER "relaying_attacker"

///Trait given to limb by /mob/living/basic/living_limb_flesh
#define TRAIT_IGNORED_BY_LIVING_FLESH "livingflesh_ignored"

/// Trait given while using /datum/action/cooldown/mob_cooldown/wing_buffet
#define TRAIT_WING_BUFFET "wing_buffet"
/// Trait given while tired after using /datum/action/cooldown/mob_cooldown/wing_buffet
#define TRAIT_WING_BUFFET_TIRED "wing_buffet_tired"
/// Trait given to a dragon who fails to defend their rifts
#define TRAIT_RIFT_FAILURE "fail_dragon_loser"

///trait determines if this mob can breed given by /datum/component/breeding
#define TRAIT_MOB_BREEDER "mob_breeder"
/// Trait given to mobs that we do not want to mindswap
#define TRAIT_NO_MINDSWAP "no_mindswap"
///trait given to food that can be baked by /datum/component/bakeable
#define TRAIT_BAKEABLE "bakeable"

/// Trait given to foam darts that have an insert in them
#define TRAIT_DART_HAS_INSERT "dart_has_insert"

/// Trait determines if this mob has examined an eldritch painting
#define TRAIT_ELDRITCH_PAINTING_EXAMINE "eldritch_painting_examine"

/// Trait used by the /datum/brain_trauma/severe/flesh_desire trauma to change their preferences of what they eat
#define TRAIT_FLESH_DESIRE "flesh_desire"

///Trait granted by janitor skillchip, allows communication with cleanbots
#define TRAIT_CLEANBOT_WHISPERER "cleanbot_whisperer"

///Trait granted by the miner skillchip, allows communication with minebots
#define TRAIT_ROCK_STONER "rock_stoner"

///Trait given by the regenerative shield component
#define TRAIT_REGEN_SHIELD "regen_shield"

/// Trait given when a mob is currently in invisimin mode
#define TRAIT_INVISIMIN "invisimin"

///Trait given when a mob has been tipped
#define TRAIT_MOB_TIPPED "mob_tipped"

/// Trait which self-identifies as an enemy of the law
#define TRAIT_ALWAYS_WANTED "always_wanted"

/// Trait given to mobs that have the basic eating element
#define TRAIT_MOB_EATER "mob_eater"
/// Trait which means whatever has this is dancing by a dance machine
#define TRAIT_DISCO_DANCER "disco_dancer"

/// That which allows mobs to instantly break down boulders.
#define TRAIT_INSTANTLY_PROCESSES_BOULDERS "instantly_processes_boulders"

/// Trait applied to objects and mobs that can attack a boulder and break it down. (See /obj/item/boulder/manual_process())
#define TRAIT_BOULDER_BREAKER "boulder_breaker"

/// Prevents the affected object from opening a loot window via alt click. See atom/AltClick()
#define TRAIT_ALT_CLICK_BLOCKER "no_alt_click"

// END TRAIT DEFINES
