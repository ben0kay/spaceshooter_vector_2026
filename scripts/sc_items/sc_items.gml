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

/// @description Returns the configured effectiveness multiplier of one item grade.
function sc_item_grade_multiplier_get(_grade)
{
    return global.config.crafting.grades[_grade].multiplier;
}

/// @description Rolls the grade of one crafted module or assembly.
function sc_item_crafted_grade_roll(_item)
{
    if (_item.layer < ItemLayer.MODULE) return undefined;

    var _grades = global.config.crafting.grades;
    var _roll = random(1);
    var _total = 0;

    for (var _grade = ItemGrade.PROTOTYPE; _grade >= ItemGrade.IMPROVED; --_grade)
    {
        _total += _grades[_grade].chance;
        if (_roll < _total) return _grade;
    }

    return ItemGrade.COMMON;
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

/// @description Registers the initial industrial production tree.
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
        identity: { key: "item_silicon", name: "Silicate Deposit" },
        layer: ItemLayer.RAW,
        description: "Raw silicate material suitable for semiconductor processing.",
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
        identity: { key: "item_refined_copper", name: "Refined Copper" },
        layer: ItemLayer.MATERIAL,
        description: "Purified conductive copper prepared for electrical manufacturing.",
        cargo: { weight: 3, stack_max: 50 },
        visual: { colour: make_colour_rgb(214, 119, 65), glow: make_colour_rgb(255, 171, 78), draw_script: sc_item_ingot_primitive_draw }
    })
    && sc_item_register({
        identity: { key: "item_silicon_wafer", name: "Silicon Wafer" },
        layer: ItemLayer.MATERIAL,
        description: "Processed semiconductor material used in electronic components.",
        cargo: { weight: 1, stack_max: 50 },
        visual: { colour: make_colour_rgb(95, 184, 173), glow: make_colour_rgb(69, 242, 218), draw_script: sc_item_plate_primitive_draw }
    })
    && sc_item_register({
        identity: { key: "item_carbon_composite", name: "Carbon Composite" },
        layer: ItemLayer.MATERIAL,
        description: "A lightweight structural material produced from processed carbon.",
        cargo: { weight: 2, stack_max: 50 },
        visual: { colour: make_colour_rgb(66, 82, 90), glow: make_colour_rgb(56, 190, 203), draw_script: sc_item_ingot_primitive_draw }
    })

    && sc_item_register({
        identity: { key: "item_iron_plate", name: "Iron Plate" },
        layer: ItemLayer.COMPONENT,
        description: "A standardized structural plate used in ship construction.",
        cargo: { weight: 6, stack_max: 30 },
        visual: { colour: make_colour_rgb(156, 174, 185), glow: make_colour_rgb(54, 154, 174), draw_script: sc_item_plate_primitive_draw }
    })
    && sc_item_register({
        identity: { key: "item_copper_wire", name: "Copper Wire" },
        layer: ItemLayer.COMPONENT,
        description: "Flexible conductive wiring used throughout electrical systems.",
        cargo: { weight: 2, stack_max: 50 },
        visual: { colour: make_colour_rgb(205, 104, 53), glow: make_colour_rgb(255, 168, 76), draw_script: sc_item_plate_primitive_draw }
    })
    && sc_item_register({
        identity: { key: "item_copper_coil", name: "Copper Coil" },
        layer: ItemLayer.COMPONENT,
        description: "A wound conductive coil used in motors and power systems.",
        cargo: { weight: 4, stack_max: 30 },
        visual: { colour: make_colour_rgb(190, 91, 48), glow: make_colour_rgb(255, 156, 55), draw_script: sc_item_ingot_primitive_draw }
    })
    && sc_item_register({
        identity: { key: "item_circuit_board", name: "Circuit Board" },
        layer: ItemLayer.COMPONENT,
        description: "A programmable electronic board used to control ship systems.",
        cargo: { weight: 2, stack_max: 30 },
        visual: { colour: make_colour_rgb(50, 134, 112), glow: make_colour_rgb(44, 239, 205), draw_script: sc_item_plate_primitive_draw }
    })
    && sc_item_register({
        identity: { key: "item_motor", name: "Motor" },
        layer: ItemLayer.COMPONENT,
        description: "A compact electromechanical motor used in moving assemblies.",
        cargo: { weight: 7, stack_max: 20 },
        visual: { colour: make_colour_rgb(116, 136, 148), glow: make_colour_rgb(223, 131, 58), draw_script: sc_item_ingot_primitive_draw }
    })

    && sc_item_register({
        identity: { key: "item_armour_plate", name: "Armour Plate" },
        layer: ItemLayer.MODULE,
        description: "A complete reinforced armour assembly fitted over the ship hull.",
        cargo: { weight: 18, stack_max: 10 },
        module: { slot: ModuleSlot.ARMOUR, effectiveness: 1, install_duration: 300 },
        visual: { colour: make_colour_rgb(126, 158, 171), glow: make_colour_rgb(0, 224, 235), draw_script: sc_item_armour_primitive_draw }
    })
    && sc_item_register({
        identity: { key: "item_lightweight_armour_plate", name: "Lightweight Armour Plate" },
        layer: ItemLayer.MODULE,
        description: "Light composite armour providing reduced protection with considerably less mass.",
        cargo: { weight: 11, stack_max: 10 },
        module: { slot: ModuleSlot.ARMOUR, effectiveness: 0.85, install_duration: 240 },
        visual: { colour: make_colour_rgb(66, 102, 112), glow: make_colour_rgb(40, 235, 221), draw_script: sc_item_armour_primitive_draw }
    })
    && sc_item_register({
        identity: { key: "item_radar_array", name: "Radar Array" },
        layer: ItemLayer.MODULE,
        description: "A complete sensor and signal-processing module for ship targeting systems.",
        cargo: { weight: 12, stack_max: 10 },
        module: { slot: ModuleSlot.TARGETING, effectiveness: 1, install_duration: 300 },
        visual: { colour: make_colour_rgb(71, 115, 132), glow: make_colour_rgb(38, 231, 243), draw_script: sc_item_plate_primitive_draw }
        })
    && sc_item_register({
        identity: { key: "item_scanning_drone", name: "Scanning Drone" },
        layer: ItemLayer.ASSEMBLY,
        description: "A compact autonomous drone equipped with short-range scanning equipment.",
        cargo: { weight: 8, stack_max: 5 },
        visual: { colour: make_colour_rgb(86, 142, 156), glow: make_colour_rgb(0, 235, 245), draw_script: sc_item_plate_primitive_draw }
    });
}