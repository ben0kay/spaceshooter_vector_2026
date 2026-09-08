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

/// @description Registers the first complete iron production chain.
function sc_recipe_register_all()
{
    return sc_recipe_register({ identity: { key: "recipe_refined_iron", name: "Refined Iron" }, service: FacilityService.REFINERY, duration: 180, inputs: [["item_iron", 4]], outputs: [["item_refined_iron", 1]] })
    && sc_recipe_register({ identity: { key: "recipe_iron_plate", name: "Iron Plate" }, service: FacilityService.FABRICATOR, duration: 240, inputs: [["item_refined_iron", 2]], outputs: [["item_iron_plate", 1]] })
    && sc_recipe_register({ identity: { key: "recipe_armour_plate", name: "Armour Plate" }, service: FacilityService.FABRICATOR, duration: 360, inputs: [["item_iron_plate", 3]], outputs: [["item_armour_plate", 1]] });
}