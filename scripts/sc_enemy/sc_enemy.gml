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
        movement: { velocity_x: 0, velocity_y: 0 },

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
        core_alpha: 1
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

/// @description Updates detection, combat and forget transitions using final stats.
function sc_enemy_perception_update(_enemy)
{
    var _data = _enemy.enemy;
    var _stats = _data.stats.final;

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

            if (_data.target_distance_sq <= _stats.detection_range_sq)
            {
                _data.target_id = global.player_id;
                _data.state = EnemyState.CHASING;
            }
        break;

        case EnemyState.CHASING:
            if (_data.target_distance_sq > _stats.forget_range_sq)
            {
                sc_enemy_attack_cancel(_enemy);
                _data.target_id = noone;
                _data.state = EnemyState.IDLE;
            }
            else if (_data.target_distance_sq <= _stats.combat_range_sq)
                _data.state = EnemyState.ATTACKING;
        break;

        case EnemyState.ATTACKING:
            if (_data.target_distance_sq > _stats.forget_range_sq)
            {
                sc_enemy_attack_cancel(_enemy);
                _data.target_id = noone;
                _data.state = EnemyState.IDLE;
            }
            else if (_data.target_distance_sq > _stats.combat_range_sq)
            {
                sc_enemy_attack_cancel(_enemy);
                _data.state = EnemyState.CHASING;
            }
        break;
    }
}

