/// @description Initializes optional independent utility channels for one enemy.
function sc_enemy_utility_controller_init(_enemy)
{
    var _data = _enemy.enemy;
    var _controller = _data.utility_controller;
    if (!is_struct(_controller)) return true;

    for (var _c = 0; _c < array_length(_controller.channels); _c++)
    {
        var _channel = _controller.channels[_c];
        var _hardpoint_index = -1;

        for (var _h = 0; _h < array_length(_data.hardpoints); _h++)
        {
            if (_data.hardpoints[_h].group != _channel.hardpoint_group) continue;
            _hardpoint_index = _h;
            break;
        }

        if (_hardpoint_index < 0)
        {
            show_debug_message(
                "ENEMY UTILITY ERROR - no hardpoint group "
                + _channel.hardpoint_group + " on " + _data.key
            );

            return false;
        }

        _channel.runtime = {
            target_id: noone,
            hardpoint_index: _hardpoint_index,
            next_target_tick: GAME_TICK,
            next_action_tick: GAME_TICK,
            active: false,
            aligned: false
        };
    }

    return true;
}

/// @description Clears one utility channel's committed target.
function sc_enemy_utility_target_clear(_channel)
{
    var _runtime = _channel.runtime;

    _runtime.target_id = noone;
    _runtime.active = false;
    _runtime.aligned = false;
    _runtime.next_target_tick = GAME_TICK + max(1, round(_channel.retarget_interval));
}

/// @description Returns whether a damaged allied repair target remains valid.
function sc_enemy_utility_target_repair_valid(_enemy, _channel, _target)
{
    if (!instance_exists(_target) || !_target.initialized) return false;

    var _data = _enemy.enemy;
    var _target_data = _target.enemy;
    var _defence = _target_data.defence;

    if (_target == _enemy
    || _target_data.state == EnemyState.DEAD
    || _target_data.identity.faction != _data.identity.faction)
        return false;

    if (_defence.armour.current >= _defence.armour.maximum
    && _defence.hull.current >= _defence.hull.maximum)
        return false;

    return sc_point_distance_sq(
        _enemy.x, _enemy.y,
        _target.x, _target.y
    ) <= sqr(_channel.release_range);
}

/// @description Selects the best damaged ally while prioritizing ships sheltered here.
function sc_enemy_utility_target_damaged_ally(_enemy, _channel)
{
    var _data = _enemy.enemy;
    var _list = ds_list_create();

    collision_circle_list(
        _enemy.x, _enemy.y,
        _channel.acquire_range,
        o_enemy, false, true,
        _list, false
    );

    var _target = noone;
    var _best_priority = -1;
    var _best_damage = -1;
    var _best_distance_sq = sqr(_channel.acquire_range);

    for (var _i = 0; _i < ds_list_size(_list); _i++)
    {
        var _candidate = _list[| _i];
        if (_candidate == _enemy || !_candidate.initialized) continue;

        var _candidate_data = _candidate.enemy;
        var _defence = _candidate_data.defence;

        if (_candidate_data.state == EnemyState.DEAD
        || _candidate_data.identity.faction != _data.identity.faction)
            continue;

        var _armour_missing = 1 - _defence.armour.current / max(1, _defence.armour.maximum);
        var _hull_missing = 1 - _defence.hull.current / max(1, _defence.hull.maximum);
        if (_armour_missing <= 0 && _hull_missing <= 0) continue;

        var _priority = _candidate_data.flee.sheltered
            && _candidate_data.flee.target_id == _enemy;

        var _damage = _hull_missing * 2 + _armour_missing;
        var _distance_sq = sc_point_distance_sq(
            _enemy.x, _enemy.y,
            _candidate.x, _candidate.y
        );

        if (_priority < _best_priority) continue;

        if (_priority == _best_priority)
        {
            if (_damage < _best_damage) continue;
            if (_damage == _best_damage && _distance_sq >= _best_distance_sq) continue;
        }

        _target = _candidate;
        _best_priority = _priority;
        _best_damage = _damage;
        _best_distance_sq = _distance_sq;
    }

    ds_list_destroy(_list);
    return _target;
}

/// @description Aims one utility hardpoint independently from combat targeting.
function sc_enemy_utility_hardpoint_aim_update(_enemy, _channel)
{
    var _data = _enemy.enemy;
    var _runtime = _channel.runtime;
    var _target = _runtime.target_id;
    var _hardpoint = _data.hardpoints[_runtime.hardpoint_index];
    var _hardpoint_runtime = _hardpoint.runtime;
    var _base_angle = _enemy.draw_angle + _hardpoint.angle;
    var _desired_angle = _base_angle;

    if (instance_exists(_target))
    {
        var _radius = _data.visual.radius;
        var _mount_x = _enemy.x
            + lengthdir_x(_hardpoint.forward * _radius, _enemy.draw_angle)
            + lengthdir_x(_hardpoint.side * _radius, _enemy.draw_angle + 90);

        var _mount_y = _enemy.y
            + lengthdir_y(_hardpoint.forward * _radius, _enemy.draw_angle)
            + lengthdir_y(_hardpoint.side * _radius, _enemy.draw_angle + 90);

        var _target_angle = point_direction(
            _mount_x, _mount_y,
            _target.x, _target.y
        );

        var _arc_half = _hardpoint.rotation.arc * 0.5;

        _desired_angle = _hardpoint.rotation.arc >= 360
            ? _target_angle
            : _base_angle + clamp(
                angle_difference(_target_angle, _base_angle),
                -_arc_half, _arc_half
            );
    }

    _hardpoint_runtime.aim_angle += clamp(
        angle_difference(_desired_angle, _hardpoint_runtime.aim_angle),
        -_hardpoint.rotation.turn_speed,
        _hardpoint.rotation.turn_speed
    );

    _runtime.aligned = instance_exists(_target)
        && abs(angle_difference(_desired_angle, _hardpoint_runtime.aim_angle))
            <= _channel.aim_tolerance;
}

