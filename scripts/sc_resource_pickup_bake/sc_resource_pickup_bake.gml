/*
RESOURCE PICKUP BAKING

Bakes four visual fragment variants for every registered cargo item.
Runtime pickup objects only draw cached sprites.
*/

/// @description Bakes one registered resource pickup variant.
function sc_resource_pickup_visual_bake(_definition, _variant)
{
    var _canvas = 64;
    var _centre = _canvas * 0.5;
    var _surface = surface_create(_canvas, _canvas);

    if (!surface_exists(_surface)) return -1;

    surface_set_target(_surface);
    draw_clear_alpha(c_black, 0);

    sc_resource_pickup_primitive_draw(
        _centre,
        _centre,
        12,
        _variant,
        _definition.visual
    );

    surface_reset_target();

    var _sprite = sprite_create_from_surface(
        _surface,
        0, 0,
        _canvas, _canvas,
        false, false,
        _centre, _centre
    );

    surface_free(_surface);
    return _sprite;
}

/// @description Bakes every registered resource pickup and fragment variant.
function sc_resource_pickup_visual_cache_init()
{
    if (variable_global_exists("resource_pickup_visual_cache"))
        sc_resource_pickup_visual_cache_destroy();

    global.resource_pickup_visual_cache = {};
    var _keys = variable_struct_get_names(global.data.items);

    for (var _k = 0; _k < array_length(_keys); _k++)
    {
        var _key = _keys[_k];
        var _definition = variable_struct_get(global.data.items, _key);
        var _variants = array_create(4, -1);

        for (var _variant = 0; _variant < 4; _variant++)
        {
            var _sprite = sc_resource_pickup_visual_bake(
                _definition,
                _variant
            );

            if (!sprite_exists(_sprite))
            {
                sc_resource_pickup_visual_cache_destroy();
                show_debug_message(
                    "RESOURCE PICKUP BAKE ERROR - "
                    + _key
                    + " VARIANT "
                    + string(_variant)
                );

                return false;
            }

            _variants[_variant] = _sprite;
        }

        variable_struct_set(
            global.resource_pickup_visual_cache,
            _key,
            _variants
        );
    }

    show_debug_message("RESOURCE PICKUP VISUAL CACHE BAKED");
    return true;
}

/// @description Returns one cached resource pickup variant.
function sc_resource_pickup_visual_cache_get(_item_key, _variant)
{
    return variable_struct_get(
        global.resource_pickup_visual_cache,
        _item_key
    )[_variant];
}

/// @description Deletes every generated resource pickup sprite.
function sc_resource_pickup_visual_cache_destroy()
{
    if (!variable_global_exists("resource_pickup_visual_cache")) return;

    var _keys = variable_struct_get_names(
        global.resource_pickup_visual_cache
    );

    for (var _k = 0; _k < array_length(_keys); _k++)
    {
        var _variants = variable_struct_get(
            global.resource_pickup_visual_cache,
            _keys[_k]
        );

        for (var _variant = 0; _variant < array_length(_variants); _variant++)
        {
            var _sprite = _variants[_variant];

            if (sprite_exists(_sprite))
                sprite_delete(_sprite);
        }
    }

    global.resource_pickup_visual_cache = {};
    show_debug_message("RESOURCE PICKUP VISUAL CACHE DESTROYED");
}