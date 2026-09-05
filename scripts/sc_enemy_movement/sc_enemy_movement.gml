/// @description Resets the reusable movement command to the enemy's registered defaults.
function sc_enemy_movement_command_reset(_enemy)
{
    var _controller = _enemy.enemy.movement_controller;
    var _command = _enemy.enemy.movement.command;

    _command.active = false;
    _command.direction = _enemy.draw_angle;
    _command.speed_scale = 1;
    _command.apply_friction = true;
    _command.facing_mode = _controller.facing.default_mode;
    _command.face_direction = _enemy.draw_angle;
}

/// @description Leaves the enemy stationary while preserving normal friction and facing.
function sc_enemy_movement_hold(_enemy)
{
    // Future stationary behaviour can be added here.
}

/// @description Moves toward and briefly searches one last-known position.
function sc_enemy_movement_investigate(_enemy)
{
    var _data = _enemy.enemy;
    var _awareness = _data.awareness;
    var _controller = _data.awareness_controller;
    var _command = _data.movement.command;

    if (GAME_TICK >= _awareness.memory_until)
    {
        _data.state = EnemyState.IDLE;
        return;
    }

    if (_awareness.arrived)
    {
        if (GAME_TICK >= _awareness.search_until)
        {
            _data.state = EnemyState.IDLE;
            _awareness.memory_until = 0;
        }

        return;
    }

    var _dx = _awareness.last_known_x - _enemy.x;
    var _dy = _awareness.last_known_y - _enemy.y;

    if (_dx * _dx + _dy * _dy <= sqr(_controller.arrival_radius))
    {
        _awareness.arrived = true;
        _awareness.search_until = GAME_TICK + max(1, round(_controller.search_duration));
        return;
    }

    _command.active = true;
    _command.apply_friction = false;
    _command.direction = point_direction(0, 0, _dx, _dy);
    _command.face_direction = _command.direction;
    _command.facing_mode = EnemyFacingMode.MOVEMENT;
    _command.speed_scale = clamp(_controller.speed_scale, 0, 1);
}

/// @description Holds during combat but repositions when its target view is obstructed.
function sc_enemy_movement_hold_line_of_sight(_enemy)
{
    var _data = _enemy.enemy;
    if (!instance_exists(_data.target_id)) return;

    // Remain stationary while the player is clearly visible.
    if (sc_enemy_attack_line_of_sight_clear(_enemy)) return;

    // Pursue the player; shared asteroid avoidance converts this
    // into a route around whichever asteroid blocks the corridor.
    sc_enemy_movement_chase(_enemy);
}

/// @description Selects a cached attack line passing beside and beyond the target.
function sc_enemy_flyby_run_select(_enemy)
{
    var _data = _enemy.enemy;
    var _target = _data.target_id;
    if (!instance_exists(_target)) return false;

    var _movement = _data.movement;
    var _runtime = _movement.behaviour_runtime.flyby;
    var _flyby = _data.movement_controller.flyby;
    var _toward = point_direction(_enemy.x, _enemy.y, _target.x, _target.y);

    if (_runtime.side == 0)
        _runtime.side = choose(-1, 1);
    else if (_flyby.alternate_side)
        _runtime.side *= -1;
    else
        _runtime.side = choose(-1, 1);

    var _offset = random_range(_flyby.offset_min, _flyby.offset_max) * _runtime.side;
    var _pass_x = _target.x + lengthdir_x(_offset, _toward + 90);
    var _pass_y = _target.y + lengthdir_y(_offset, _toward + 90);

    _runtime.destination_x = _pass_x + lengthdir_x(_flyby.exit_distance, _toward);
    _runtime.destination_y = _pass_y + lengthdir_y(_flyby.exit_distance, _toward);
    _runtime.active = true;
    return true;
}

/// @description Performs repeated cached straight attack runs past the target.
function sc_enemy_movement_flyby(_enemy)
{
    var _data = _enemy.enemy;
    var _movement = _data.movement;
    var _runtime = _movement.behaviour_runtime.flyby;
    var _flyby = _data.movement_controller.flyby;

    if (!instance_exists(_data.target_id)) return;
    if (GAME_TICK < _runtime.next_run_tick) return;

    if (!_runtime.active && !sc_enemy_flyby_run_select(_enemy))
        return;

    var _dx = _runtime.destination_x - _enemy.x;
    var _dy = _runtime.destination_y - _enemy.y;

    if (_dx * _dx + _dy * _dy <= sqr(_flyby.arrival_radius))
    {
        _runtime.active = false;
        _runtime.next_run_tick = GAME_TICK + _flyby.turnaround_delay;
        return;
    }

    var _command = _movement.command;
    _command.active = true;
    _command.apply_friction = false;
    _command.direction = point_direction(0, 0, _dx, _dy);
    _command.face_direction = _command.direction;
    _command.facing_mode = EnemyFacingMode.MOVEMENT;
    _command.speed_scale = _flyby.speed_scale;
}

