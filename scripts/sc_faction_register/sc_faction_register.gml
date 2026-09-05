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
		    movement_script: sc_enemy_movement_flee_away,
		    speed_scale: 1,
		    sway_amount: 4,
		    sway_speed: 0.025
		}
			
		},
    });
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
    chance: 0.4,
    trigger_layer: DefenceLayer.HULL,
    trigger_ratio: 0.3,
    max_attempts: 1,
    cooldown: 300,
    movement_script: sc_enemy_movement_flee_away,
    speed_scale: 1,
    sway_amount: 14,
    sway_speed: 0.04
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
