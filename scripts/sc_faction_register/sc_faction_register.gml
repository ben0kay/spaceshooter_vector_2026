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

/// @description Registers the Simulant faction and visual language.
function sc_faction_register_simulant()
{
    return sc_faction_register(Faction.SIMULANT, {
        identity: { name: "Simulant" },

        palette: {
            void: make_colour_rgb(6, 4, 10),
            hull_dark: make_colour_rgb(16, 14, 23),
            hull_mid: make_colour_rgb(34, 31, 45),
            hull_light: make_colour_rgb(62, 59, 75),
            metal: make_colour_rgb(105, 103, 118),

            outline: make_colour_rgb(86, 82, 102),
            accent: make_colour_rgb(108, 55, 240),
            energy: make_colour_rgb(150, 80, 255),
            core: make_colour_rgb(225, 205, 255),
            glow: make_colour_rgb(85, 35, 200)
        }
    });
}