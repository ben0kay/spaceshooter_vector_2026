/// @description Returns the first asteroid blocking a ship-sized movement corridor.
function sc_enemy_asteroid_route_probe(_enemy, _direction, _distance)
{
    var _data = _enemy.enemy;
    var _config = global.config.enemy.asteroid;
    var _clearance = max(
        _data.collision.radius_forward,
        _data.collision.radius_side
    ) + _config.clearance_margin;

    var _spacing = max(12, _clearance * _config.sample_spacing_scale);
    var _start = max(8, _clearance * 0.65);

    for (var _distance_current = _start;
        _distance_current <= _distance;
        _distance_current += _spacing)
    {
        var _x = _enemy.x + lengthdir_x(_distance_current, _direction);
        var _y = _enemy.y + lengthdir_y(_distance_current, _direction);
        var _asteroid = collision_circle(
            _x, _y, _clearance,
            o_asteroid, false, true
        );

        if (instance_exists(_asteroid))
            return _asteroid;
    }

    return noone;
}

/// @description Stops an enemy movement command without changing its strategic target.
function sc_enemy_asteroid_stop(_enemy)
{
    var _command = _enemy.enemy.movement.command;
    _command.active = false;
    _command.apply_friction = true;
}

/// @description Chooses and caches a clear movement direction around an asteroid.
function sc_enemy_asteroid_avoid_direction_select(_enemy, _desired_direction, _look_ahead)
{
    var _data = _enemy.enemy;
    var _runtime = _data.movement.obstacle;
    var _config = global.config.enemy.asteroid;
    var _angles = _config.candidate_angles;
    var _selected_direction = 0;
    var _selected_side = 0;
    var _selected_score = infinity;

    for (var _i = 0; _i < array_length(_angles); _i++)
    {
        var _offset = _angles[_i];
        var _direction = _desired_direction + _offset;

        if (instance_exists(sc_enemy_asteroid_route_probe(
            _enemy,
            _direction,
            _look_ahead
        )))
            continue;

        var _side = sign(_offset);
        var _score = abs(_offset);

        if (_runtime.side != 0 && _side != _runtime.side)
            _score += _config.side_switch_penalty;

        if (_score >= _selected_score) continue;

        _selected_score = _score;
        _selected_direction = _direction;
        _selected_side = _side;
    }

    if (_selected_score == infinity)
        return false;

    _runtime.active = true;
    _runtime.direction = _selected_direction;
    _runtime.side = _selected_side;

    var _command = _data.movement.command;
    _command.direction = _selected_direction;
    return true;
}

/// @description Separates an enemy from an asteroid only when an overlap has already occurred.
function sc_enemy_asteroid_overlap_resolve(_enemy)
{
    // Ensure the collision ellipse matches the latest hull rotation.
    _enemy.image_angle = _enemy.draw_angle;

    var _asteroid = instance_place(_enemy.x, _enemy.y, o_asteroid);
    if (!instance_exists(_asteroid)) return false;

    var _movement = _enemy.enemy.movement;
    var _normal;

    if (point_distance(_asteroid.x, _asteroid.y, _enemy.x, _enemy.y) > 0.01)
        _normal = point_direction(_asteroid.x, _asteroid.y, _enemy.x, _enemy.y);
    else if (abs(_movement.velocity_x) + abs(_movement.velocity_y) > 0.01)
        _normal = point_direction(0, 0, -_movement.velocity_x, -_movement.velocity_y);
    else
        _normal = _enemy.draw_angle + 180;

    // Exceptional recovery only; normally avoidance prevents reaching this point.
    for (var _i = 0; _i < 128; _i++)
    {
        _enemy.x += lengthdir_x(2, _normal);
        _enemy.y += lengthdir_y(2, _normal);

        if (!place_meeting(_enemy.x, _enemy.y, o_asteroid))
        {
            _movement.velocity_x = 0;
            _movement.velocity_y = 0;
            return true;
        }
    }

    _movement.velocity_x = 0;
    _movement.velocity_y = 0;
    return true;
}

/// @description Returns whether an enemy is currently committed to destroying a blocking asteroid.
function sc_enemy_asteroid_destroy_active(_enemy)
{
    var _data = _enemy.enemy;
    var _runtime = _data.movement.obstacle;

    return _data.movement_controller.asteroid_response == AsteroidResponse.DESTROY
        && _runtime.active
        && instance_exists(_runtime.target_id);
}

