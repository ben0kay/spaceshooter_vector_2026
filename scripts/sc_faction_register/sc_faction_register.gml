/// @description Registers one faction definition.
function sc_faction_register(_faction, _data)
{
    var _factions = global.data.factions;

    if (!is_undefined(_factions[_faction]))
    {
        show_debug_message(
            "FACTION REGISTRATION ERROR - duplicate faction: "
            + string(_faction)
        );

        return false;
    }

    _factions[_faction] = _data;
    global.data.factions = _factions;

    return true;
}

function sc_faction_register_player()
{
    return sc_faction_register(Faction.PLAYER,{
        identity:{name:"Player"},

        palette:{
            void: make_colour_rgb(2,7,12),
            hull_dark: make_colour_rgb(10,23,31),
            hull_mid: make_colour_rgb(28,56,68),
            hull_light: make_colour_rgb(75,126,140),
            metal: make_colour_rgb(175,220,228),

            outline: make_colour_rgb(45,105,120),
            accent: make_colour_rgb(25,135,255),
            energy: make_colour_rgb(25,225,255),
            core: make_colour_rgb(220,255,255),
            glow: make_colour_rgb(0,115,195),

            warning: make_colour_rgb(232,151,38)
        }
    });
}


/// @description Registers the Simulant faction and visual language.
function sc_faction_register_simulant()
{
    return sc_faction_register(Faction.SIMULANT, {
        identity: { name: "Simulant" },

        palette: {
            void: make_colour_rgb(4, 2, 8),
            hull_dark: make_colour_rgb(13, 10, 20),
            hull_mid: make_colour_rgb(28, 23, 40),
            hull_light: make_colour_rgb(56, 47, 76),
            metal: make_colour_rgb(124, 112, 150),

            outline: make_colour_rgb(102, 86, 138),
            accent: make_colour_rgb(132, 66, 255),
            energy: make_colour_rgb(184, 94, 255),
            core: make_colour_rgb(243, 224, 255),
            glow: make_colour_rgb(106, 42, 224)
        },
		
		damage_fx: {
		    emit_script: sc_particles_enemy_damage_smoke_emit,
		    colour_light: make_colour_rgb(92, 78, 112),
		    colour_dark: make_colour_rgb(18, 13, 25)
		},
		
		doctrine: {
		    alert: {
		        chance: 0,
		        on_detection: false,
		        on_damage: false,
				max_attempts: 1,
				cooldown: 300,
				memory_duration: 300
		    },

			engagement: {
                chance: 1,
                reject_cooldown: 300,
                retaliation_script: sc_enemy_engagement_retaliate_default,
				
				retarget: {
                    script: sc_enemy_engagement_retarget_closer,
                    interval: 40,
                    distance_ratio: 0.65
                }
            },

		    critical_response: {
    chance: 0.05,
    trigger_layer: DefenceLayer.HULL,
    trigger_ratio: 0.1,
    max_attempts: 1,
    cooldown: 300,
    speed_scale: 1,
    sway_amount: 4,
    sway_speed: 0.025,

    responses: [
        {
            response: EnemyCriticalResponse.FLEE,
            weight: 100,
            target_script: sc_enemy_critical_response_target_map,
            movement_script: sc_enemy_movement_flee_away,
            arrival_script: sc_enemy_flee_arrive_map
        }
    ]
}
			
		},
    });
}

