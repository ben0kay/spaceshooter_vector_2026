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
            radius: _radius * _data.collision.radius_scale,
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

    if (!sc_entity_init(_enemy, _runtime.identity.faction, sc_enemy_damage, _runtime.collision.radius))
        return false;

    _runtime.defence = {
        shield: {
            current: _final.shield_max,
            maximum: _final.shield_max
        },

        armour: {
            current: _final.armour_max,
            maximum: _final.armour_max
        },

        hull: {
            current: _final.hull_max,
            maximum: _final.hull_max
        }
    };

    _runtime.visual.runtime = {
        body_sprite: is_struct(_cache) ? _cache.body : -1,
        core_sprite: is_struct(_cache) ? _cache.core : -1,
        thrust_sprite: is_struct(_cache) ? _cache.thrust : -1,
        core_angle: 0,
        core_alpha: 1
    };

    for (var _i = 0; _i < array_length(_runtime.hardpoints); _i++)
    {
        var _sprite = is_struct(_cache) && _i < array_length(_cache.hardpoints) ? _cache.hardpoints[_i] : -1;
        _runtime.hardpoints[_i].runtime = { sprite: _sprite, recoil: 0 };
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
        active: false,
        current_attack: -1,
        next_attack_index: 0,
        hardpoint_cursor: 0,
        volley_count: 0,
        next_fire_tick: 0,
        cooldown_until: 0
    };

    _enemy.draw_angle = 0;
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

