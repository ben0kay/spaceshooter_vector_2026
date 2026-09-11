/*
ENVIRONMENT GAS CLOUDS

Registers keyed gas-cloud definitions, bakes their reusable artwork and
draws generic environmental-field instances.

Gameplay interference will be connected separately after visuals are tested.
*/

/// @description Registers one reusable environmental-field definition.
function sc_environment_field_register(_definition)
{
    if (!is_struct(_definition)
    || !variable_struct_exists(_definition, "identity")
    || !variable_struct_exists(_definition.identity, "key"))
    {
        show_debug_message("ENVIRONMENT FIELD REGISTRATION ERROR - invalid definition");
        return false;
    }

    var _key = _definition.identity.key;

    if (variable_struct_exists(global.data.environment_fields, _key))
    {
        show_debug_message("ENVIRONMENT FIELD REGISTRATION ERROR - duplicate key: " + _key);
        return false;
    }

    variable_struct_set(global.data.environment_fields, _key, _definition);
    return true;
}

/// @description Registers the initial keyed gas-cloud definitions.
function sc_gas_cloud_register_all()
{
    if (!sc_environment_field_register({
        identity: {
            key: "environment_gas_ionized",
            name: "Ionized Gas Cloud",
            type: EnvironmentFieldType.GAS
        },

        interference: {
            detection_multiplier: 0.55,
            targeting_multiplier: 0.75,
            forget_multiplier: 0.7,
            alert_share_multiplier: 0.45,

            radar_strength: 0.75,
            radar_boundary_fade: 0.22
        },

        visual: {
            canvas_size: 768,
            seed: 704,

            colour_dark: make_colour_rgb(8,34,46),
            colour_mid: make_colour_rgb(18,100,122),
            colour_glow: make_colour_rgb(48,190,210),

            body_amount: 72,
            wisp_amount: 26,

            // Individual cloud patches.
            alpha_min: 0.32,
            alpha_max: 0.72,

            sprite_variants: 4,

            patch_spacing_sparse: 1850,
            patch_spacing_dense: 1350,
            patch_size_min: 2800,
            patch_size_max: 4200,
            patch_aspect_min: 0.72,
            patch_aspect_max: 1.28,

            formation_chance_min: 0.08,
            formation_chance_max: 0.28,
            formation_scale: 1.35,

            // Continuous background haze across the complete gas field.
            field_haze_alpha_min: 0.05,
            field_haze_alpha_max: 0.15,

            // Faint foreground haze when the player is inside.
            player_haze_size: 2400,
            player_haze_alpha_min: 0.025,
            player_haze_alpha_max: 0.085,

            drift_amount: 0.035,
            drift_speed: 0.012,
            pulse_amount: 0.035,
            pulse_speed: 0.01
        }
    }))
        return false;

    return true;
}

