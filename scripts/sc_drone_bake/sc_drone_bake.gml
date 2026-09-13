/*
DRONE VISUAL BAKING

Each registered drone body is rendered once during game initialization.
Runtime fields, targeting indicators and health bars remain dynamically drawn.
*/

/// @description Bakes every registered drone body into a shared sprite cache.
function sc_drone_visual_cache_init()
{
    if (variable_global_exists("drone_visual_cache"))
        sc_drone_visual_cache_destroy();

    global.drone_visual_cache = {};
    var _keys = variable_struct_get_names(global.data.drones);

    for (var _i = 0; _i < array_length(_keys); ++_i)
    {
        var _key = _keys[_i];
        var _definition = variable_struct_get(global.data.drones,_key);
        var _sprite = sc_drone_visual_bake(_key,_definition);

        if (!sprite_exists(_sprite))
        {
            sc_drone_visual_cache_destroy();
            return false;
        }

        variable_struct_set(global.drone_visual_cache,_key,_sprite);
    }

    show_debug_message(
        "DRONE VISUAL CACHE INITIALIZED - "
        +string(array_length(_keys))
    );

    return true;
}

/// @description Bakes one registered drone's static primitive body.
function sc_drone_visual_bake(_key,_definition)
{
    var _visual = _definition.visual;
    var _canvas_size = _visual.bake.canvas_size;
    var _surface = surface_create(_canvas_size,_canvas_size);

    if (!surface_exists(_surface))
    {
        show_debug_message("DRONE BAKE ERROR - "+_key);
        return -1;
    }

    var _centre = _canvas_size*0.5;

    surface_set_target(_surface);
    draw_clear_alpha(c_black,0);
    draw_set_alpha(1);
    draw_set_colour(c_white);

    _visual.draw_script(
        _centre,
        _centre,
        _visual.radius,
        0,
        _visual
    );

    gpu_set_blendmode(bm_normal);
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

/// @description Returns one drone's shared baked body sprite.
function sc_drone_visual_cache_get(_key)
{
    return variable_struct_get(
        global.drone_visual_cache,
        _key
    );
}

/// @description Deletes every generated drone body sprite.
function sc_drone_visual_cache_destroy()
{
    if (!variable_global_exists("drone_visual_cache"))
        return;

    var _keys = variable_struct_get_names(
        global.drone_visual_cache
    );

    for (var _i = 0; _i < array_length(_keys); ++_i)
    {
        var _sprite = variable_struct_get(
            global.drone_visual_cache,
            _keys[_i]
        );

        if (sprite_exists(_sprite))
            sprite_delete(_sprite);
    }

    global.drone_visual_cache = {};
    show_debug_message("DRONE VISUAL CACHE DESTROYED");
}