/// @description Creates one generic visual death-fragment effect.
function sc_death_fragment_create(_x, _y, _fragments, _flash_colour, _glow_colour, _radius, _life = 38)
{
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