/// @description Bakes every registered projectile visual and the shared gradient trail.
function sc_projectile_visual_cache_init()
{
    if (variable_global_exists("projectile_visual_cache")
    || variable_global_exists("projectile_trail_cache"))
        sc_projectile_visual_cache_destroy();

    global.projectile_visual_cache = {};
    global.projectile_trail_cache = sc_projectile_trail_visual_bake();

    if (!is_struct(global.projectile_trail_cache))
    {
        show_debug_message("PROJECTILE TRAIL CACHE ERROR - bake failed");
        return false;
    }

    var _keys = variable_struct_get_names(global.data.projectiles);

    for (var _i = 0; _i < array_length(_keys); _i++)
    {
        var _key = _keys[_i];
        var _data = variable_struct_get(global.data.projectiles, _key);
        var _visual = _data.visual;
        var _frame_count = max(1, round(_visual.bake.frames));
        var _cache = {
            sprites: array_create(_frame_count, -1),
            frame_speed: max(1, round(_visual.bake.frame_speed))
        };

        for (var _frame = 0; _frame < _frame_count; _frame++)
            _cache.sprites[_frame] = sc_projectile_visual_frame_bake(_visual, _frame, _frame_count);

        variable_struct_set(global.projectile_visual_cache, _key, _cache);
        show_debug_message("PROJECTILE VISUAL CACHE BAKED - " + _key);
    }

    return true;
}

/// @description Bakes one reusable white trail fading from its attached end to transparency.
function sc_projectile_trail_visual_bake()
{
    var _width = 256;
    var _height = 16;
    var _surface = surface_create(_width, _height);

    if (!surface_exists(_surface))
        return undefined;

    surface_set_target(_surface);
    draw_clear_alpha(c_black, 0);
    draw_set_colour(c_white);

    for (var _x = 0; _x < _width; _x++)
    {
        var _progress = _x / (_width - 1);
        var _alpha = power(_progress, 0.4);

        draw_set_alpha(_alpha);
        draw_line(_x, 0, _x, _height - 1);
    }

    draw_set_alpha(1);
    draw_set_colour(c_white);
    surface_reset_target();

    // Origin sits on the bright attached end so the sprite extends backwards.
    var _sprite = sprite_create_from_surface(
        _surface,
        0, 0,
        _width, _height,
        false, false,
        _width - 1,
        _height * 0.5
    );

    surface_free(_surface);

    if (!sprite_exists(_sprite))
        return undefined;

    return {
        sprite: _sprite,
        width: _width,
        height: _height
    };
}

/// @description Bakes one registered projectile animation frame.
function sc_projectile_visual_frame_bake(_visual, _frame, _frame_count)
{
    var _canvas_size = _visual.bake.canvas_size;
    var _surface = surface_create(_canvas_size, _canvas_size);
    if (!surface_exists(_surface)) return -1;

    var _centre = _canvas_size * 0.5;

    surface_set_target(_surface);
    draw_clear_alpha(c_black, 0);
    draw_set_alpha(1);
    draw_set_colour(c_white);

    _visual.draw_script(_centre, _centre, 0, _visual, _frame, _frame_count);

    draw_set_alpha(1);
    draw_set_colour(c_white);
    surface_reset_target();

    var _sprite = sprite_create_from_surface(
        _surface,
        0, 0,
        _canvas_size, _canvas_size,
        false, false,
        _centre, _centre
    );

    surface_free(_surface);
    return _sprite;
}

/// @description Returns one registered projectile's shared visual cache.
function sc_projectile_visual_cache_get(_projectile_key)
{
    return variable_struct_get(global.projectile_visual_cache, _projectile_key);
}

/// @description Returns the shared baked projectile-trail cache.
function sc_projectile_trail_cache_get()
{
    return global.projectile_trail_cache;
}

/// @description Deletes all generated projectile and trail sprites.
function sc_projectile_visual_cache_destroy()
{
    if (variable_global_exists("projectile_visual_cache"))
    {
        var _keys = variable_struct_get_names(global.projectile_visual_cache);

        for (var _i = 0; _i < array_length(_keys); _i++)
        {
            var _cache = variable_struct_get(global.projectile_visual_cache, _keys[_i]);

            for (var _frame = 0; _frame < array_length(_cache.sprites); _frame++)
            {
                if (sprite_exists(_cache.sprites[_frame]))
                    sprite_delete(_cache.sprites[_frame]);
            }
        }

        global.projectile_visual_cache = {};
    }

    if (variable_global_exists("projectile_trail_cache")
    && is_struct(global.projectile_trail_cache))
    {
        var _trail_sprite = global.projectile_trail_cache.sprite;

        if (sprite_exists(_trail_sprite))
            sprite_delete(_trail_sprite);

        global.projectile_trail_cache = undefined;
    }

    show_debug_message("PROJECTILE VISUAL CACHE DESTROYED");
}