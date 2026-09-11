/*
ASTEROID COMPONENT VISUAL EXPERIMENT

Builds detailed asteroids using:
- s_asteroid_base
- s_asteroid_craters
- s_asteroid_minerals_dark
- s_asteroid_minerals_light

Everything is only drawn during startup baking.
Runtime asteroid drawing still uses one cached sprite.
*/

/// @description Returns the experimental component-renderer configuration.
function sc_asteroid_component_config()
{
    return {
        enabled: true,

        variant_count: 16,

        crater_min: 1,
        crater_max: 3,

        mineral_min: 8,
        mineral_max: 16,

        seam_min: 1,
        seam_max: 3,

        rock_has_minerals: false,

        excluded_keys: []
    };
}

/// @description Returns whether all component sprites are available.
function sc_asteroid_component_assets_available()
{
    return sprite_exists(s_asteroid_base)
        && sprite_exists(s_asteroid_craters)
        && sprite_exists(s_asteroid_minerals_dark)
        && sprite_exists(s_asteroid_minerals_light);
}

/// @description Returns whether one material should use component visuals.
function sc_asteroid_component_material_enabled(_data)
{
    var _config = sc_asteroid_component_config();

    if (!_config.enabled)
        return false;

    if (!sc_asteroid_component_assets_available())
        return false;

    var _key = _data.identity.key;

    for (var _i = 0; _i < array_length(_config.excluded_keys); ++_i)
    {
        if (_config.excluded_keys[_i] == _key)
            return false;
    }

    return true;
}

/// @description Returns a deterministic value from zero to one.
function sc_asteroid_component_noise(_seed)
{
    return frac(
        abs(
            sin(_seed * 12.9898 + 78.233)
            * 43758.5453
        )
    );
}

/// @description Returns a deterministic value inside a range.
function sc_asteroid_component_range(_seed, _minimum, _maximum)
{
    return lerp(
        _minimum,
        _maximum,
        sc_asteroid_component_noise(_seed)
    );
}

/// @description Returns a deterministic integer inside a range.
function sc_asteroid_component_irange(_seed, _minimum, _maximum)
{
    return floor(
        sc_asteroid_component_range(
            _seed,
            _minimum,
            _maximum + 1
        )
    );
}

/// @description Draws the neutral asteroid base.
function sc_asteroid_component_base_draw(_x, _y, _radius, _variant)
{
    var _frame_count = sprite_get_number(s_asteroid_base);
    var _frame = _variant mod max(1, _frame_count);

    var _scale = (_radius * 2) / sprite_get_width(
        s_asteroid_base
    );

    draw_sprite_ext(
        s_asteroid_base,
        _frame,
        _x,
        _y,
        _scale,
        _scale,
        0,
        c_white,
        1
    );
}

/// @description Draws one prepared crater layout.
function sc_asteroid_component_craters_draw(
    _x,
    _y,
    _layout
)
{
    for (var _i = 0;
    _i < array_length(_layout);
    ++_i)
    {
        var _crater = _layout[_i];

        draw_sprite_ext(
            s_asteroid_craters,
            _crater.frame,
            _x + _crater.x,
            _y + _crater.y,
            _crater.scale * _crater.scale_x,
            _crater.scale * _crater.scale_y,
            _crater.angle,
            c_white,
            1
        );
    }
}

