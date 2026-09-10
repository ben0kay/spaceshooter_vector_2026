/// @description Draws one source sprite at a requested size during a gas-cloud bake.
function sc_gas_cloud_source_draw(_sprite, _x, _y, _width, _height, _angle, _colour, _alpha)
{
    draw_sprite_ext(
        _sprite,
        0,
        _x,
        _y,
        _width / max(1, sprite_get_width(_sprite)),
        _height / max(1, sprite_get_height(_sprite)),
        _angle,
        _colour,
        _alpha
    );
}

/// @description Generates one reusable detailed gas-cloud patch.
function sc_gas_cloud_sprite_create(_visual)
{
    var _size = _visual.canvas_size;
    var _centre = _size * 0.5;
    var _surface = surface_create(_size, _size);

    if (!surface_exists(_surface))
        return -1;

    var _seed = _visual.seed;

    surface_set_target(_surface);
    draw_clear_alpha(c_black, 0);

    // Large high-resolution blurs establish a smooth foundation.
    for (var _i = 0; _i < 18; ++_i)
    {
        var _direction = sc_space_hash(_seed + _i * 17.31) * 360;
        var _distance = power(
            sc_space_hash(_seed + _i * 43.73),
            1.55
        ) * _size * 0.25;

        var _x = _centre + lengthdir_x(_distance, _direction);
        var _y = _centre + lengthdir_y(_distance * 0.74, _direction);
        var _diameter = lerp(
            _size * 0.28,
            _size * 0.68,
            sc_space_hash(_seed + _i * 67.91)
        );

        var _stretch = lerp(
            0.75,
            1.65,
            sc_space_hash(_seed + _i * 89.17)
        );

        sc_gas_cloud_source_draw(
            s_particle_blur_1024,
            _x,
            _y,
            _diameter * _stretch,
            _diameter / _stretch,
            sc_space_hash(_seed + _i * 101.39) * 360,
            merge_colour(
                _visual.colour_dark,
                _visual.colour_mid,
                sc_space_hash(_seed + _i * 127.53)
            ),
            lerp(
                0.1,
                0.22,
                sc_space_hash(_seed + _i * 149.21)
            )
        );
    }

    // Irregular cloud sprites break up the smooth circular foundation.
    for (var _i = 0; _i < 24; ++_i)
    {
        var _sprite = sc_space_hash(_seed + _i * 167.91) < 0.5
            ? s_particle_cloud_002
            : s_particle_cloud_003;

        var _direction = sc_space_hash(_seed + _i * 181.37) * 360;
        var _distance = power(
            sc_space_hash(_seed + _i * 199.73),
            1.15
        ) * _size * 0.34;

        var _x = _centre + lengthdir_x(_distance, _direction);
        var _y = _centre + lengthdir_y(_distance * 0.72, _direction);
        var _width = lerp(
            _size * 0.16,
            _size * 0.38,
            sc_space_hash(_seed + _i * 223.11)
        );

        var _height = _width * lerp(
            0.38,
            0.72,
            sc_space_hash(_seed + _i * 241.57)
        );

        sc_gas_cloud_source_draw(
            _sprite,
            _x,
            _y,
            _width,
            _height,
            sc_space_hash(_seed + _i * 263.17) * 360,
            merge_colour(
                _visual.colour_dark,
                _visual.colour_mid,
                sc_space_hash(_seed + _i * 281.49)
            ),
            lerp(
                0.07,
                0.17,
                sc_space_hash(_seed + _i * 307.83)
            )
        );
    }

    // Fine smoky wisps join neighbouring cloud masses.
    gpu_set_blendmode(bm_add);

    for (var _i = 0; _i < _visual.wisp_amount; ++_i)
    {
        var _direction = sc_space_hash(_seed + _i * 331.19) * 360;
        var _distance = power(
            sc_space_hash(_seed + _i * 353.61),
            1.25
        ) * _size * 0.32;

        var _x = _centre + lengthdir_x(_distance, _direction);
        var _y = _centre + lengthdir_y(_distance * 0.72, _direction);
        var _width = lerp(
            _size * 0.11,
            _size * 0.3,
            sc_space_hash(_seed + _i * 379.27)
        );

        var _height = _width * lerp(
            0.22,
            0.46,
            sc_space_hash(_seed + _i * 397.53)
        );

        sc_gas_cloud_source_draw(
            s_particle_smokey_wisp_001,
            _x,
            _y,
            _width,
            _height,
            _direction + lerp(
                -55,
                55,
                sc_space_hash(_seed + _i * 419.71)
            ),
            _visual.colour_glow,
            lerp(
                0.035,
                0.11,
                sc_space_hash(_seed + _i * 443.37)
            )
        );
    }

    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
    draw_set_colour(c_white);
    surface_reset_target();

    var _sprite = sprite_create_from_surface(
        _surface,
        0,
        0,
        _size,
        _size,
        false,
        false,
        _centre,
        _centre
    );

    surface_free(_surface);
    return _sprite;
}

/// @description Bakes several visual variations for every environment field.
function sc_environment_field_visual_cache_init()
{
    global.environment_field_visual_cache = {};

    var _keys = variable_struct_get_names(
        global.data.environment_fields
    );

    for (var _i = 0; _i < array_length(_keys); ++_i)
    {
        var _key = _keys[_i];
        var _definition = variable_struct_get(
            global.data.environment_fields,
            _key
        );

        var _variant_amount = max(
            1,
            round(_definition.visual.sprite_variants)
        );

        var _sprites = array_create(_variant_amount, -1);

        for (var _variant = 0;
        _variant < _variant_amount;
        ++_variant)
        {
            var _variant_visual = variable_clone(
                _definition.visual
            );

            _variant_visual.seed = _definition.visual.seed
                + _variant * 1049;

            var _sprite = sc_gas_cloud_sprite_create(
                _variant_visual
            );

            if (!sprite_exists(_sprite))
            {
                sc_environment_field_visual_cache_destroy();

                show_debug_message(
                    "ENVIRONMENT FIELD BAKE ERROR - "
                    + _key
                    + " VARIANT "
                    + string(_variant)
                );

                return false;
            }

            _sprites[_variant] = _sprite;
        }

        variable_struct_set(
            global.environment_field_visual_cache,
            _key,
            {
                sprites: _sprites,
                canvas_size: _definition.visual.canvas_size
            }
        );
    }

    return true;
}

/// @description Returns one baked environmental-field visual cache.
function sc_environment_field_visual_cache_get(_key)
{
    if (!variable_struct_exists(
        global.environment_field_visual_cache,
        _key
    ))
        return undefined;

    return variable_struct_get(
        global.environment_field_visual_cache,
        _key
    );
}

/// @description Deletes every runtime-generated environmental-field sprite.
function sc_environment_field_visual_cache_destroy()
{
    if (!is_struct(global.environment_field_visual_cache))
        return;

    var _keys = variable_struct_get_names(
        global.environment_field_visual_cache
    );

    for (var _i = 0; _i < array_length(_keys); ++_i)
    {
        var _cache = variable_struct_get(
            global.environment_field_visual_cache,
            _keys[_i]
        );

        if (!is_struct(_cache))
            continue;

        for (var _variant = 0;
        _variant < array_length(_cache.sprites);
        ++_variant)
        {
            var _sprite = _cache.sprites[_variant];

            if (sprite_exists(_sprite))
                sprite_delete(_sprite);
        }
    }

    global.environment_field_visual_cache = {};
}