/// @description Creates overlapping cloud layers throughout one gas ellipse.
function sc_gas_cloud_patches_create(_seed, _radius_x, _radius_y, _density, _visual, _variant_amount)
{
    var _patches = [];
    var _spacing = lerp(
        _visual.patch_spacing_sparse,
        _visual.patch_spacing_dense,
        _density
    );

    var _columns = ceil((_radius_x * 2) / _spacing);
    var _rows = ceil((_radius_y * 2) / _spacing);
    var _start_x = -_columns * _spacing * 0.5;
    var _start_y = -_rows * _spacing * 0.5;
    var _index = 0;

    for (var _column = 0; _column <= _columns; ++_column)
    {
        for (var _row = 0; _row <= _rows; ++_row)
        {
            var _local_x = _start_x + _column * _spacing;
            var _local_y = _start_y + _row * _spacing;

            // Offset alternate rows to prevent obvious square placement.
            if (_row mod 2 == 1)
                _local_x += _spacing * 0.5;

            var _jitter_x = lerp(
                -_spacing * 0.27,
                _spacing * 0.27,
                sc_space_hash(_seed + _index * 19.31)
            );

            var _jitter_y = lerp(
                -_spacing * 0.27,
                _spacing * 0.27,
                sc_space_hash(_seed + _index * 43.77)
            );

            _local_x += _jitter_x;
            _local_y += _jitter_y;

            var _normalized_x = _local_x / max(1, _radius_x);
            var _normalized_y = _local_y / max(1, _radius_y);
            var _distance_sq = _normalized_x * _normalized_x
                + _normalized_y * _normalized_y;

            // Slightly exceed the logical boundary to avoid a hard visual edge.
            if (_distance_sq <= 1.08)
            {
                var _formation_chance = lerp(
                    _visual.formation_chance_min,
                    _visual.formation_chance_max,
                    _density
                );

                var _formation = sc_space_hash(
                    _seed + _index * 67.93
                ) <= _formation_chance;

                var _size = lerp(
                    _visual.patch_size_min,
                    _visual.patch_size_max,
                    sc_space_hash(_seed + _index * 89.17)
                );

                if (_formation)
                    _size *= _visual.formation_scale;

                var _aspect = lerp(
                    _visual.patch_aspect_min,
                    _visual.patch_aspect_max,
                    sc_space_hash(_seed + _index * 103.41)
                );

                var _variant = clamp(
                    floor(
                        sc_space_hash(_seed + _index * 127.59)
                        * _variant_amount
                    ),
                    0,
                    _variant_amount - 1
                );

                array_push(
                    _patches,
                    {
                        local_x: _local_x,
                        local_y: _local_y,

                        width: _size * _aspect,
                        height: _size / _aspect,

                        angle: sc_space_hash(
                            _seed + _index * 149.83
                        ) * 360,

                        alpha: lerp(
                            0.48,
                            0.9,
                            sc_space_hash(_seed + _index * 173.17)
                        ),

                        variant: _variant,
                        formation: _formation,

                        phase: sc_space_hash(
                            _seed + _index * 191.53
                        ) * 360
                    }
                );
            }

            ++_index;
        }
    }

    return _patches;
}

/// @description Initializes one generic environmental-field instance.
function sc_environment_field_init(_field, _create)
{
    if (!is_struct(_create)
    || !variable_struct_exists(_create, "key")
    || !variable_struct_exists(
        global.data.environment_fields,
        _create.key
    ))
    {
        show_debug_message("ENVIRONMENT FIELD INITIALIZATION ERROR");
        return false;
    }

    var _definition = variable_struct_get(
        global.data.environment_fields,
        _create.key
    );

    var _cache = sc_environment_field_visual_cache_get(
        _create.key
    );

    if (!is_struct(_cache))
    {
        show_debug_message(
            "ENVIRONMENT FIELD CACHE ERROR - " + _create.key
        );

        return false;
    }

    var _radius_x = max(64, _create.radius_x);
    var _radius_y = max(64, _create.radius_y);
    var _density = clamp(_create.density, 0, 1);

    var _phase = variable_struct_exists(_create, "phase")
        ? _create.phase
        : random(360);

    var _variant_amount = array_length(_cache.sprites);

    _field.environment_field = {
        key: _create.key,
        identity: variable_clone(_definition.identity),
        interference: variable_clone(_definition.interference),
        visual: variable_clone(_definition.visual),

        radius_x: _radius_x,
        radius_y: _radius_y,

        angle: variable_struct_exists(_create, "angle")
            ? _create.angle
            : 0,

        density: _density,

        runtime: {
            sprites: _cache.sprites,
            canvas_size: _cache.canvas_size,
            phase: _phase,

            patches: sc_gas_cloud_patches_create(
                _definition.visual.seed + _phase * 17.31,
                _radius_x,
                _radius_y,
                _density,
                _definition.visual,
                _variant_amount
            )
        }
    };

    // Gas remains above ships very faintly so they appear inside it.
    _field.depth = 20;
    _field.initialized = true;
    return true;
}

/// @description Creates one generic environmental field from a registered key.
function sc_environment_field_create(_key, _x, _y, _layer, _radius_x, _radius_y, _angle, _density)
{
    return instance_create_layer(
        _x,
        _y,
        _layer,
        o_environment_field,
        {
            environment_field_create: {
                key: _key,
                radius_x: _radius_x,
                radius_y: _radius_y,
                angle: _angle,
                density: _density,
                phase: random(360)
            }
        }
    );
}

