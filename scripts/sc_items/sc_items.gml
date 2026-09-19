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
		
	// ITEM: item_lithium - Lithium Ore
	&& sc_item_register({
	    identity: { key: "item_lithium", name: "Lithium Ore" },
	    layer: ItemLayer.RAW, type: ItemType.RESOURCE, cargo: { weight: 1, stack_max: 99 },
	    description: "Light reactive ore used in batteries, capacitors and high-density energy storage.",
	    visual: { colour: make_colour_rgb(211,239,244), glow: make_colour_rgb(86,195,214), draw_script: sc_item_raw_primitive_draw }
	})

	// ITEM: item_nickel - Nickel Ore
	&& sc_item_register({
	    identity: { key: "item_nickel", name: "Nickel Ore" },
	    layer: ItemLayer.RAW, type: ItemType.RESOURCE, cargo: { weight: 1, stack_max: 99 },
	    description: "Durable metallic ore used in engines, turbines and high-temperature machinery.",
	    visual: { colour: make_colour_rgb(194,211,190), glow: make_colour_rgb(111,157,124), draw_script: sc_item_raw_primitive_draw }
	})

	// ITEM: item_cobalt - Cobalt Ore
	&& sc_item_register({
	    identity: { key: "item_cobalt", name: "Cobalt Ore" },
	    layer: ItemLayer.RAW, type: ItemType.RESOURCE, cargo: { weight: 1, stack_max: 99 },
	    description: "Magnetically useful ore used in field coils, advanced motors and electromagnetic systems.",
	    visual: { colour: make_colour_rgb(96,163,239), glow: make_colour_rgb(49,91,224), draw_script: sc_item_raw_primitive_draw }
	})

	// ITEM: item_tungsten - Tungsten Ore
	&& sc_item_register({
	    identity: { key: "item_tungsten", name: "Tungsten Ore" },
	    layer: ItemLayer.RAW, type: ItemType.RESOURCE, cargo: { weight: 2, stack_max: 50 },
	    description: "Extremely dense heat-resistant ore used in heavy armour, penetrators and weapon components.",
	    visual: { colour: make_colour_rgb(179,187,198), glow: make_colour_rgb(103,119,139), draw_script: sc_item_raw_primitive_draw }
	})

	// ITEM: item_platinum - Platinum Ore
	&& sc_item_register({
	    identity: { key: "item_platinum", name: "Platinum Ore" },
	    layer: ItemLayer.RAW, type: ItemType.RESOURCE, cargo: { weight: 1, stack_max: 50 },
	    description: "Rare conductive ore used in precision electronics, catalysts and advanced sensor systems.",
	    visual: { colour: make_colour_rgb(237,230,247), glow: make_colour_rgb(172,140,222), draw_script: sc_item_raw_primitive_draw }
	})

	// ITEM: item_iridium - Iridium Ore
	&& sc_item_register({
	    identity: { key: "item_iridium", name: "Iridium Ore" },
	    layer: ItemLayer.RAW, type: ItemType.RESOURCE, cargo: { weight: 2, stack_max: 50 },
	    description: "Exceptionally rare dense ore used in prototype containment, exotic alloys and late-stage technology.",
	    visual: { colour: make_colour_rgb(190,207,255), glow: make_colour_rgb(115,74,255), draw_script: sc_item_raw_primitive_draw }
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
		
	    // ITEM: item_industrial_ceramic - Industrial Ceramic
    && sc_item_register({
        identity: { key: "item_industrial_ceramic", name: "Industrial Ceramic" },
        layer: ItemLayer.REFINED, type: ItemType.STRUCTURAL, cargo: { weight: 2, stack_max: 50 },
        description: "Dense processed ceramic material used in thermal shielding, armour and reactor construction.",
        visual: { colour: make_colour_rgb(188,181,164), glow: make_colour_rgb(224,177,96), draw_script: sc_item_ingot_primitive_draw }
    })

    // ITEM: item_optical_quartz - Optical Quartz
    && sc_item_register({
        identity: { key: "item_optical_quartz", name: "Optical Quartz" },
        layer: ItemLayer.REFINED, type: ItemType.ELECTRICAL, cargo: { weight: 1, stack_max: 50 },
        description: "Purified optical-grade quartz used in lenses, sensors and focused-energy systems.",
        visual: { colour: make_colour_rgb(221,217,242), glow: make_colour_rgb(151,205,255), draw_script: sc_item_ingot_primitive_draw }
    })

    // ITEM: item_separated_volatiles - Separated Volatiles
    && sc_item_register({
        identity: { key: "item_separated_volatiles", name: "Separated Volatiles" },
        layer: ItemLayer.REFINED, type: ItemType.RESOURCE, cargo: { weight: 1, stack_max: 50 },
        description: "Processed volatile compounds extracted from asteroid ice for fuel and coolant production.",
        visual: { colour: make_colour_rgb(188,232,240), glow: make_colour_rgb(79,210,255), draw_script: sc_item_ingot_primitive_draw }
    })

    // ITEM: item_lithium_compound - Lithium Compound
    && sc_item_register({
        identity: { key: "item_lithium_compound", name: "Lithium Compound" },
        layer: ItemLayer.REFINED, type: ItemType.ELECTRICAL, cargo: { weight: 1, stack_max: 50 },
        description: "Processed lithium compound used in high-density batteries, capacitors and power-storage systems.",
        visual: { colour: make_colour_rgb(211,232,234), glow: make_colour_rgb(84,217,228), draw_script: sc_item_ingot_primitive_draw }
    })

    // ITEM: item_refined_nickel - Refined Nickel
    && sc_item_register({
        identity: { key: "item_refined_nickel", name: "Refined Nickel" },
        layer: ItemLayer.REFINED, type: ItemType.STRUCTURAL, cargo: { weight: 3, stack_max: 50 },
        description: "Purified heat-resistant nickel used in engines, turbines and advanced structural alloys.",
        visual: { colour: make_colour_rgb(166,184,171), glow: make_colour_rgb(95,169,122), draw_script: sc_item_ingot_primitive_draw }
    })

    // ITEM: item_refined_cobalt - Refined Cobalt
    && sc_item_register({
        identity: { key: "item_refined_cobalt", name: "Refined Cobalt" },
        layer: ItemLayer.REFINED, type: ItemType.ELECTRICAL, cargo: { weight: 3, stack_max: 50 },
        description: "Purified cobalt used in magnetic assemblies, field systems and high-temperature machinery.",
        visual: { colour: make_colour_rgb(84,135,191), glow: make_colour_rgb(51,112,255), draw_script: sc_item_ingot_primitive_draw }
    })

    // ITEM: item_refined_tungsten - Refined Tungsten
    && sc_item_register({
        identity: { key: "item_refined_tungsten", name: "Refined Tungsten" },
        layer: ItemLayer.REFINED, type: ItemType.STRUCTURAL, cargo: { weight: 5, stack_max: 30 },
        description: "Extremely dense refined metal intended for heavy armour, penetrators and heat-resistant weapon parts.",
        visual: { colour: make_colour_rgb(120,129,140), glow: make_colour_rgb(89,111,140), draw_script: sc_item_ingot_primitive_draw }
    })

    // ITEM: item_refined_platinum - Refined Platinum
    && sc_item_register({
        identity: { key: "item_refined_platinum", name: "Refined Platinum" },
        layer: ItemLayer.REFINED, type: ItemType.ELECTRICAL, cargo: { weight: 2, stack_max: 30 },
        description: "High-purity platinum used in precision contacts, catalysts and advanced electronic systems.",
        visual: { colour: make_colour_rgb(224,220,234), glow: make_colour_rgb(184,150,235), draw_script: sc_item_ingot_primitive_draw }
    })

    // ITEM: item_enriched_uranium - Enriched Uranium
    && sc_item_register({
        identity: { key: "item_enriched_uranium", name: "Enriched Uranium" },
        layer: ItemLayer.REFINED, type: ItemType.RESOURCE, cargo: { weight: 4, stack_max: 30 },
        description: "Concentrated nuclear material prepared for reactor fuel manufacturing and high-output power systems.",
        visual: { colour: make_colour_rgb(164,201,73), glow: make_colour_rgb(111,255,46), draw_script: sc_item_ingot_primitive_draw }
    })

    // ITEM: item_iridium_matrix - Iridium Matrix
    && sc_item_register({
        identity: { key: "item_iridium_matrix", name: "Iridium Matrix" },
        layer: ItemLayer.REFINED, type: ItemType.STRUCTURAL, cargo: { weight: 4, stack_max: 20 },
        description: "An exotic processed iridium material capable of surviving extreme energy and containment stresses.",
        visual: { colour: make_colour_rgb(164,182,221), glow: make_colour_rgb(125,86,255), draw_script: sc_item_ingot_primitive_draw }
    })

    // ITEM: item_nickel_steel_alloy - Nickel Steel Alloy
    && sc_item_register({
        identity: { key: "item_nickel_steel_alloy", name: "Nickel Steel Alloy" },
        layer: ItemLayer.REFINED, type: ItemType.STRUCTURAL, cargo: { weight: 4, stack_max: 40 },
        description: "A durable heat-resistant steel alloy used in engines, machinery and reinforced structural assemblies.",
        visual: { colour: make_colour_rgb(128,151,143), glow: make_colour_rgb(83,164,141), draw_script: sc_item_ingot_primitive_draw }
    })

    // ITEM: item_cobalt_superalloy - Cobalt Superalloy
    && sc_item_register({
        identity: { key: "item_cobalt_superalloy", name: "Cobalt Superalloy" },
        layer: ItemLayer.REFINED, type: ItemType.STRUCTURAL, cargo: { weight: 4, stack_max: 30 },
        description: "An advanced cobalt-nickel-titanium alloy engineered for extreme temperatures and high-output machinery.",
        visual: { colour: make_colour_rgb(104,140,173), glow: make_colour_rgb(73,139,241), draw_script: sc_item_ingot_primitive_draw }
    })

    // ITEM: item_tungsten_carbide - Tungsten Carbide
    && sc_item_register({
        identity: { key: "item_tungsten_carbide", name: "Tungsten Carbide" },
        layer: ItemLayer.REFINED, type: ItemType.STRUCTURAL, cargo: { weight: 5, stack_max: 30 },
        description: "An exceptionally hard tungsten-carbon material used in penetrators, drilling systems and heavy weapon construction.",
        visual: { colour: make_colour_rgb(91,101,111), glow: make_colour_rgb(129,148,166), draw_script: sc_item_ingot_primitive_draw }
    })

    // ITEM: item_resonant_alloy - Resonant Alloy
    && sc_item_register({
        identity: { key: "item_resonant_alloy", name: "Resonant Alloy" },
        layer: ItemLayer.REFINED, type: ItemType.ELECTRICAL, cargo: { weight: 3, stack_max: 30 },
        description: "A titanium-crystal composite capable of carrying intense resonant energy through structural components.",
        visual: { colour: make_colour_rgb(108,173,199), glow: make_colour_rgb(119,88,255), draw_script: sc_item_ingot_primitive_draw }
    })

    // ITEM: item_iridium_composite - Iridium Composite
    && sc_item_register({
        identity: { key: "item_iridium_composite", name: "Iridium Composite" },
        layer: ItemLayer.REFINED, type: ItemType.STRUCTURAL, cargo: { weight: 4, stack_max: 20 },
        description: "A prototype-grade composite combining iridium, titanium and carbon for extreme-performance equipment.",
        visual: { colour: make_colour_rgb(151,173,205), glow: make_colour_rgb(135,83,255), draw_script: sc_item_ingot_primitive_draw }
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
		
	    // ITEM: item_steel_casing - Steel Casing
    && sc_item_register({
        identity: { key: "item_steel_casing", name: "Steel Casing" },
        layer: ItemLayer.COMPONENT, type: ItemType.STRUCTURAL, cargo: { weight: 3, stack_max: 50 },
        description: "A standardized steel housing used in machinery, ammunition and industrial assemblies.",
        visual: { colour: make_colour_rgb(126,142,151), glow: make_colour_rgb(66,139,158), draw_script: sc_item_plate_primitive_draw }
    })

    // ITEM: item_reinforced_plate - Reinforced Plate
    && sc_item_register({
        identity: { key: "item_reinforced_plate", name: "Reinforced Plate" },
        layer: ItemLayer.COMPONENT, type: ItemType.STRUCTURAL, cargo: { weight: 7, stack_max: 30 },
        description: "A heavy structural plate fabricated from reinforced steel alloy.",
        visual: { colour: make_colour_rgb(112,128,138), glow: make_colour_rgb(64,150,172), draw_script: sc_item_plate_primitive_draw }
    })

    // ITEM: item_titanium_frame - Titanium Frame
    && sc_item_register({
        identity: { key: "item_titanium_frame", name: "Titanium Frame" },
        layer: ItemLayer.COMPONENT, type: ItemType.STRUCTURAL, cargo: { weight: 5, stack_max: 30 },
        description: "A lightweight structural framework used in advanced machinery, drones and propulsion systems.",
        visual: { colour: make_colour_rgb(145,184,207), glow: make_colour_rgb(66,175,237), draw_script: sc_item_plate_primitive_draw }
    })

    // ITEM: item_ceramic_plate - Ceramic Plate
    && sc_item_register({
        identity: { key: "item_ceramic_plate", name: "Ceramic Plate" },
        layer: ItemLayer.COMPONENT, type: ItemType.STRUCTURAL, cargo: { weight: 3, stack_max: 30 },
        description: "A thermally resistant ceramic panel used in armour, reactors and heat shielding.",
        visual: { colour: make_colour_rgb(188,181,164), glow: make_colour_rgb(224,177,96), draw_script: sc_item_plate_primitive_draw }
    })

    // ITEM: item_bearing_assembly - Bearing Assembly
    && sc_item_register({
        identity: { key: "item_bearing_assembly", name: "Bearing Assembly" },
        layer: ItemLayer.COMPONENT, type: ItemType.MECHANICAL, cargo: { weight: 2, stack_max: 50 },
        description: "A precision mechanical bearing assembly used in motors, turbines and weapon mounts.",
        visual: { colour: make_colour_rgb(137,149,156), glow: make_colour_rgb(187,151,88), draw_script: sc_item_ingot_primitive_draw }
    })

    // ITEM: item_servo_assembly - Servo Assembly
    && sc_item_register({
        identity: { key: "item_servo_assembly", name: "Servo Assembly" },
        layer: ItemLayer.COMPONENT, type: ItemType.MECHANICAL, cargo: { weight: 5, stack_max: 30 },
        description: "A controlled electromechanical actuator used in turrets, drones and precision moving systems.",
        visual: { colour: make_colour_rgb(112,134,146), glow: make_colour_rgb(76,192,214), draw_script: sc_item_ingot_primitive_draw }
    })

    // ITEM: item_linear_actuator - Linear Actuator
    && sc_item_register({
        identity: { key: "item_linear_actuator", name: "Linear Actuator" },
        layer: ItemLayer.COMPONENT, type: ItemType.MECHANICAL, cargo: { weight: 5, stack_max: 30 },
        description: "A powered linear actuator used in weapon mounts, mining equipment and heavy machinery.",
        visual: { colour: make_colour_rgb(121,136,145), glow: make_colour_rgb(221,141,64), draw_script: sc_item_ingot_primitive_draw }
    })

    // ITEM: item_pump_assembly - Pump Assembly
    && sc_item_register({
        identity: { key: "item_pump_assembly", name: "Pump Assembly" },
        layer: ItemLayer.COMPONENT, type: ItemType.MECHANICAL, cargo: { weight: 6, stack_max: 30 },
        description: "A compact industrial pump used to circulate fuel, coolant and other working fluids.",
        visual: { colour: make_colour_rgb(111,139,151), glow: make_colour_rgb(73,199,219), draw_script: sc_item_ingot_primitive_draw }
    })

    // ITEM: item_turbine_assembly - Turbine Assembly
    && sc_item_register({
        identity: { key: "item_turbine_assembly", name: "Turbine Assembly" },
        layer: ItemLayer.COMPONENT, type: ItemType.MECHANICAL, cargo: { weight: 8, stack_max: 20 },
        description: "A high-speed turbine assembly used in advanced propulsion and reactor systems.",
        visual: { colour: make_colour_rgb(136,170,188), glow: make_colour_rgb(68,192,236), draw_script: sc_item_ingot_primitive_draw }
    })

    // ITEM: item_gyroscope - Gyroscope
    && sc_item_register({
        identity: { key: "item_gyroscope", name: "Gyroscope" },
        layer: ItemLayer.COMPONENT, type: ItemType.MECHANICAL, cargo: { weight: 4, stack_max: 30 },
        description: "A precision inertial assembly used in navigation, drones and ship control systems.",
        visual: { colour: make_colour_rgb(105,135,154), glow: make_colour_rgb(76,220,235), draw_script: sc_item_ingot_primitive_draw }
    })

    // ITEM: item_pressure_vessel - Pressure Vessel
    && sc_item_register({
        identity: { key: "item_pressure_vessel", name: "Pressure Vessel" },
        layer: ItemLayer.COMPONENT, type: ItemType.MECHANICAL, cargo: { weight: 8, stack_max: 20 },
        description: "A reinforced containment vessel designed for pressurized fuel, coolant and reactor systems.",
        visual: { colour: make_colour_rgb(129,145,151), glow: make_colour_rgb(201,172,96), draw_script: sc_item_ingot_primitive_draw }
    })

    // ITEM: item_heat_sink - Heat Sink
    && sc_item_register({
        identity: { key: "item_heat_sink", name: "Heat Sink" },
        layer: ItemLayer.COMPONENT, type: ItemType.MECHANICAL, cargo: { weight: 4, stack_max: 30 },
        description: "A conductive thermal sink used to draw heat away from weapons, electronics and reactors.",
        visual: { colour: make_colour_rgb(129,103,86), glow: make_colour_rgb(255,151,65), draw_script: sc_item_plate_primitive_draw }
    })

    // ITEM: item_radiator_assembly - Radiator Assembly
    && sc_item_register({
        identity: { key: "item_radiator_assembly", name: "Radiator Assembly" },
        layer: ItemLayer.COMPONENT, type: ItemType.MECHANICAL, cargo: { weight: 7, stack_max: 20 },
        description: "A lightweight radiator system designed to reject large quantities of waste heat.",
        visual: { colour: make_colour_rgb(107,145,158), glow: make_colour_rgb(80,215,235), draw_script: sc_item_plate_primitive_draw }
    })

    // ITEM: item_fuel_injector - Fuel Injector
    && sc_item_register({
        identity: { key: "item_fuel_injector", name: "Fuel Injector" },
        layer: ItemLayer.COMPONENT, type: ItemType.MECHANICAL, cargo: { weight: 3, stack_max: 30 },
        description: "A precision fuel-delivery assembly used in high-performance propulsion systems.",
        visual: { colour: make_colour_rgb(138,153,141), glow: make_colour_rgb(98,207,155), draw_script: sc_item_ingot_primitive_draw }
    })

    // ITEM: item_weapon_mount - Weapon Mount
    && sc_item_register({
        identity: { key: "item_weapon_mount", name: "Weapon Mount" },
        layer: ItemLayer.COMPONENT, type: ItemType.MECHANICAL, cargo: { weight: 10, stack_max: 20 },
        description: "A reinforced powered mounting assembly designed to support ship-mounted weapon systems.",
        visual: { colour: make_colour_rgb(116,131,141), glow: make_colour_rgb(231,125,65), draw_script: sc_item_plate_primitive_draw }
    })

    // ITEM: item_drone_chassis - Drone Chassis
    && sc_item_register({
        identity: { key: "item_drone_chassis", name: "Drone Chassis" },
        layer: ItemLayer.COMPONENT, type: ItemType.MECHANICAL, cargo: { weight: 7, stack_max: 20 },
        description: "A lightweight autonomous vehicle frame used as the foundation for specialized drones.",
        visual: { colour: make_colour_rgb(112,154,168), glow: make_colour_rgb(62,220,235), draw_script: sc_item_plate_primitive_draw }
    })

    // ITEM: item_drill_head - Drill Head
    && sc_item_register({
        identity: { key: "item_drill_head", name: "Drill Head" },
        layer: ItemLayer.COMPONENT, type: ItemType.MECHANICAL, cargo: { weight: 8, stack_max: 20 },
        description: "An extremely hard industrial cutting head intended for asteroid mining systems.",
        visual: { colour: make_colour_rgb(101,109,118), glow: make_colour_rgb(163,141,103), draw_script: sc_item_ingot_primitive_draw }
    })

    // ITEM: item_optical_lens - Optical Lens
    && sc_item_register({
        identity: { key: "item_optical_lens", name: "Optical Lens" },
        layer: ItemLayer.COMPONENT, type: ItemType.ELECTRICAL, cargo: { weight: 1, stack_max: 50 },
        description: "A precision optical lens used in sensors, scanners and directed-energy systems.",
        visual: { colour: make_colour_rgb(198,223,238), glow: make_colour_rgb(103,210,255), draw_script: sc_item_plate_primitive_draw }
    })

    // ITEM: item_focusing_lens - Focusing Lens
    && sc_item_register({
        identity: { key: "item_focusing_lens", name: "Focusing Lens" },
        layer: ItemLayer.COMPONENT, type: ItemType.ELECTRICAL, cargo: { weight: 2, stack_max: 30 },
        description: "An energy-reactive optical element capable of focusing concentrated beam emissions.",
        visual: { colour: make_colour_rgb(167,211,235), glow: make_colour_rgb(155,79,255), draw_script: sc_item_plate_primitive_draw }
    })

    // ITEM: item_processor_core - Processor Core
    && sc_item_register({
        identity: { key: "item_processor_core", name: "Processor Core" },
        layer: ItemLayer.COMPONENT, type: ItemType.ELECTRICAL, cargo: { weight: 2, stack_max: 30 },
        description: "A high-performance processing unit used in advanced automated and electronic systems.",
        visual: { colour: make_colour_rgb(76,136,132), glow: make_colour_rgb(53,235,214), draw_script: sc_item_plate_primitive_draw }
    })

    // ITEM: item_control_unit - Control Unit
    && sc_item_register({
        identity: { key: "item_control_unit", name: "Control Unit" },
        layer: ItemLayer.COMPONENT, type: ItemType.ELECTRICAL, cargo: { weight: 3, stack_max: 30 },
        description: "A programmable control assembly used to coordinate engines, modules and machinery.",
        visual: { colour: make_colour_rgb(76,130,139), glow: make_colour_rgb(62,219,225), draw_script: sc_item_plate_primitive_draw }
    })

    // ITEM: item_sensor_package - Sensor Package
    && sc_item_register({
        identity: { key: "item_sensor_package", name: "Sensor Package" },
        layer: ItemLayer.COMPONENT, type: ItemType.ELECTRICAL, cargo: { weight: 3, stack_max: 30 },
        description: "An integrated optical and electronic detection package used by scanners and targeting systems.",
        visual: { colour: make_colour_rgb(83,141,151), glow: make_colour_rgb(58,229,244), draw_script: sc_item_plate_primitive_draw }
    })

    // ITEM: item_navigation_computer - Navigation Computer
    && sc_item_register({
        identity: { key: "item_navigation_computer", name: "Navigation Computer" },
        layer: ItemLayer.COMPONENT, type: ItemType.ELECTRICAL, cargo: { weight: 4, stack_max: 20 },
        description: "An advanced navigation processor used by autonomous craft and precision flight systems.",
        visual: { colour: make_colour_rgb(76,127,151), glow: make_colour_rgb(72,197,255), draw_script: sc_item_plate_primitive_draw }
    })

    // ITEM: item_targeting_computer - Targeting Computer
    && sc_item_register({
        identity: { key: "item_targeting_computer", name: "Targeting Computer" },
        layer: ItemLayer.COMPONENT, type: ItemType.ELECTRICAL, cargo: { weight: 4, stack_max: 20 },
        description: "A dedicated combat processor designed for weapon tracking and precision targeting.",
        visual: { colour: make_colour_rgb(104,118,133), glow: make_colour_rgb(255,115,72), draw_script: sc_item_plate_primitive_draw }
    })

    // ITEM: item_guidance_unit - Guidance Unit
    && sc_item_register({
        identity: { key: "item_guidance_unit", name: "Guidance Unit" },
        layer: ItemLayer.COMPONENT, type: ItemType.ELECTRICAL, cargo: { weight: 3, stack_max: 30 },
        description: "A compact guidance processor used in missiles and autonomous weapon systems.",
        visual: { colour: make_colour_rgb(97,120,135), glow: make_colour_rgb(225,143,62), draw_script: sc_item_plate_primitive_draw }
    })

    // ITEM: item_signal_amplifier - Signal Amplifier
    && sc_item_register({
        identity: { key: "item_signal_amplifier", name: "Signal Amplifier" },
        layer: ItemLayer.COMPONENT, type: ItemType.ELECTRICAL, cargo: { weight: 3, stack_max: 30 },
        description: "A precision electronic amplifier used in radar, communications and advanced sensors.",
        visual: { colour: make_colour_rgb(124,128,155), glow: make_colour_rgb(169,113,245), draw_script: sc_item_plate_primitive_draw }
    })

    // ITEM: item_power_regulator - Power Regulator
    && sc_item_register({
        identity: { key: "item_power_regulator", name: "Power Regulator" },
        layer: ItemLayer.COMPONENT, type: ItemType.ELECTRICAL, cargo: { weight: 4, stack_max: 30 },
        description: "A high-current control assembly used to regulate power in reactors, shields and energy systems.",
        visual: { colour: make_colour_rgb(104,127,151), glow: make_colour_rgb(92,178,255), draw_script: sc_item_plate_primitive_draw }
    })

    // ITEM: item_magnetic_core - Magnetic Core
    && sc_item_register({
        identity: { key: "item_magnetic_core", name: "Magnetic Core" },
        layer: ItemLayer.COMPONENT, type: ItemType.ELECTRICAL, cargo: { weight: 4, stack_max: 30 },
        description: "A cobalt-based magnetic core used in motors, field systems and electromagnetic weapons.",
        visual: { colour: make_colour_rgb(79,119,175), glow: make_colour_rgb(56,104,255), draw_script: sc_item_ingot_primitive_draw }
    })

    // ITEM: item_field_coil - Field Coil
    && sc_item_register({
        identity: { key: "item_field_coil", name: "Field Coil" },
        layer: ItemLayer.COMPONENT, type: ItemType.ELECTRICAL, cargo: { weight: 5, stack_max: 30 },
        description: "A high-strength electromagnetic coil used in shield generators and field-based technology.",
        visual: { colour: make_colour_rgb(103,102,160), glow: make_colour_rgb(109,103,255), draw_script: sc_item_ingot_primitive_draw }
    })

    // ITEM: item_resonance_coil - Resonance Coil
    && sc_item_register({
        identity: { key: "item_resonance_coil", name: "Resonance Coil" },
        layer: ItemLayer.COMPONENT, type: ItemType.ELECTRICAL, cargo: { weight: 5, stack_max: 20 },
        description: "An advanced field coil incorporating resonant crystalline material for high-energy systems.",
        visual: { colour: make_colour_rgb(115,106,174), glow: make_colour_rgb(173,73,255), draw_script: sc_item_ingot_primitive_draw }
    })

    // ITEM: item_precision_contacts - Precision Contacts
    && sc_item_register({
        identity: { key: "item_precision_contacts", name: "Precision Contacts" },
        layer: ItemLayer.COMPONENT, type: ItemType.ELECTRICAL, cargo: { weight: 1, stack_max: 50 },
        description: "High-purity electrical contacts used in advanced control and sensor assemblies.",
        visual: { colour: make_colour_rgb(220,205,221), glow: make_colour_rgb(193,145,237), draw_script: sc_item_plate_primitive_draw }
    })

    // ITEM: item_battery_cell - Battery Cell
    && sc_item_register({
        identity: { key: "item_battery_cell", name: "Battery Cell" },
        layer: ItemLayer.COMPONENT, type: ItemType.ELECTRICAL, cargo: { weight: 1, stack_max: 50 },
        description: "A compact high-density electrochemical energy cell.",
        visual: { colour: make_colour_rgb(137,183,190), glow: make_colour_rgb(74,230,239), draw_script: sc_item_ingot_primitive_draw }
    })

    // ITEM: item_battery_pack - Battery Pack
    && sc_item_register({
        identity: { key: "item_battery_pack", name: "Battery Pack" },
        layer: ItemLayer.COMPONENT, type: ItemType.ELECTRICAL, cargo: { weight: 4, stack_max: 30 },
        description: "An integrated rechargeable power pack used in drones, shields and auxiliary systems.",
        visual: { colour: make_colour_rgb(104,152,161), glow: make_colour_rgb(66,230,239), draw_script: sc_item_plate_primitive_draw }
    })

    // ITEM: item_capacitor_bank - Capacitor Bank
    && sc_item_register({
        identity: { key: "item_capacitor_bank", name: "Capacitor Bank" },
        layer: ItemLayer.COMPONENT, type: ItemType.ELECTRICAL, cargo: { weight: 5, stack_max: 20 },
        description: "A high-discharge energy-storage assembly used in shields and energy weapons.",
        visual: { colour: make_colour_rgb(100,123,169), glow: make_colour_rgb(112,98,255), draw_script: sc_item_plate_primitive_draw }
    })

    // ITEM: item_cryogenic_coolant - Cryogenic Coolant
    && sc_item_register({
        identity: { key: "item_cryogenic_coolant", name: "Cryogenic Coolant" },
        layer: ItemLayer.COMPONENT, type: ItemType.RESOURCE, cargo: { weight: 2, stack_max: 50 },
        description: "A processed cryogenic working fluid used in reactor, weapon and propulsion cooling systems.",
        visual: { colour: make_colour_rgb(170,229,239), glow: make_colour_rgb(62,211,255), draw_script: sc_item_ingot_primitive_draw }
    })

    // ITEM: item_hydrogen_fuel - Hydrogen Fuel
    && sc_item_register({
        identity: { key: "item_hydrogen_fuel", name: "Hydrogen Fuel" },
        layer: ItemLayer.COMPONENT, type: ItemType.RESOURCE, cargo: { weight: 2, stack_max: 50 },
        description: "Processed hydrogen-rich fuel intended for propulsion and auxiliary power systems.",
        visual: { colour: make_colour_rgb(159,207,225), glow: make_colour_rgb(76,178,255), draw_script: sc_item_ingot_primitive_draw }
    })

    // ITEM: item_coolant_cell - Coolant Cell
    && sc_item_register({
        identity: { key: "item_coolant_cell", name: "Coolant Cell" },
        layer: ItemLayer.COMPONENT, type: ItemType.MECHANICAL, cargo: { weight: 4, stack_max: 30 },
        description: "A sealed coolant reservoir used in high-output thermal management systems.",
        visual: { colour: make_colour_rgb(108,175,190), glow: make_colour_rgb(68,227,255), draw_script: sc_item_ingot_primitive_draw }
    })

    // ITEM: item_fuel_cell - Fuel Cell
    && sc_item_register({
        identity: { key: "item_fuel_cell", name: "Fuel Cell" },
        layer: ItemLayer.COMPONENT, type: ItemType.MECHANICAL, cargo: { weight: 4, stack_max: 30 },
        description: "A sealed fuel-storage assembly designed for propulsion and auxiliary power systems.",
        visual: { colour: make_colour_rgb(128,161,173), glow: make_colour_rgb(72,183,245), draw_script: sc_item_ingot_primitive_draw }
    })

    // ITEM: item_reactor_fuel_pellet - Reactor Fuel Pellet
    && sc_item_register({
        identity: { key: "item_reactor_fuel_pellet", name: "Reactor Fuel Pellet" },
        layer: ItemLayer.COMPONENT, type: ItemType.ELECTRICAL, cargo: { weight: 2, stack_max: 50 },
        description: "A compact enriched nuclear fuel pellet prepared for installation in reactor fuel assemblies.",
        visual: { colour: make_colour_rgb(154,190,76), glow: make_colour_rgb(105,255,55), draw_script: sc_item_ingot_primitive_draw }
    })

    // ITEM: item_reactor_fuel_rod - Reactor Fuel Rod
    && sc_item_register({
        identity: { key: "item_reactor_fuel_rod", name: "Reactor Fuel Rod" },
        layer: ItemLayer.COMPONENT, type: ItemType.ELECTRICAL, cargo: { weight: 7, stack_max: 20 },
        description: "A shielded nuclear fuel assembly used in compact high-output reactors.",
        visual: { colour: make_colour_rgb(127,157,79), glow: make_colour_rgb(105,255,55), draw_script: sc_item_ingot_primitive_draw }
    })

    // ITEM: item_reactor_core - Reactor Core
    && sc_item_register({
        identity: { key: "item_reactor_core", name: "Reactor Core" },
        layer: ItemLayer.COMPONENT, type: ItemType.ELECTRICAL, cargo: { weight: 12, stack_max: 10 },
        description: "A complete reactor core assembly used as the central component of advanced power-generation systems.",
        visual: { colour: make_colour_rgb(100,126,139), glow: make_colour_rgb(126,238,75), draw_script: sc_item_plate_primitive_draw }
    })

    // ITEM: item_propellant_compound - Propellant Compound
    && sc_item_register({
        identity: { key: "item_propellant_compound", name: "Propellant Compound" },
        layer: ItemLayer.COMPONENT, type: ItemType.AMMUNITION, cargo: { weight: 2, stack_max: 50 },
        description: "A stable energetic compound formulated for ballistic and rocket propulsion.",
        visual: { colour: make_colour_rgb(177,142,56), glow: make_colour_rgb(255,108,36), draw_script: sc_item_ingot_primitive_draw }
    })

    // ITEM: item_explosive_compound - Explosive Compound
    && sc_item_register({
        identity: { key: "item_explosive_compound", name: "Explosive Compound" },
        layer: ItemLayer.COMPONENT, type: ItemType.AMMUNITION, cargo: { weight: 3, stack_max: 40 },
        description: "A concentrated energetic material used in warheads, mines and explosive ammunition.",
        visual: { colour: make_colour_rgb(174,116,47), glow: make_colour_rgb(255,73,32), draw_script: sc_item_ingot_primitive_draw }
    })

    // ITEM: item_tungsten_penetrator - Tungsten Penetrator
    && sc_item_register({
        identity: { key: "item_tungsten_penetrator", name: "Tungsten Penetrator" },
        layer: ItemLayer.COMPONENT, type: ItemType.AMMUNITION, cargo: { weight: 3, stack_max: 50 },
        description: "A dense tungsten-carbide penetrator intended for armour-piercing kinetic ammunition.",
        visual: { colour: make_colour_rgb(102,109,119), glow: make_colour_rgb(151,164,177), draw_script: sc_item_ingot_primitive_draw }
    })

    // ITEM: item_bullet_components - Bullet Components
    && sc_item_register({
        identity: { key: "item_bullet_components", name: "Bullet Components" },
        layer: ItemLayer.COMPONENT, type: ItemType.AMMUNITION, cargo: { weight: 2, stack_max: 99 },
        description: "Standardized casings and propellant charges ready for ballistic ammunition production.",
        visual: { colour: make_colour_rgb(144,125,82), glow: make_colour_rgb(235,160,61), draw_script: sc_item_ingot_primitive_draw }
    })

    // ITEM: item_ap_bullet_components - AP Bullet Components
    && sc_item_register({
        identity: { key: "item_ap_bullet_components", name: "AP Bullet Components" },
        layer: ItemLayer.COMPONENT, type: ItemType.AMMUNITION, cargo: { weight: 3, stack_max: 99 },
        description: "Armour-piercing ammunition components incorporating dense tungsten penetrators.",
        visual: { colour: make_colour_rgb(112,111,105), glow: make_colour_rgb(228,147,57), draw_script: sc_item_ingot_primitive_draw }
    })

    // ITEM: item_rocket_warhead - Rocket Warhead
    && sc_item_register({
        identity: { key: "item_rocket_warhead", name: "Rocket Warhead" },
        layer: ItemLayer.COMPONENT, type: ItemType.AMMUNITION, cargo: { weight: 5, stack_max: 30 },
        description: "A sealed explosive warhead intended for rockets, missiles and guided munitions.",
        visual: { colour: make_colour_rgb(135,111,83), glow: make_colour_rgb(255,84,42), draw_script: sc_item_ingot_primitive_draw }
    })

    // ITEM: item_rocket_motor - Rocket Motor
    && sc_item_register({
        identity: { key: "item_rocket_motor", name: "Rocket Motor" },
        layer: ItemLayer.COMPONENT, type: ItemType.AMMUNITION, cargo: { weight: 5, stack_max: 30 },
        description: "A compact propulsion motor designed for rockets and guided missile systems.",
        visual: { colour: make_colour_rgb(122,139,146), glow: make_colour_rgb(255,143,55), draw_script: sc_item_ingot_primitive_draw }
    })

    // ITEM: item_missile_assembly - Missile Assembly
    && sc_item_register({
        identity: { key: "item_missile_assembly", name: "Missile Assembly" },
        layer: ItemLayer.COMPONENT, type: ItemType.AMMUNITION, cargo: { weight: 9, stack_max: 20 },
        description: "A complete guided munition assembly combining propulsion, guidance and an explosive warhead.",
        visual: { colour: make_colour_rgb(119,132,139), glow: make_colour_rgb(255,99,45), draw_script: sc_item_plate_primitive_draw }
    })

    // ITEM: item_mine_charge - Mine Charge
    && sc_item_register({
        identity: { key: "item_mine_charge", name: "Mine Charge" },
        layer: ItemLayer.COMPONENT, type: ItemType.AMMUNITION, cargo: { weight: 7, stack_max: 20 },
        description: "A self-contained explosive assembly intended for deployable mine systems.",
        visual: { colour: make_colour_rgb(124,104,84), glow: make_colour_rgb(255,76,39), draw_script: sc_item_plate_primitive_draw }
    })


    //==================================================
    // SYSTEM MODULES
    //==================================================

    // ITEM: item_engine_governor_mk1 - Engine Governor Mk I
    && sc_item_register({
        identity: { key: "item_engine_governor_mk1", name: "Engine Governor Mk I" },
        layer: ItemLayer.PRODUCT, type: ItemType.MODULE, cargo: { weight: 5, stack_max: 10 },
        description: "A fixed-output engine controller that improves ship acceleration.",

        module: {
            system: ShipSystemType.ENGINES,
            modifiers: [
                { stat: "acceleration", add: 0.04 }
            ]
        },

        visual: { colour: make_colour_rgb(104,153,168), glow: make_colour_rgb(72,226,241), draw_script: sc_item_plate_primitive_draw }
    })

    // ITEM: item_thruster_vectoring_mk1 - Thruster Vectoring Module Mk I
    && sc_item_register({
        identity: { key: "item_thruster_vectoring_mk1", name: "Thruster Vectoring Module Mk I" },
        layer: ItemLayer.PRODUCT, type: ItemType.MODULE, cargo: { weight: 5, stack_max: 10 },
        description: "A fixed-output thrust controller that improves ship rotation speed.",

        module: {
            system: ShipSystemType.THRUSTERS,
            modifiers: [
                { stat: "turn_speed", add: 0.4 }
            ]
        },

        visual: { colour: make_colour_rgb(91,142,160), glow: make_colour_rgb(62,216,247), draw_script: sc_item_plate_primitive_draw }
    })

    // ITEM: item_shield_capacitor_mk1 - Shield Capacitor Mk I
    && sc_item_register({
        identity: { key: "item_shield_capacitor_mk1", name: "Shield Capacitor Mk I" },
        layer: ItemLayer.PRODUCT, type: ItemType.MODULE, cargo: { weight: 6, stack_max: 10 },
        description: "A fixed-output capacitor that improves shield recharge rate.",

        module: {
            system: ShipSystemType.SHIELD_GENERATOR,
            modifiers: [
                { stat: "shield_recharge_rate", add: 0.05 }
            ]
        },

        visual: { colour: make_colour_rgb(76,139,178), glow: make_colour_rgb(55,218,255), draw_script: sc_item_plate_primitive_draw }
    })

    // ITEM: item_reactor_regulator_mk1 - Reactor Regulator Mk I
    && sc_item_register({
        identity: { key: "item_reactor_regulator_mk1", name: "Reactor Regulator Mk I" },
        layer: ItemLayer.PRODUCT, type: ItemType.MODULE, cargo: { weight: 6, stack_max: 10 },
        description: "A fixed-output reactor regulator that improves energy regeneration.",

        module: {
            system: ShipSystemType.REACTOR,
            modifiers: [
                { stat: "energy_regeneration", add: 0.05 }
            ]
        },

        visual: { colour: make_colour_rgb(121,115,166), glow: make_colour_rgb(170,116,255), draw_script: sc_item_plate_primitive_draw }
    })

    // ITEM: item_coolant_module_mk1 - Coolant Module Mk I
    && sc_item_register({
        identity: { key: "item_coolant_module_mk1", name: "Coolant Module Mk I" },
        layer: ItemLayer.PRODUCT, type: ItemType.MODULE, cargo: { weight: 5, stack_max: 10 },
        description: "A fixed-output cooling module that improves heat removal from ship weapons.",

        module: {
            system: ShipSystemType.COOLING,
            modifiers: [
                { stat: "weapon_cooling_rate", add: 0.25 }
            ]
        },

        visual: { colour: make_colour_rgb(87,171,185), glow: make_colour_rgb(88,235,255), draw_script: sc_item_plate_primitive_draw }
    })

    // ITEM: item_weapon_stabilizer_mk1 - Weapon Stabilizer Mk I
    && sc_item_register({
        identity: { key: "item_weapon_stabilizer_mk1", name: "Weapon Stabilizer Mk I" },
        layer: ItemLayer.PRODUCT, type: ItemType.MODULE, cargo: { weight: 5, stack_max: 10 },
        description: "A fixed-output targeting stabilizer that reduces weapon spread.",

        module: {
            system: ShipSystemType.WEAPONS,
            modifiers: [
                { stat: "weapon_spread_multiplier", multiply: 0.95 }
            ]
        },

        visual: { colour: make_colour_rgb(157,125,102), glow: make_colour_rgb(255,169,78), draw_script: sc_item_plate_primitive_draw }
    })

    // ITEM: item_sensor_hardening_mk1 - Sensor Hardening Module Mk I
    && sc_item_register({
        identity: { key: "item_sensor_hardening_mk1", name: "Sensor Hardening Module Mk I" },
        layer: ItemLayer.PRODUCT, type: ItemType.MODULE, cargo: { weight: 4, stack_max: 10 },
        description: "A fixed-output signal processor that reduces sensor disruption duration.",

        module: {
            system: ShipSystemType.SENSORS,
            modifiers: [
                { stat: "sensors_disruption_resistance", add: 0.1 }
            ]
        },

        visual: { colour: make_colour_rgb(86,157,148), glow: make_colour_rgb(70,245,214), draw_script: sc_item_plate_primitive_draw }
    })

    // ITEM: item_drone_command_processor_mk1 - Drone Command Processor Mk I
    && sc_item_register({
        identity: { key: "item_drone_command_processor_mk1", name: "Drone Command Processor Mk I" },
        layer: ItemLayer.PRODUCT, type: ItemType.MODULE, cargo: { weight: 4, stack_max: 10 },
        description: "A fixed-output command processor that reduces drone-bay disruption duration.",

        module: {
            system: ShipSystemType.DRONE_BAY,
            modifiers: [
                { stat: "drone_bay_disruption_resistance", add: 0.1 }
            ]
        },

        visual: { colour: make_colour_rgb(92,135,153), glow: make_colour_rgb(75,213,241), draw_script: sc_item_plate_primitive_draw }
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