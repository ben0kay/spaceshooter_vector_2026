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
            void: make_colour_rgb(7, 4, 12),
            hull_dark: make_colour_rgb(17, 3, 28),
            hull_mid: make_colour_rgb(35, 8, 55),
            outline: make_colour_rgb(140, 45, 255),
            accent: make_colour_rgb(255, 45, 190),
            energy: make_colour_rgb(185, 70, 255),
            core: make_colour_rgb(230, 185, 255),
            glow: make_colour_rgb(105, 25, 190)
        }
    });
}