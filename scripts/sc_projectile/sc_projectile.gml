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

/// @description Finds the nearest opposing entity for a homing launch.
function sc_projectile_target_find(_projectile, _range)
{
    var _data = _projectile.projectile;
    var _list = ds_list_create();

    collision_circle_list(
        _projectile.x, _projectile.y,
        _range,
        o_entity, false, true,
        _list, false
    );

    var _target = noone;
    var _best_distance_sq = _range * _range;

    for (var _i = 0; _i < ds_list_size(_list); _i++)
    {
        var _candidate = _list[| _i];

        if (_candidate == _data.source.owner_id) continue;
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
            detonated: false
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

/// @description Updates one travelling projectile with optional weapon guidance.
function sc_projectile_update(_projectile)
{
    var _data = _projectile.projectile;

    sc_projectile_homing_update(_projectile);

    _projectile.x += lengthdir_x(_data.movement.speed, _data.direction);
    _projectile.y += lengthdir_y(_data.movement.speed, _data.direction);
    _projectile.draw_angle = _data.direction;
    _data.life.remaining--;

    if (_data.life.remaining > 0) return;

    sc_projectile_detonate(_projectile);
    instance_destroy(_projectile);
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

/// @description Creates a visual-only baked projectile deflection.
function sc_projectile_fragment_create(_projectile, _target, _class_config)
{
    var _data = _projectile.projectile;
    var _outward = point_direction(_target.x, _target.y, _projectile.x, _projectile.y);
    var _direction = _outward + random_range(-22, 22);
    var _spin = choose(-1, 1) * random_range(_class_config.deflect_spin_min, _class_config.deflect_spin_max);

    return instance_create_layer(_projectile.x, _projectile.y, _projectile.layer, o_projectile_fragment, {
        fragment_create: {
            sprite: sc_projectile_sprite_get(_projectile),
            direction: _direction,
            speed: _class_config.deflect_speed * random_range(0.85, 1.15),
            spin: _spin,
            scale: _data.scale * _class_config.deflect_scale,
            shrink: _class_config.deflect_shrink,
            life: _class_config.deflect_life
        }
    });
}

/// @description Resolves one projectile collision against a damageable entity.
function sc_projectile_entity_collision(_projectile, _target)
{
    var _data = _projectile.projectile;

    if (_target == _data.source.owner_id) return false;
    if (_target.entity.faction == _data.source.faction) return false;

    var _result = _target.entity.damage_script(_target, _data.damage);
    var _class_config = sc_projectile_class_config_get(_data.projectile_class);

    _data.visual.impact_script(
        _projectile.x,
        _projectile.y,
        _data.direction,
        _target,
        _data.scale
    );

    if (is_struct(_result))
    {
        if (_target == global.player_id && _class_config.camera_shake > 0)
            sc_camera_shake(_class_config.camera_shake, _class_config.shake_time);

        if (_result.impact_layer == DefenceLayer.SHIELD
        && _data.damage.type == DamageType.KINETIC
        && _class_config.shield_deflect)
            sc_projectile_fragment_create(_projectile, _target, _class_config);
    }

    sc_projectile_detonate(_projectile);

    // Insert registered impact audio callback here later.
    instance_destroy(_projectile);
    return true;
}

/// @description Draws one baked projectile using weapon-owned scale.
function sc_projectile_draw(_projectile)
{
    var _data = _projectile.projectile;

    draw_sprite_ext(
        sc_projectile_sprite_get(_projectile), 0,
        _projectile.x, _projectile.y,
        _data.scale, _data.scale,
        _projectile.draw_angle,
        c_white, 1
    );
}