/// @description Commands direct movement toward the current target.
function sc_enemy_movement_chase(_enemy)
{
    var _data = _enemy.enemy;
    if (!instance_exists(_data.target_id)) return;

    var _command = _data.movement.command;
    _command.active = true;
    _command.apply_friction = false;
    _command.direction = point_direction(_enemy.x, _enemy.y, _data.target_id.x, _data.target_id.y);
    _command.face_direction = _command.direction;
}

/// @description Pursues the target while allowing attacks and optional strafing.
function sc_enemy_movement_pursue(_enemy)
{
    sc_enemy_movement_chase(_enemy);
}

/// @description Commands movement directly away from a target inside the emergency backaway range.
function sc_enemy_movement_backaway(_enemy)
{
    var _data = _enemy.enemy;
    if (!instance_exists(_data.target_id)) return;

    var _controller = _data.movement_controller;
    var _command = _data.movement.command;
    var _toward = point_direction(_enemy.x, _enemy.y, _data.target_id.x, _data.target_id.y);

    _command.active = true;
    _command.apply_friction = false;
    _command.direction = _toward + 180;
    _command.face_direction = _command.direction;
    _command.facing_mode = _controller.facing.backaway_mode;
}

/// @description Commands tangential movement while correcting toward the registered orbit radius.
function sc_enemy_movement_orbit(_enemy)
{
    var _data = _enemy.enemy;
    var _target = _data.target_id;
    if (!instance_exists(_target)) return;

    var _controller = _data.movement_controller;
    var _orbit = _controller.orbit;
    var _movement = _data.movement;
    var _command = _movement.command;
    var _dx = _target.x - _enemy.x;
    var _dy = _target.y - _enemy.y;
    var _distance = max(1, point_distance(0, 0, _dx, _dy));
    var _toward = point_direction(0, 0, _dx, _dy);

    if (_orbit.direction_change_chance > 0 && random(1) < _orbit.direction_change_chance)
        _movement.orbit_direction *= -1;

    var _tangent = _toward + 90 * _movement.orbit_direction;
    var _radial = clamp((_distance - _orbit.range) / max(1, _orbit.range), -1, 1) * _orbit.radial_strength;
    var _move_x = lengthdir_x(1, _tangent) + lengthdir_x(_radial, _toward);
    var _move_y = lengthdir_y(1, _tangent) + lengthdir_y(_radial, _toward);

    _command.active = true;
    _command.apply_friction = false;
    _command.direction = point_direction(0, 0, _move_x, _move_y);
    _command.speed_scale = clamp(point_distance(0, 0, _move_x, _move_y), 0.25, 1);
    _command.face_direction = _toward;
}

/// @description Selects one unobstructed wander destination inside the registered spawn radius.
function sc_enemy_wander_target_select(_enemy)
{
    var _data = _enemy.enemy;
    var _movement = _data.movement;
    var _wander = _movement.wander;
    var _range = _data.stats.final.range.wander;
    var _config = global.config.enemy.wander;
    var _radius_forward = _data.collision.radius_forward;
    var _radius_side = _data.collision.radius_side;
    var _margin = max(_radius_forward, _radius_side) + _config.edge_margin;

    for (var _i = 0; _i < _config.candidate_attempts; _i++)
    {
        var _direction = random(360);
        var _distance = sqrt(random(1)) * _range;
        var _target_x = _movement.spawn_x + lengthdir_x(_distance, _direction);
        var _target_y = _movement.spawn_y + lengthdir_y(_distance, _direction);

        if (_target_x < _margin || _target_x > room_width - _margin
        || _target_y < _margin || _target_y > room_height - _margin)
            continue;

        var _blocked = collision_ellipse(
            _target_x - _radius_forward, _target_y - _radius_side,
            _target_x + _radius_forward, _target_y + _radius_side,
            o_solid, false, true
        ) != noone;

        if (_blocked) continue;
        if (collision_line(_enemy.x, _enemy.y, _target_x, _target_y, o_solid, false, true) != noone) continue;

        _wander.target_x = _target_x;
        _wander.target_y = _target_y;
        _wander.active = true;
        return true;
    }

    _wander.active = false;
    _wander.next_move_tick = GAME_TICK + irandom_range(_config.wait_min, _config.wait_max);
    return false;
}