/// @description Draws one mineral seam while avoiding craters.
function sc_asteroid_component_seam_draw(
    _x,
    _y,
    _radius,
    _variant,
    _seam,
    _piece_count,
    _palette,
    _craters
)
{
    var _seed = _variant * 419
        + _seam * 107
        + 31;

    var _seam_angle = sc_asteroid_component_range(
        _seed + 1,
        -65,
        65
    );

    if (sc_asteroid_component_noise(_seed + 2) < 0.5)
        _seam_angle += 180;

    var _normal_angle = _seam_angle + 90;

    var _seam_offset = sc_asteroid_component_range(
        _seed + 3,
        -_radius * 0.3,
        _radius * 0.3
    );

    var _centre_x = lengthdir_x(
        _seam_offset,
        _normal_angle
    );

    var _centre_y = lengthdir_y(
        _seam_offset,
        _normal_angle
    );

    var _dark_frames = sprite_get_number(
        s_asteroid_minerals_dark
    );

    var _light_frames = sprite_get_number(
        s_asteroid_minerals_light
    );

    for (var _i = 0; _i < _piece_count; ++_i)
    {
        var _piece_seed = _seed + _i * 73;

        var _progress = 0.5;

        if (_piece_count > 1)
            _progress = _i / (_piece_count - 1);

        var _along = lerp(
            -_radius * 0.43,
            _radius * 0.43,
            _progress
        );

        _along += sc_asteroid_component_range(
            _piece_seed + 1,
            -_radius * 0.045,
            _radius * 0.045
        );

        var _side = sc_asteroid_component_range(
            _piece_seed + 2,
            -_radius * 0.045,
            _radius * 0.045
        );

        var _local_x = _centre_x
            + lengthdir_x(_along, _seam_angle)
            + lengthdir_x(_side, _normal_angle);

        var _local_y = _centre_y
            + lengthdir_y(_along, _seam_angle)
            + lengthdir_y(_side, _normal_angle);

        if (point_distance(
            0,
            0,
            _local_x,
            _local_y
        ) > _radius * 0.5)
            continue;

        var _mineral_radius = _radius
            * sc_asteroid_component_range(
                _piece_seed + 3,
                0.025,
                0.045
            );

        if (!sc_asteroid_component_mineral_position_valid(
            _local_x,
            _local_y,
            _mineral_radius,
            _craters
        ))
            continue;

        var _use_light = (
            sc_asteroid_component_noise(
                _piece_seed + 4
            ) > 0.7
        );

        var _sprite = _use_light
            ? s_asteroid_minerals_light
            : s_asteroid_minerals_dark;

        var _frame_count = _use_light
            ? _light_frames
            : _dark_frames;

        var _frame = sc_asteroid_component_irange(
            _piece_seed + 5,
            0,
            max(0, _frame_count - 1)
        );

        var _scale = sc_asteroid_component_range(
            _piece_seed + 6,
            0.04,
            0.095
        );

        var _stretch_x = sc_asteroid_component_range(
            _piece_seed + 7,
            0.72,
            1.2
        );

        var _stretch_y = sc_asteroid_component_range(
            _piece_seed + 8,
            0.78,
            1.12
        );

        var _angle = _seam_angle
            + sc_asteroid_component_range(
                _piece_seed + 9,
                -24,
                24
            );

        var _colour = _use_light
            ? _palette.resource
            : _palette.light;

        draw_sprite_ext(
            _sprite,
            _frame,
            _x + _local_x,
            _y + _local_y,
            _scale * _stretch_x,
            _scale * _stretch_y,
            _angle,
            _colour,
            0.96
        );
    }
}

/// @description Draws mineral deposits without covering craters.
function sc_asteroid_component_minerals_draw(
    _x,
    _y,
    _radius,
    _variant,
    _data,
    _craters
)
{
    var _config = sc_asteroid_component_config();

    if (_data.identity.key == "asteroid_rock"
    && !_config.rock_has_minerals)
        return;

    var _seam_count = sc_asteroid_component_irange(
        _variant * 157 + 13,
        _config.seam_min,
        _config.seam_max
    );

    var _mineral_count = sc_asteroid_component_irange(
        _variant * 193 + 29,
        _config.mineral_min,
        _config.mineral_max
    );

    var _remaining = _mineral_count;

    for (var _seam = 0;
    _seam < _seam_count;
    ++_seam)
    {
        var _seams_left = _seam_count - _seam;

        var _piece_count = max(
            1,
            round(_remaining / _seams_left)
        );

        sc_asteroid_component_seam_draw(
            _x,
            _y,
            _radius,
            _variant,
            _seam,
            _piece_count,
            _data.palette,
            _craters
        );

        _remaining -= _piece_count;
    }
}

