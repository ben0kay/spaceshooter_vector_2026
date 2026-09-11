/// @description Bakes one asteroid material, variant and damage stage.
function sc_asteroid_visual_bake(_data, _variant, _stage)
{
    var _canvas = 256;
    var _centre = _canvas * 0.5;
    var _radius = 108;

    var _surface = surface_create(
        _canvas,
        _canvas
    );

    if (!surface_exists(_surface))
        return -1;

    surface_set_target(_surface);
    draw_clear_alpha(c_black, 0);

    if (sc_asteroid_component_material_enabled(_data))
    {
        sc_asteroid_component_draw(
            _centre,
            _centre,
            _radius,
            _variant,
            _stage,
            _data
        );
    }
    else
    {
        sc_asteroid_primitive_draw(
            _centre,
            _centre,
            _radius,
            _variant mod 6,
            _stage,
            _data.palette
        );
    }

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

/// @description Bakes every registered asteroid material and damage stage.
function sc_asteroid_visual_cache_init()
{
    if (variable_global_exists("asteroid_visual_cache"))
        sc_asteroid_visual_cache_destroy();

    global.asteroid_visual_cache = {};

    var _config = sc_asteroid_component_config();
    var _variant_count = max(
        6,
        _config.variant_count
    );

    var _keys = variable_struct_get_names(
        global.data.asteroids
    );

    for (var _k = 0; _k < array_length(_keys); ++_k)
    {
        var _key = _keys[_k];

        var _data = variable_struct_get(
            global.data.asteroids,
            _key
        );

        var _variants = array_create(
            _variant_count
        );

        for (var _variant = 0;
        _variant < _variant_count;
        ++_variant)
        {
            _variants[_variant] = array_create(
                4,
                -1
            );

            for (var _stage = 0; _stage < 4; ++_stage)
            {
                var _sprite = sc_asteroid_visual_bake(
                    _data,
                    _variant,
                    _stage
                );

                if (!sprite_exists(_sprite))
                {
                    sc_asteroid_visual_cache_destroy();

                    show_debug_message(
                        "ASTEROID BAKE ERROR - "
                        + _key
                    );

                    return false;
                }

                _variants[_variant][_stage] = _sprite;
            }
        }

        variable_struct_set(
            global.asteroid_visual_cache,
            _key,
            _variants
        );
    }

    show_debug_message(
        "ASTEROID VISUAL CACHE BAKED - "
        + string(_variant_count)
        + " VARIANTS"
    );

    return true;
}

/// @description Returns one cached asteroid sprite.
function sc_asteroid_visual_cache_get(
    _key,
    _variant,
    _stage
)
{
    var _variants = variable_struct_get(
        global.asteroid_visual_cache,
        _key
    );

    var _variant_index = _variant
        mod array_length(_variants);

    var _stage_index = clamp(
        _stage,
        0,
        array_length(_variants[_variant_index]) - 1
    );

    return _variants[
        _variant_index
    ][
        _stage_index
    ];
}

/// @description Deletes every generated asteroid sprite.
function sc_asteroid_visual_cache_destroy()
{
    if (!variable_global_exists("asteroid_visual_cache"))
        return;

    var _keys = variable_struct_get_names(
        global.asteroid_visual_cache
    );

    for (var _k = 0; _k < array_length(_keys); ++_k)
    {
        var _variants = variable_struct_get(
            global.asteroid_visual_cache,
            _keys[_k]
        );

        for (var _variant = 0;
        _variant < array_length(_variants);
        ++_variant)
        {
            for (var _stage = 0;
            _stage < array_length(_variants[_variant]);
            ++_stage)
            {
                var _sprite = _variants[
                    _variant
                ][
                    _stage
                ];

                if (sprite_exists(_sprite))
                    sprite_delete(_sprite);
            }
        }
    }

    global.asteroid_visual_cache = {};

    show_debug_message(
        "ASTEROID VISUAL CACHE DESTROYED"
    );
}