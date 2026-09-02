/// @description Initializes the shared damageable-entity contract and elliptical collision mask.
function sc_entity_init(_entity, _faction, _damage_script, _collision)
{
    _entity.entity = {
        faction: _faction,
        damage_script: _damage_script,

        collision: {
            radius_forward: _collision.radius_forward,
            radius_side: _collision.radius_side
        },

        status: {
            stagger: {
                remaining: 0,
                return_state: 0
            }
        }
    };

    _entity.mask_index = s_collision_circle;
    _entity.image_xscale = _collision.radius_forward / 16;
    _entity.image_yscale = _collision.radius_side / 16;
    _entity.image_angle = _entity.draw_angle;
    return true;
}

/// @description Draws one rotated elliptical entity collision boundary for debugging.
function sc_entity_collision_debug_draw(_entity)
{
    var _collision = _entity.entity.collision;
    var _radius_forward = _collision.radius_forward;
    var _radius_side = _collision.radius_side;
    var _angle = _entity.draw_angle;
    var _segments = 40;

    draw_set_alpha(0.9);
    draw_set_colour(c_lime);

    var _previous_x = _entity.x + lengthdir_x(_radius_forward, _angle);
    var _previous_y = _entity.y + lengthdir_y(_radius_forward, _angle);

    for (var _i = 1; _i <= _segments; _i++)
    {
        var _direction = (_i / _segments) * 360;
        var _cos = dcos(_direction);
        var _sin = dsin(_direction);

        var _current_x = _entity.x
            + lengthdir_x(_radius_forward * _cos, _angle)
            + lengthdir_x(_radius_side * _sin, _angle + 90);

        var _current_y = _entity.y
            + lengthdir_y(_radius_forward * _cos, _angle)
            + lengthdir_y(_radius_side * _sin, _angle + 90);

        draw_line(_previous_x, _previous_y, _current_x, _current_y);
        _previous_x = _current_x;
        _previous_y = _current_y;
    }

    draw_set_alpha(1);
    draw_set_colour(c_white);
}