/// @description Commands idle movement toward occasional valid points around the spawn location.
function sc_enemy_movement_wander(_enemy)
{
    var _data = _enemy.enemy;
    var _movement = _data.movement;
    var _wander = _movement.wander;
    var _config = global.config.enemy.wander;

    if (_data.stats.final.range.wander <= 0) return;

    if (!_wander.active)
    {
        if (GAME_TICK >= _wander.next_move_tick)
            sc_enemy_wander_target_select(_enemy);

        return;
    }

    var _dx = _wander.target_x - _enemy.x;
    var _dy = _wander.target_y - _enemy.y;

    if (_dx * _dx + _dy * _dy <= sqr(_config.arrival_radius))
    {
        _wander.active = false;
        _wander.next_move_tick = GAME_TICK + irandom_range(_config.wait_min, _config.wait_max);
        return;
    }

    var _command = _movement.command;
    _command.active = true;
    _command.apply_friction = false;
    _command.direction = point_direction(0, 0, _dx, _dy);
    _command.speed_scale = _config.speed_scale;
    _command.face_direction = _command.direction;
    _command.facing_mode = EnemyFacingMode.MOVEMENT;
}

/// @description Adds a lightweight lateral weave to the current combat movement command.
function sc_enemy_movement_strafe_apply(_enemy)
{
    var _data = _enemy.enemy;
    var _strafe = _data.movement_controller.strafe;
    var _command = _data.movement.command;

    if (!_command.active || _strafe.amount <= 0) return;

    var _side = sin(GAME_TICK * _strafe.speed + _data.movement.strafe_phase) * _strafe.amount;
    var _move_x = lengthdir_x(_command.speed_scale, _command.direction) + lengthdir_x(_side, _command.direction + 90);
    var _move_y = lengthdir_y(_command.speed_scale, _command.direction) + lengthdir_y(_side, _command.direction + 90);

    _command.direction = point_direction(0, 0, _move_x, _move_y);
    _command.speed_scale = clamp(point_distance(0, 0, _move_x, _move_y), 0, 1);
}


/// @description Updates hull rotation independently from movement and hardpoint rotation.
function sc_enemy_facing_update(_enemy)
{
    var _data = _enemy.enemy;
    var _controller = _data.movement_controller;
    var _facing = _controller.facing;
    var _command = _data.movement.command;
    var _mode = _command.facing_mode;

    if (sc_enemy_attack_aim_locked(_enemy)) return;

    if (_mode == EnemyFacingMode.FIXED) return;

    if (_mode == EnemyFacingMode.SPIN)
    {
        _enemy.draw_angle = (_enemy.draw_angle + _facing.spin_speed) mod 360;
        return;
    }

    var _desired = _enemy.draw_angle;

    switch (_mode)
    {
        case EnemyFacingMode.TARGET:
            if (instance_exists(_data.target_id))
                _desired = point_direction(_enemy.x, _enemy.y, _data.target_id.x, _data.target_id.y);
        break;

        case EnemyFacingMode.MOVEMENT:
            if (_command.active)
                _desired = _command.direction;
            else if (abs(_data.movement.velocity_x) + abs(_data.movement.velocity_y) > 0.01)
                _desired = point_direction(0, 0, _data.movement.velocity_x, _data.movement.velocity_y);
        break;

        case EnemyFacingMode.COMMAND:
            _desired = _command.face_direction;
        break;
    }

    _desired += _facing.angle_offset;

    var _turn_speed = _data.stats.final.handling.turn_speed * _facing.turn_speed_scale;
    _enemy.draw_angle += clamp(angle_difference(_desired, _enemy.draw_angle), -_turn_speed, _turn_speed);
    _enemy.draw_angle = _enemy.draw_angle mod 360;
}

/// @description Returns movement alignment where 1 is forward and 0 is directly backwards.
function sc_enemy_movement_alignment(_enemy, _move_direction)
{
    var _handling = _enemy.enemy.stats.final.handling;
    if (!_handling.directional) return 1;

    return (dcos(angle_difference(_move_direction, _enemy.draw_angle)) + 1) * 0.5;
}