/// @description Updates shared visual animation, recoil and registered thrusters.
function sc_enemy_visual_update(_enemy)
{
    var _data = _enemy.enemy;
    var _visual = _data.visual;
    var _movement = _data.movement;
    var _speed_max = _data.stats.final.speed_max;

    _visual.runtime.core_angle = (_visual.runtime.core_angle + 1.5) mod 360;
    _visual.runtime.core_alpha = 0.78 + sin(GAME_TICK * 0.09) * 0.22;

    for (var _i = 0; _i < array_length(_data.hardpoints); _i++)
    {
        var _hardpoint = _data.hardpoints[_i];

        if (_hardpoint.runtime.recoil > 0.01)
            _hardpoint.runtime.recoil = lerp(_hardpoint.runtime.recoil, 0, 0.22);
        else
            _hardpoint.runtime.recoil = 0;
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

        var _thruster_x = _enemy.x
            + lengthdir_x(_forward, _enemy.draw_angle)
            + lengthdir_x(_side, _enemy.draw_angle + 90);

        var _thruster_y = _enemy.y
            + lengthdir_y(_forward, _enemy.draw_angle)
            + lengthdir_y(_side, _enemy.draw_angle + 90);

        var _thruster_angle = _enemy.draw_angle + _thruster.angle;

        if (_active && !_runtime.active)
            _visual.thrust.ignition_script(_thruster_x, _thruster_y, _thruster_angle, _thruster.scale);

        _runtime.active = _active;
        _runtime.power = lerp(_runtime.power, _target_power, _target_power > _runtime.power ? 0.22 : 0.12);

        if (_runtime.power > 0.15 && ((GAME_TICK + _runtime.phase) mod 3) == 0)
            _visual.thrust.particle_script(_thruster_x, _thruster_y, _thruster_angle, _runtime.power, _thruster.scale);
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

    var _turn = angle_difference(_direction, _enemy.draw_angle);
    _enemy.draw_angle += clamp(_turn, -_stats.turn_speed, _stats.turn_speed);
    _enemy.draw_angle = _enemy.draw_angle mod 360;

    sc_enemy_attack_update(_enemy);
}

/// @description Cancels the currently active attack volley.
function sc_enemy_attack_cancel(_enemy)
{
    var _runtime = _enemy.enemy.attack_controller.runtime;
    _runtime.active = false;
    _runtime.current_attack = -1;
    _runtime.hardpoint_cursor = 0;
    _runtime.volley_count = 0;
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

/// @description Updates attack timing using final enemy fire-rate stats.
function sc_enemy_attack_update(_enemy)
{
    var _data = _enemy.enemy;
    var _controller = _data.attack_controller;
    var _runtime = _controller.runtime;
    var _fire_rate = _data.stats.final.fire_rate_multiplier;

    if (!_runtime.active)
    {
        if (GAME_TICK < _runtime.cooldown_until) return;

        _runtime.current_attack = sc_enemy_attack_select(_enemy);
        _runtime.active = true;
        _runtime.hardpoint_cursor = 0;
        _runtime.volley_count = 0;
        _runtime.next_fire_tick = GAME_TICK;
    }

    if (GAME_TICK < _runtime.next_fire_tick) return;

    var _attack = _controller.attacks[_runtime.current_attack];
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
    {
        _runtime.active = false;
        _runtime.current_attack = -1;
        _runtime.cooldown_until = GAME_TICK + max(1, round(_attack.firing.cooldown / _fire_rate));
    }
    else
        _runtime.next_fire_tick = GAME_TICK + max(1, round(_attack.firing.interval / _fire_rate));
}

/// @description Resolves one hardpoint muzzle and fires its configured weapon.
function sc_enemy_attack_fire_hardpoint(_enemy, _attack, _hardpoint_index)
{
    var _data = _enemy.enemy;
    var _hardpoint = _data.hardpoints[_hardpoint_index];
    var _radius = _data.visual.radius;
    var _mount_angle = _enemy.draw_angle + _hardpoint.angle;
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

    var _muzzle_distance = _hardpoint.muzzle_forward * _radius;
    var _muzzle_x = _mount_x + lengthdir_x(_muzzle_distance, _mount_angle);
    var _muzzle_y = _mount_y + lengthdir_y(_muzzle_distance, _mount_angle);
    var _direction = _mount_angle;

    switch (_attack.aim.mode)
    {
        case AimMode.TARGET:
            _direction = point_direction(_muzzle_x, _muzzle_y, _data.target_id.x, _data.target_id.y);
        break;

        case AimMode.TARGET_LEAD:
            // Target-leading solution goes here later.
            _direction = point_direction(_muzzle_x, _muzzle_y, _data.target_id.x, _data.target_id.y);
        break;

        case AimMode.WORLD:
            _direction = _attack.aim.world_direction;
        break;
    }

    _direction += _attack.aim.angle_offset + random_range(-_attack.aim.inaccuracy, _attack.aim.inaccuracy);

    sc_weapon_fire(
        _enemy,
        _attack.weapon_key,
        _attack.shot,
        _muzzle_x,
        _muzzle_y,
        _direction,
        _data.stats.final.damage_multiplier
    );

    _hardpoint.runtime.recoil = _radius * 0.14;

    // Insert muzzle flash and weapon audio here.
}


/// @description Draws one enemy using shared baked components.
function sc_enemy_draw(_enemy)
{
    var _data = _enemy.enemy;
    var _visual = _data.visual;
    var _visual_runtime = _visual.runtime;

    for (var _i = 0; _i < array_length(_data.thrusters); _i++)
    {
        var _thruster = _data.thrusters[_i];
        var _power = _thruster.runtime.power;

        if (_power <= 0.01)
            continue;

        var _forward = _thruster.forward * _visual.radius;
        var _side = _thruster.side * _visual.radius;

        var _thruster_x = _enemy.x
            + lengthdir_x(_forward, _enemy.draw_angle)
            + lengthdir_x(_side, _enemy.draw_angle + 90);

        var _thruster_y = _enemy.y
            + lengthdir_y(_forward, _enemy.draw_angle)
            + lengthdir_y(_side, _enemy.draw_angle + 90);

        var _thruster_angle = _enemy.draw_angle + _thruster.angle;
        var _flicker = 0.94 + sin(GAME_TICK * 0.35 + _thruster.runtime.phase) * 0.06;
        var _length_scale = _thruster.scale * (0.25 + _power * 0.75) * _flicker;
        var _width_scale = _thruster.scale * (0.82 + _power * 0.18);

        if (sprite_exists(_visual_runtime.thrust_sprite))
        {
            draw_sprite_ext(
                _visual_runtime.thrust_sprite,
                0,
                _thruster_x,
                _thruster_y,
                _length_scale,
                _width_scale,
                _thruster_angle,
                c_white,
                _power
            );
        }
        else
        {
            _visual.thrust.draw_script(
		    _thruster_x,
		    _thruster_y,
		    _visual.radius * _thruster.scale,
		    _thruster_angle,
		    _visual,
		    _power
		);
        }
    }

    if (sprite_exists(_visual_runtime.body_sprite))
    {
        draw_sprite_ext(
            _visual_runtime.body_sprite,
            0,
            _enemy.x,
            _enemy.y,
            1,
            1,
            _enemy.draw_angle,
            c_white,
            1
        );
    }
    else
    {
        _visual.draw.body(_enemy.x, _enemy.y, _visual.radius, _enemy.draw_angle, _visual);
    }

    var _core_angle = _enemy.draw_angle + _visual_runtime.core_angle;

    if (sprite_exists(_visual_runtime.core_sprite))
    {
        draw_sprite_ext(
            _visual_runtime.core_sprite,
            0,
            _enemy.x,
            _enemy.y,
            1,
            1,
            _core_angle,
            c_white,
            _visual_runtime.core_alpha
        );
    }
    else
    {
        _visual.draw.core(
            _enemy.x,
            _enemy.y,
            _visual.radius,
            _core_angle,
            _visual,
            _visual_runtime.core_alpha
        );
    }

    for (var _i = 0; _i < array_length(_data.hardpoints); _i++)
    {
        var _hardpoint = _data.hardpoints[_i];
        var _forward = _hardpoint.forward * _visual.radius;
        var _side = _hardpoint.side * _visual.radius;
        var _hardpoint_angle = _enemy.draw_angle + _hardpoint.angle;
        var _recoil = _hardpoint.runtime.recoil;

        var _hardpoint_x = _enemy.x
            + lengthdir_x(_forward, _enemy.draw_angle)
            + lengthdir_x(_side, _enemy.draw_angle + 90)
            - lengthdir_x(_recoil, _hardpoint_angle);

        var _hardpoint_y = _enemy.y
            + lengthdir_y(_forward, _enemy.draw_angle)
            + lengthdir_y(_side, _enemy.draw_angle + 90)
            - lengthdir_y(_recoil, _hardpoint_angle);

        if (sprite_exists(_hardpoint.runtime.sprite))
        {
            draw_sprite_ext(
                _hardpoint.runtime.sprite,
                0,
                _hardpoint_x,
                _hardpoint_y,
                1,
                1,
                _hardpoint_angle,
                c_white,
                1
            );
        }
        else
        {
            _hardpoint.draw_script(
                _hardpoint_x,
                _hardpoint_y,
                _visual.radius,
                _hardpoint_angle,
                _visual,
                1
            );
        }
    }
}

/// @description Applies one damage packet to an enemy's layered defence.
function sc_enemy_damage(_enemy, _packet)
{
    var _data = _enemy.enemy;
    if (_data.state == EnemyState.DEAD) return false;

    var _defence = _data.defence;
    var _result = sc_damage_resolve(
        _packet,
        _defence.shield.current,
        _defence.armour.current,
        _defence.hull.current
    );

    _defence.shield.current = _result.shield;
    _defence.armour.current = _result.armour;
    _defence.hull.current = _result.hull;

    if (_result.dealt.total <= 0) return false;

    sc_health_bar_damage_show(_enemy.health_bar);

    if (_defence.hull.current <= 0)
    {
        _defence.hull.current = 0;
        _data.state = EnemyState.DEAD;
        sc_enemy_attack_cancel(_enemy);

        _data.visual.death_script(_enemy.x, _enemy.y, _data.visual.radius);

        // Insert drops and enemy destruction audio here later.
        instance_destroy(_enemy);
    }

    // _result.effect is ready for the upcoming timed-effect manager.
    return true;
}