/// @description Stops at an asteroid while periodically checking whether the player is visible again.
function sc_enemy_asteroid_destroy_hold(_enemy)
{
    var _data = _enemy.enemy;
    var _runtime = _data.movement.obstacle;
    var _movement = _data.movement;
    var _command = _movement.command;
    var _target = _runtime.target_id;

    if (!instance_exists(_target)) return false;

    var _config = global.config.enemy.asteroid;

    // Reconsider the asteroid only at a staggered interval.
    if (GAME_TICK >= _runtime.next_check_tick)
    {
        var _lazy = _data.optimization.lazy_factor;

        _runtime.next_check_tick = GAME_TICK
            + max(
                1,
                round(
                    _config.destroy_visibility_interval
                    * _lazy
                )
            );

        if (instance_exists(global.player_id)
        && sc_enemy_attack_line_of_sight_clear_to(
            _enemy,
            global.player_id
        ))
        {
            sc_enemy_attack_cancel(_enemy);

            _runtime.active = false;
            _runtime.target_id = noone;

            return false;
        }
    }

    sc_enemy_asteroid_stop(_enemy);

    // Heavy controlled braking while preparing to fire.
    _movement.velocity_x *= 0.55;
    _movement.velocity_y *= 0.55;

    _command.facing_mode = EnemyFacingMode.COMMAND;
    _command.face_direction = point_direction(
        _enemy.x,
        _enemy.y,
        _target.x,
        _target.y
    );

    return true;
}

/// @description Applies registered avoidance, stopping or destruction behaviour around asteroids.
function sc_enemy_asteroid_response_apply(_enemy)
{
    var _data = _enemy.enemy;
    var _command = _data.movement.command;
    var _movement = _data.movement;
    var _runtime = _movement.obstacle;
    var _response = _data.movement_controller.asteroid_response;

    if (_response == AsteroidResponse.IGNORE
    || global.level.asteroids_alive <= 0)
    {
        if (_runtime.active && _response == AsteroidResponse.DESTROY)
            sc_enemy_attack_cancel(_enemy);

        _runtime.active = false;
        _runtime.target_id = noone;
        return;
    }

    // DESTROY commits to the cached asteroid until it no longer exists.
    if (_response == AsteroidResponse.DESTROY && _runtime.active)
    {
        if (instance_exists(_runtime.target_id))
        {
            sc_enemy_asteroid_destroy_hold(_enemy);
            return;
        }

        sc_enemy_attack_cancel(_enemy);
        _runtime.active = false;
        _runtime.target_id = noone;
    }

    var _speed = point_distance(
        0, 0,
        _movement.velocity_x,
        _movement.velocity_y
    );

    // Stationary ships with no destruction target require no obstacle work.
    if (!_command.active && _speed <= 0.01)
    {
        _runtime.active = false;
        _runtime.target_id = noone;
        return;
    }

    if (GAME_TICK < _runtime.next_check_tick)
    {
        if (!_runtime.active) return;

        if (_command.active && _response == AsteroidResponse.AVOID)
            _command.direction = _runtime.direction;
        else if (_command.active)
            sc_enemy_asteroid_stop(_enemy);

        return;
    }

    var _config = global.config.enemy.asteroid;
    var _lazy = _data.optimization.lazy_factor;

    _runtime.next_check_tick = GAME_TICK
        + max(1, round(_config.check_interval * _lazy));

    // Rare overlap recovery remains shared by all solid asteroid responses.
    if (sc_enemy_asteroid_overlap_resolve(_enemy))
    {
        _runtime.active = false;
        _runtime.target_id = noone;
        return;
    }

    var _clearance = max(
        _data.collision.radius_forward,
        _data.collision.radius_side
    ) + _config.clearance_margin;

    var _look_ahead = _clearance
        + _config.look_ahead_base
        + _speed * _config.look_ahead_speed;

    var _desired_direction = _command.active
        ? _command.direction
        : point_direction(
            0, 0,
            _movement.velocity_x,
            _movement.velocity_y
        );

    var _asteroid = sc_enemy_asteroid_route_probe(
        _enemy,
        _desired_direction,
        _look_ahead
    );

    if (!instance_exists(_asteroid))
    {
        _runtime.active = false;
        _runtime.target_id = noone;
        _runtime.direction = _desired_direction;
        return;
    }

    _runtime.active = true;
    _runtime.target_id = _asteroid;

    // Drifting ships stop rather than suddenly gaining steering propulsion.
    if (!_command.active)
    {
        _movement.velocity_x = 0;
        _movement.velocity_y = 0;

        if (_response != AsteroidResponse.DESTROY)
        {
            _runtime.active = false;
            _runtime.target_id = noone;
        }

        return;
    }

    switch (_response)
    {
        case AsteroidResponse.AVOID:
            if (!sc_enemy_asteroid_avoid_direction_select(
                _enemy,
                _desired_direction,
                _look_ahead
            ))
                sc_enemy_asteroid_stop(_enemy);
        break;

        case AsteroidResponse.STOP:
            sc_enemy_asteroid_stop(_enemy);
        break;

        case AsteroidResponse.DESTROY:
            sc_enemy_attack_cancel(_enemy);
            sc_enemy_asteroid_destroy_hold(_enemy);
        break;
    }
}