/// @description Initializes a reusable projectile template using weapon-owned launch data.
function sc_projectile_init(_projectile, _create)
{
    if (!variable_struct_exists(global.data.projectiles, _create.key))
    {
        show_debug_message("PROJECTILE INITIALIZATION ERROR - unknown key: " + _create.key);
        return false;
    }

    var _data = variable_struct_get(global.data.projectiles, _create.key);
    var _delivery = _create.delivery;
    var _launch = _delivery.projectile;
    var _scale = max(0.01, _launch.scale);
    var _collision = variable_clone(_data.collision);
    var _visual = variable_clone(_data.visual);
    var _cache = sc_projectile_visual_cache_get(_create.key);
    var _frame_count = array_length(_cache.sprites);

    _collision.radius *= _scale;

    _visual.runtime = {
        cache: _cache,
        phase: _frame_count > 1 ? irandom(_frame_count - 1) : 0
    };

    var _detonation = undefined;

    if (variable_struct_exists(_data, "detonation"))
    {
        _detonation = {
            area: variable_clone(_data.detonation.area),
            scale: _delivery.detonation.scale,
            damage: variable_clone(_delivery.detonation.damage)
        };
    }

    _projectile.projectile = {
        key: _create.key,
        state: ProjectileState.ACTIVE,
        projectile_class: _data.projectile_class,
        source: _create.source,
        direction: _create.direction,
        scale: _scale,

        movement: {
            speed: max(0, _launch.speed)
        },

        life: {
            remaining: max(1, round(_launch.life)),
            maximum: max(1, round(_launch.life))
        },

        guidance: variable_clone(_delivery.guidance),
        damage: sc_damage_packet_create(_delivery.damage, _create.source),
        collision: _collision,
        visual: _visual,
        detonation: _detonation,

        runtime: {
            target_id: noone,
            next_target_tick: GAME_TICK,
            detonated: false,
            ricochet: undefined
        }
    };

    _projectile.mask_index = s_collision_circle;

    var _mask_scale = _collision.radius / 16;
    _projectile.image_xscale = _mask_scale;
    _projectile.image_yscale = _mask_scale;
    _projectile.draw_angle = _create.direction;
    _projectile.initialized = true;
    return true;
}

/// @description Returns centralized visual feedback for one projectile class.
function sc_projectile_class_config_get(_class)
{
    return global.config.projectile.classes[_class];
}

/// @description Creates one projectile using its weapon's launch parameters.
function sc_projectile_create(_projectile_key, _source, _delivery, _x, _y, _direction, _layer)
{
    return instance_create_layer(_x, _y, _layer, o_projectile, {
        projectile_create: {
            key: _projectile_key,
            source: _source,
            delivery: _delivery,
            direction: _direction
        }
    });
}

/// @description Finds the nearest valid opposing entity for a homing launch.
/// @description Registers projectiles shared across players and enemy factions.
function sc_projectiles_shared_register_all()
{
    if (!sc_projectile_register_minigun()) return false;
    return true;
}

function sc_projectile_target_find(_projectile, _range)
{
    var _data = _projectile.projectile;
    var _list = ds_list_create();

    collision_circle_list(
        _projectile.x, _projectile.y, _range,
        o_entity, false, true, _list, false
    );

    var _target = noone;
    var _best_distance_sq = _range * _range;

    for (var _i = 0; _i < ds_list_size(_list); _i++)
    {
        var _candidate = _list[| _i];

        if (_candidate == _data.source.owner_id) continue;
        if (!_candidate.entity.guidance_targetable) continue;
        if (_candidate.entity.faction == _data.source.faction) continue;

        var _distance_sq = sc_point_distance_sq(
            _projectile.x, _projectile.y,
            _candidate.x, _candidate.y
        );

        if (_distance_sq >= _best_distance_sq) continue;

        _best_distance_sq = _distance_sq;
        _target = _candidate;
    }

    ds_list_destroy(_list);
    return _target;
}

/// @description Updates weapon-supplied projectile guidance.
function sc_projectile_homing_update(_projectile)
{
    var _data = _projectile.projectile;
    var _guidance = _data.guidance;

    if (!_guidance.homing) return;

    var _runtime = _data.runtime;
    var _target = _runtime.target_id;

    if (!instance_exists(_target) || GAME_TICK >= _runtime.next_target_tick)
    {
        _target = sc_projectile_target_find(_projectile, _guidance.acquire_range);
        _runtime.target_id = _target;
        _runtime.next_target_tick = GAME_TICK + max(1, round(_guidance.reacquire_interval));
    }

    if (!instance_exists(_target)) return;

    var _target_direction = point_direction(_projectile.x, _projectile.y, _target.x, _target.y);
    var _turn = angle_difference(_target_direction, _data.direction);
    _data.direction += clamp(_turn, -_guidance.turn_speed, _guidance.turn_speed);
    _data.direction = _data.direction mod 360;
}

