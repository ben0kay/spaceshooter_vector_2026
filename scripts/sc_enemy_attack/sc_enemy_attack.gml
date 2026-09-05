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

/// @description Returns whether an attack requires an unobstructed target view.
function sc_enemy_attack_line_of_sight_required(_attack)
{
    return variable_struct_exists(_attack, "conditions")
        && variable_struct_exists(_attack.conditions, "line_of_sight")
        && _attack.conditions.line_of_sight;
}

/// @description Returns the current combat target without replacing the strategic player target.
function sc_enemy_attack_target_get(_enemy)
{
    if (sc_enemy_asteroid_destroy_active(_enemy))
        return _enemy.enemy.movement.obstacle.target_id;

    return _enemy.enemy.target_id;
}

/// @description Checks a broad three-line corridor to one supplied target.
function sc_enemy_attack_line_of_sight_clear_to(_enemy, _target)
{
    if (!instance_exists(_target)) return false;
    if (global.level.asteroids_alive <= 0) return true;

    var _target_collision = _target.entity.collision;
    var _width = min(
        _target_collision.radius_forward,
        _target_collision.radius_side
    ) * global.config.enemy.asteroid.line_of_sight_width_scale;

    var _direction = point_direction(
        _enemy.x,
        _enemy.y,
        _target.x,
        _target.y
    );

    for (var _side = -1; _side <= 1; _side++)
    {
        var _offset = _width * _side;
        var _start_x = _enemy.x + lengthdir_x(_offset, _direction + 90);
        var _start_y = _enemy.y + lengthdir_y(_offset, _direction + 90);
        var _end_x = _target.x + lengthdir_x(_offset, _direction + 90);
        var _end_y = _target.y + lengthdir_y(_offset, _direction + 90);

        if (collision_line(
            _start_x, _start_y,
            _end_x, _end_y,
            o_asteroid, false, true
        ) != noone)
            return false;

        if (collision_line(
            _start_x, _start_y,
            _end_x, _end_y,
            o_solid, false, true
        ) != noone)
            return false;
    }

    return true;
}

/// @description Checks line of sight to the enemy's current attack target.
function sc_enemy_attack_line_of_sight_clear(_enemy)
{
    var _target = sc_enemy_attack_target_get(_enemy);
    if (!instance_exists(_target)) return false;

    // The blocking asteroid is itself the intended target.
    if (sc_enemy_asteroid_destroy_active(_enemy))
        return true;

    return sc_enemy_attack_line_of_sight_clear_to(
        _enemy,
        _target
    );
}

/// @description Returns whether one attack is a committed telegraphed beam.
function sc_enemy_attack_is_committed_beam(_attack)
{
    if (!variable_struct_exists(_attack, "telegraph")) return false;

    var _weapon = variable_struct_get(global.data.weapons, _attack.weapon_key);
    return _weapon.delivery.type == AttackDelivery.BEAM;
}

/// @description Returns whether one hardpoint is aimed close enough to its current attack target.
function sc_enemy_attack_hardpoint_aligned(_enemy, _attack, _hardpoint_index)
{
    var _target = sc_enemy_attack_target_get(_enemy);
    if (!instance_exists(_target)) return false;

    var _transform = { x: 0, y: 0, direction: 0 };
    sc_enemy_hardpoint_attack_transform(
        _enemy,
        _attack,
        _hardpoint_index,
        _transform
    );

    var _target_direction = point_direction(
        _transform.x,
        _transform.y,
        _target.x,
        _target.y
    );

    return abs(angle_difference(
        _target_direction,
        _transform.direction
    )) <= _attack.aim.fire_tolerance;
}

/// @description Returns whether enough participating hardpoints are aligned to begin an attack.
function sc_enemy_attack_alignment_ready(_enemy, _attack)
{
    var _indices = _attack.hardpoint_indices;
    if (array_length(_indices) <= 0) return false;

    switch (_attack.firing.order)
    {
        case HardpointFireOrder.ALL:
            for (var _i = 0; _i < array_length(_indices); _i++)
            {
                if (!sc_enemy_attack_hardpoint_aligned(_enemy, _attack, _indices[_i]))
                    return false;
            }

            return true;

        case HardpointFireOrder.SEQUENTIAL:
            return sc_enemy_attack_hardpoint_aligned(
                _enemy,
                _attack,
                _indices[0]
            );

        case HardpointFireOrder.RANDOM:
            for (var _i = 0; _i < array_length(_indices); _i++)
            {
                if (sc_enemy_attack_hardpoint_aligned(_enemy, _attack, _indices[_i]))
                    return true;
            }

            return false;
    }

    return false;
}

