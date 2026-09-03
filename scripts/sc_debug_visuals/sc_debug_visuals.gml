/// @description Draws the enemy's wander boundary, spawn point and active destination.
function sc_enemy_wander_debug_draw(_enemy)
{
    var _data = _enemy.enemy;
    var _range = _data.stats.final.range.wander;

    if (_range <= 0) return;

    var _movement = _data.movement;
    var _wander = _movement.wander;

    draw_set_alpha(0.3);
    draw_set_colour(c_yellow);
    draw_circle(_movement.spawn_x, _movement.spawn_y, _range, true);

    draw_set_alpha(0.8);
    draw_circle(_movement.spawn_x, _movement.spawn_y, 4, false);

    if (_wander.active)
    {
        draw_set_colour(c_aqua);
        draw_circle(_wander.target_x, _wander.target_y, 6, true);
        draw_line(_enemy.x, _enemy.y, _wander.target_x, _wander.target_y);
    }

    draw_set_alpha(1);
    draw_set_colour(c_white);
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