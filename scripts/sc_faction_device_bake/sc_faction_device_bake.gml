/// @description Bakes every registered faction-device visual.
function sc_faction_device_visual_cache_init()
{
    if (variable_global_exists("faction_device_visual_cache"))
        sc_faction_device_visual_cache_destroy();

    global.faction_device_visual_cache = {};
    var _keys = variable_struct_get_names(global.data.devices);

    for (var _i = 0; _i < array_length(_keys); ++_i)
    {
        var _key = _keys[_i];
        var _data = variable_struct_get(global.data.devices,_key);
        var _visual = _data.visual;

        var _cache = {
            base: sc_faction_device_visual_component_bake(
                _key,_data,"base",_visual.bake.base_canvas_size
            ),

            head: sc_faction_device_visual_component_bake(
                _key,_data,"head",_visual.bake.head_canvas_size
            ),

            shield: sc_faction_device_visual_component_bake(
                _key,_data,"shield",_visual.bake.shield_canvas_size
            )
        };

        if (!sprite_exists(_cache.base)
        || !sprite_exists(_cache.head)
        || !sprite_exists(_cache.shield))
        {
            sc_faction_device_visual_cache_destroy();
            return false;
        }

        variable_struct_set(
            global.faction_device_visual_cache,
            _key,
            _cache
        );
    }

    show_debug_message(
        "FACTION DEVICE VISUAL CACHE INITIALIZED - "
        + string(array_length(_keys))
    );

    return true;
}

/// @description Bakes one faction-device visual component.
function sc_faction_device_visual_component_bake(_key,_data,_component,_canvas_size)
{
    var _surface = surface_create(_canvas_size,_canvas_size);

    if (!surface_exists(_surface))
    {
        show_debug_message(
            "FACTION DEVICE BAKE ERROR - "
            + _key
            + " / "
            + _component
        );

        return -1;
    }

    var _visual = _data.visual;
    var _centre = _canvas_size * 0.5;

    surface_set_target(_surface);
    draw_clear_alpha(c_black,0);
    draw_set_alpha(1);
    draw_set_colour(c_white);

    switch (_component)
    {
        case "base":
            _visual.draw.base(
                _centre,
                _centre,
                _visual.radius,
                0,
                _visual
            );
        break;

        case "head":
            _visual.draw.head(
                _centre,
                _centre,
                _visual.radius,
                0,
                _visual
            );
        break;

        case "shield":
            sc_visual_shield_bake_draw(
                _centre,
                _centre,
                _data.collision.radius,
                _data.collision.radius,
                _visual.palette
            );
        break;
    }

    draw_set_alpha(1);
    draw_set_colour(c_white);
    surface_reset_target();

    var _sprite = sprite_create_from_surface(
        _surface,
        0,
        0,
        _canvas_size,
        _canvas_size,
        false,
        false,
        _centre,
        _centre
    );

    surface_free(_surface);
    return _sprite;
}

/// @description Returns one device's shared visual cache.
function sc_faction_device_visual_cache_get(_key)
{
    if (!variable_global_exists("faction_device_visual_cache")
    || !variable_struct_exists(global.faction_device_visual_cache,_key))
        return undefined;

    return variable_struct_get(
        global.faction_device_visual_cache,
        _key
    );
}

/// @description Deletes every generated faction-device sprite.
function sc_faction_device_visual_cache_destroy()
{
    if (!variable_global_exists("faction_device_visual_cache"))
        return;

    var _keys = variable_struct_get_names(
        global.faction_device_visual_cache
    );

    for (var _i = 0; _i < array_length(_keys); ++_i)
    {
        var _cache = variable_struct_get(
            global.faction_device_visual_cache,
            _keys[_i]
        );

        if (sprite_exists(_cache.base)) sprite_delete(_cache.base);
        if (sprite_exists(_cache.head)) sprite_delete(_cache.head);
        if (sprite_exists(_cache.shield)) sprite_delete(_cache.shield);
    }

    global.faction_device_visual_cache = {};
    show_debug_message("FACTION DEVICE VISUAL CACHE DESTROYED");
}