/// @description Creates the projectile template's explosion using weapon-owned power.
function sc_projectile_detonate(_projectile)
{
    var _data = _projectile.projectile;
    var _detonation = _data.detonation;

    if (_data.runtime.detonated || !is_struct(_detonation))
        return false;

    _data.runtime.detonated = true;

    sc_attack_area_create(
        _detonation.area,
        _data.source,
        _detonation.damage,
        _projectile.x,
        _projectile.y,
        _data.direction,
        _projectile.layer,
        _detonation.scale
    );

    return true;
}

/// @description Updates one active projectile or harmless shield ricochet.
function sc_projectile_update(_projectile)
{
    var _data = _projectile.projectile;

    switch (_data.state)
    {
        case ProjectileState.ACTIVE:
            sc_projectile_active_update(_projectile, _data);
        break;

        case ProjectileState.RICOCHET:
            sc_projectile_ricochet_update(_projectile, _data);
        break;
    }
}

/// @description Updates one damaging travelling projectile.
function sc_projectile_active_update(_projectile, _data)
{
    sc_projectile_homing_update(_projectile);

    _projectile.x += lengthdir_x(_data.movement.speed, _data.direction);
    _projectile.y += lengthdir_y(_data.movement.speed, _data.direction);
    _projectile.draw_angle = _data.direction;
	if (variable_struct_exists(_data.visual, "trail_script"))
    _data.visual.trail_script(_projectile, _data);
    _data.life.remaining--;

    if (_data.life.remaining > 0) return;

    sc_projectile_detonate(_projectile);
    instance_destroy(_projectile);
}

/// @description Moves, shrinks and fades one harmless shield ricochet.
function sc_projectile_ricochet_update(_projectile, _data)
{
    var _ricochet = _data.runtime.ricochet;

    _projectile.x += lengthdir_x(_data.movement.speed, _data.direction);
    _projectile.y += lengthdir_y(_data.movement.speed, _data.direction);

    _data.movement.speed *= 0.96;
    _projectile.draw_angle = _data.direction;
    _ricochet.scale *= _ricochet.shrink;
    _ricochet.remaining--;
    _ricochet.alpha = sqr(max(0, _ricochet.remaining / _ricochet.maximum));

    if (_ricochet.remaining <= 0)
        instance_destroy(_projectile);
}

/// @description Returns an elliptical shield-surface impact position and outward normal.
function sc_projectile_shield_impact_get(_projectile, _target)
{
    var _data = _projectile.projectile;
    var _collision = _target.entity.collision;
    var _shield_scale = global.config.visual.shield.radius_scale;
    var _radius_forward = _collision.radius_forward * _shield_scale;
    var _radius_side = _collision.radius_side * _shield_scale;
    var _target_angle = _target.draw_angle;
    var _distance = point_distance(_target.x, _target.y, _projectile.x, _projectile.y);
    var _relative_angle = angle_difference(point_direction(_target.x, _target.y, _projectile.x, _projectile.y), _target_angle);
    var _local_x = lengthdir_x(_distance, _relative_angle);
    var _local_y = -lengthdir_y(_distance, _relative_angle);
    var _incoming_angle = angle_difference(_data.direction, _target_angle);
    var _incoming_x = dcos(_incoming_angle);
    var _incoming_y = dsin(_incoming_angle);

    var _forward_sq = _radius_forward * _radius_forward;
    var _side_sq = _radius_side * _radius_side;
    var _a = (_incoming_x * _incoming_x) / _forward_sq + (_incoming_y * _incoming_y) / _side_sq;
    var _b = -2 * ((_local_x * _incoming_x) / _forward_sq + (_local_y * _incoming_y) / _side_sq);
    var _c = (_local_x * _local_x) / _forward_sq + (_local_y * _local_y) / _side_sq - 1;
    var _root = sqrt(max(0, _b * _b - 4 * _a * _c));
    var _distance_back = max((-_b - _root) / (2 * _a), (-_b + _root) / (2 * _a), 0);
    var _impact_local_x = _local_x - _incoming_x * _distance_back;
    var _impact_local_y = _local_y - _incoming_y * _distance_back;

    var _impact_x = _target.x
        + lengthdir_x(_impact_local_x, _target_angle)
        + lengthdir_x(_impact_local_y, _target_angle + 90);

    var _impact_y = _target.y
        + lengthdir_y(_impact_local_x, _target_angle)
        + lengthdir_y(_impact_local_y, _target_angle + 90);

    var _normal_local_x = _impact_local_x / _forward_sq;
    var _normal_local_y = _impact_local_y / _side_sq;

    var _normal_end_x = _impact_x
        + lengthdir_x(_normal_local_x, _target_angle)
        + lengthdir_x(_normal_local_y, _target_angle + 90);

    var _normal_end_y = _impact_y
        + lengthdir_y(_normal_local_x, _target_angle)
        + lengthdir_y(_normal_local_y, _target_angle + 90);

    return {
        x: _impact_x,
        y: _impact_y,
        normal: point_direction(_impact_x, _impact_y, _normal_end_x, _normal_end_y)
    };
}

