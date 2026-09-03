/// @description Initializes one enemy from registered data and final stats.
function sc_enemy_init(_enemy, _enemy_key)
{
    if (!variable_struct_exists(global.data.enemies, _enemy_key))
    {
        show_debug_message("ENEMY INITIALIZATION ERROR - unknown key: " + _enemy_key);
        return false;
    }

    var _data = variable_struct_get(global.data.enemies, _enemy_key);
    var _radius = _data.visual.radius;

    _enemy.enemy = {
        key: _enemy_key,
        identity: variable_clone(_data.identity),
        state: EnemyState.IDLE,
        target_id: noone,
        target_distance_sq: 0,
        stats: undefined,
        defence: undefined,
        movement: {
            velocity_x: 0,
            velocity_y: 0,

            spawn_x: _enemy.x,
            spawn_y: _enemy.y,

            wander: {
                active: false,
                target_x: _enemy.x,
                target_y: _enemy.y,
                next_move_tick: GAME_TICK + irandom_range(30, 90)
            }
        },

        collision: {
            radius_forward: _radius * _data.collision.radius_forward_scale,
            radius_side: _radius * _data.collision.radius_side_scale,
            blocks_player: _data.collision.blocks_player
        },

        visual: variable_clone(_data.visual),
        hardpoints: variable_clone(_data.hardpoints),
        thrusters: variable_clone(_data.thrusters),
        attack_controller: variable_clone(_data.attack_controller)
    };

    if (!sc_enemy_stats_init(_enemy, _data.stats_base)) return false;

    var _runtime = _enemy.enemy;
    var _final = _runtime.stats.final;
    var _cache = sc_enemy_visual_cache_get(_enemy_key);

    _enemy.draw_angle = 0;

    if (!sc_entity_init(_enemy, _runtime.identity.faction, sc_enemy_damage, _runtime.collision)) return false;

    _runtime.defence = {
        shield: { current: _final.shield_max, maximum: _final.shield_max },
        armour: { current: _final.armour_max, maximum: _final.armour_max },
        hull: { current: _final.hull_max, maximum: _final.hull_max }
    };

    _runtime.visual.runtime = {
        body_sprite: is_struct(_cache) ? _cache.body : -1,
        core_sprite: is_struct(_cache) ? _cache.core : -1,
        thrust_sprite: is_struct(_cache) ? _cache.thrust : -1,
        shield_sprite: is_struct(_cache) ? _cache.shield : -1,
        shield_hit_alpha: 0,
        core_angle: 0,
        core_alpha: 1,
        motion_phase: random(2 * pi)
    };

    for (var _i = 0; _i < array_length(_runtime.hardpoints); _i++)
    {
        var _hardpoint = _runtime.hardpoints[_i];
        var _sprite = is_struct(_cache) && _i < array_length(_cache.hardpoints) ? _cache.hardpoints[_i] : -1;

        if (!variable_struct_exists(_hardpoint, "rotation"))
            _hardpoint.rotation = { mode: HardpointRotation.FIXED, turn_speed: 0, arc: 0, return_to_rest: true };

        _hardpoint.runtime = { sprite: _sprite, recoil: 0, aim_angle: _enemy.draw_angle + _hardpoint.angle };
    }

    for (var _i = 0; _i < array_length(_runtime.thrusters); _i++)
        _runtime.thrusters[_i].runtime = { active: false, power: 0, phase: irandom(359) };

    for (var _i = 0; _i < array_length(_runtime.attack_controller.attacks); _i++)
    {
        var _attack = _runtime.attack_controller.attacks[_i];
        _attack.hardpoint_indices = [];

        for (var _h = 0; _h < array_length(_runtime.hardpoints); _h++)
        {
            if (_runtime.hardpoints[_h].group == _attack.hardpoint_group)
                array_push(_attack.hardpoint_indices, _h);
        }
    }

    _runtime.attack_controller.runtime = {
        phase: EnemyAttackPhase.IDLE,
        current_attack: -1,
        next_attack_index: 0,
        hardpoint_cursor: 0,
        volley_count: 0,
        next_fire_tick: 0,
        cooldown_until: 0,
        attack_end_tick: 0,
        telegraph_start_tick: 0,
        telegraph_end_tick: 0,
        next_telegraph_particle_tick: 0,
        active_deliveries: []
    };

    _enemy.initialized = true;
    global.level.enemies_alive++;
    show_debug_message("ENEMY INITIALIZED - " + _runtime.identity.name);
    return true;
}

/// @description Updates detection, combat and forget transitions using final ranges.
function sc_enemy_perception_update(_enemy)
{
    var _data = _enemy.enemy;
    var _range = _data.stats.final.range;

    if (!instance_exists(global.player_id))
    {
        _data.target_id = noone;
        _data.state = EnemyState.IDLE;
        return;
    }

    var _dx = global.player_id.x - _enemy.x;
    var _dy = global.player_id.y - _enemy.y;
    _data.target_distance_sq = _dx * _dx + _dy * _dy;

    switch (_data.state)
    {
        case EnemyState.IDLE:
            if (!UPDATE_4) return;

            if (_data.target_distance_sq <= _range.detection_sq)
            {
                _data.target_id = global.player_id;
                _data.state = EnemyState.CHASING;
            }
        break;

        case EnemyState.CHASING:
            if (_data.target_distance_sq > _range.forget_sq)
            {
                sc_enemy_attack_cancel(_enemy);
                _data.target_id = noone;
                _data.state = EnemyState.IDLE;
            }
            else if (_data.target_distance_sq <= _range.combat_sq)
                _data.state = EnemyState.ATTACKING;
        break;

        case EnemyState.ATTACKING:
            if (_data.target_distance_sq > _range.forget_sq)
            {
                sc_enemy_attack_cancel(_enemy);
                _data.target_id = noone;
                _data.state = EnemyState.IDLE;
            }
            else if (_data.target_distance_sq > _range.combat_sq)
            {
                sc_enemy_attack_cancel(_enemy);
                _data.state = EnemyState.CHASING;
            }
        break;
    }
}