/// @description Draws one complete component-based asteroid.
function sc_asteroid_component_draw(
    _x,
    _y,
    _radius,
    _variant,
    _stage,
    _data
)
{
    draw_set_alpha(1);
    draw_set_colour(c_white);

    var _craters = sc_asteroid_component_crater_layout(
        _radius,
        _variant
    );

    sc_asteroid_component_base_draw(
        _x,
        _y,
        _radius,
        _variant
    );

    sc_asteroid_component_craters_draw(
        _x,
        _y,
        _craters
    );

    sc_asteroid_component_minerals_draw(
        _x,
        _y,
        _radius,
        _variant,
        _data,
        _craters
    );

    sc_asteroid_damage_draw(
        _x,
        _y,
        _radius,
        _stage,
        _data.palette
    );

    draw_set_alpha(1);
    draw_set_colour(c_white);
}

/// @description Builds deterministic, non-overlapping crater placements.
function sc_asteroid_component_crater_layout(
    _radius,
    _variant
)
{
    var _config = sc_asteroid_component_config();

    var _wanted = sc_asteroid_component_irange(
        _variant * 41 + 7,
        _config.crater_min,
        _config.crater_max
    );

    var _layout = [];
    var _attempt = 0;
    var _maximum_attempts = 40;

    while (array_length(_layout) < _wanted
    && _attempt < _maximum_attempts)
    {
        var _seed = _variant * 239
            + _attempt * 61
            + 19;

        var _direction = sc_asteroid_component_range(
            _seed + 1,
            0,
            360
        );

        var _distance = sc_asteroid_component_range(
            _seed + 2,
            _radius * 0.08,
            _radius * 0.42
        );

        var _px = lengthdir_x(
            _distance,
            _direction
        );

        var _py = lengthdir_y(
            _distance,
            _direction
        );

        var _scale = sc_asteroid_component_range(
            _seed + 3,
            0.075,
            0.145
        );

        var _feature_radius = _radius
            * sc_asteroid_component_range(
                _seed + 4,
                0.075,
                0.125
            );

        var _valid = true;

        for (var _i = 0;
        _i < array_length(_layout);
        ++_i)
        {
            var _other = _layout[_i];

            var _separation = point_distance(
                _px,
                _py,
                _other.x,
                _other.y
            );

            if (_separation
            < _feature_radius
            + _other.exclusion_radius)
            {
                _valid = false;
                break;
            }
        }

        if (_valid)
        {
            array_push(
                _layout,
                {
                    x: _px,
                    y: _py,

                    scale: _scale,

                    scale_x:
                        sc_asteroid_component_range(
                            _seed + 5,
                            0.88,
                            1.12
                        ),

                    scale_y:
                        sc_asteroid_component_range(
                            _seed + 6,
                            0.88,
                            1.12
                        ),

                    angle:
                        sc_asteroid_component_range(
                            _seed + 7,
                            0,
                            360
                        ),

                    frame:
                        sc_asteroid_component_irange(
                            _seed + 8,
                            0,
                            max(
                                0,
                                sprite_get_number(
                                    s_asteroid_craters
                                ) - 1
                            )
                        ),

                    exclusion_radius:
                        _feature_radius
                }
            );
        }

        ++_attempt;
    }

    return _layout;
}

/// @description Returns whether a mineral is clear of every crater.
function sc_asteroid_component_mineral_position_valid(
    _x,
    _y,
    _mineral_radius,
    _craters
)
{
    for (var _i = 0;
    _i < array_length(_craters);
    ++_i)
    {
        var _crater = _craters[_i];

        var _distance = point_distance(
            _x,
            _y,
            _crater.x,
            _crater.y
        );

        if (_distance
        < _mineral_radius
        + _crater.exclusion_radius)
            return false;
    }

    return true;
}