/// @description Returns whether an environmental field overlaps the camera.
function sc_environment_field_visible(_field)
{
    var _data = _field.environment_field;
    var _camera = view_camera[0];
    var _camera_x = camera_get_view_x(_camera);
    var _camera_y = camera_get_view_y(_camera);
    var _view_w = camera_get_view_width(_camera);
    var _view_h = camera_get_view_height(_camera);
    var _padding = max(_data.radius_x, _data.radius_y) * 1.15;

    return _field.x + _padding >= _camera_x
        && _field.x - _padding <= _camera_x + _view_w
        && _field.y + _padding >= _camera_y
        && _field.y - _padding <= _camera_y + _view_h;
}

/// @description Returns whether one gas element overlaps the camera.
function sc_gas_cloud_patch_visible(_x, _y, _radius)
{
    var _camera = view_camera[0];
    var _camera_x = camera_get_view_x(_camera);
    var _camera_y = camera_get_view_y(_camera);
    var _view_w = camera_get_view_width(_camera);
    var _view_h = camera_get_view_height(_camera);

    return _x + _radius >= _camera_x
        && _x - _radius <= _camera_x + _view_w
        && _y + _radius >= _camera_y
        && _y - _radius <= _camera_y + _view_h;
}

/// @description Returns normalized elliptical distance from a point to a field.
function sc_environment_field_distance_get(_field, _x, _y)
{
    var _data = _field.environment_field;
    var _direction = point_direction(_field.x, _field.y, _x, _y);
    var _distance = point_distance(_field.x, _field.y, _x, _y);
    var _local_angle = _direction - _data.angle;

    var _local_x = lengthdir_x(_distance, _local_angle);
    var _local_y = lengthdir_y(_distance, _local_angle);

    var _normalized_x = _local_x / max(1, _data.radius_x);
    var _normalized_y = _local_y / max(1, _data.radius_y);

    return sqrt(
        _normalized_x * _normalized_x
        + _normalized_y * _normalized_y
    );
}

/// @description Draws the faint haze covering the complete gas ellipse.
function sc_gas_cloud_field_haze_draw(_field, _alpha)
{
    var _data = _field.environment_field;
    var _visual = _data.visual;
    var _sprite = s_particle_blur_1024;

    var _scale_x = (_data.radius_x * 2.1)
        / max(1, sprite_get_width(_sprite));

    var _scale_y = (_data.radius_y * 2.1)
        / max(1, sprite_get_height(_sprite));

    draw_sprite_ext(
        _sprite,
        0,
        _field.x,
        _field.y,
        _scale_x,
        _scale_y,
        _data.angle,
        _visual.colour_dark,
        _alpha
    );

    gpu_set_blendmode(bm_add);

    draw_sprite_ext(
        _sprite,
        0,
        _field.x,
        _field.y,
        _scale_x * 0.86,
        _scale_y * 0.86,
        _data.angle + 17,
        _visual.colour_mid,
        _alpha * 0.42
    );

    gpu_set_blendmode(bm_normal);
}

/// @description Draws subtle local haze over the player while inside gas.
function sc_gas_cloud_player_haze_draw(_field)
{
    if (!instance_exists(global.player_id))
        return;

    var _distance = sc_environment_field_distance_get(
        _field,
        global.player_id.x,
        global.player_id.y
    );

    if (_distance >= 1)
        return;

    var _data = _field.environment_field;
    var _visual = _data.visual;

    // Fade smoothly after crossing the gas boundary.
    var _inside = clamp((1 - _distance) * 4, 0, 1);

    var _alpha = lerp(
        _visual.player_haze_alpha_min,
        _visual.player_haze_alpha_max,
        _data.density
    ) * _inside;

    var _size = _visual.player_haze_size;
    var _sprite = s_particle_blur_1024;

    draw_sprite_ext(
        _sprite,
        0,
        global.player_id.x,
        global.player_id.y,
        _size / max(1, sprite_get_width(_sprite)),
        _size / max(1, sprite_get_height(_sprite)),
        current_time * 0.001,
        _visual.colour_mid,
        _alpha
    );
}

