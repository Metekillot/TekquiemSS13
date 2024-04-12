import { BooleanLike } from 'common/react';

import { Region } from '../common/AccessConfig';

export type AccessData = {
  name: string;
  number: number;
};

type MechElectronics = {
  microphone: boolean;
  speaker: boolean;
  frequency: number;
  minfreq: number;
  maxfreq: number;
};

export type MechWeapon = {
  name: string;
  desc: string;
  ref: string;
  isballisticweapon: boolean;
  integrity: number;
  energy_per_use: number;
  // null when not ballistic weapon
  disabledreload: boolean | null;
  projectiles: number | null;
  max_magazine: number | null;
  projectiles_cache: number | null;
  projectiles_cache_max: number | null;
  ammo_type: string | null;
  // first entry is always "snowflake_id"=snowflake_id if snowflake
  snowflake: any;
};

export type MainData = {
  isoperator: boolean;
};

export type MaintData = {
  name: string;
  mecha_flags: number;
  mechflag_keys: string[];
  internal_tank_valve: number;
  cell: string;
  scanning: string;
  capacitor: string;
  operation_req_access: AccessData[];
  idcard_access: AccessData[];
};

export type OperatorData = {
  name: string;
  integrity: number;
  power_level: number | null;
  power_max: number | null;
  mecha_flags: number;
  internal_damage: number;
  internal_damage_keys: string[];
  airtank_present: BooleanLike;
  air_source: string;
  mechflag_keys: string[];

  can_use_overclock: BooleanLike;
  overclock_safety_available: BooleanLike;
  overclock_safety: BooleanLike;
  overclock_mode: BooleanLike;
  overclock_temp_percentage: number;

  one_access: BooleanLike;
  regions: Region[];
  accesses: string[];

  servo_rating: number;
  scanmod_rating: number;
  capacitor_rating: number;

  cabin_pressure_warning_min: number;
  cabin_pressure_hazard_min: number;
  cabin_pressure_warning_max: number;
  cabin_pressure_hazard_max: number;
  cabin_temp_warning_min: number;
  cabin_temp_hazard_min: number;
  cabin_temp_warning_max: number;
  cabin_temp_hazard_max: number;

  one_atmosphere: number;
  cabin_pressure: number;
  cabin_temp: number;
  dna_lock: string | null;
  mech_electronics: MechElectronics;
  right_arm_weapon: MechWeapon | null;
  left_arm_weapon: MechWeapon | null;
  weapons_safety: boolean;
  mech_equipment: string[];
  mech_view: string;
  mineral_material_amount: number;
};

export type MechaUtility = {
  name: string;
  ref: string;
  snowflake: any;
};