/// @description Updates enemy hardpoint aiming, aim locks and recoil runtime.
function sc_enemy_hardpoint_update(_enemy)
{
    var _data = _enemy.enemy;
    var _visual = _data.visual;
    var _hardpoints = _data.hardpoints;
    var _has_target = instance_exists(_data.target_id);

    for (var _i = 0; _i < array_length(_hardpoints); _i++)
    {
        var _hardpoint = _hardpoints[_i];
        var _rotation = _hardpoint.rotation;
        var _runtime = _hardpoint.runtime;
        var _base_angle = _enemy.draw_angle + _hardpoint.angle;
        var _desired_angle = _runtime.aim_angle;
        var _aim_locked = sc_enemy_attack_hardpoint_aim_locked(_enemy, _i);

        if (!_aim_locked)
        {
            if (_rotation.mode == HardpointRotation.TARGET && _has_target)
            {
                var _forward = _hardpoint.forward * _visual.radius;
                var _side = _hardpoint.side * _visual.radius;
                var _mount_x = _enemy.x + lengthdir_x(_forward, _enemy.draw_angle) + lengthdir_x(_side, _enemy.draw_angle + 90);
                var _mount_y = _enemy.y + lengthdir_y(_forward, _enemy.draw_angle) + lengthdir_y(_side, _enemy.draw_angle + 90);
                var _target_angle = point_direction(_mount_x, _mount_y, _data.target_id.x, _data.target_id.y);
                var _arc_half = _rotation.arc * 0.5;

                _desired_angle = _rotation.arc >= 360
                    ? _target_angle
                    : _base_angle + clamp(angle_difference(_target_angle, _base_angle), -_arc_half, _arc_half);
            }
            else if (_rotation.mode == HardpointRotation.FIXED || _rotation.return_to_rest)
                _desired_angle = _base_angle;

            if (_rotation.mode == HardpointRotation.FIXED)
                _runtime.aim_angle = _base_angle;
            else
                _runtime.aim_angle += clamp(angle_difference(_desired_angle, _runtime.aim_angle), -_rotation.turn_speed, _rotation.turn_speed);
        }

        if (_runtime.recoil > 0.01)
            _runtime.recoil = lerp(_runtime.recoil, 0, 0.22);
        else
            _runtime.recoil = 0;
    }
}

/// @description Updates visual-only enemy animation, shield feedback and thruster effects.
function sc_enemy_visual_update(_enemy)
{
    var _data = _enemy.enemy;
    var _visual = _data.visual;
    var _movement = _data.movement;
    var _thrusters = _data.thrusters;
    var _speed_max = _data.stats.final.handling.speed_max;
    var _thrust_config = global.config.visual.enemy_thrust;

    _visual.runtime.core_angle = (_visual.runtime.core_angle + 1.5) mod 360;
    _visual.runtime.core_alpha = 0.78 + sin(GAME_TICK * 0.09) * 0.22;
    _visual.runtime.shield_hit_alpha = max(0, _visual.runtime.shield_hit_alpha - 0.06);

    var _speed = point_distance(0, 0, _movement.velocity_x, _movement.velocity_y);
    var _target_power = _speed_max > 0 ? clamp(_speed / _speed_max, 0, 1) : 0;

    for (var _i = 0; _i < array_length(_thrusters); _i++)
    {
        var _thruster = _thrusters[_i];
        var _runtime = _thruster.runtime;
        var _active = _target_power > _thrust_config.active_power_min;
        var _forward = _thruster.forward * _visual.radius;
        var _side = _thruster.side * _visual.radius;
        var _thruster_x = _enemy.x + lengthdir_x(_forward, _enemy.draw_angle) + lengthdir_x(_side, _enemy.draw_angle + 90);
        var _thruster_y = _enemy.y + lengthdir_y(_forward, _enemy.draw_angle) + lengthdir_y(_side, _enemy.draw_angle + 90);
        var _thruster_angle = _enemy.draw_angle + _thruster.angle;

        if (_active && !_runtime.active)
            _visual.thrust.ignition_script(_thruster_x, _thruster_y, _thruster_angle, _target_power,
                _thruster.scale, _visual.radius, _visual.visual_mass, _visual.palette);

        _runtime.active = _active;
        _runtime.power = lerp(_runtime.power, _target_power, _target_power > _runtime.power ? 0.22 : 0.12);

        if (_runtime.power > _thrust_config.emit_power_min
        && ((GAME_TICK + _runtime.phase) mod _thrust_config.emit_interval) == 0)
            _visual.thrust.particle_script(_thruster_x, _thruster_y, _thruster_angle, _runtime.power,
                _thruster.scale, _visual.radius, _visual.visual_mass, _visual.palette);
    }
}

/// @description Begins or extends a brief enemy movement and attack disruption.
function sc_enemy_stagger_begin(_enemy, _effect)
{
    var _data = _enemy.enemy;
    if (_data.state == EnemyState.DEAD) return false;

    var _stagger = _enemy.entity.status.stagger;

    if (_stagger.remaining <= 0)
        _stagger.return_state = _data.state;

    _stagger.remaining = max(_stagger.remaining, max(1, round(_effect.duration)));

    var _velocity_retained = 1 - clamp(_effect.strength, 0, 1);
    _data.movement.velocity_x *= _velocity_retained;
    _data.movement.velocity_y *= _velocity_retained;

    sc_enemy_attack_cancel(_enemy);
    _data.state = EnemyState.STUNNED;

    // Insert brief stagger flash, particles or audio here later.
    return true;
}

/// @description Updates brief enemy stagger drift and restores its previous state.
function sc_enemy_update_stunned(_enemy)
{
    var _data = _enemy.enemy;
    var _movement = _data.movement;
    var _stagger = _enemy.entity.status.stagger;
    var _friction_coeff = _data.stats.final.handling.friction_coeff;

    _movement.velocity_x *= _friction_coeff;
    _movement.velocity_y *= _friction_coeff;

    _enemy.x += _movement.velocity_x;
    _enemy.y += _movement.velocity_y;

    _stagger.remaining--;

    if (_stagger.remaining <= 0)
    {
        _stagger.remaining = 0;
        _data.state = _stagger.return_state;
    }
}

