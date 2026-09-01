/// @description Registers one faction definition.
function sc_faction_register(_faction, _data)
{
    if (!is_undefined(global.data.factions[_faction]))
    {
        show_debug_message("FACTION REGISTRATION ERROR - duplicate faction: " + string(_faction));
        return false;
    }

    global.data.factions[_faction] = _data;
    return true;
}

/// @description Returns one registered faction palette.
function sc_faction_palette_get(_faction)
{
    return global.data.factions[_faction].palette;
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