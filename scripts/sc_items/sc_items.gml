/*
RESOURCE ITEM DATA

Items define cargo behaviour and pickup appearance.
Asteroids reference items by key without owning inventory logic.
*/

/// @description Registers one cargo item.
function sc_item_register(_data)
{
    var _key = _data.identity.key;

    if (variable_struct_exists(global.data.items, _key))
    {
        show_debug_message("ITEM REGISTRATION ERROR - duplicate key: " + _key);
        return false;
    }

    variable_struct_set(global.data.items, _key, _data);
    return true;
}

/// @description Registers the initial asteroid resources.
function sc_item_register_all()
{
    return sc_item_register({
        identity: { key: "item_carbon", name: "Carbon" },
        cargo: { weight: 1, stack_max: 99 },
        visual: { colour: make_colour_rgb(104, 143, 158), glow: make_colour_rgb(39, 118, 150) }
    })
    && sc_item_register({
        identity: { key: "item_iron", name: "Iron" },
        cargo: { weight: 1, stack_max: 99 },
        visual: { colour: make_colour_rgb(194, 205, 211), glow: make_colour_rgb(83, 116, 133) }
    })
    && sc_item_register({
        identity: { key: "item_copper", name: "Copper" },
        cargo: { weight: 1, stack_max: 99 },
        visual: { colour: make_colour_rgb(229, 132, 66), glow: make_colour_rgb(51, 139, 123) }
    })
    && sc_item_register({
        identity: { key: "item_silicon", name: "Silicon" },
        cargo: { weight: 1, stack_max: 99 },
        visual: { colour: make_colour_rgb(119, 225, 184), glow: make_colour_rgb(41, 155, 112) }
    })
    && sc_item_register({
        identity: { key: "item_titanium", name: "Titanium" },
        cargo: { weight: 1, stack_max: 99 },
        visual: { colour: make_colour_rgb(188, 225, 243), glow: make_colour_rgb(61, 139, 193) }
    })
    && sc_item_register({
        identity: { key: "item_crystal", name: "Crystal" },
        cargo: { weight: 1, stack_max: 99 },
        visual: { colour: make_colour_rgb(105, 239, 255), glow: make_colour_rgb(148, 61, 231) }
    })
    && sc_item_register({
        identity: { key: "item_ice", name: "Ice" },
        cargo: { weight: 1, stack_max: 99 },
        visual: { colour: make_colour_rgb(214, 252, 255), glow: make_colour_rgb(45, 188, 229) }
    });
}