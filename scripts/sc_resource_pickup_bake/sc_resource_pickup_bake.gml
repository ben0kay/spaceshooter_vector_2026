/*
ITEM VISUAL BAKING

Authored s_item_[name] sprites override primitive-baked fallbacks.
Only generated runtime sprites are deleted during cleanup.
*/

/// @description Returns the conventional authored sprite name for one item.
function sc_item_visual_sprite_name_get(_item_key)
{
    var _name = _item_key;

    if (string_copy(_name, 1, 5) == "item_")
        _name = string_delete(_name, 1, 5);

    return "s_item_" + _name;
}

/// @description Bakes one registered item visual variant.
function sc_resource_pickup_visual_bake(_definition, _variant)
{
    var _canvas = 64;
    var _centre = _canvas * 0.5;
    var _surface = surface_create(_canvas, _canvas);

    if (!surface_exists(_surface)) return -1;

    surface_set_target(_surface);
    draw_clear_alpha(c_black, 0);

    _definition.visual.draw_script(
        _centre,
        _centre,
        14,
        _variant,
        _definition.visual
    );

    draw_set_alpha(1);
    draw_set_colour(c_white);
    surface_reset_target();

    var _sprite = sprite_create_from_surface(
        _surface,
        0,
        0,
        _canvas,
        _canvas,
        false,
        false,
        _centre,
        _centre
    );

    surface_free(_surface);
    return _sprite;
}

/// @description Resolves authored sprites and bakes missing item visuals.
function sc_resource_pickup_visual_cache_init()
{
    if (variable_global_exists("resource_pickup_visual_cache"))
        sc_resource_pickup_visual_cache_destroy();

    global.resource_pickup_visual_cache = {};
    var _keys = variable_struct_get_names(global.data.items);

    for (var _k = 0; _k < array_length(_keys); ++_k)
    {
        var _key = _keys[_k];
        var _definition = variable_struct_get(global.data.items, _key);
        var _authored = asset_get_index(sc_item_visual_sprite_name_get(_key));

        if (sprite_exists(_authored))
        {
            variable_struct_set(global.resource_pickup_visual_cache, _key, {
                sprites: array_create(4, _authored),
                generated: false
            });

            continue;
        }

        var _entry = {
            sprites: array_create(4, -1),
            generated: true
        };

        variable_struct_set(global.resource_pickup_visual_cache, _key, _entry);

        for (var _variant = 0; _variant < 4; ++_variant)
        {
            var _sprite = sc_resource_pickup_visual_bake(_definition, _variant);

            if (!sprite_exists(_sprite))
            {
                sc_resource_pickup_visual_cache_destroy();
                show_debug_message("ITEM VISUAL BAKE ERROR - " + _key + " VARIANT " + string(_variant));
                return false;
            }

            _entry.sprites[_variant] = _sprite;
        }
    }

    show_debug_message("ITEM VISUAL CACHE READY");
    return true;
}

/// @description Returns one resolved authored or generated item sprite.
function sc_resource_pickup_visual_cache_get(_item_key, _variant)
{
    var _entry = variable_struct_get(global.resource_pickup_visual_cache, _item_key);
    return _entry.sprites[_variant mod array_length(_entry.sprites)];
}

/// @description Deletes only generated item sprites.
function sc_resource_pickup_visual_cache_destroy()
{
    if (!variable_global_exists("resource_pickup_visual_cache")) return;

    var _keys = variable_struct_get_names(global.resource_pickup_visual_cache);

    for (var _k = 0; _k < array_length(_keys); ++_k)
    {
        var _entry = variable_struct_get(global.resource_pickup_visual_cache, _keys[_k]);
        if (!_entry.generated) continue;

        for (var _i = 0; _i < array_length(_entry.sprites); ++_i)
            if (sprite_exists(_entry.sprites[_i]))
                sprite_delete(_entry.sprites[_i]);
    }

    global.resource_pickup_visual_cache = {};
    show_debug_message("ITEM VISUAL CACHE DESTROYED");
}