/// @description Updates shared visual animation, hardpoint tracking, recoil and registered thrusters.
function sc_enemy_visual_update(_enemy)
{
    var _data = _enemy.enemy;
    var _visual = _data.visual;
    var _movement = _data.movement;
    var _speed_max = _data.stats.final.speed_max;
    var _has_target = instance_exists(_data.target_id);

    _visual.runtime.core_angle = (_visual.runtime.core_angle + 1.5) mod 360;
    _visual.runtime.core_alpha = 0.78 + sin(GAME_TICK * 0.09) * 0.22;
    _visual.runtime.shield_hit_alpha = max(0, _visual.runtime.shield_hit_alpha - 0.06);

    for (var _i = 0; _i < array_length(_data.hardpoints); _i++)
    {
        var _hardpoint = _data.hardpoints[_i];
        var _rotation = _hardpoint.rotation;
        var _runtime = _hardpoint.runtime;
        var _base_angle = _enemy.draw_angle + _hardpoint.angle;
        var _desired_angle = _runtime.aim_angle;

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

        if (_runtime.recoil > 0.01)
            _runtime.recoil = lerp(_runtime.recoil, 0, 0.22);
        else
            _runtime.recoil = 0;
    }

    var _speed = point_distance(0, 0, _movement.velocity_x, _movement.velocity_y);
    var _target_power = _speed_max > 0 ? clamp(_speed / _speed_max, 0, 1) : 0;

    for (var _i = 0; _i < array_length(_data.thrusters); _i++)
    {
        var _thruster = _data.thrusters[_i];
        var _runtime = _thruster.runtime;
        var _active = _target_power > 0.05;
        var _forward = _thruster.forward * _visual.radius;
        var _side = _thruster.side * _visual.radius;
        var _thruster_x = _enemy.x + lengthdir_x(_forward, _enemy.draw_angle) + lengthdir_x(_side, _enemy.draw_angle + 90);
        var _thruster_y = _enemy.y + lengthdir_y(_forward, _enemy.draw_angle) + lengthdir_y(_side, _enemy.draw_angle + 90);
        var _thruster_angle = _enemy.draw_angle + _thruster.angle;

        if (_active && !_runtime.active)
            _visual.thrust.ignition_script(_thruster_x, _thruster_y, _thruster_angle, _thruster.scale);

        _runtime.active = _active;
        _runtime.power = lerp(_runtime.power, _target_power, _target_power > _runtime.power ? 0.22 : 0.12);

        if (_runtime.power > 0.15 && ((GAME_TICK + _runtime.phase) mod 3) == 0)
            _visual.thrust.particle_script(_thruster_x, _thruster_y, _thruster_angle, _runtime.power, _thruster.scale);
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

    _movement.velocity_x *= _data.stats.final.friction;
    _movement.velocity_y *= _data.stats.final.friction;

    _enemy.x += _movement.velocity_x;
    _enemy.y += _movement.velocity_y;

    _stagger.remaining--;

    if (_stagger.remaining <= 0)
    {
        _stagger.remaining = 0;
        _data.state = _stagger.return_state;
    }
}

/// @description Applies passive idle movement decay.
function sc_enemy_update_idle(_enemy)
{
    var _data = _enemy.enemy;
    var _movement = _data.movement;
    var _friction = _data.stats.final.friction;

    _movement.velocity_x *= _friction;
    _movement.velocity_y *= _friction;

    if (abs(_movement.velocity_x) < 0.001) _movement.velocity_x = 0;
    if (abs(_movement.velocity_y) < 0.001) _movement.velocity_y = 0;

    _enemy.x += _movement.velocity_x;
    _enemy.y += _movement.velocity_y;
}

/// @description Moves the enemy toward its target using final stats.
function sc_enemy_update_chasing(_enemy)
{
    var _data = _enemy.enemy;
    var _stats = _data.stats.final;
    var _movement = _data.movement;
    var _target = _data.target_id;
    var _direction = point_direction(_enemy.x, _enemy.y, _target.x, _target.y);
    var _target_vx = lengthdir_x(_stats.speed_max, _direction);
    var _target_vy = lengthdir_y(_stats.speed_max, _direction);

    _movement.velocity_x += clamp(_target_vx - _movement.velocity_x, -_stats.acceleration, _stats.acceleration);
    _movement.velocity_y += clamp(_target_vy - _movement.velocity_y, -_stats.acceleration, _stats.acceleration);

    _enemy.x += _movement.velocity_x;
    _enemy.y += _movement.velocity_y;

    var _turn = angle_difference(_direction, _enemy.draw_angle);
    _enemy.draw_angle += clamp(_turn, -_stats.turn_speed, _stats.turn_speed);
    _enemy.draw_angle = _enemy.draw_angle mod 360;
}

/// @description Holds combat range, faces the player and attacks.
function sc_enemy_update_attacking(_enemy)
{
    var _data = _enemy.enemy;
    var _stats = _data.stats.final;
    var _movement = _data.movement;
    var _target = _data.target_id;
    var _direction = point_direction(_enemy.x, _enemy.y, _target.x, _target.y);

    _movement.velocity_x *= _stats.friction;
    _movement.velocity_y *= _stats.friction;

    _enemy.x += _movement.velocity_x;
    _enemy.y += _movement.velocity_y;

    if (!sc_enemy_attack_aim_locked(_enemy))
    {
        var _turn = angle_difference(_direction, _enemy.draw_angle);
        _enemy.draw_angle += clamp(_turn, -_stats.turn_speed, _stats.turn_speed);
        _enemy.draw_angle = _enemy.draw_angle mod 360;
    }

    sc_enemy_attack_update(_enemy);
}

/// @description Returns whether the current telegraph has entered its final aim-lock period.
function sc_enemy_attack_aim_locked(_enemy)
{
    var _controller = _enemy.enemy.attack_controller;
    var _runtime = _controller.runtime;

    if (_runtime.phase != EnemyAttackPhase.TELEGRAPH || _runtime.current_attack < 0) return false;

    var _attack = _controller.attacks[_runtime.current_attack];
    if (!variable_struct_exists(_attack.telegraph, "aim_lock_remaining")) return false;

    return GAME_TICK >= _runtime.telegraph_end_tick - _attack.telegraph.aim_lock_remaining;
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

/// @description Chooses an attack using the configured selection method.
function sc_enemy_attack_select(_enemy)
{
    var _controller = _enemy.enemy.attack_controller;
    var _runtime = _controller.runtime;
    var _count = array_length(_controller.attacks);

    switch (_controller.selection)
    {
        case AttackSelection.SEQUENTIAL:
            var _selected = _runtime.next_attack_index;
            _runtime.next_attack_index = (_runtime.next_attack_index + 1) mod _count;
            return _selected;

        case AttackSelection.RANDOM:
            return irandom(_count - 1);

        case AttackSelection.WEIGHTED:
            var _weight_total = 0;

            for (var _i = 0; _i < _count; _i++)
                _weight_total += _controller.attacks[_i].weight;

            var _roll = random(_weight_total);

            for (var _i = 0; _i < _count; _i++)
            {
                _roll -= _controller.attacks[_i].weight;
                if (_roll <= 0) return _i;
            }

            return _count - 1;
    }

    return 0;
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

/// @description Draws a generic faction-coloured energy charge at telegraphed hardpoints.
function sc_enemy_attack_telegraph_draw(_enemy)
{
    var _data = _enemy.enemy;
    var _controller = _data.attack_controller;
    var _runtime = _controller.runtime;

    if (_runtime.phase != EnemyAttackPhase.TELEGRAPH || _runtime.current_attack < 0) return;

    var _attack = _controller.attacks[_runtime.current_attack];
    var _telegraph = _attack.telegraph;
    var _progress = clamp(
        (GAME_TICK - _runtime.telegraph_start_tick)
        / max(1, _runtime.telegraph_end_tick - _runtime.telegraph_start_tick),
        0, 1
    );

    for (var _i = 0; _i < array_length(_attack.hardpoint_indices); _i++)
    {
        var _transform = { x: 0, y: 0, direction: 0 };
        sc_enemy_hardpoint_attack_transform(_enemy, _attack, _attack.hardpoint_indices[_i], _transform);
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

/// @description Updates telegraphs, projectile volleys and sustained beam attacks.
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
        _runtime.current_attack = sc_enemy_attack_select(_enemy);
        _runtime.hardpoint_cursor = 0;
        _runtime.volley_count = 0;
        _runtime.active_deliveries = [];

        var _attack = _controller.attacks[_runtime.current_attack];

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

/// @description Draws one enemy using shared baked components with its shield above the ship.
function sc_enemy_draw(_enemy)
{
    var _data = _enemy.enemy;
    var _visual = _data.visual;
    var _runtime = _visual.runtime;
    var _defence = _data.defence;

    for (var _i = 0; _i < array_length(_data.thrusters); _i++)
    {
        var _thruster = _data.thrusters[_i];
        var _power = _thruster.runtime.power;
        if (_power <= 0.01) continue;

        var _forward = _thruster.forward * _visual.radius;
        var _side = _thruster.side * _visual.radius;
        var _thruster_x = _enemy.x + lengthdir_x(_forward, _enemy.draw_angle) + lengthdir_x(_side, _enemy.draw_angle + 90);
        var _thruster_y = _enemy.y + lengthdir_y(_forward, _enemy.draw_angle) + lengthdir_y(_side, _enemy.draw_angle + 90);
        var _thruster_angle = _enemy.draw_angle + _thruster.angle;
        var _flicker = 0.94 + sin(GAME_TICK * 0.35 + _thruster.runtime.phase) * 0.06;
        var _length_scale = _thruster.scale * (0.25 + _power * 0.75) * _flicker;
        var _width_scale = _thruster.scale * (0.82 + _power * 0.18);

        if (sprite_exists(_runtime.thrust_sprite))
            draw_sprite_ext(_runtime.thrust_sprite, 0, _thruster_x, _thruster_y, _length_scale, _width_scale, _thruster_angle, c_white, _power);
        else
            _visual.thrust.draw_script(_thruster_x, _thruster_y, _visual.radius * _thruster.scale, _thruster_angle, _visual, _power);
    }

    if (sprite_exists(_runtime.body_sprite))
        draw_sprite_ext(_runtime.body_sprite, 0, _enemy.x, _enemy.y, 1, 1, _enemy.draw_angle, c_white, 1);
    else
        _visual.draw.body(_enemy.x, _enemy.y, _visual.radius, _enemy.draw_angle, _visual);

    // Position follows the ship angle; only the core sprite itself rotates.
    var _core_x = _enemy.x
        + lengthdir_x(_visual.core.forward * _visual.radius, _enemy.draw_angle)
        + lengthdir_x(_visual.core.side * _visual.radius, _enemy.draw_angle + 90);

    var _core_y = _enemy.y
        + lengthdir_y(_visual.core.forward * _visual.radius, _enemy.draw_angle)
        + lengthdir_y(_visual.core.side * _visual.radius, _enemy.draw_angle + 90);

    var _core_angle = _enemy.draw_angle + _runtime.core_angle;

    if (sprite_exists(_runtime.core_sprite))
        draw_sprite_ext(_runtime.core_sprite, 0, _core_x, _core_y, 1, 1, _core_angle, c_white, _runtime.core_alpha);
    else
        _visual.draw.core(_core_x, _core_y, _visual.radius, _core_angle, _visual, _runtime.core_alpha);

    for (var _i = 0; _i < array_length(_data.hardpoints); _i++)
    {
        var _hardpoint = _data.hardpoints[_i];
        var _forward = _hardpoint.forward * _visual.radius;
        var _side = _hardpoint.side * _visual.radius;
        var _angle = _hardpoint.runtime.aim_angle;
        var _recoil = _hardpoint.runtime.recoil;

        var _hardpoint_x = _enemy.x
            + lengthdir_x(_forward, _enemy.draw_angle)
            + lengthdir_x(_side, _enemy.draw_angle + 90)
            - lengthdir_x(_recoil, _angle);

        var _hardpoint_y = _enemy.y
            + lengthdir_y(_forward, _enemy.draw_angle)
            + lengthdir_y(_side, _enemy.draw_angle + 90)
            - lengthdir_y(_recoil, _angle);

        if (sprite_exists(_hardpoint.runtime.sprite))
            draw_sprite_ext(_hardpoint.runtime.sprite, 0, _hardpoint_x, _hardpoint_y, 1, 1, _angle, c_white, 1);
        else
            _hardpoint.draw_script(_hardpoint_x, _hardpoint_y, _visual.radius, _angle, _visual, 1);
    }
	
	sc_enemy_attack_telegraph_draw(_enemy);

    // Shield remains above all ship components.
    if (_defence.shield.current > 0 && sprite_exists(_runtime.shield_sprite))
    {
        var _shield_ratio = _defence.shield.current / _defence.shield.maximum;

        sc_visual_shield_sprite_draw(
            _runtime.shield_sprite,
            _enemy.x,
            _enemy.y,
            _enemy.draw_angle,
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