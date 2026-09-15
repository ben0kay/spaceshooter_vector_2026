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
    return GCFG.crafting.grades[_grade].multiplier;
}

/// @description Returns whether an item has at least one explicitly grade-scaled equipment modifier.
function sc_item_grade_supported(_item)
{
    if (!variable_struct_exists(_item,"equipment")
    || !variable_struct_exists(_item.equipment,"modifiers"))
        return false;

    var _modifiers = _item.equipment.modifiers;

    for (var _i = 0; _i < array_length(_modifiers); ++_i)
    {
        var _modifier = _modifiers[_i];

        if (variable_struct_exists(_modifier,"grade_scaled")
        && _modifier.grade_scaled)
            return true;
    }

    return false;
}

/// @description Rolls the grade of one crafted graded item.
function sc_item_crafted_grade_roll(_item)
{
    if (!sc_item_grade_supported(_item)) return undefined;

    var _grades = GCFG.crafting.grades;
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
        case ItemLayer.REFINED: return "REFINED MATERIAL";
        case ItemLayer.COMPONENT: return "INDUSTRIAL COMPONENT";
        case ItemLayer.PRODUCT: return "FINISHED PRODUCT";
    }

    return "UNCLASSIFIED ITEM";
}

/// @description Returns a readable functional item-type name.
function sc_item_type_name_get(_type)
{
    switch (_type)
    {
        case ItemType.RESOURCE: return "RESOURCE";
        case ItemType.STRUCTURAL: return "STRUCTURAL";
        case ItemType.MECHANICAL: return "MECHANICAL";
        case ItemType.ELECTRICAL: return "ELECTRICAL";
        case ItemType.AMMUNITION: return "AMMUNITION";
        case ItemType.EQUIPMENT: return "SHIP EQUIPMENT";
        case ItemType.MODULE: return "SYSTEM MODULE";
        case ItemType.DRONE: return "DRONE";
        case ItemType.WEAPON: return "WEAPON";
        case ItemType.DEVICE: return "DEVICE";
    }

    return "UNCLASSIFIED";
}