/// @description Applies one externally controlled armour and hull repair tick.
function sc_enemy_utility_action_repair(_enemy, _channel, _target)
{
    var _defence = _target.enemy.defence;
    var _repair = _channel.repair;

    _defence.hull.current = min(
        _defence.hull.maximum,
        _defence.hull.current + _repair.hull
    );

    _defence.armour.current = min(
        _defence.armour.maximum,
        _defence.armour.current + _repair.armour
    );

    return true;
}

/// @description Updates every optional utility channel owned by one enemy.
function sc_enemy_utility_update(_enemy)
{
    var _data = _enemy.enemy;
    var _controller = _data.utility_controller;
    if (!is_struct(_controller)) return false;

    var _disabled = _data.state == EnemyState.FLEEING
        || _data.state == EnemyState.STUNNED
        || _data.state == EnemyState.DEAD;

    for (var _c = 0; _c < array_length(_controller.channels); _c++)
    {
        var _channel = _controller.channels[_c];
        var _runtime = _channel.runtime;
        _target = _channel.target_script(_enemy, _channel);

        if (_disabled)
        {
            if (instance_exists(_target))
                sc_enemy_utility_target_clear(_channel);

            continue;
        }

        if (instance_exists(_target)
        && !_channel.valid_script(_enemy, _channel, _target))
        {
            sc_enemy_utility_target_clear(_channel);
            _target = noone;
        }

        if (!instance_exists(_target)
			&& GAME_TICK >= _runtime.next_target_tick)
			{
			    _target = _channel.target_script(_enemy, _channel);
			    _runtime.target_id = _target;
			    _runtime.active = instance_exists(_target);

			    if (!instance_exists(_target))
			        _runtime.next_target_tick = GAME_TICK
			            + max(1, round(_channel.retarget_interval));
			}

        sc_enemy_utility_hardpoint_aim_update(_enemy, _channel);

        if (!_runtime.active
        || !_runtime.aligned
        || GAME_TICK < _runtime.next_action_tick)
            continue;

        _channel.action_script(_enemy, _channel, _runtime.target_id);
        _runtime.next_action_tick = GAME_TICK + max(1, round(_channel.action_interval));
    }

    return true;
}

/// @description Draws one stable Corporation repair beam between emitter and ally.
function sc_enemy_utility_repair_beam_draw(_x, _y, _target_x, _target_y, _channel, _palette)
{
    var _pulse = 0.9 + sin(GAME_TICK * 0.18) * 0.1;
    var _width = _channel.visual.width * _pulse;

    gpu_set_blendmode(bm_add);

    draw_set_alpha(0.16);
    draw_set_colour(_palette.glow);
    draw_line_width(_x, _y, _target_x, _target_y, _channel.visual.glow_width * _pulse);

    draw_set_alpha(0.48);
    draw_set_colour(_palette.accent);
    draw_line_width(_x, _y, _target_x, _target_y, _width * 2.2);

    draw_set_alpha(0.9);
    draw_set_colour(_palette.energy);
    draw_line_width(_x, _y, _target_x, _target_y, _width);

    draw_set_alpha(1);
    draw_set_colour(_palette.core);
    draw_line_width(_x, _y, _target_x, _target_y, max(1, _width * 0.3));

    draw_set_alpha(0.24);
    draw_set_colour(_palette.glow);
    draw_circle(_target_x, _target_y, 24 * _pulse, false);

    draw_set_alpha(1);
    draw_set_colour(_palette.core);
    draw_circle(_target_x, _target_y, 5 * _pulse, false);

    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
    draw_set_colour(c_white);
}

/// @description Draws active utility channels using their independently aimed hardpoints.
function sc_enemy_utility_draw(_enemy, _draw_x, _draw_y)
{
    var _data = _enemy.enemy;
    var _controller = _data.utility_controller;
    if (!is_struct(_controller)) return;

    for (var _c = 0; _c < array_length(_controller.channels); _c++)
    {
        var _channel = _controller.channels[_c];
        var _runtime = _channel.runtime;
        var _target = _runtime.target_id;

        if (!_runtime.active || !_runtime.aligned || !instance_exists(_target))
            continue;

        var _hardpoint = _data.hardpoints[_runtime.hardpoint_index];
        var _radius = _data.visual.radius;
        var _angle = _enemy.draw_angle;
        var _hardpoint_angle = _hardpoint.runtime.aim_angle;

        var _mount_x = _draw_x
            + lengthdir_x(_hardpoint.forward * _radius, _angle)
            + lengthdir_x(_hardpoint.side * _radius, _angle + 90);

        var _mount_y = _draw_y
            + lengthdir_y(_hardpoint.forward * _radius, _angle)
            + lengthdir_y(_hardpoint.side * _radius, _angle + 90);

        var _muzzle_x = _mount_x
            + lengthdir_x(_hardpoint.muzzle_forward * _radius, _hardpoint_angle);

        var _muzzle_y = _mount_y
            + lengthdir_y(_hardpoint.muzzle_forward * _radius, _hardpoint_angle);

        _channel.draw_script(
            _muzzle_x, _muzzle_y,
            _target.x, _target.y,
            _channel,
            _data.visual.palette
        );
    }
}