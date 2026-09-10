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

        // These values remain unused until interference is connected.
        interference: {
            detection_multiplier: 0.55,
            targeting_multiplier: 0.75,
            forget_multiplier: 0.7,
            alert_share_multiplier: 0.45
        },

        visual: {
            canvas_size: 768,
            seed: 704,

            colour_dark: make_colour_rgb(8, 34, 46),
            colour_mid: make_colour_rgb(18, 100, 122),
            colour_glow: make_colour_rgb(48, 190, 210),

            body_amount: 72,
            wisp_amount: 26,

            alpha_min: 0.32,
            alpha_max: 0.7,

            layer_scale_inner: 0.9,
            layer_scale_middle: 1.02,

            drift_amount: 0.055,
            drift_speed: 0.012,
            pulse_amount: 0.045,
            pulse_speed: 0.01
        }
    }))
        return false;

    return true;
}

/// @description Initializes one generic environmental-field instance.
function sc_environment_field_init(_field, _create)
{
    if (!is_struct(_create)
    || !variable_struct_exists(_create, "key")
    || !variable_struct_exists(global.data.environment_fields, _create.key))
    {
        show_debug_message("ENVIRONMENT FIELD INITIALIZATION ERROR");
        return false;
    }

    var _definition = variable_struct_get(
        global.data.environment_fields,
        _create.key
    );

    var _cache = sc_environment_field_visual_cache_get(_create.key);

    if (!is_struct(_cache))
    {
        show_debug_message("ENVIRONMENT FIELD CACHE ERROR - " + _create.key);
        return false;
    }

    _field.environment_field = {
        key: _create.key,
        identity: variable_clone(_definition.identity),
        interference: variable_clone(_definition.interference),
        visual: variable_clone(_definition.visual),

        radius_x: max(64, _create.radius_x),
        radius_y: max(64, _create.radius_y),
        angle: variable_struct_exists(_create, "angle") ? _create.angle : 0,
        density: clamp(_create.density, 0, 1),

        runtime: {
            sprite: _cache.sprite,
            canvas_size: _cache.canvas_size,
            phase: variable_struct_exists(_create, "phase")
                ? _create.phase
                : random(360)
        }
    };

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
    var _padding = max(_data.radius_x, _data.radius_y) * 1.3;

    return _field.x + _padding >= _camera_x
        && _field.x - _padding <= _camera_x + _view_w
        && _field.y + _padding >= _camera_y
        && _field.y - _padding <= _camera_y + _view_h;
}

/// @description Draws one visible baked gas cloud using three drifting layers.
function sc_gas_cloud_draw(_field)
{
    if (!sc_environment_field_visible(_field))
        return;

    var _data = _field.environment_field;
    var _visual = _data.visual;
    var _runtime = _data.runtime;
    var _scale_x = (_data.radius_x * 2) / _runtime.canvas_size;
    var _scale_y = (_data.radius_y * 2) / _runtime.canvas_size;
    var _time = current_time * _visual.drift_speed;
    var _pulse = 1 + dsin(
        current_time * _visual.pulse_speed
        + _runtime.phase
    ) * _visual.pulse_amount;

    var _alpha = lerp(
        _visual.alpha_min,
        _visual.alpha_max,
        _data.density
    );

    // Broad stationary foundation.
    draw_sprite_ext(
        _runtime.sprite, 0,
        _field.x,
        _field.y,
        _scale_x,
        _scale_y,
        _data.angle,
        c_white,
        _alpha * 0.72
    );

    // Slowly drifting middle layer.
    draw_sprite_ext(
        _runtime.sprite, 0,
        _field.x + dcos(_runtime.phase + _time) * _data.radius_x * _visual.drift_amount,
        _field.y + dsin(_runtime.phase + _time) * _data.radius_y * _visual.drift_amount,
        _scale_x * _visual.layer_scale_middle * _pulse,
        _scale_y * _visual.layer_scale_middle,
        _data.angle + 41,
        c_white,
        _alpha * 0.34
    );

    // Smaller counter-rotated inner layer.
    draw_sprite_ext(
        _runtime.sprite, 0,
        _field.x + dcos(_runtime.phase + 180 - _time * 0.7) * _data.radius_x * _visual.drift_amount,
        _field.y + dsin(_runtime.phase + 180 - _time * 0.7) * _data.radius_y * _visual.drift_amount,
        _scale_x * _visual.layer_scale_inner,
        _scale_y * _visual.layer_scale_inner * _pulse,
        _data.angle - 57,
        c_white,
        _alpha * 0.27
    );

    draw_set_alpha(1);
    draw_set_colour(c_white);
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

/// @description Spawns large temporary visual test clouds in the sector.
function sc_gas_cloud_test_spawn(_layer)
{
    var _centre_x = room_width * 0.5;
    var _centre_y = room_height * 0.5;

    global.game.sector.environment_fields = [];

    array_push(
        global.game.sector.environment_fields,
        sc_environment_field_create(
            "environment_gas_ionized",
            _centre_x + 12000,
            _centre_y - 3000,
            _layer,

            // Large elongated gas region.
            11000,
            7250,

            24,
            0.5
        )
    );

    array_push(
        global.game.sector.environment_fields,
        sc_environment_field_create(
            "environment_gas_ionized",
            _centre_x - 15000,
            _centre_y + 10000,
            _layer,

            // Very large dense gas region.
            17000,
            9500,

            -38,
            0.8
        )
    );

    return true;
}