/// @description Registers the initial industrial production tree.
function sc_item_register_all()
{
    //==================================================
    // RAW RESOURCES
    //==================================================

    // ITEM: item_rock - Rock
    return sc_item_register({
        identity: { key: "item_rock", name: "Rock" },
        layer: ItemLayer.RAW, type: ItemType.RESOURCE, cargo: { weight: 1, stack_max: 99 },
        description: "Common non-metallic asteroid material with basic industrial uses.",
        visual: { colour: make_colour_rgb(126,120,110), glow: make_colour_rgb(83,78,70), draw_script: sc_item_raw_primitive_draw }
    })

    // ITEM: item_carbon - Carbon Ore
    && sc_item_register({
        identity: { key: "item_carbon", name: "Carbon Ore" },
        layer: ItemLayer.RAW, type: ItemType.RESOURCE, cargo: { weight: 1, stack_max: 99 },
        description: "Unprocessed carbon-rich material recovered from asteroid deposits.",
        visual: { colour: make_colour_rgb(104,143,158), glow: make_colour_rgb(39,118,150), draw_script: sc_item_raw_primitive_draw }
    })

    // ITEM: item_iron - Iron Ore
    && sc_item_register({
        identity: { key: "item_iron", name: "Iron Ore" },
        layer: ItemLayer.RAW, type: ItemType.RESOURCE, cargo: { weight: 1, stack_max: 99 },
        description: "Dense unprocessed iron ore suitable for industrial refining.",
        visual: { colour: make_colour_rgb(194,205,211), glow: make_colour_rgb(83,116,133), draw_script: sc_item_raw_primitive_draw }
    })

    // ITEM: item_copper - Copper Ore
    && sc_item_register({
        identity: { key: "item_copper", name: "Copper Ore" },
        layer: ItemLayer.RAW, type: ItemType.RESOURCE, cargo: { weight: 1, stack_max: 99 },
        description: "Conductive copper-bearing ore recovered from asteroid deposits.",
        visual: { colour: make_colour_rgb(229,132,66), glow: make_colour_rgb(51,139,123), draw_script: sc_item_raw_primitive_draw }
    })

    // ITEM: item_silicon - Silicate Deposit
    && sc_item_register({
        identity: { key: "item_silicon", name: "Silicate Deposit" },
        layer: ItemLayer.RAW, type: ItemType.RESOURCE, cargo: { weight: 1, stack_max: 99 },
        description: "Raw silicate material suitable for semiconductor processing.",
        visual: { colour: make_colour_rgb(119,225,184), glow: make_colour_rgb(41,155,112), draw_script: sc_item_raw_primitive_draw }
    })

    // ITEM: item_titanium - Titanium Ore
    && sc_item_register({
        identity: { key: "item_titanium", name: "Titanium Ore" },
        layer: ItemLayer.RAW, type: ItemType.RESOURCE, cargo: { weight: 1, stack_max: 99 },
        description: "Strong lightweight ore requiring advanced industrial processing.",
        visual: { colour: make_colour_rgb(188,225,243), glow: make_colour_rgb(61,139,193), draw_script: sc_item_raw_primitive_draw }
    })

    // ITEM: item_crystal - Resonant Crystal Deposit
    && sc_item_register({
        identity: { key: "item_crystal", name: "Resonant Crystal Deposit" },
        layer: ItemLayer.RAW, type: ItemType.RESOURCE, cargo: { weight: 1, stack_max: 99 },
        description: "Unprocessed crystalline material with unusual energy-reactive properties.",
        visual: { colour: make_colour_rgb(105,239,255), glow: make_colour_rgb(148,61,231), draw_script: sc_item_raw_primitive_draw }
    })

    // ITEM: item_ice - Ice
    && sc_item_register({
        identity: { key: "item_ice", name: "Ice" },
        layer: ItemLayer.RAW, type: ItemType.RESOURCE, cargo: { weight: 1, stack_max: 99 },
        description: "Frozen volatile material with life-support and fuel-processing uses.",
        visual: { colour: make_colour_rgb(214,252,255), glow: make_colour_rgb(45,188,229), draw_script: sc_item_raw_primitive_draw }
    })

    // ITEM: item_sulfur - Sulfur Deposit
    && sc_item_register({
        identity: { key: "item_sulfur", name: "Sulfur Deposit" },
        layer: ItemLayer.RAW, type: ItemType.RESOURCE, cargo: { weight: 1, stack_max: 99 },
        description: "Reactive sulfur-bearing mineral used in propellants and explosives.",
        visual: { colour: make_colour_rgb(214,184,61), glow: make_colour_rgb(255,119,32), draw_script: sc_item_raw_primitive_draw }
    })

    // ITEM: item_quartz - Quartz Deposit
    && sc_item_register({
        identity: { key: "item_quartz", name: "Quartz Deposit" },
        layer: ItemLayer.RAW, type: ItemType.RESOURCE, cargo: { weight: 1, stack_max: 99 },
        description: "Crystalline silica used in optical systems, sensors and precision electronics.",
        visual: { colour: make_colour_rgb(239,224,255), glow: make_colour_rgb(178,112,232), draw_script: sc_item_raw_primitive_draw }
    })

    // ITEM: item_uranium - Uranium Ore
    && sc_item_register({
        identity: { key: "item_uranium", name: "Uranium Ore" },
        layer: ItemLayer.RAW, type: ItemType.RESOURCE, cargo: { weight: 2, stack_max: 50 },
        description: "Dense radioactive ore used in reactor fuel and high-output power systems.",
        visual: { colour: make_colour_rgb(194,241,76), glow: make_colour_rgb(101,255,48), draw_script: sc_item_raw_primitive_draw }
    })


    //==================================================
    // REFINED MATERIALS
    //==================================================

    // ITEM: item_refined_iron - Refined Iron
    && sc_item_register({
        identity: { key: "item_refined_iron", name: "Refined Iron" },
        layer: ItemLayer.REFINED, type: ItemType.STRUCTURAL, cargo: { weight: 3, stack_max: 50 },
        description: "Purified iron produced by refining raw iron ore.",
        visual: { colour: make_colour_rgb(174,188,198), glow: make_colour_rgb(62,137,162), draw_script: sc_item_ingot_primitive_draw }
    })

    // ITEM: item_refined_copper - Refined Copper
    && sc_item_register({
        identity: { key: "item_refined_copper", name: "Refined Copper" },
        layer: ItemLayer.REFINED, type: ItemType.ELECTRICAL, cargo: { weight: 3, stack_max: 50 },
        description: "Purified conductive copper prepared for electrical manufacturing.",
        visual: { colour: make_colour_rgb(214,119,65), glow: make_colour_rgb(255,171,78), draw_script: sc_item_ingot_primitive_draw }
    })

    // ITEM: item_silicon_wafer - Silicon Wafer
    && sc_item_register({
        identity: { key: "item_silicon_wafer", name: "Silicon Wafer" },
        layer: ItemLayer.REFINED, type: ItemType.ELECTRICAL, cargo: { weight: 1, stack_max: 50 },
        description: "Processed semiconductor material used in electronic components.",
        visual: { colour: make_colour_rgb(95,184,173), glow: make_colour_rgb(69,242,218), draw_script: sc_item_plate_primitive_draw }
    })

    // ITEM: item_industrial_carbon - Industrial Carbon
    && sc_item_register({
        identity: { key: "item_industrial_carbon", name: "Industrial Carbon" },
        layer: ItemLayer.REFINED, type: ItemType.STRUCTURAL, cargo: { weight: 2, stack_max: 50 },
        description: "Purified carbon used in composites, propellants and advanced alloys.",
        visual: { colour: make_colour_rgb(55,68,74), glow: make_colour_rgb(79,159,173), draw_script: sc_item_ingot_primitive_draw }
    })

    // ITEM: item_industrial_sulfur - Industrial Sulfur
    && sc_item_register({
        identity: { key: "item_industrial_sulfur", name: "Industrial Sulfur" },
        layer: ItemLayer.REFINED, type: ItemType.AMMUNITION, cargo: { weight: 2, stack_max: 50 },
        description: "Processed reactive sulfur used in explosives and weapon propellants.",
        visual: { colour: make_colour_rgb(201,164,46), glow: make_colour_rgb(255,102,27), draw_script: sc_item_ingot_primitive_draw }
    })

    // ITEM: item_refined_titanium - Refined Titanium
    && sc_item_register({
        identity: { key: "item_refined_titanium", name: "Refined Titanium" },
        layer: ItemLayer.REFINED, type: ItemType.STRUCTURAL, cargo: { weight: 3, stack_max: 50 },
        description: "Purified lightweight titanium prepared for advanced alloying.",
        visual: { colour: make_colour_rgb(169,203,221), glow: make_colour_rgb(63,151,211), draw_script: sc_item_ingot_primitive_draw }
    })

    // ITEM: item_resonant_crystal - Resonant Crystal
    && sc_item_register({
        identity: { key: "item_resonant_crystal", name: "Resonant Crystal" },
        layer: ItemLayer.REFINED, type: ItemType.ELECTRICAL, cargo: { weight: 2, stack_max: 30 },
        description: "Stabilized crystalline material capable of conducting concentrated energy.",
        visual: { colour: make_colour_rgb(115,227,255), glow: make_colour_rgb(165,67,255), draw_script: sc_item_ingot_primitive_draw }
    })

    // ITEM: item_carbon_composite - Carbon Composite
    && sc_item_register({
        identity: { key: "item_carbon_composite", name: "Carbon Composite" },
        layer: ItemLayer.REFINED, type: ItemType.STRUCTURAL, cargo: { weight: 2, stack_max: 50 },
        description: "A lightweight structural material fabricated from processed carbon.",
        visual: { colour: make_colour_rgb(66,82,90), glow: make_colour_rgb(56,190,203), draw_script: sc_item_ingot_primitive_draw }
    })

    // ITEM: item_steel_alloy - Steel Alloy
    && sc_item_register({
        identity: { key: "item_steel_alloy", name: "Steel Alloy" },
        layer: ItemLayer.REFINED, type: ItemType.STRUCTURAL, cargo: { weight: 4, stack_max: 40 },
        description: "A durable iron-carbon alloy used in reinforced structures and weapon components.",
        visual: { colour: make_colour_rgb(126,142,151), glow: make_colour_rgb(45,139,161), draw_script: sc_item_ingot_primitive_draw }
    })

    // ITEM: item_titanium_alloy - Titanium Alloy
    && sc_item_register({
        identity: { key: "item_titanium_alloy", name: "Titanium Alloy" },
        layer: ItemLayer.REFINED, type: ItemType.STRUCTURAL, cargo: { weight: 3, stack_max: 30 },
        description: "A strong lightweight alloy intended for advanced armour and engine assemblies.",
        visual: { colour: make_colour_rgb(145,184,207), glow: make_colour_rgb(66,175,237), draw_script: sc_item_ingot_primitive_draw }
    })


    //==================================================
    // COMPONENTS
    //==================================================

    // ITEM: item_iron_plate - Iron Plate
    && sc_item_register({
        identity: { key: "item_iron_plate", name: "Iron Plate" },
        layer: ItemLayer.COMPONENT, type: ItemType.STRUCTURAL, cargo: { weight: 6, stack_max: 30 },
        description: "A standardized structural plate used in ship construction.",
        visual: { colour: make_colour_rgb(156,174,185), glow: make_colour_rgb(54,154,174), draw_script: sc_item_plate_primitive_draw }
    })

    // ITEM: item_copper_wire - Copper Wire
    && sc_item_register({
        identity: { key: "item_copper_wire", name: "Copper Wire" },
        layer: ItemLayer.COMPONENT, type: ItemType.ELECTRICAL, cargo: { weight: 2, stack_max: 50 },
        description: "Flexible conductive wiring used throughout electrical systems.",
        visual: { colour: make_colour_rgb(205,104,53), glow: make_colour_rgb(255,168,76), draw_script: sc_item_plate_primitive_draw }
    })

    // ITEM: item_copper_coil - Copper Coil
    && sc_item_register({
        identity: { key: "item_copper_coil", name: "Copper Coil" },
        layer: ItemLayer.COMPONENT, type: ItemType.ELECTRICAL, cargo: { weight: 4, stack_max: 30 },
        description: "A wound conductive coil used in motors and power systems.",
        visual: { colour: make_colour_rgb(190,91,48), glow: make_colour_rgb(255,156,55), draw_script: sc_item_ingot_primitive_draw }
    })

    // ITEM: item_circuit_board - Circuit Board
    && sc_item_register({
        identity: { key: "item_circuit_board", name: "Circuit Board" },
        layer: ItemLayer.COMPONENT, type: ItemType.ELECTRICAL, cargo: { weight: 2, stack_max: 30 },
        description: "A programmable electronic board used to control ship systems.",
        visual: { colour: make_colour_rgb(50,134,112), glow: make_colour_rgb(44,239,205), draw_script: sc_item_plate_primitive_draw }
    })

    // ITEM: item_motor - Motor
    && sc_item_register({
        identity: { key: "item_motor", name: "Motor" },
        layer: ItemLayer.COMPONENT, type: ItemType.MECHANICAL, cargo: { weight: 7, stack_max: 20 },
        description: "A compact electromechanical motor used in moving assemblies.",
        visual: { colour: make_colour_rgb(116,136,148), glow: make_colour_rgb(223,131,58), draw_script: sc_item_ingot_primitive_draw }
    })


    //==================================================
    // PRODUCTS
    //==================================================

    // ITEM: item_armour_plate - Armour Plate
    && sc_item_register({
        identity: { key: "item_armour_plate", name: "Armour Plate" },
        layer: ItemLayer.PRODUCT, type: ItemType.EQUIPMENT, cargo: { weight: 18, stack_max: 10 },
        description: "A complete reinforced armour assembly fitted over the ship hull.",

        equipment: {
            slot: EquipmentSlot.ARMOUR,
            install_duration: 300,
            modifiers: [
                { stat: "armour_max", add: 20, grade_scaled: true }
            ]
        },

        visual: { colour: make_colour_rgb(126,158,171), glow: make_colour_rgb(0,224,235), draw_script: sc_item_armour_primitive_draw }
    })

    // ITEM: item_lightweight_armour_plate - Lightweight Armour Plate
    && sc_item_register({
        identity: { key: "item_lightweight_armour_plate", name: "Lightweight Armour Plate" },
        layer: ItemLayer.PRODUCT, type: ItemType.EQUIPMENT, cargo: { weight: 11, stack_max: 10 },
        description: "Light composite armour providing reduced protection with considerably less mass.",

        equipment: {
            slot: EquipmentSlot.ARMOUR,
            install_duration: 240,
            modifiers: [
                { stat: "armour_max", add: 14, grade_scaled: true }
            ]
        },

        visual: { colour: make_colour_rgb(66,102,112), glow: make_colour_rgb(40,235,221), draw_script: sc_item_armour_primitive_draw }
    })

    // ITEM: item_radar_array - Radar Array
    && sc_item_register({
        identity: { key: "item_radar_array", name: "Radar Array" },
        layer: ItemLayer.PRODUCT, type: ItemType.EQUIPMENT, cargo: { weight: 12, stack_max: 10 },
        description: "A tactical sensor array with selectable detection ranges.",

        equipment: {
            slot: EquipmentSlot.TARGETING,
            install_duration: 300,

            radar: {
                range_levels: [1500,3000,4500,6000],
                default_range_index: 1
            },

            modifiers: []
        },

        visual: { colour: make_colour_rgb(71,115,132), glow: make_colour_rgb(38,231,243), draw_script: sc_item_plate_primitive_draw }
    })

    // ITEM: item_scanning_drone - Scanning Drone
    && sc_item_register({
        identity: { key: "item_scanning_drone", name: "Scanning Drone" },
        layer: ItemLayer.PRODUCT, type: ItemType.DRONE, cargo: { weight: 8, stack_max: 5 },
        description: "A compact autonomous drone equipped with short-range scanning equipment.",

        drone: {
            key: "drone_scanner"
        },

        visual: { colour: make_colour_rgb(86,142,156), glow: make_colour_rgb(0,235,245), draw_script: sc_item_plate_primitive_draw }
    })

    // ITEM: item_point_defence_drone - Point Defence Drone
    && sc_item_register({
        identity: { key: "item_point_defence_drone", name: "Point Defence Drone" },
        layer: ItemLayer.PRODUCT, type: ItemType.DRONE, cargo: { weight: 12, stack_max: 4 },
        description: "An autonomous defensive drone designed to intercept hostile missiles and other durable projectiles.",

        drone: {
            key: "drone_player_point_defence",
            equipment_key: "equipment_point_defence_drone"
        },

        visual: { colour: make_colour_rgb(58,125,145), glow: make_colour_rgb(0,235,245), draw_script: sc_item_plate_primitive_draw }
    });
}