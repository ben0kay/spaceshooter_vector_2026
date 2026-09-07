/// @description Creates all baked world-structure sprites.
function sc_world_structure_visual_cache_init()
{
    if (variable_global_exists("world_structure_visual_cache"))
        sc_world_structure_visual_cache_destroy();

    global.world_structure_visual_cache = {};

    var _keys = variable_struct_get_names(global.data.structures);

    for (var _i = 0; _i < array_length(_keys); ++_i)
    {
        var _key = _keys[_i];
        var _data = variable_struct_get(global.data.structures, _key);
        var _visual = _data.visual;
        var _surface = surface_create(
            _visual.canvas_width,
            _visual.canvas_height
        );

        if (!surface_exists(_surface))
        {
            show_debug_message("WORLD STRUCTURE BAKE ERROR - surface failed: " + _key);
            sc_world_structure_visual_cache_destroy();
            return false;
        }

        var _centre_x = _visual.canvas_width * 0.5;
        var _centre_y = _visual.canvas_height * 0.5;

        surface_set_target(_surface);
        draw_clear_alpha(c_black, 0);
        draw_set_alpha(1);
        draw_set_colour(c_white);

        _visual.draw_script(
            _centre_x,
            _centre_y,
            _visual
        );

        draw_set_alpha(1);
        draw_set_colour(c_white);
        surface_reset_target();

        var _sprite = sprite_create_from_surface(
            _surface,
            0,
            0,
            _visual.canvas_width,
            _visual.canvas_height,
            false,
            false,
            _centre_x,
            _centre_y
        );

        surface_free(_surface);

        if (!sprite_exists(_sprite))
        {
            show_debug_message("WORLD STRUCTURE BAKE ERROR - sprite failed: " + _key);
            sc_world_structure_visual_cache_destroy();
            return false;
        }

        variable_struct_set(
            global.world_structure_visual_cache,
            _key,
            _sprite
        );
    }

    show_debug_message("WORLD STRUCTURE VISUAL CACHE INITIALIZED");
    return true;
}

/// @description Returns one shared baked world-structure sprite.
function sc_world_structure_visual_cache_get(_key)
{
    if (!variable_global_exists("world_structure_visual_cache")
    || !variable_struct_exists(global.world_structure_visual_cache, _key))
        return -1;

    return variable_struct_get(
        global.world_structure_visual_cache,
        _key
    );
}

/// @description Deletes every generated world-structure sprite.
function sc_world_structure_visual_cache_destroy()
{
    if (!variable_global_exists("world_structure_visual_cache"))
        return;

    var _keys = variable_struct_get_names(
        global.world_structure_visual_cache
    );

    for (var _i = 0; _i < array_length(_keys); ++_i)
    {
        var _sprite = variable_struct_get(
            global.world_structure_visual_cache,
            _keys[_i]
        );

        if (sprite_exists(_sprite))
            sprite_delete(_sprite);
    }

    global.world_structure_visual_cache = {};
    show_debug_message("WORLD STRUCTURE VISUAL CACHE DESTROYED");
}