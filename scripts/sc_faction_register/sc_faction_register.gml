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

		    flee: {
    chance: 0.05,
    trigger_layer: DefenceLayer.HULL,
    trigger_ratio: 0.1,
    max_attempts: 1,
    cooldown: 300,
    speed_scale: 1,
    sway_amount: 4,
    sway_speed: 0.025,

    targets: [
        {
            key: "leave_map",
            weight: 100,
            target_script: sc_enemy_flee_target_map,
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

        palette: {
            void: make_colour_rgb(9, 13, 20),
            hull_dark: make_colour_rgb(38, 47, 59),
            hull_mid: make_colour_rgb(100, 112, 126),
            hull_light: make_colour_rgb(190, 198, 207),
            metal: make_colour_rgb(225, 230, 235),

            outline: make_colour_rgb(65, 77, 92),
            accent: make_colour_rgb(35, 94, 214),
            energy: make_colour_rgb(52, 132, 255),
            core: make_colour_rgb(202, 229, 255),
            glow: make_colour_rgb(18, 82, 224)
        },

        palette_elite: {
            void: make_colour_rgb(4, 7, 12),
            hull_dark: make_colour_rgb(15, 22, 31),
            hull_mid: make_colour_rgb(39, 49, 62),
            hull_light: make_colour_rgb(100, 111, 124),
            metal: make_colour_rgb(174, 183, 193),

            outline: make_colour_rgb(62, 76, 94),
            accent: make_colour_rgb(29, 78, 190),
            energy: make_colour_rgb(47, 119, 255),
            core: make_colour_rgb(210, 233, 255),
            glow: make_colour_rgb(13, 62, 204)
        },

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

		    flee: {
    chance: 0.3,
    trigger_layer: DefenceLayer.HULL,
    trigger_ratio: 0.6,
    max_attempts: 2,
    cooldown: 300,
    speed_scale: 1,
    sway_amount: 5,
    sway_speed: 0.025,

    targets: [
        {
            key: "larger_ally",
            weight: 60,
            range: 2400,
            arrival_margin: 96,
            target_script: sc_enemy_flee_target_larger_ally,
            movement_script: sc_enemy_movement_flee_toward_ally,
            arrival_script: sc_enemy_flee_arrive_shelter
        },
        {
            key: "leave_map",
            weight: 40,
            target_script: sc_enemy_flee_target_map,
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
            void: make_colour_rgb(15, 12, 10),
            hull_dark: make_colour_rgb(43, 38, 32),
            hull_mid: make_colour_rgb(91, 78, 61),
            hull_light: make_colour_rgb(151, 132, 99),
            metal: make_colour_rgb(184, 166, 128),

            outline: make_colour_rgb(211, 184, 132),
            accent: make_colour_rgb(202, 105, 35),
            energy: make_colour_rgb(255, 151, 49),
            core: make_colour_rgb(255, 222, 147),
            glow: make_colour_rgb(176, 59, 16)
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

		    flee: {
    chance: 1,
    trigger_layer: DefenceLayer.HULL,
    trigger_ratio: 0.9,
    max_attempts: 1,
    cooldown: 300,
    speed_scale: 1,
    sway_amount: 14,
    sway_speed: 0.04,

    targets: [
        {
            key: "larger_ally",
            weight: 5,
            range: 1600,
            arrival_margin: 128,
            target_script: sc_enemy_flee_target_larger_ally,
            movement_script: sc_enemy_movement_flee_toward_ally,
            arrival_script: sc_enemy_flee_arrive_shelter
        },
        {
            key: "leave_map",
            weight: 95,
            target_script: sc_enemy_flee_target_map,
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
