/// @description Creates one generic visual death-fragment effect with a subtle outward explosion impulse.
function sc_death_fragment_create(_x, _y, _fragments, _flash_colour, _glow_colour, _radius, _life = 38)
{
    for (var _i = 0; _i < array_length(_fragments); _i++)
    {
        var _fragment = _fragments[_i];
        var _distance = point_distance(_x, _y, _fragment.x, _fragment.y);
        var _direction = _distance > 1 ? point_direction(_x, _y, _fragment.x, _fragment.y) : irandom(359);
        var _impulse = random_range(0.65, 1.25);

        _fragment.velocity_x += lengthdir_x(_impulse, _direction);
        _fragment.velocity_y += lengthdir_y(_impulse, _direction);
    }

    return instance_create_layer(_x, _y, "Instances", o_death_fragment, {
        fragments: _fragments,
        flash_colour: _flash_colour,
        glow_colour: _glow_colour,
        effect_radius: _radius,
        effect_life: _life
    });
}

/// @description Creates one fragment runtime struct.
function sc_death_fragment_data(_sprite, _x, _y, _direction, _speed, _angle, _spin, _scale = 1)
{
    return {
        sprite: _sprite,
        x: _x,
        y: _y,
        velocity_x: lengthdir_x(_speed, _direction),
        velocity_y: lengthdir_y(_speed, _direction),
        angle: _angle,
        spin: _spin,
        scale: _scale,
        alpha: 1
    };
}