/// @description Converts the real projectile into a harmless fading shield ricochet.
function sc_projectile_ricochet_begin(_projectile, _impact, _class_config)
{
    var _data = _projectile.projectile;
    var _reflected = 2 * _impact.normal - _data.direction + 180;

	var _direction = _data.direction
	    + angle_difference(_reflected, _data.direction) * _class_config.deflect_strength
	    + random_range(-_class_config.deflect_spread, _class_config.deflect_spread);

    var _life = max(1, round(_class_config.deflect_life));

    _projectile.x = _impact.x + lengthdir_x(4, _impact.normal);
    _projectile.y = _impact.y + lengthdir_y(4, _impact.normal);

    _data.state = ProjectileState.RICOCHET;
    _data.direction = _direction;
    _data.movement.speed = max(
        _class_config.deflect_speed,
        _data.movement.speed * random_range(0.3, 0.45)
    );

    _data.runtime.target_id = noone;
    _data.runtime.ricochet = {
        scale: _data.scale * _class_config.deflect_scale,
        shrink: _class_config.deflect_shrink,
        alpha: 1,
        remaining: _life,
        maximum: _life
    };

    _projectile.draw_angle = _direction;
    _projectile.mask_index = -1;
    return true;
}

/// @description Returns the currently displayed baked projectile frame.
function sc_projectile_sprite_get(_projectile)
{
    var _runtime = _projectile.projectile.visual.runtime;
    var _cache = _runtime.cache;
    var _frame_count = array_length(_cache.sprites);
    var _frame = _frame_count > 1
        ? ((GAME_TICK div _cache.frame_speed) + _runtime.phase) mod _frame_count
        : 0;

    return _cache.sprites[_frame];
}

/// @description Resolves one projectile collision against a damageable entity.
function sc_projectile_entity_collision(_projectile, _target)
{
    var _data = _projectile.projectile;

    if (_data.state != ProjectileState.ACTIVE) return false;
    if (_target == _data.source.owner_id) return false;
    if (_target.entity.faction == _data.source.faction) return false;

    var _target_faction = _target.entity.faction;
    var _result = _target.entity.damage_script(_target, _data.damage);
    var _class_config = sc_projectile_class_config_get(_data.projectile_class);
    var _impact_x = _projectile.x;
    var _impact_y = _projectile.y;
    var _shield_impact = undefined;

    if (is_struct(_result) && _result.impact_layer == DefenceLayer.SHIELD)
    {
        _shield_impact = sc_projectile_shield_impact_get(_projectile, _target);
        _impact_x = _shield_impact.x;
        _impact_y = _shield_impact.y;

        _projectile.x = _impact_x;
        _projectile.y = _impact_y;
    }

    _data.visual.impact_script(
        _impact_x,
        _impact_y,
        _data.direction,
        _target,
        _data.scale
    );

    if (is_struct(_result))
    {
        sc_entity_knockback_apply(
            _target,
            _data.damage.knockback_force,
            _data.direction
        );

        if (_target_faction == Faction.PLAYER && _class_config.camera_shake > 0)
            sc_camera_shake(_class_config.camera_shake, _class_config.shake_time);

        var _can_ricochet =
            _result.impact_layer == DefenceLayer.SHIELD
            && _data.damage.type == DamageType.KINETIC
            && _class_config.shield_deflect
            && random(1) < _class_config.deflect_chance;

        if (_can_ricochet)
            return sc_projectile_ricochet_begin(_projectile, _shield_impact, _class_config);
    }

    sc_projectile_detonate(_projectile);

    // Insert registered impact audio callback here later.
    instance_destroy(_projectile);
    return true;
}

/// @description Draws one active projectile or fading shield ricochet.
function sc_projectile_draw(_projectile)
{
    var _data = _projectile.projectile;
    var _scale = _data.scale;
    var _alpha = 1;

    if (_data.state == ProjectileState.RICOCHET)
    {
        _scale = _data.runtime.ricochet.scale;
        _alpha = _data.runtime.ricochet.alpha;
    }

    if (_data.state == ProjectileState.ACTIVE
    && variable_struct_exists(_data.visual, "trail"))
    {
        var _trail = _data.visual.trail;

        if (_trail.enabled)
        {
            var _cache = sc_projectile_trail_cache_get();
            var _palette = _data.visual.palette;
            var _rear = _data.visual.length * 0.42 * _scale;
            var _trail_x = _projectile.x - lengthdir_x(_rear, _data.direction);
            var _trail_y = _projectile.y - lengthdir_y(_rear, _data.direction);
            var _length_scale = (_trail.length * _scale) / _cache.width;
            var _glow_scale = (_trail.glow_width * _scale) / _cache.height;
            var _width_scale = (_trail.width * _scale) / _cache.height;

            draw_sprite_ext(
                _cache.sprite, 0,
                _trail_x, _trail_y,
                _length_scale, _glow_scale,
                _data.direction,
                _palette.glow,
                _trail.glow_alpha * _alpha
            );

            draw_sprite_ext(
                _cache.sprite, 0,
                _trail_x, _trail_y,
                _length_scale, _width_scale,
                _data.direction,
                _palette.energy,
                _trail.alpha * _alpha
            );
        }
    }

    draw_sprite_ext(
        sc_projectile_sprite_get(_projectile), 0,
        _projectile.x, _projectile.y,
        _scale, _scale,
        _projectile.draw_angle,
        c_white, _alpha
    );
}