/// @description Generates one reusable soft gas-cloud sprite.
function sc_gas_cloud_sprite_create(_visual)
{
    var _size = _visual.canvas_size;
    var _centre = _size * 0.5;
    var _surface = surface_create(_size, _size);

    if (!surface_exists(_surface))
        return -1;

    var _blur_width = max(1, sprite_get_width(s_blur));
    var _blur_height = max(1, sprite_get_height(s_blur));
    var _seed = _visual.seed;

    surface_set_target(_surface);
    draw_clear_alpha(c_black, 0);

    // Broad overlapping smoke masses form the cloud body.
    for (var _i = 0; _i < _visual.body_amount; ++_i)
    {
        var _direction = sc_space_hash(_seed + _i * 17.31) * 360;
        var _distance = power(sc_space_hash(_seed + _i * 43.73), 1.5) * _size * 0.31;
        var _x = _centre + lengthdir_x(_distance, _direction);
        var _y = _centre + lengthdir_y(_distance * 0.72, _direction);
        var _diameter = lerp(_size * 0.13, _size * 0.36, sc_space_hash(_seed + _i * 67.91));
        var _stretch = lerp(0.72, 1.7, sc_space_hash(_seed + _i * 89.17));
        var _angle = sc_space_hash(_seed + _i * 101.39) * 360;
        var _mix = sc_space_hash(_seed + _i * 127.53);
        var _colour = merge_colour(_visual.colour_dark, _visual.colour_mid, _mix);

        draw_sprite_ext(
            s_blur, 0,
            _x, _y,
            (_diameter / _blur_width) * _stretch,
            (_diameter / _blur_height) / _stretch,
            _angle,
            _colour,
            lerp(0.11, 0.25, sc_space_hash(_seed + _i * 149.21))
        );
    }

    // Small additive wisps provide ionized detail inside the cloud.
    gpu_set_blendmode(bm_add);

    for (var _i = 0; _i < _visual.wisp_amount; ++_i)
    {
        var _direction = sc_space_hash(_seed + _i * 173.11) * 360;
        var _distance = power(sc_space_hash(_seed + _i * 191.37), 1.8) * _size * 0.27;
        var _x = _centre + lengthdir_x(_distance, _direction);
        var _y = _centre + lengthdir_y(_distance * 0.68, _direction);
        var _diameter = lerp(_size * 0.04, _size * 0.13, sc_space_hash(_seed + _i * 211.63));
        var _stretch = lerp(1.2, 2.8, sc_space_hash(_seed + _i * 229.87));

        draw_sprite_ext(
            s_blur, 0,
            _x, _y,
            (_diameter / _blur_width) * _stretch,
            (_diameter / _blur_height) / _stretch,
            sc_space_hash(_seed + _i * 251.43) * 360,
            _visual.colour_glow,
            lerp(0.07, 0.17, sc_space_hash(_seed + _i * 269.71))
        );
    }

    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
    draw_set_colour(c_white);
    surface_reset_target();

    var _sprite = sprite_create_from_surface(
        _surface,
        0, 0,
        _size, _size,
        false, false,
        _centre, _centre
    );

    surface_free(_surface);
    return _sprite;
}

/// @description Bakes every registered environmental-field visual once.
function sc_environment_field_visual_cache_init()
{
    global.environment_field_visual_cache = {};

    var _keys = variable_struct_get_names(global.data.environment_fields);

    for (var _i = 0; _i < array_length(_keys); ++_i)
    {
        var _key = _keys[_i];
        var _definition = variable_struct_get(global.data.environment_fields, _key);
        var _sprite = sc_gas_cloud_sprite_create(_definition.visual);

        if (_sprite == -1)
        {
            show_debug_message("ENVIRONMENT FIELD BAKE ERROR - " + _key);
            return false;
        }

        variable_struct_set(
            global.environment_field_visual_cache,
            _key,
            {
                sprite: _sprite,
                canvas_size: _definition.visual.canvas_size
            }
        );
    }

    return true;
}

/// @description Returns one baked environmental-field visual.
function sc_environment_field_visual_cache_get(_key)
{
    if (!variable_struct_exists(global.environment_field_visual_cache, _key))
        return undefined;

    return variable_struct_get(global.environment_field_visual_cache, _key);
}

/// @description Deletes every runtime-generated environmental-field sprite.
function sc_environment_field_visual_cache_destroy()
{
    if (!is_struct(global.environment_field_visual_cache))
        return;

    var _keys = variable_struct_get_names(global.environment_field_visual_cache);

    for (var _i = 0; _i < array_length(_keys); ++_i)
    {
        var _cache = variable_struct_get(
            global.environment_field_visual_cache,
            _keys[_i]
        );

        if (is_struct(_cache) && sprite_exists(_cache.sprite))
            sprite_delete(_cache.sprite);
    }

    global.environment_field_visual_cache = {};
}