/// @description Draws one gas field with continuous overlapping cloud coverage.
function sc_gas_cloud_draw(_field)
{
    if (!sc_environment_field_visible(_field))
        return;

    var _data = _field.environment_field;
    var _visual = _data.visual;
    var _runtime = _data.runtime;
    var _patches = _runtime.patches;

    var _field_alpha = lerp(
        _visual.field_haze_alpha_min,
        _visual.field_haze_alpha_max,
        _data.density
    );

    var _cloud_alpha = lerp(
        _visual.alpha_min,
        _visual.alpha_max,
        _data.density
    );

    var _time = current_time * _visual.drift_speed;

    // Guarantees that the environmental ellipse never looks empty.
    sc_gas_cloud_field_haze_draw(
        _field,
        _field_alpha
    );

    for (var _i = 0; _i < array_length(_patches); ++_i)
    {
        var _patch = _patches[_i];

        // Rotate the locally positioned cloud with the full field.
        var _x = _field.x
            + lengthdir_x(_patch.local_x, _data.angle)
            + lengthdir_x(_patch.local_y, _data.angle + 90);

        var _y = _field.y
            + lengthdir_y(_patch.local_x, _data.angle)
            + lengthdir_y(_patch.local_y, _data.angle + 90);

        _x += dcos(_patch.phase + _time)
            * _visual.drift_amount
            * 100;

        _y += dsin(_patch.phase + _time)
            * _visual.drift_amount
            * 100;

        var _radius = max(
            _patch.width,
            _patch.height
        ) * 0.6;

        if (!sc_gas_cloud_patch_visible(_x, _y, _radius))
            continue;

        var _pulse = 1 + dsin(
            current_time * _visual.pulse_speed
            + _patch.phase
        ) * _visual.pulse_amount;

        var _alpha = _cloud_alpha * _patch.alpha;

        if (_patch.formation)
            _alpha = min(1, _alpha * 1.12);

        draw_sprite_ext(
            _runtime.sprites[_patch.variant],
            0,
            _x,
            _y,
            (_patch.width / _runtime.canvas_size) * _pulse,
            _patch.height / _runtime.canvas_size,
            _data.angle + _patch.angle,
            c_white,
            _alpha
        );
    }

    // Very faint foreground layer confirms that the player is inside gas.
    sc_gas_cloud_player_haze_draw(_field);

    draw_set_alpha(1);
    draw_set_colour(c_white);
    gpu_set_blendmode(bm_normal);
}

/// @description Draws one generic environmental field using its registered type.
function sc_environment_field_draw(_field)
{
    switch (_field.environment_field.identity.type)
    {
        case EnvironmentFieldType.GAS:
            sc_gas_cloud_draw(_field);
        break;

        case EnvironmentFieldType.ELECTRIC:
            // Electric-field drawing can be introduced later.
        break;
    }
}

/// @description Generates deterministic gas fields for one sector.
function sc_gas_cloud_sector_spawn(
    _layer,
    _sector_seed
)
{
    global.game.sector.environment_fields = [];

    var _previous_seed = random_get_seed();

    var _gas_seed = abs(
        (_sector_seed + 190871)
        mod 2147483647
    );

    random_set_seed(
        max(1, floor(_gas_seed))
    );

    var _roll = random(1);
    var _count = 0;

    if (_roll < 0.3)
    {
        _count = 0;
    }
    else if (_roll < 0.7)
    {
        _count = irandom_range(1, 3);
    }
    else
    {
        _count = irandom_range(4, 5);
    }

    for (var _i = 0; _i < _count; ++_i)
    {
        var _radius_x = random_range(
            4500,
            8500
        );

        var _radius_y = random_range(
            3500,
            6500
        );

        var _margin_x = _radius_x + 900;
        var _margin_y = _radius_y + 900;

        var _x = random_range(
            _margin_x,
            room_width - _margin_x
        );

        var _y = random_range(
            _margin_y,
            room_height - _margin_y
        );

        var _angle = random_range(
            -180,
            180
        );

        var _density = random_range(
            0.35,
            0.85
        );

        array_push(
            global.game.sector.environment_fields,
            sc_environment_field_create(
                "environment_gas_ionized",
                _x,
                _y,
                _layer,
                _radius_x,
                _radius_y,
                _angle,
                _density
            )
        );
    }

    random_set_seed(_previous_seed);

    show_debug_message(
        "SECTOR GAS FIELDS - "
        + string(_count)
    );

    return _count;
}