/// @description Selects one unobstructed wander destination inside the registered spawn radius.
function sc_enemy_wander_target_select(_enemy)
{
    var _data = _enemy.enemy;
    var _movement = _data.movement;
    var _wander = _movement.wander;
    var _range = _data.stats.final.range.wander;
    var _config = global.config.enemy.wander;
    var _extent = max(_data.collision.radius_forward, _data.collision.radius_side);
    var _margin = _extent + _config.edge_margin;

    for (var _i = 0; _i < _config.candidate_attempts; _i++)
    {
        var _direction = random(360);
        var _distance = sqrt(random(1)) * _range;
        var _target_x = _movement.spawn_x + lengthdir_x(_distance, _direction);
        var _target_y = _movement.spawn_y + lengthdir_y(_distance, _direction);

        if (_target_x < _margin || _target_x > room_width - _margin
        || _target_y < _margin || _target_y > room_height - _margin)
            continue;

        if (place_meeting(_target_x, _target_y, o_solid)) continue;
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

/// @description Moves an idle enemy between occasional valid points around its spawn location.
function sc_enemy_wander_update(_enemy)
{
    var _data = _enemy.enemy;
    var _movement = _data.movement;
    var _wander = _movement.wander;
    var _config = global.config.enemy.wander;

    if (!_wander.active)
    {
        if (GAME_TICK >= _wander.next_move_tick)
            sc_enemy_wander_target_select(_enemy);

        return false;
    }

    var _dx = _wander.target_x - _enemy.x;
    var _dy = _wander.target_y - _enemy.y;
    var _distance_sq = _dx * _dx + _dy * _dy;

    if (_distance_sq <= sqr(_config.arrival_radius))
    {
        _wander.active = false;
        _wander.next_move_tick = GAME_TICK + irandom_range(_config.wait_min, _config.wait_max);
        return false;
    }

    var _direction = point_direction(_enemy.x, _enemy.y, _wander.target_x, _wander.target_y);
    var _turn_speed = _data.stats.final.handling.turn_speed;

    sc_enemy_movement_accelerate(_enemy, _direction, _config.speed_scale);

    var _turn = angle_difference(_direction, _enemy.draw_angle);
    _enemy.draw_angle += clamp(_turn, -_turn_speed, _turn_speed);
    _enemy.draw_angle = _enemy.draw_angle mod 360;
    return true;
}

/// @description Wanders around the spawn location or applies passive idle decay when disabled.
function sc_enemy_update_idle(_enemy)
{
    var _data = _enemy.enemy;
    var _movement = _data.movement;
    var _friction_coeff = _data.stats.final.handling.friction_coeff;
    var _wandering = false;

    if (_data.stats.final.range.wander > 0)
        _wandering = sc_enemy_wander_update(_enemy);

    if (!_wandering)
    {
        _movement.velocity_x *= _friction_coeff;
        _movement.velocity_y *= _friction_coeff;

        if (abs(_movement.velocity_x) < 0.001) _movement.velocity_x = 0;
        if (abs(_movement.velocity_y) < 0.001) _movement.velocity_y = 0;
    }

    _enemy.x += _movement.velocity_x;
    _enemy.y += _movement.velocity_y;

    // Future: range.alert_share controls one-time nearby ally alert broadcasting.
}

/// @description Returns movement alignment where 1 is forward and 0 is directly backwards.
function sc_enemy_movement_alignment(_enemy, _move_direction)
{
    var _handling = _enemy.enemy.stats.final.handling;
    if (!_handling.directional) return 1;

    return (dcos(angle_difference(_move_direction, _enemy.draw_angle)) + 1) * 0.5;
}

/// @description Accelerates toward a direction using final handling and optional directional penalties.
function sc_enemy_movement_accelerate(_enemy, _move_direction, _speed_scale = 1)
{
    var _data = _enemy.enemy;
    var _handling = _data.stats.final.handling;
    var _movement = _data.movement;
    var _alignment = sc_enemy_movement_alignment(_enemy, _move_direction);
    var _speed_factor = lerp(_handling.directional_speed_min, 1, _alignment);
    var _thrust_factor = lerp(_handling.directional_thrust_min, 1, _alignment);
    var _speed_max = _handling.speed_max * _speed_scale * _speed_factor;
    var _acceleration = _handling.acceleration * _thrust_factor;
    var _target_vx = lengthdir_x(_speed_max, _move_direction);
    var _target_vy = lengthdir_y(_speed_max, _move_direction);

    _movement.velocity_x += clamp(_target_vx - _movement.velocity_x, -_acceleration, _acceleration);
    _movement.velocity_y += clamp(_target_vy - _movement.velocity_y, -_acceleration, _acceleration);

    return _alignment;
}

/// @description Returns a rotated ellipse's radius along one world direction.
function sc_enemy_collision_radius_at_direction(_enemy, _direction)
{
    var _collision = _enemy.entity.collision;
    var _forward = max(1, _collision.radius_forward);
    var _side = max(1, _collision.radius_side);
    var _relative = angle_difference(_direction, _enemy.draw_angle);
    var _cos = dcos(_relative);
    var _sin = dsin(_relative);

    return 1 / sqrt(sqr(_cos / _forward) + sqr(_sin / _side));
}

/// @description Separates one overlapping enemy pair using their rotated elliptical collision shapes.
function sc_enemy_separation_resolve(_enemy, _other)
{
    if (_enemy.enemy.state == EnemyState.DEAD || _other.enemy.state == EnemyState.DEAD) return false;

    var _dx = _other.x - _enemy.x;
    var _dy = _other.y - _enemy.y;
    var _distance = point_distance(0, 0, _dx, _dy);
    var _direction = _distance > 0.001 ? point_direction(0, 0, _dx, _dy) : (real(_enemy.id) mod 360);
    var _radius_enemy = sc_enemy_collision_radius_at_direction(_enemy, _direction);
    var _radius_other = sc_enemy_collision_radius_at_direction(_other, _direction + 180);
    var _overlap = _radius_enemy + _radius_other - _distance;

    if (_overlap <= 0) return false;

    var _config = global.config.enemy.separation;
    var _mass_enemy = _enemy.entity.collision.radius_forward * _enemy.entity.collision.radius_side;
    var _mass_other = _other.entity.collision.radius_forward * _other.entity.collision.radius_side;
    var _mass_total = max(1, _mass_enemy + _mass_other);
    var _weight_enemy = _mass_other / _mass_total;
    var _weight_other = _mass_enemy / _mass_total;
    var _push = min(_config.maximum_push, _overlap * _config.strength);
    var _correction = min(_overlap, _overlap * _config.position_correction);
    var _nx = lengthdir_x(1, _direction);
    var _ny = lengthdir_y(1, _direction);

    _enemy.enemy.movement.velocity_x -= _nx * _push * _weight_enemy;
    _enemy.enemy.movement.velocity_y -= _ny * _push * _weight_enemy;
    _other.enemy.movement.velocity_x += _nx * _push * _weight_other;
    _other.enemy.movement.velocity_y += _ny * _push * _weight_other;

    _enemy.x -= _nx * _correction * _weight_enemy;
    _enemy.y -= _ny * _correction * _weight_enemy;
    _other.x += _nx * _correction * _weight_other;
    _other.y += _ny * _correction * _weight_other;

    return true;
}

/// @description Moves the enemy toward its target using shared directional handling.
function sc_enemy_update_chasing(_enemy)
{
    var _data = _enemy.enemy;
    var _handling = _data.stats.final.handling;
    var _target = _data.target_id;
    var _direction = point_direction(_enemy.x, _enemy.y, _target.x, _target.y);

    sc_enemy_movement_accelerate(_enemy, _direction);

    _enemy.x += _data.movement.velocity_x;
    _enemy.y += _data.movement.velocity_y;

    var _turn = angle_difference(_direction, _enemy.draw_angle);
    _enemy.draw_angle += clamp(_turn, -_handling.turn_speed, _handling.turn_speed);
    _enemy.draw_angle = _enemy.draw_angle mod 360;
}

/// @description Attacks while retreating from targets that enter the registered close range.
function sc_enemy_update_attacking(_enemy)
{
    var _data = _enemy.enemy;
    var _stats = _data.stats.final;
    var _handling = _stats.handling;
    var _range = _stats.range;
    var _movement = _data.movement;
    var _target = _data.target_id;
    var _direction = point_direction(_enemy.x, _enemy.y, _target.x, _target.y);

    if (_range.retreat > 0 && _data.target_distance_sq < _range.retreat_sq)
        sc_enemy_movement_accelerate(_enemy, _direction + 180);
    else
    {
        _movement.velocity_x *= _handling.friction_coeff;
        _movement.velocity_y *= _handling.friction_coeff;
    }

    _enemy.x += _movement.velocity_x;
    _enemy.y += _movement.velocity_y;

    if (!sc_enemy_attack_aim_locked(_enemy))
    {
        var _turn = angle_difference(_direction, _enemy.draw_angle);
        _enemy.draw_angle += clamp(_turn, -_handling.turn_speed, _handling.turn_speed);
        _enemy.draw_angle = _enemy.draw_angle mod 360;
    }

    sc_enemy_attack_update(_enemy);

    // Future: range.alert_share controls one-time nearby ally alert broadcasting.
}

/// @description Returns whether a fixed participating hardpoint currently locks the enemy hull.
function sc_enemy_attack_aim_locked(_enemy)
{
    var _controller = _enemy.enemy.attack_controller;
    var _runtime = _controller.runtime;

    if (_runtime.current_attack < 0) return false;

    var _attack = _controller.attacks[_runtime.current_attack];
    if (!variable_struct_exists(_attack, "telegraph")) return false;

    var _locked = false;

    switch (_runtime.phase)
    {
        case EnemyAttackPhase.TELEGRAPH:
            _locked = GAME_TICK >= _runtime.telegraph_end_tick - _attack.telegraph.aim_lock_remaining;
        break;

        case EnemyAttackPhase.ACTIVE:
            _locked = !_attack.telegraph.track_during_active;
        break;
    }

    if (!_locked) return false;

    for (var _i = 0; _i < array_length(_attack.hardpoint_indices); _i++)
    {
        var _hardpoint = _enemy.enemy.hardpoints[_attack.hardpoint_indices[_i]];
        if (_hardpoint.rotation.mode == HardpointRotation.FIXED) return true;
    }

    return false;
}

/// @description Returns whether one independently rotating participating hardpoint has locked its aim.
function sc_enemy_attack_hardpoint_aim_locked(_enemy, _hardpoint_index)
{
    var _controller = _enemy.enemy.attack_controller;
    var _runtime = _controller.runtime;

    if (_runtime.current_attack < 0) return false;

    var _attack = _controller.attacks[_runtime.current_attack];
    if (!variable_struct_exists(_attack, "telegraph")) return false;

    var _locked = false;

    switch (_runtime.phase)
    {
        case EnemyAttackPhase.TELEGRAPH:
            _locked = GAME_TICK >= _runtime.telegraph_end_tick - _attack.telegraph.aim_lock_remaining;
        break;

        case EnemyAttackPhase.ACTIVE:
            _locked = !_attack.telegraph.track_during_active;
        break;
    }

    if (!_locked) return false;

    for (var _i = 0; _i < array_length(_attack.hardpoint_indices); _i++)
    {
        if (_attack.hardpoint_indices[_i] == _hardpoint_index)
            return _enemy.enemy.hardpoints[_hardpoint_index].rotation.mode == HardpointRotation.TARGET;
    }

    return false;
}

/// @description Releases active deliveries and cancels the current enemy attack.
function sc_enemy_attack_cancel(_enemy)
{
    var _runtime = _enemy.enemy.attack_controller.runtime;

    for (var _i = 0; _i < array_length(_runtime.active_deliveries); _i++)
    {
        var _delivery = _runtime.active_deliveries[_i].delivery_id;
        if (instance_exists(_delivery)) sc_beam_release(_delivery);
    }

    _runtime.active_deliveries = [];
    _runtime.phase = EnemyAttackPhase.IDLE;
    _runtime.current_attack = -1;
    _runtime.hardpoint_cursor = 0;
    _runtime.volley_count = 0;
    _runtime.attack_end_tick = 0;
    _runtime.telegraph_start_tick = 0;
    _runtime.telegraph_end_tick = 0;
}

/// @description Completes one enemy attack and begins its registered cooldown.
function sc_enemy_attack_finish(_enemy, _cooldown)
{
    var _runtime = _enemy.enemy.attack_controller.runtime;

    for (var _i = 0; _i < array_length(_runtime.active_deliveries); _i++)
    {
        var _delivery = _runtime.active_deliveries[_i].delivery_id;
        if (instance_exists(_delivery)) sc_beam_release(_delivery);
    }

    _runtime.active_deliveries = [];
    _runtime.phase = EnemyAttackPhase.COOLDOWN;
    _runtime.current_attack = -1;
    _runtime.hardpoint_cursor = 0;
    _runtime.volley_count = 0;
    _runtime.attack_end_tick = 0;
    _runtime.telegraph_start_tick = 0;
    _runtime.telegraph_end_tick = 0;
    _runtime.cooldown_until = GAME_TICK + max(1, round(_cooldown));
}

/// @description Returns whether an attack satisfies its optional range and defence conditions.
function sc_enemy_attack_can_use(_enemy, _attack)
{
    if (!variable_struct_exists(_attack, "conditions")) return true;

    var _conditions = _attack.conditions;
    var _data = _enemy.enemy;
    var _defence = _data.defence;
    var _distance_sq = _data.target_distance_sq;

    if (variable_struct_exists(_conditions, "range_min")
    && _distance_sq < sqr(_conditions.range_min))
        return false;

    if (variable_struct_exists(_conditions, "range_max")
    && _distance_sq > sqr(_conditions.range_max))
        return false;

    var _shield_ratio = _defence.shield.maximum > 0 ? _defence.shield.current / _defence.shield.maximum : 0;
    var _armour_ratio = _defence.armour.maximum > 0 ? _defence.armour.current / _defence.armour.maximum : 0;
    var _hull_ratio = _defence.hull.current / _defence.hull.maximum;

    if (variable_struct_exists(_conditions, "shield_ratio_min") && _shield_ratio < _conditions.shield_ratio_min) return false;
    if (variable_struct_exists(_conditions, "shield_ratio_max") && _shield_ratio > _conditions.shield_ratio_max) return false;
    if (variable_struct_exists(_conditions, "armour_ratio_min") && _armour_ratio < _conditions.armour_ratio_min) return false;
    if (variable_struct_exists(_conditions, "armour_ratio_max") && _armour_ratio > _conditions.armour_ratio_max) return false;
    if (variable_struct_exists(_conditions, "hull_ratio_min") && _hull_ratio < _conditions.hull_ratio_min) return false;
    if (variable_struct_exists(_conditions, "hull_ratio_max") && _hull_ratio > _conditions.hull_ratio_max) return false;

    return true;
}

/// @description Chooses one currently usable attack using the registered selection method.
function sc_enemy_attack_select(_enemy)
{
    var _controller = _enemy.enemy.attack_controller;
    var _runtime = _controller.runtime;
    var _count = array_length(_controller.attacks);

    switch (_controller.selection)
    {
        case AttackSelection.SEQUENTIAL:
            for (var _offset = 0; _offset < _count; _offset++)
            {
                var _index = (_runtime.next_attack_index + _offset) mod _count;

                if (sc_enemy_attack_can_use(_enemy, _controller.attacks[_index]))
                {
                    _runtime.next_attack_index = (_index + 1) mod _count;
                    return _index;
                }
            }
        break;

        case AttackSelection.RANDOM:
            var _selected = -1;
            var _eligible_count = 0;

            for (var _i = 0; _i < _count; _i++)
            {
                if (!sc_enemy_attack_can_use(_enemy, _controller.attacks[_i])) continue;

                _eligible_count++;
                if (irandom(_eligible_count - 1) == 0) _selected = _i;
            }

            return _selected;

        case AttackSelection.WEIGHTED:
            var _weight_total = 0;

            for (var _i = 0; _i < _count; _i++)
            {
                var _attack = _controller.attacks[_i];
                if (sc_enemy_attack_can_use(_enemy, _attack))
                    _weight_total += _attack.weight;
            }

            if (_weight_total <= 0) return -1;

            var _roll = random(_weight_total);

            for (var _i = 0; _i < _count; _i++)
            {
                var _attack = _controller.attacks[_i];
                if (!sc_enemy_attack_can_use(_enemy, _attack)) continue;

                _roll -= _attack.weight;
                if (_roll <= 0) return _i;
            }
        break;

        default:
            for (var _i = 0; _i < _count; _i++)
            {
                if (sc_enemy_attack_can_use(_enemy, _controller.attacks[_i]))
                    return _i;
            }
        break;
    }

    return -1;
}

/// @description Resolves one hardpoint muzzle and attack direction into a reusable transform.
function sc_enemy_hardpoint_attack_transform(_enemy, _attack, _hardpoint_index, _transform)
{
    var _data = _enemy.enemy;
    var _hardpoint = _data.hardpoints[_hardpoint_index];
    var _radius = _data.visual.radius;
    var _mount_angle = _hardpoint.runtime.aim_angle;
    var _forward = _hardpoint.forward * _radius;
    var _side = _hardpoint.side * _radius;
    var _recoil = _hardpoint.runtime.recoil;

    var _mount_x = _enemy.x
        + lengthdir_x(_forward, _enemy.draw_angle)
        + lengthdir_x(_side, _enemy.draw_angle + 90)
        - lengthdir_x(_recoil, _mount_angle);

    var _mount_y = _enemy.y
        + lengthdir_y(_forward, _enemy.draw_angle)
        + lengthdir_y(_side, _enemy.draw_angle + 90)
        - lengthdir_y(_recoil, _mount_angle);

    _transform.x = _mount_x + lengthdir_x(_hardpoint.muzzle_forward * _radius, _mount_angle);
    _transform.y = _mount_y + lengthdir_y(_hardpoint.muzzle_forward * _radius, _mount_angle);
    _transform.direction = _mount_angle;

    if (_hardpoint.rotation.mode == HardpointRotation.FIXED)
    {
        switch (_attack.aim.mode)
        {
            case AimMode.TARGET:
                _transform.direction = point_direction(_transform.x, _transform.y, _data.target_id.x, _data.target_id.y);
            break;

            case AimMode.TARGET_LEAD:
                // Target-leading solution goes here later.
                _transform.direction = point_direction(_transform.x, _transform.y, _data.target_id.x, _data.target_id.y);
            break;

            case AimMode.WORLD:
                _transform.direction = _attack.aim.world_direction;
            break;
        }
    }
    else if (_attack.aim.mode == AimMode.WORLD)
        _transform.direction = _attack.aim.world_direction;

    _transform.direction += _attack.aim.angle_offset;
    return _transform;
}

/// @description Fires one hardpoint and returns its created delivery instance.
function sc_enemy_attack_fire_hardpoint(_enemy, _attack, _hardpoint_index)
{
    var _transform = { x: 0, y: 0, direction: 0 };
    sc_enemy_hardpoint_attack_transform(_enemy, _attack, _hardpoint_index, _transform);

    var _direction = _transform.direction + random_range(-_attack.aim.inaccuracy, _attack.aim.inaccuracy);
    var _delivery = sc_weapon_fire(
        _enemy,
        _attack.weapon_key,
        _attack.shot,
        _transform.x,
        _transform.y,
        _direction,
        _enemy.enemy.stats.final.damage_multiplier
    );

    _enemy.enemy.hardpoints[_hardpoint_index].runtime.recoil = _enemy.enemy.visual.radius * 0.14;
    return _delivery;
}

/// @description Starts the selected enemy attack after any telegraph finishes.
function sc_enemy_attack_activate(_enemy, _attack)
{
    var _runtime = _enemy.enemy.attack_controller.runtime;
    var _weapon = variable_struct_get(global.data.weapons, _attack.weapon_key);

    _runtime.phase = EnemyAttackPhase.ACTIVE;
    _runtime.next_fire_tick = GAME_TICK;

    if (_weapon.delivery.type != AttackDelivery.BEAM) return true;

    _runtime.attack_end_tick = GAME_TICK + max(1, round(_attack.firing.duration));

    if (!sc_enemy_beam_attack_start(_enemy, _attack))
    {
        sc_enemy_attack_finish(_enemy, _attack.firing.cooldown / _enemy.enemy.stats.final.fire_rate_multiplier);
        return false;
    }

    return true;
}

/// @description Updates faction-coloured particles during an enemy attack telegraph.
function sc_enemy_attack_telegraph_update(_enemy, _attack)
{
    var _runtime = _enemy.enemy.attack_controller.runtime;
    var _telegraph = _attack.telegraph;

    if (GAME_TICK >= _runtime.telegraph_end_tick)
    {
        sc_enemy_attack_activate(_enemy, _attack);
        return;
    }

    if (GAME_TICK < _runtime.next_telegraph_particle_tick) return;

    _runtime.next_telegraph_particle_tick = GAME_TICK + max(1, round(_telegraph.particle_interval));

    var _progress = clamp(
        (GAME_TICK - _runtime.telegraph_start_tick)
        / max(1, _runtime.telegraph_end_tick - _runtime.telegraph_start_tick),
        0, 1
    );

    for (var _i = 0; _i < array_length(_attack.hardpoint_indices); _i++)
    {
        var _transform = { x: 0, y: 0, direction: 0 };
        sc_enemy_hardpoint_attack_transform(_enemy, _attack, _attack.hardpoint_indices[_i], _transform);
        _telegraph.particle_script(_enemy, _attack, _transform, _progress, _enemy.enemy.visual.palette, _telegraph);
    }
}

/// @description Draws faction-coloured attack telegraphs at the enemy's visual position.
function sc_enemy_attack_telegraph_draw(_enemy, _draw_x, _draw_y)
{
    var _data = _enemy.enemy;
    var _controller = _data.attack_controller;
    var _runtime = _controller.runtime;

    if (_runtime.phase != EnemyAttackPhase.TELEGRAPH || _runtime.current_attack < 0) return;

    var _attack = _controller.attacks[_runtime.current_attack];
    var _telegraph = _attack.telegraph;
    var _offset_x = _draw_x - _enemy.x;
    var _offset_y = _draw_y - _enemy.y;
    var _progress = clamp(
        (GAME_TICK - _runtime.telegraph_start_tick)
        / max(1, _runtime.telegraph_end_tick - _runtime.telegraph_start_tick),
        0, 1
    );

    for (var _i = 0; _i < array_length(_attack.hardpoint_indices); _i++)
    {
        var _transform = { x: 0, y: 0, direction: 0 };
        sc_enemy_hardpoint_attack_transform(_enemy, _attack, _attack.hardpoint_indices[_i], _transform);

        _transform.x += _offset_x;
        _transform.y += _offset_y;

        _telegraph.draw_script(_enemy, _attack, _transform, _progress, _data.visual.palette, _telegraph);
    }
}

/// @description Draws the reusable glowing energy-ball attack telegraph.
function sc_attack_telegraph_energy_draw(_enemy, _attack, _transform, _progress, _palette, _config)
{
    var _base_radius = _enemy.enemy.visual.radius * _config.scale;
    var _pulse = 1 + sin(GAME_TICK * lerp(0.18, 0.55, _progress)) * lerp(0.08, 0.18, _progress);
    var _radius = lerp(_base_radius * 0.18, _base_radius, _progress) * _pulse;
    var _orbit_radius = lerp(_base_radius * 1.5, _base_radius * 0.58, _progress);
    var _alpha = lerp(0.35, 1, _progress);
    var _rotation = GAME_TICK * lerp(3, 9, _progress);

    gpu_set_blendmode(bm_add);

    draw_set_colour(_palette.glow);
    draw_set_alpha(_alpha * 0.16);
    draw_circle(_transform.x, _transform.y, _radius * 2.6, false);

    draw_set_colour(_palette.accent);
    draw_set_alpha(_alpha * 0.3);
    draw_circle(_transform.x, _transform.y, _radius * 1.65, false);

    draw_set_colour(_palette.energy);
    draw_set_alpha(_alpha * 0.82);
    draw_circle(_transform.x, _transform.y, _radius, false);

    draw_set_colour(_palette.core);
    draw_set_alpha(_alpha);
    draw_circle(_transform.x, _transform.y, max(1.5, _radius * 0.32), false);

    for (var _i = 0; _i < 4; _i++)
    {
        var _angle = _rotation + _i * 90;
        var _spark_x = _transform.x + lengthdir_x(_orbit_radius, _angle);
        var _spark_y = _transform.y + lengthdir_y(_orbit_radius, _angle);

        draw_set_colour(_palette.energy);
        draw_set_alpha(_alpha * 0.75);
        draw_line_width(
            _spark_x,
            _spark_y,
            _transform.x + lengthdir_x(_radius, _angle),
            _transform.y + lengthdir_y(_radius, _angle),
            max(1, _base_radius * 0.08)
        );
    }

    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
    draw_set_colour(c_white);

    // Future: sc_attack_telegraph_cannon_charge_draw for sequential launcher lights.
}

/// @description Creates every beam delivery required by the selected enemy beam attack.
function sc_enemy_beam_attack_start(_enemy, _attack)
{
    var _runtime = _enemy.enemy.attack_controller.runtime;
    var _indices = _attack.hardpoint_indices;

    switch (_attack.firing.order)
    {
        case HardpointFireOrder.ALL:
            for (var _i = 0; _i < array_length(_indices); _i++)
            {
                var _beam = sc_enemy_attack_fire_hardpoint(_enemy, _attack, _indices[_i]);

                if (instance_exists(_beam))
                    array_push(_runtime.active_deliveries, {
                        hardpoint_index: _indices[_i],
                        delivery_id: _beam,
                        x: 0, y: 0, direction: 0
                    });
            }
        break;

        case HardpointFireOrder.SEQUENTIAL:
            var _index = _indices[_runtime.hardpoint_cursor];
            var _beam = sc_enemy_attack_fire_hardpoint(_enemy, _attack, _index);
            _runtime.hardpoint_cursor = (_runtime.hardpoint_cursor + 1) mod array_length(_indices);

            if (instance_exists(_beam))
                array_push(_runtime.active_deliveries, {
                    hardpoint_index: _index,
                    delivery_id: _beam,
                    x: 0, y: 0, direction: 0
                });
        break;

        case HardpointFireOrder.RANDOM:
            var _index = _indices[irandom(array_length(_indices) - 1)];
            var _beam = sc_enemy_attack_fire_hardpoint(_enemy, _attack, _index);

            if (instance_exists(_beam))
                array_push(_runtime.active_deliveries, {
                    hardpoint_index: _index,
                    delivery_id: _beam,
                    x: 0, y: 0, direction: 0
                });
        break;
    }

    return array_length(_runtime.active_deliveries) > 0;
}

/// @description Keeps all active enemy beams attached to their moving hardpoints.
function sc_enemy_beam_attack_sustain(_enemy, _attack)
{
    var _runtime = _enemy.enemy.attack_controller.runtime;

    for (var _i = array_length(_runtime.active_deliveries) - 1; _i >= 0; _i--)
    {
        var _active = _runtime.active_deliveries[_i];

        if (!instance_exists(_active.delivery_id))
        {
            array_delete(_runtime.active_deliveries, _i, 1);
            continue;
        }

        sc_enemy_hardpoint_attack_transform(_enemy, _attack, _active.hardpoint_index, _active);
        sc_beam_sustain(_active.delivery_id, _active.x, _active.y, _active.direction);
    }

    return array_length(_runtime.active_deliveries) > 0;
}

/// @description Updates telegraphs, gated projectile volleys and sustained beam attacks.
function sc_enemy_attack_update(_enemy)
{
    var _data = _enemy.enemy;
    var _controller = _data.attack_controller;
    var _runtime = _controller.runtime;
    var _fire_rate = _data.stats.final.fire_rate_multiplier;

    if (_runtime.phase == EnemyAttackPhase.COOLDOWN)
    {
        if (GAME_TICK < _runtime.cooldown_until) return;
        _runtime.phase = EnemyAttackPhase.IDLE;
    }

    if (_runtime.phase == EnemyAttackPhase.IDLE)
    {
        var _selected = sc_enemy_attack_select(_enemy);

        if (_selected < 0)
        {
            _runtime.phase = EnemyAttackPhase.COOLDOWN;
            _runtime.cooldown_until = GAME_TICK + 15;
            return;
        }

        _runtime.current_attack = _selected;
        _runtime.hardpoint_cursor = 0;
        _runtime.volley_count = 0;
        _runtime.active_deliveries = [];

        var _attack = _controller.attacks[_selected];

        if (variable_struct_exists(_attack, "telegraph"))
        {
            _runtime.phase = EnemyAttackPhase.TELEGRAPH;
            _runtime.telegraph_start_tick = GAME_TICK;
            _runtime.telegraph_end_tick = GAME_TICK + max(1, round(_attack.telegraph.duration));
            _runtime.next_telegraph_particle_tick = GAME_TICK;
            return;
        }

        sc_enemy_attack_activate(_enemy, _attack);
        return;
    }

    var _attack = _controller.attacks[_runtime.current_attack];

    if (_runtime.phase == EnemyAttackPhase.TELEGRAPH)
    {
        sc_enemy_attack_telegraph_update(_enemy, _attack);
        return;
    }

    var _weapon = variable_struct_get(global.data.weapons, _attack.weapon_key);

    if (_weapon.delivery.type == AttackDelivery.BEAM)
    {
        if (GAME_TICK >= _runtime.attack_end_tick || !sc_enemy_beam_attack_sustain(_enemy, _attack))
            sc_enemy_attack_finish(_enemy, _attack.firing.cooldown / _fire_rate);

        return;
    }

    if (GAME_TICK < _runtime.next_fire_tick) return;

    var _indices = _attack.hardpoint_indices;

    switch (_attack.firing.order)
    {
        case HardpointFireOrder.ALL:
            for (var _i = 0; _i < array_length(_indices); _i++)
                sc_enemy_attack_fire_hardpoint(_enemy, _attack, _indices[_i]);
        break;

        case HardpointFireOrder.SEQUENTIAL:
            var _index = _indices[_runtime.hardpoint_cursor];
            sc_enemy_attack_fire_hardpoint(_enemy, _attack, _index);
            _runtime.hardpoint_cursor = (_runtime.hardpoint_cursor + 1) mod array_length(_indices);
        break;

        case HardpointFireOrder.RANDOM:
            var _index = _indices[irandom(array_length(_indices) - 1)];
            sc_enemy_attack_fire_hardpoint(_enemy, _attack, _index);
        break;
    }

    _runtime.volley_count++;

    if (_runtime.volley_count >= _attack.firing.volley_max)
        sc_enemy_attack_finish(_enemy, _attack.firing.cooldown / _fire_rate);
    else
        _runtime.next_fire_tick = GAME_TICK + max(1, round(_attack.firing.interval / _fire_rate));
}

/// @description Draws the complete enemy assembly with shared slow visual floating motion.
function sc_enemy_draw(_enemy)
{
    var _data = _enemy.enemy;
    var _visual = _data.visual;
    var _runtime = _visual.runtime;
    var _defence = _data.defence;
    var _angle = _enemy.draw_angle;
    var _motion = global.config.visual.ship_motion;
    var _phase = _runtime.motion_phase;
    var _strength = _visual.motion_strength;
    var _bob_side = sin(GAME_TICK * _motion.side_speed + _phase) * _motion.side_amount * _strength;
    var _bob_forward = sin(GAME_TICK * _motion.forward_speed + 1.7 + _phase * 0.73) * _motion.forward_amount * _strength;

    var _draw_x = _enemy.x
        + lengthdir_x(_bob_forward, _angle)
        + lengthdir_x(_bob_side, _angle + 90);

    var _draw_y = _enemy.y
        + lengthdir_y(_bob_forward, _angle)
        + lengthdir_y(_bob_side, _angle + 90);

    for (var _i = 0; _i < array_length(_data.thrusters); _i++)
    {
        var _thruster = _data.thrusters[_i];
        var _power = _thruster.runtime.power;
        if (_power <= 0.01) continue;

        var _forward = _thruster.forward * _visual.radius;
        var _side = _thruster.side * _visual.radius;
        var _thruster_x = _draw_x + lengthdir_x(_forward, _angle) + lengthdir_x(_side, _angle + 90);
        var _thruster_y = _draw_y + lengthdir_y(_forward, _angle) + lengthdir_y(_side, _angle + 90);
        var _thruster_angle = _angle + _thruster.angle;
        var _flicker = 0.94 + sin(GAME_TICK * 0.35 + _thruster.runtime.phase) * 0.06;
        var _length_scale = _thruster.scale * (0.25 + _power * 0.75) * _flicker;
        var _width_scale = _thruster.scale * (0.82 + _power * 0.18);

        if (sprite_exists(_runtime.thrust_sprite))
            draw_sprite_ext(_runtime.thrust_sprite, 0, _thruster_x, _thruster_y, _length_scale, _width_scale, _thruster_angle, c_white, _power);
        else
            _visual.thrust.draw_script(_thruster_x, _thruster_y, _visual.radius * _thruster.scale, _thruster_angle, _visual, _power);
    }

    if (sprite_exists(_runtime.body_sprite))
        draw_sprite_ext(_runtime.body_sprite, 0, _draw_x, _draw_y, 1, 1, _angle, c_white, 1);
    else
        _visual.draw.body(_draw_x, _draw_y, _visual.radius, _angle, _visual);

    var _core_x = _draw_x
        + lengthdir_x(_visual.core.forward * _visual.radius, _angle)
        + lengthdir_x(_visual.core.side * _visual.radius, _angle + 90);

    var _core_y = _draw_y
        + lengthdir_y(_visual.core.forward * _visual.radius, _angle)
        + lengthdir_y(_visual.core.side * _visual.radius, _angle + 90);

    var _core_angle = _angle + _runtime.core_angle;

    if (sprite_exists(_runtime.core_sprite))
        draw_sprite_ext(_runtime.core_sprite, 0, _core_x, _core_y, 1, 1, _core_angle, c_white, _runtime.core_alpha);
    else
        _visual.draw.core(_core_x, _core_y, _visual.radius, _core_angle, _visual, _runtime.core_alpha);

    for (var _i = 0; _i < array_length(_data.hardpoints); _i++)
    {
        var _hardpoint = _data.hardpoints[_i];
        var _forward = _hardpoint.forward * _visual.radius;
        var _side = _hardpoint.side * _visual.radius;
        var _hardpoint_angle = _hardpoint.runtime.aim_angle;
        var _recoil = _hardpoint.runtime.recoil;

        var _hardpoint_x = _draw_x
            + lengthdir_x(_forward, _angle)
            + lengthdir_x(_side, _angle + 90)
            - lengthdir_x(_recoil, _hardpoint_angle);

        var _hardpoint_y = _draw_y
            + lengthdir_y(_forward, _angle)
            + lengthdir_y(_side, _angle + 90)
            - lengthdir_y(_recoil, _hardpoint_angle);

        if (sprite_exists(_hardpoint.runtime.sprite))
            draw_sprite_ext(_hardpoint.runtime.sprite, 0, _hardpoint_x, _hardpoint_y, 1, 1, _hardpoint_angle, c_white, 1);
        else
            _hardpoint.draw_script(_hardpoint_x, _hardpoint_y, _visual.radius, _hardpoint_angle, _visual, 1);
    }

    sc_enemy_attack_telegraph_draw(_enemy, _draw_x, _draw_y);

    if (_defence.shield.current > 0 && sprite_exists(_runtime.shield_sprite))
    {
        var _shield_ratio = _defence.shield.current / _defence.shield.maximum;

        sc_visual_shield_sprite_draw(
            _runtime.shield_sprite,
            _draw_x,
            _draw_y,
            _angle,
            _visual.palette,
            _shield_ratio,
            _runtime.shield_hit_alpha,
            1
        );
    }
}

/// @description Applies one damage packet to an enemy's layered defence.
function sc_enemy_damage(_enemy, _packet)
{
    var _data = _enemy.enemy;
    if (_data.state == EnemyState.DEAD) return false;

    var _defence = _data.defence;
    var _result = sc_damage_resolve(_packet, _defence.shield.current, _defence.armour.current, _defence.hull.current);

    _defence.shield.current = _result.shield;
    _defence.armour.current = _result.armour;
    _defence.hull.current = _result.hull;

    if (_result.dealt.total <= 0) return false;

    sc_health_bar_damage_show(_enemy.health_bar);

    if (_result.dealt.shield > 0)
        _data.visual.runtime.shield_hit_alpha = 1;

    if (_defence.hull.current <= 0)
    {
        _defence.hull.current = 0;
        _data.state = EnemyState.DEAD;
        sc_enemy_die(_enemy, _packet);
    }
    else if (_result.effect.type == DamageEffect.STAGGER && sc_damage_effect_triggered(_result.effect))
        sc_enemy_stagger_begin(_enemy, _result.effect);

    return _result;
}



/// @description Processes one enemy death and its final killing source.
function sc_enemy_die(_enemy, _packet)
{
    var _data = _enemy.enemy;
    var _source = _packet.source;

    sc_enemy_attack_cancel(_enemy);
    _data.target_id = noone;

    _data.visual.death.script(_enemy);

    if (_source.faction == Faction.PLAYER)
    {
        // Increment player kill count and combat statistics here later.
        // Award player-specific experience or bounty credit here later.
    }
    else
    {
        // Handle allied, environmental or faction kill credit here later.
    }

    // Roll registered enemy drops here later.
    // Create floating kill or reward feedback here later.
    // Process registered on-death abilities here later.
    // Insert registered enemy death audio here later.

    instance_destroy(_enemy);
    return true;
}