/// @description Returns whether an attack currently satisfies all firing conditions.
function sc_enemy_attack_can_use(_enemy, _attack)
{
    var _data = _enemy.enemy;
    var _defence = _data.defence;
    var _target = sc_enemy_attack_target_get(_enemy);
    var _destroying_asteroid = sc_enemy_asteroid_destroy_active(_enemy);

    if (!instance_exists(_target)) return false;

    var _dx = _target.x - _enemy.x;
    var _dy = _target.y - _enemy.y;
    var _distance_sq = _dx * _dx + _dy * _dy;

    if (variable_struct_exists(_attack, "conditions"))
    {
        var _conditions = _attack.conditions;

        // Obstacle destruction ignores normal player-combat range restrictions.
        if (!_destroying_asteroid)
        {
            if (variable_struct_exists(_conditions, "range_min")
            && _distance_sq < sqr(_conditions.range_min))
                return false;

            if (variable_struct_exists(_conditions, "range_max")
            && _distance_sq > sqr(_conditions.range_max))
                return false;

            if (sc_enemy_attack_line_of_sight_required(_attack)
            && !sc_enemy_attack_line_of_sight_clear(_enemy))
                return false;
        }

        var _shield_ratio = _defence.shield.maximum > 0
            ? _defence.shield.current / _defence.shield.maximum
            : 0;

        var _armour_ratio = _defence.armour.maximum > 0
            ? _defence.armour.current / _defence.armour.maximum
            : 0;

        var _hull_ratio = _defence.hull.maximum > 0
            ? _defence.hull.current / _defence.hull.maximum
            : 0;

        if (variable_struct_exists(_conditions, "shield_ratio_min") && _shield_ratio < _conditions.shield_ratio_min) return false;
        if (variable_struct_exists(_conditions, "shield_ratio_max") && _shield_ratio > _conditions.shield_ratio_max) return false;
        if (variable_struct_exists(_conditions, "armour_ratio_min") && _armour_ratio < _conditions.armour_ratio_min) return false;
        if (variable_struct_exists(_conditions, "armour_ratio_max") && _armour_ratio > _conditions.armour_ratio_max) return false;
        if (variable_struct_exists(_conditions, "hull_ratio_min") && _hull_ratio < _conditions.hull_ratio_min) return false;
        if (variable_struct_exists(_conditions, "hull_ratio_max") && _hull_ratio > _conditions.hull_ratio_max) return false;
    }

    return sc_enemy_attack_alignment_ready(_enemy, _attack);
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
    var _target = sc_enemy_attack_target_get(_enemy);
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

    _transform.x = _mount_x
        + lengthdir_x(_hardpoint.muzzle_forward * _radius, _mount_angle);

    _transform.y = _mount_y
        + lengthdir_y(_hardpoint.muzzle_forward * _radius, _mount_angle);

    _transform.direction = _mount_angle;

    if (_hardpoint.rotation.mode == HardpointRotation.FIXED)
    {
        switch (_attack.aim.mode)
        {
            case AimMode.TARGET:
                if (instance_exists(_target))
                    _transform.direction = point_direction(
                        _transform.x,
                        _transform.y,
                        _target.x,
                        _target.y
                    );
            break;

            case AimMode.TARGET_LEAD:
                // Target-leading solution goes here later.
                if (instance_exists(_target))
                    _transform.direction = point_direction(
                        _transform.x,
                        _transform.y,
                        _target.x,
                        _target.y
                    );
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

/// @description Fires one aligned hardpoint when its target corridor remains clear.
function sc_enemy_attack_fire_hardpoint(_enemy, _attack, _hardpoint_index)
{
    var _committed_beam = sc_enemy_attack_is_committed_beam(_attack);

    // A beam that has already begun telegraphing must finish.
    // Ordinary attacks still recheck aim and line of sight per shot.
    if (!_committed_beam)
    {
        if (!sc_enemy_attack_hardpoint_aligned(_enemy, _attack, _hardpoint_index))
            return noone;

        if (sc_enemy_attack_line_of_sight_required(_attack)
        && !sc_enemy_attack_line_of_sight_clear(_enemy))
            return noone;
    }

    var _transform = { x: 0, y: 0, direction: 0 };
    sc_enemy_hardpoint_attack_transform(_enemy, _attack, _hardpoint_index, _transform);

    var _direction = _transform.direction
        + random_range(-_attack.aim.inaccuracy, _attack.aim.inaccuracy);

    var _delivery = sc_weapon_fire(
        _enemy,
        _attack.weapon_key,
        _attack.shot,
        _transform.x,
        _transform.y,
        _direction,
        _enemy.enemy.stats.final.damage_multiplier
    );

    if (instance_exists(_delivery))
    {
        _enemy.enemy.hardpoints[_hardpoint_index].runtime.recoil =
            _enemy.enemy.visual.radius * 0.14;
    }

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