/// @description Applies the current command through shared acceleration, friction and directional handling.
function sc_enemy_movement_apply(_enemy)
{
    var _data = _enemy.enemy;
    var _movement = _data.movement;
    var _command = _movement.command;
    var _handling = _data.stats.final.handling;

    if (_command.active)
    {
        var _alignment = sc_enemy_movement_alignment(_enemy, _command.direction);
        var _speed_factor = lerp(_handling.directional_speed_min, 1, _alignment);
        var _thrust_factor = lerp(_handling.directional_thrust_min, 1, _alignment);
        var _speed_max = _handling.speed_max * _command.speed_scale * _speed_factor;
        var _acceleration = _handling.acceleration * _thrust_factor;
        var _target_vx = lengthdir_x(_speed_max, _command.direction);
        var _target_vy = lengthdir_y(_speed_max, _command.direction);

        _movement.velocity_x += clamp(_target_vx - _movement.velocity_x, -_acceleration, _acceleration);
        _movement.velocity_y += clamp(_target_vy - _movement.velocity_y, -_acceleration, _acceleration);
    }
    else if (_command.apply_friction)
    {
        _movement.velocity_x *= _handling.friction_coeff;
        _movement.velocity_y *= _handling.friction_coeff;
    }

    if (abs(_movement.velocity_x) < 0.001) _movement.velocity_x = 0;
    if (abs(_movement.velocity_y) < 0.001) _movement.velocity_y = 0;

    _enemy.x += _movement.velocity_x;
    _enemy.y += _movement.velocity_y;
}

/// @description Moves an enemy slowly across a shallow repeating arc around its spawn anchor.
function sc_enemy_movement_swing(_enemy)
{
    var _data = _enemy.enemy;
    var _movement = _data.movement;
    var _swing = _data.movement_controller.swing;
    var _command = _movement.command;
    var _phase = GAME_TICK * _swing.speed + _movement.strafe_phase;
    var _side = sin(_phase);
    var _target_x = _movement.spawn_x + _side * _swing.width;
    var _target_y = _movement.spawn_y + (1 - _side * _side) * _swing.arc_depth;
    var _dx = _target_x - _enemy.x;
    var _dy = _target_y - _enemy.y;
    var _distance = point_distance(0, 0, _dx, _dy);

    if (_distance < 0.1) return;

    _command.active = true;
    _command.apply_friction = false;
    _command.direction = point_direction(0, 0, _dx, _dy);
    _command.speed_scale = min(_swing.speed_scale, _distance / max(1, _swing.response_distance));
    _command.facing_mode = EnemyFacingMode.FIXED;
}

/// @description Resolves current state, backaway priority, obstacle response, facing and movement.
function sc_enemy_movement_update(_enemy)
{
    var _data = _enemy.enemy;
    var _controller = _data.movement_controller;
    var _state = _data.state;
    var _backawaying = false;

    sc_enemy_movement_command_reset(_enemy);

    switch (_state)
    {
        case EnemyState.IDLE:
            _controller.idle_script(_enemy);
        break;

        case EnemyState.INVESTIGATING:
            sc_enemy_movement_investigate(_enemy);
        break;

        case EnemyState.CHASING:
            _controller.chase_script(_enemy);
        break;

        case EnemyState.ATTACKING:
            if (instance_exists(_data.target_id))
            {
                var _dx = _data.target_id.x - _enemy.x;
                var _dy = _data.target_id.y - _enemy.y;
                _data.target_distance_sq = _dx * _dx + _dy * _dy;

                if (_data.stats.final.range.backaway > 0
                && _data.target_distance_sq < _data.stats.final.range.backaway_sq)
                {
                    sc_enemy_movement_backaway(_enemy);
                    _backawaying = true;
                }
                else
                    _controller.combat_script(_enemy);
            }
        break;

        case EnemyState.STUNNED:
            var _stagger = _enemy.entity.status.stagger;
            _stagger.remaining--;

            if (_stagger.remaining <= 0)
            {
                _stagger.remaining = 0;
                _data.state = _stagger.return_state;
            }
        break;

        case EnemyState.FLEEING:
            _data.doctrine.flee.movement_script(_enemy);
        break;
    }

    if (_state == EnemyState.ATTACKING && !_backawaying)
        sc_enemy_movement_strafe_apply(_enemy);

    sc_enemy_asteroid_response_apply(_enemy);
    sc_enemy_facing_update(_enemy);
    sc_enemy_movement_apply(_enemy);

    if (_state == EnemyState.FLEEING
    && sc_enemy_flee_exit_check(_enemy))
        return true;

    return false;
}