/// @description Registers the Corporation faction with standard and elite military palettes.
function sc_faction_register_corporation()
{
    return sc_faction_register(Faction.CORPORATION, {
        identity: { name: "Corp Syndicate" },

        palette_standard: {
    void: make_colour_rgb(4, 8, 13),

    hull_dark: make_colour_rgb(22, 31, 42),
    hull_mid: make_colour_rgb(70, 82, 96),
    hull_light: make_colour_rgb(178, 186, 194),
    metal: make_colour_rgb(224, 228, 232),

    outline: make_colour_rgb(44, 58, 74),

    armour_dark: make_colour_rgb(32, 42, 54),
    armour_mid: make_colour_rgb(118, 129, 141),
    armour_light: make_colour_rgb(214, 219, 224),

    recess: make_colour_rgb(8, 14, 21),
    trim: make_colour_rgb(90, 106, 124),
    decal: make_colour_rgb(126, 145, 166),

    accent: make_colour_rgb(32, 96, 220),
    energy: make_colour_rgb(34, 128, 255),
    sensor: make_colour_rgb(78, 170, 255),
    core: make_colour_rgb(220, 241, 255),
    glow: make_colour_rgb(16, 74, 220)
}

        palette_elite: {
    void: make_colour_rgb(3, 7, 12),

    hull_dark: make_colour_rgb(18, 27, 37),
    hull_mid: make_colour_rgb(62, 74, 89),
    hull_light: make_colour_rgb(188, 196, 204),
    metal: make_colour_rgb(232, 236, 240),

    outline: make_colour_rgb(38, 52, 68),

    armour_dark: make_colour_rgb(28, 38, 50),
    armour_mid: make_colour_rgb(126, 138, 150),
    armour_light: make_colour_rgb(222, 227, 232),

    recess: make_colour_rgb(7, 12, 19),
    trim: make_colour_rgb(96, 114, 134),
    decal: make_colour_rgb(134, 154, 178),

    accent: make_colour_rgb(26, 104, 232),
    energy: make_colour_rgb(36, 138, 255),
    sensor: make_colour_rgb(90, 182, 255),
    core: make_colour_rgb(230, 246, 255),
    glow: make_colour_rgb(14, 82, 228)
}

        damage_fx: {
            emit_script: sc_particles_enemy_damage_smoke_emit,
            colour_light: make_colour_rgb(74, 87, 103),
            colour_dark: make_colour_rgb(12, 18, 26)
        },
		
		doctrine: {
		    alert: {
		        chance: 0.7,
		        on_detection: true,
		        on_damage: true,
				max_attempts: 3,
				cooldown: 300,
				memory_duration: 600
		    },
			
			engagement: {
                chance: 0.9,
                reject_cooldown: 600,
                retaliation_script: sc_enemy_engagement_retaliate_default,
				
				retarget: {
                    script: sc_enemy_engagement_retarget_closer,
                    interval: 30,
                    distance_ratio: 0.75
                }
            },

		    critical_response: {
    chance: 0.9,
    trigger_layer: DefenceLayer.HULL,
    trigger_ratio: 0.6,
    max_attempts: 2,
    cooldown: 300,
    speed_scale: 1,
    sway_amount: 5,
    sway_speed: 0.025,

    responses: [
        {
            response: EnemyCriticalResponse.RETREAT,
            weight: 95,
            range: 12000,
            arrival_margin: 96,
            preferred_role: EnemyRole.SUPPORT,
            preferred_class: EnemyClass.SUPERHEAVY,
            target_script: sc_enemy_critical_response_target_larger_ally,
            movement_script: sc_enemy_movement_retreat_toward_ally,
            arrival_script: sc_enemy_retreat_arrive_shelter
        },
        {
            response: EnemyCriticalResponse.FLEE,
            weight: 5,
            target_script: sc_enemy_critical_response_target_map,
            movement_script: sc_enemy_movement_flee_away,
            arrival_script: sc_enemy_flee_arrive_map
        }
    ]
}
			
		},
    });
}

/// @description Returns one registered faction's optional elite palette.
function sc_faction_palette_elite_get(_faction)
{
    var _factions = global.data.factions;

    if (_faction < 0 || _faction >= array_length(_factions))
    {
        show_debug_message(
            "FACTION ELITE PALETTE ERROR - invalid faction: "
            + string(_faction)
        );

        return undefined;
    }

    var _data = _factions[_faction];

    if (!is_struct(_data)
    || !variable_struct_exists(_data, "palette_elite"))
    {
        show_debug_message(
            "FACTION ELITE PALETTE ERROR - palette unavailable: "
            + string(_faction)
        );

        return undefined;
    }

    return _data.palette_elite;
}

