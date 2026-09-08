/*
ITEM DATA

Items define cargo mass, manufacturing layer, description and fallback visuals.
Asteroids, recipes, pickups and inventory reference items by key.
*/

/// @description Returns the readable name of one item grade.
function sc_item_grade_name_get(_grade)
{
    switch (_grade)
    {
        case ItemGrade.COMMON: return "COMMON";
        case ItemGrade.IMPROVED: return "IMPROVED";
        case ItemGrade.ADVANCED: return "ADVANCED";
        case ItemGrade.SUPERIOR: return "SUPERIOR";
        case ItemGrade.PROTOTYPE: return "PROTOTYPE";
    }

    return "COMMON";
}

/// @description Returns the display colour of one item grade.
function sc_item_grade_colour_get(_grade)
{
    switch (_grade)
    {
        case ItemGrade.COMMON: return make_colour_rgb(220, 232, 235);
        case ItemGrade.IMPROVED: return make_colour_rgb(45, 235, 225);
        case ItemGrade.ADVANCED: return make_colour_rgb(65, 135, 255);
        case ItemGrade.SUPERIOR: return make_colour_rgb(180, 80, 255);
        case ItemGrade.PROTOTYPE: return make_colour_rgb(255, 184, 55);
    }

    return c_white;
}

/// @description Returns the effectiveness multiplier of one item grade.
function sc_item_grade_multiplier_get(_grade)
{
    switch (_grade)
    {
        case ItemGrade.COMMON: return 1;
        case ItemGrade.IMPROVED: return 1.02;
        case ItemGrade.ADVANCED: return 1.04;
        case ItemGrade.SUPERIOR: return 1.07;
        case ItemGrade.PROTOTYPE: return 1.1;
    }

    return 1;
}

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

/// @description Returns a readable manufacturing-layer name.
function sc_item_layer_name_get(_layer)
{
    switch (_layer)
    {
        case ItemLayer.RAW: return "RAW RESOURCE";
        case ItemLayer.MATERIAL: return "PROCESSED MATERIAL";
        case ItemLayer.COMPONENT: return "CONSTRUCTION COMPONENT";
        case ItemLayer.MODULE: return "FUNCTIONAL MODULE";
        case ItemLayer.ASSEMBLY: return "COMPLETE ASSEMBLY";
    }

    return "UNCLASSIFIED ITEM";
}

/// @description Registers initial resources and the first iron production chain.
function sc_item_register_all()
{
    return sc_item_register({
        identity: { key: "item_carbon", name: "Carbon Ore" },
        layer: ItemLayer.RAW,
        description: "Unprocessed carbon-rich material recovered from asteroid deposits.",
        cargo: { weight: 1, stack_max: 99 },
        visual: { colour: make_colour_rgb(104, 143, 158), glow: make_colour_rgb(39, 118, 150), draw_script: sc_item_raw_primitive_draw }
    })
    && sc_item_register({
        identity: { key: "item_iron", name: "Iron Ore" },
        layer: ItemLayer.RAW,
        description: "Dense unprocessed iron ore suitable for industrial refining.",
        cargo: { weight: 1, stack_max: 99 },
        visual: { colour: make_colour_rgb(194, 205, 211), glow: make_colour_rgb(83, 116, 133), draw_script: sc_item_raw_primitive_draw }
    })
    && sc_item_register({
        identity: { key: "item_copper", name: "Copper Ore" },
        layer: ItemLayer.RAW,
        description: "Conductive copper-bearing ore recovered from asteroid deposits.",
        cargo: { weight: 1, stack_max: 99 },
        visual: { colour: make_colour_rgb(229, 132, 66), glow: make_colour_rgb(51, 139, 123), draw_script: sc_item_raw_primitive_draw }
    })
    && sc_item_register({
        identity: { key: "item_silicon", name: "Silicon" },
        layer: ItemLayer.RAW,
        description: "Raw silicon material used in advanced electrical manufacturing.",
        cargo: { weight: 1, stack_max: 99 },
        visual: { colour: make_colour_rgb(119, 225, 184), glow: make_colour_rgb(41, 155, 112), draw_script: sc_item_raw_primitive_draw }
    })
    && sc_item_register({
        identity: { key: "item_titanium", name: "Titanium Ore" },
        layer: ItemLayer.RAW,
        description: "Strong lightweight ore requiring advanced industrial processing.",
        cargo: { weight: 1, stack_max: 99 },
        visual: { colour: make_colour_rgb(188, 225, 243), glow: make_colour_rgb(61, 139, 193), draw_script: sc_item_raw_primitive_draw }
    })
    && sc_item_register({
        identity: { key: "item_crystal", name: "Crystal" },
        layer: ItemLayer.RAW,
        description: "An unusual energy-reactive crystalline resource.",
        cargo: { weight: 1, stack_max: 99 },
        visual: { colour: make_colour_rgb(105, 239, 255), glow: make_colour_rgb(148, 61, 231), draw_script: sc_item_raw_primitive_draw }
    })
    && sc_item_register({
        identity: { key: "item_ice", name: "Ice" },
        layer: ItemLayer.RAW,
        description: "Frozen volatile material with life-support and fuel-processing uses.",
        cargo: { weight: 1, stack_max: 99 },
        visual: { colour: make_colour_rgb(214, 252, 255), glow: make_colour_rgb(45, 188, 229), draw_script: sc_item_raw_primitive_draw }
    })
    && sc_item_register({
        identity: { key: "item_refined_iron", name: "Refined Iron" },
        layer: ItemLayer.MATERIAL,
        description: "Purified iron produced by refining raw iron ore.",
        cargo: { weight: 3, stack_max: 50 },
        visual: { colour: make_colour_rgb(174, 188, 198), glow: make_colour_rgb(62, 137, 162), draw_script: sc_item_ingot_primitive_draw }
    })
    && sc_item_register({
        identity: { key: "item_iron_plate", name: "Iron Plate" },
        layer: ItemLayer.COMPONENT,
        description: "A standardized structural plate used in ship construction.",
        cargo: { weight: 6, stack_max: 30 },
        visual: { colour: make_colour_rgb(156, 174, 185), glow: make_colour_rgb(54, 154, 174), draw_script: sc_item_plate_primitive_draw }
    })
    && sc_item_register({
	    identity: { key: "item_armour_plate", name: "Armour Plate" },
	    layer: ItemLayer.MODULE,
	    description: "A complete reinforced armour assembly fitted over the ship hull.",
	    cargo: { weight: 18, stack_max: 10 },
	    module: { slot: ModuleSlot.ARMOUR, effectiveness: 1, install_duration: 300 },
	    visual: { colour: make_colour_rgb(126, 158, 171), glow: make_colour_rgb(0, 224, 235), draw_script: sc_item_armour_primitive_draw }
	});
}