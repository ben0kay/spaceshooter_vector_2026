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
		doctrine: variable_clone(sc_faction_doctrine_get(_data.identity.faction)),
		reward: variable_clone(_data.reward),
        state: EnemyState.IDLE,
        target_id: noone,
        target_distance_sq: 0,
        stats: undefined,
        defence: undefined,

        movement_controller: variable_clone(_data.movement_controller),
		awareness_controller: variable_clone(_data.awareness_controller),

        movement: {
            velocity_x: 0,
            velocity_y: 0,
            spawn_x: _enemy.x,
            spawn_y: _enemy.y,
            orbit_direction: 1,
            strafe_phase: random(2 * pi),

            command: {
                active: false,
                direction: 0,
                speed_scale: 1,
                apply_friction: true,
                facing_mode: EnemyFacingMode.TARGET,
                face_direction: 0
            },

            wander: {
                active: false,
                target_x: _enemy.x,
                target_y: _enemy.y,
                next_move_tick: GAME_TICK + irandom_range(30, 90)
            },
			
			obstacle: {
			    active: false,
			    target_id: noone,
			    direction: 0,
			    side: 0,
			    next_check_tick: GAME_TICK
			},
			
			behaviour_runtime: 
				variable_struct_exists(_data.movement_controller, "runtime")
			    ? variable_clone(_data.movement_controller.runtime)
			    : {}
			
        },

        collision: {
            radius_forward: _radius * _data.collision.radius_forward_scale,
            radius_side: _radius * _data.collision.radius_side_scale,
            blocks_player: _data.collision.blocks_player
        },
			
		alert: {
		    attempts: 0,
		    next_attempt_tick: 0
		},
			
		flee: {
    attempts: 0,
    next_attempt_tick: 0,
    direction: 0
},

		awareness: {
		    memory_until: 0,
		    last_known_x: _enemy.x,
		    last_known_y: _enemy.y,
		    arrived: false,
		    search_until: 0
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
    var _orbit_direction = _runtime.movement_controller.orbit.direction;

    _enemy.draw_angle = 0;
    _runtime.movement.orbit_direction = _orbit_direction == 0 ? choose(-1, 1) : sign(_orbit_direction);
    _runtime.movement.command.facing_mode = _runtime.movement_controller.facing.default_mode;

    if (!sc_entity_init(_enemy, _runtime.identity.faction, sc_enemy_damage, _runtime.collision)) return false;

    _runtime.defence = {
        shield: { current: _final.shield_max, maximum: _final.shield_max },
        armour: { current: _final.armour_max, maximum: _final.armour_max },
        hull: { current: _final.hull_max, maximum: _final.hull_max }
    };

    _runtime.visual.runtime = {
        body_sprite: is_struct(_cache) ? _cache.body : -1,
		damage_layers: is_struct(_cache) ? _cache.damage_layers : undefined,
        core_sprite: is_struct(_cache) ? _cache.core : -1,
        thrust_sprite: is_struct(_cache) ? _cache.thrust : -1,
        shield_sprite: is_struct(_cache) ? _cache.shield : -1,
		damage_fx: sc_faction_damage_fx_get(_runtime.identity.faction),
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

/// @description Updates detection, investigation, combat and forget transitions.
function sc_enemy_perception_update(_enemy)
{
    var _data = _enemy.enemy;
    var _range = _data.stats.final.range;
    var _awareness = _data.awareness;

    if (!instance_exists(global.player_id))
    {
        sc_enemy_attack_cancel(_enemy);
        _data.target_id = noone;
        _data.state = EnemyState.IDLE;
        _awareness.memory_until = 0;
        return;
    }

    var _dx = global.player_id.x - _enemy.x;
    var _dy = global.player_id.y - _enemy.y;
    _data.target_distance_sq = _dx * _dx + _dy * _dy;

    if (_data.target_distance_sq <= _range.detection_sq)
    {
        _awareness.last_known_x = global.player_id.x;
        _awareness.last_known_y = global.player_id.y;
    }

    switch (_data.state)
    {
        case EnemyState.IDLE:
            if (_data.target_distance_sq <= _range.detection_sq)
            {
                _data.target_id = global.player_id;
                _data.state = EnemyState.CHASING;
                sc_enemy_alert_try(_enemy, _data.doctrine.alert.on_detection);
            }
        break;

        case EnemyState.INVESTIGATING:
            if (_data.target_distance_sq <= _range.detection_sq)
            {
                _data.target_id = global.player_id;
                _awareness.memory_until = 0;
                _awareness.arrived = false;
                _data.state = EnemyState.CHASING;
                sc_enemy_alert_try(_enemy, _data.doctrine.alert.on_detection);
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

/// @description Emits faction-specific visual damage across the enemy hull.
function sc_enemy_damage_visual_update(_enemy)
{
    var _data = _enemy.enemy;
    var _defence = _data.defence;
    var _visual = _data.visual;
    var _runtime = _visual.runtime;
    var _config = global.config.visual.enemy_damage;
    var _hull_ratio = _defence.hull.current / max(1, _defence.hull.maximum);

    if (_hull_ratio >= _config.hull_threshold) return false;

    var _severity = clamp(
        (_config.hull_threshold - _hull_ratio) / _config.hull_threshold,
        0,
        1
    );

    var _interval = max(1, round(lerp(_config.interval_max, _config.interval_min, _severity)));

    if (((GAME_TICK + real(_enemy.id)) mod _interval) != 0)
        return false;

    var _collision = _enemy.entity.collision;
    var _footprint = _config.footprint_scale;
    var _mass = _data.stats.final.mass;
    var _scale = clamp(
        (_visual.radius / _config.radius_reference)
        * (1 + max(0, _mass - 1) * _config.mass_scale),
        _config.scale_min,
        _config.scale_max
    );

    var _count = round(lerp(_config.puff_count_min, _config.puff_count_max, _severity));

    for (var _i = 0; _i < _count; _i++)
    {
        var _point_radius = sqrt(random(1));
        var _point_angle = random(360);
        var _forward = dcos(_point_angle) * _point_radius * _collision.radius_forward * _footprint;
        var _side = dsin(_point_angle) * _point_radius * _collision.radius_side * _footprint;

        var _x = _enemy.x
            + lengthdir_x(_forward, _enemy.draw_angle)
            + lengthdir_x(_side, _enemy.draw_angle + 90);

        var _y = _enemy.y
            + lengthdir_y(_forward, _enemy.draw_angle)
            + lengthdir_y(_side, _enemy.draw_angle + 90);

        _runtime.damage_fx.emit_script(_x, _y, _scale, _severity, _runtime.damage_fx);
    }

    return true;
}

/// @description Updates shared visual animation, damage effects and registered thrusters.
function sc_enemy_visual_update(_enemy)
{
    var _data = _enemy.enemy;
    var _visual = _data.visual;
    var _movement = _data.movement;
    var _thrusters = _data.thrusters;
    var _speed_max = _data.stats.final.handling.speed_max;
    var _mass = _data.stats.final.mass;
    var _thrust_config = global.config.visual.enemy_thrust;

    _visual.runtime.core_angle = (_visual.runtime.core_angle + 1.5) mod 360;
    _visual.runtime.core_alpha = 0.78 + sin(GAME_TICK * 0.09) * 0.22;
    _visual.runtime.shield_hit_alpha = max(0, _visual.runtime.shield_hit_alpha - 0.06);

    sc_enemy_damage_visual_update(_enemy);

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
                _thruster.scale, _visual.radius, _mass, _visual.palette);

        _runtime.active = _active;
        _runtime.power = lerp(_runtime.power, _target_power, _target_power > _runtime.power ? 0.22 : 0.12);

        if (_runtime.power > _thrust_config.emit_power_min
        && ((GAME_TICK + _runtime.phase) mod _thrust_config.emit_interval) == 0)
            _visual.thrust.particle_script(_thruster_x, _thruster_y, _thruster_angle, _runtime.power,
                _thruster.scale, _visual.radius, _mass, _visual.palette);
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
    var _mass_enemy = _enemy.enemy.stats.final.mass;
	var _mass_other = _other.enemy.stats.final.mass;
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

/// @description Returns one of four enemy visual damage stages.
function sc_enemy_damage_visual_stage(_current, _maximum)
{
    var _ratio = _maximum > 0 ? _current / _maximum : 0;

    if (_ratio > 0.75) return 0;
    if (_ratio > 0.5) return 1;
    if (_ratio > 0.25) return 2;
    return 3;
}

/// @description Draws either optional damage layers or the original body.
function sc_enemy_body_visual_draw(_enemy, _draw_x, _draw_y, _angle)
{
    var _data = _enemy.enemy;
    var _visual = _data.visual;
    var _runtime = _visual.runtime;
    var _layers = _runtime.damage_layers;

    if (!is_struct(_layers))
    {
        if (sprite_exists(_runtime.body_sprite))
            draw_sprite_ext(_runtime.body_sprite, 0, _draw_x, _draw_y, 1, 1, _angle, c_white, 1);
        else
            _visual.draw.body(_draw_x, _draw_y, _visual.radius, _angle, _visual);

        return;
    }

    var _hull_stage = sc_enemy_damage_visual_stage(
        _data.defence.hull.current,
        _data.defence.hull.maximum
    );

    var _armour_stage = sc_enemy_damage_visual_stage(
        _data.defence.armour.current,
        _data.defence.armour.maximum
    );

    draw_sprite_ext(
        _layers.hull[_hull_stage], 0,
        _draw_x, _draw_y,
        1, 1, _angle,
        c_white, 1
    );

    if (_data.defence.armour.current > 0)
	{
	    draw_sprite_ext(
	        _layers.armour[_armour_stage], 0,
	        _draw_x, _draw_y,
	        1, 1, _angle,
	        c_white, 1
	    );
	}
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

		sc_enemy_body_visual_draw(_enemy, _draw_x, _draw_y, _angle);

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

    if (_result.dealt.shield > 0)
        _data.visual.runtime.shield_hit_alpha = 1;

    if (_defence.hull.current <= 0)
    {
        _defence.hull.current = 0;
        _data.state = EnemyState.DEAD;
        sc_enemy_die(_enemy, _packet);
        return _result;
    }
	
	if (_data.state == EnemyState.FLEEING)
		{
		    if (_result.effect.type == DamageEffect.STAGGER
		    && sc_damage_effect_triggered(_result.effect))
		        sc_enemy_stagger_begin(_enemy, _result.effect);

		    return _result;
		}

    sc_enemy_awareness_damage_try(_enemy, _packet);
    sc_enemy_alert_try(_enemy, _data.doctrine.alert.on_damage);
    sc_enemy_flee_try(_enemy, _result);

    if (_result.effect.type == DamageEffect.STAGGER
    && sc_damage_effect_triggered(_result.effect))
        sc_enemy_stagger_begin(_enemy, _result.effect);

    return _result;
}

/// @description Processes one enemy death and its final killing source.
function sc_enemy_die(_enemy, _packet)
{
    var _data = _enemy.enemy;
    var _source = _packet.source;
    var _death_x = _enemy.x;
    var _death_y = _enemy.y;
    var _death_layer = _enemy.layer;
    var _shake_config = global.config.visual.enemy_death;
    var _mass = _data.stats.final.mass;

    sc_enemy_attack_cancel(_enemy);
    _data.target_id = noone;
    _data.visual.death.script(_enemy);

    var _shake_magnitude = clamp(
        _shake_config.shake_base + _mass * _shake_config.shake_per_mass,
        _shake_config.shake_min,
        _shake_config.shake_max
    );

    var _shake_time = min(
        _shake_config.time_max,
        round(_shake_config.time_base + _mass * _shake_config.time_per_mass)
    );

    sc_camera_shake_at(
        _death_x, _death_y,
        _shake_magnitude, _shake_time,
        _shake_config.falloff_start,
        _shake_config.falloff_end,
        _shake_config.falloff_min
    );

    if (_source.faction == Faction.PLAYER)
    {
        sc_player_reward_grant(_data.reward, _death_x, _death_y, _death_layer);
        // Increment player kill count and combat statistics here later.
    }
    else
    {
        // Handle allied, environmental or faction kill credit here later.
    }

    // Roll registered enemy drops here later.
    // Process registered on-death abilities here later.
    // Insert registered enemy death audio here later.

    instance_destroy(_enemy);
    return true;
}