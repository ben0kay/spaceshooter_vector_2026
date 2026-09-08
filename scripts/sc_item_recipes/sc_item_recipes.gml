/*
MANUFACTURING RECIPES

Recipes contain only data.
Facilities decide which service types they provide.
*/

/// @description Registers one manufacturing recipe.
function sc_recipe_register(_data)
{
    var _key = _data.identity.key;

    if (variable_struct_exists(global.data.recipes, _key))
    {
        show_debug_message("RECIPE REGISTRATION ERROR - duplicate key: " + _key);
        return false;
    }

    variable_struct_set(global.data.recipes, _key, _data);
    return true;
}

/// @description Returns one registered recipe.
function sc_recipe_get(_key)
{
    if (!variable_struct_exists(global.data.recipes, _key))
    {
        show_debug_message("RECIPE ERROR - unknown key: " + _key);
        return undefined;
    }

    return variable_struct_get(global.data.recipes, _key);
}

/// @description Registers the initial industrial production tree.
function sc_recipe_register_all()
{
    return sc_recipe_register({ identity: { key: "recipe_refined_iron", name: "Refined Iron" }, service: FacilityService.REFINERY, duration: 180, inputs: [["item_iron", 4]], outputs: [["item_refined_iron", 1]] })
    && sc_recipe_register({ identity: { key: "recipe_refined_copper", name: "Refined Copper" }, service: FacilityService.REFINERY, duration: 180, inputs: [["item_copper", 4]], outputs: [["item_refined_copper", 1]] })
    && sc_recipe_register({ identity: { key: "recipe_silicon_wafer", name: "Silicon Wafer" }, service: FacilityService.REFINERY, duration: 180, inputs: [["item_silicon", 3]], outputs: [["item_silicon_wafer", 1]] })
    && sc_recipe_register({ identity: { key: "recipe_carbon_composite", name: "Carbon Composite" }, service: FacilityService.REFINERY, duration: 210, inputs: [["item_carbon", 4]], outputs: [["item_carbon_composite", 1]] })

    && sc_recipe_register({ identity: { key: "recipe_iron_plate", name: "Iron Plate" }, service: FacilityService.FABRICATOR, duration: 240, inputs: [["item_refined_iron", 2]], outputs: [["item_iron_plate", 1]] })
    && sc_recipe_register({ identity: { key: "recipe_copper_wire", name: "Copper Wire" }, service: FacilityService.FABRICATOR, duration: 150, inputs: [["item_refined_copper", 1]], outputs: [["item_copper_wire", 2]] })
    && sc_recipe_register({ identity: { key: "recipe_copper_coil", name: "Copper Coil" }, service: FacilityService.FABRICATOR, duration: 210, inputs: [["item_refined_copper", 2]], outputs: [["item_copper_coil", 1]] })
    && sc_recipe_register({ identity: { key: "recipe_circuit_board", name: "Circuit Board" }, service: FacilityService.FABRICATOR, duration: 270, inputs: [["item_copper_wire", 2], ["item_silicon_wafer", 1]], outputs: [["item_circuit_board", 1]] })
    && sc_recipe_register({ identity: { key: "recipe_motor", name: "Motor" }, service: FacilityService.FABRICATOR, duration: 300, inputs: [["item_refined_iron", 1], ["item_copper_coil", 1]], outputs: [["item_motor", 1]] })

    && sc_recipe_register({ identity: { key: "recipe_armour_plate", name: "Armour Plate" }, service: FacilityService.FABRICATOR, duration: 360, inputs: [["item_iron_plate", 3]], outputs: [["item_armour_plate", 1]] })
    && sc_recipe_register({ identity: { key: "recipe_lightweight_armour_plate", name: "Lightweight Armour Plate" }, service: FacilityService.FABRICATOR, duration: 420, inputs: [["item_carbon_composite", 2], ["item_iron_plate", 1]], outputs: [["item_lightweight_armour_plate", 1]] })
    && sc_recipe_register({ identity: { key: "recipe_radar_array", name: "Radar Array" }, service: FacilityService.FABRICATOR, duration: 420, inputs: [["item_iron_plate", 1], ["item_circuit_board", 1]], outputs: [["item_radar_array", 1]] });
}