/// @description Registers the Rebel faction and battered industrial visual language.
function sc_faction_register_rebel()
{
    return sc_faction_register(Faction.REBEL, {
        identity: { name: "Rebel" },

                palette: {
            void: make_colour_rgb(12, 12, 11),
            hull_dark: make_colour_rgb(39, 37, 33),
            hull_mid: make_colour_rgb(83, 76, 64),
            hull_light: make_colour_rgb(151, 137, 110),
            metal: make_colour_rgb(158, 153, 141),

            outline: make_colour_rgb(27, 27, 25),
            accent: make_colour_rgb(175, 78, 27),
            energy: make_colour_rgb(255, 143, 38),
            core: make_colour_rgb(255, 220, 146),
            glow: make_colour_rgb(167, 53, 14),

            steel_dark: make_colour_rgb(47, 48, 46),
            steel_mid: make_colour_rgb(91, 91, 84),
            steel_light: make_colour_rgb(184, 180, 165),
            paint: make_colour_rgb(126, 105, 73),
            warning: make_colour_rgb(207, 148, 29),
            decal: make_colour_rgb(211, 207, 188),
            rust: make_colour_rgb(111, 57, 31)
        },
		
		damage_fx: {
		    emit_script: sc_particles_enemy_damage_smoke_emit,
		    colour_light: make_colour_rgb(105, 98, 86),
		    colour_dark: make_colour_rgb(30, 25, 20)
		},	
		
		doctrine: {
		    alert: {
		        chance: 1,
		        on_detection: false,
		        on_damage: true,
				max_attempts: 1,
				cooldown: 300,
				memory_duration: 300
		    },
				
			engagement: {
                chance: 0.7,
                reject_cooldown: 600,
                retaliation_script: sc_enemy_engagement_retaliate_default,
				
				retarget: {
                    script: sc_enemy_engagement_retarget_closer,
                    interval: 45,
                    distance_ratio: 0.7
                }
            },

		    critical_response: {
    chance: 1,
    trigger_layer: DefenceLayer.HULL,
    trigger_ratio: 0.9,
    max_attempts: 1,
    cooldown: 300,
    speed_scale: 1,
    sway_amount: 14,
    sway_speed: 0.04,

    responses: [
        {
            response: EnemyCriticalResponse.RETREAT,
            weight: 5,
            range: 1600,
            arrival_margin: 128,
            target_script: sc_enemy_critical_response_target_larger_ally,
            movement_script: sc_enemy_movement_retreat_toward_ally,
            arrival_script: sc_enemy_retreat_arrive_shelter
        },
        {
            response: EnemyCriticalResponse.FLEE,
            weight: 95,
            target_script: sc_enemy_critical_response_target_map,
            movement_script: sc_enemy_movement_flee_away,
            arrival_script: sc_enemy_flee_arrive_map
        }
    ]
}

		},
    });
}

/// @description Returns one registered faction palette.
function sc_faction_palette_get(_faction)
{
    var _factions = global.data.factions;

    if (_faction < 0 || _faction >= array_length(_factions))
    {
        show_debug_message(
            "FACTION PALETTE ERROR - invalid faction: "
            + string(_faction)
        );

        return undefined;
    }

    var _data = _factions[_faction];

    if (!is_struct(_data))
    {
        show_debug_message(
            "FACTION PALETTE ERROR - faction not registered: "
            + string(_faction)
        );

        return undefined;
    }

    return _data.palette;
}

/// @description Returns one faction's shared low-hull visual effect.
function sc_faction_damage_fx_get(_faction)
{
    var _factions = global.data.factions;

    if (_faction < 0 || _faction >= array_length(_factions))
    {
        show_debug_message("FACTION DAMAGE FX ERROR - invalid faction: " + string(_faction));
        return undefined;
    }

    var _data = _factions[_faction];

    if (!is_struct(_data) || !variable_struct_exists(_data, "damage_fx"))
    {
        show_debug_message("FACTION DAMAGE FX ERROR - effect unavailable: " + string(_faction));
        return undefined;
    }

    return _data.damage_fx;
}

/// @description Returns one registered faction's shared behaviour doctrine.
function sc_faction_doctrine_get(_faction)
{
    var _factions = global.data.factions;

    if (_faction < 0 || _faction >= array_length(_factions))
    {
        show_debug_message("FACTION DOCTRINE ERROR - invalid faction: " + string(_faction));
        return undefined;
    }

    var _data = _factions[_faction];

    if (!is_struct(_data) || !variable_struct_exists(_data, "doctrine"))
    {
        show_debug_message("FACTION DOCTRINE ERROR - doctrine unavailable: " + string(_faction));
        return undefined;
    }

    return _data.doctrine;
}
