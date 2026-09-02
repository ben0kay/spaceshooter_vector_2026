/// @description Returns centralized visual feedback for one projectile class.
function sc_projectile_class_config_get(_class)
{
    return global.config.projectile.classes[_class];
}

/// @description Creates one generic projectile.
function sc_projectile_create(_projectile_key, _source, _x, _y, _direction, _layer)
{
    return instance_create_layer(_x, _y, _layer, o_projectile, {
        projectile_create: { key: _projectile_key, source: _source, direction: _direction }
    });
}

/// @description Finds the nearest opposing entity for an optional homing projectile.
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

        var _distance_sq = point_distance_squared(
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

/// @description Initializes one projectile from registered data and shared baked visuals.
function sc_projectile_init(_projectile, _create)
{
    if (!variable_struct_exists(global.data.projectiles, _create.key))
    {
        show_debug_message("PROJECTILE INITIALIZATION ERROR - unknown key: " + _create.key);
        return false;
    }

    var _data = variable_struct_get(global.data.projectiles, _create.key);
    var _visual = variable_clone(_data.visual);
    var _cache = sc_projectile_visual_cache_get(_create.key);
    var _frame_count = array_length(_cache.sprites);

    _visual.runtime = {
        cache: _cache,
        phase: _frame_count > 1 ? irandom(_frame_count - 1) : 0
    };

    _projectile.projectile = {
        key: _create.key,
        projectile_class: _data.projectile_class,
        source: _create.source,
        direction: _create.direction,
        movement: variable_clone(_data.movement),
        damage: sc_damage_packet_create(_data.damage, _create.source),
        collision: variable_clone(_data.collision),
        visual: _visual,
        life: { remaining: _data.life.maximum, maximum: _data.life.maximum },

        detonation: variable_struct_exists(_data, "detonation")
            ? variable_clone(_data.detonation)
            : undefined,

        runtime: {
            target_id: noone,
            next_target_tick: GAME_TICK,
            detonated: false
        }
    };

    _projectile.mask_index = s_collision_circle;

    var _mask_scale = _projectile.projectile.collision.radius / 16;
    _projectile.image_xscale = _mask_scale;
    _projectile.image_yscale = _mask_scale;
    _projectile.draw_angle = _create.direction;
    _projectile.initialized = true;
    return true;
}

/// @description Updates optional homing without affecting ordinary projectiles.
function sc_projectile_homing_update(_projectile)
{
    var _data = _projectile.projectile;
    var _movement = _data.movement;

    if (!variable_struct_exists(_movement, "homing")) return;

    var _homing = _movement.homing;
    var _runtime = _data.runtime;
    var _target = _runtime.target_id;

    if (!instance_exists(_target) || GAME_TICK >= _runtime.next_target_tick)
    {
        _target = sc_projectile_target_find(_projectile, _homing.acquire_range);
        _runtime.target_id = _target;
        _runtime.next_target_tick = GAME_TICK + max(1, _homing.reacquire_interval);
    }

    if (!instance_exists(_target)) return;

    var _target_direction = point_direction(_projectile.x, _projectile.y, _target.x, _target.y);
    var _turn = angle_difference(_target_direction, _data.direction);
    _data.direction += clamp(_turn, -_homing.turn_speed, _homing.turn_speed);
    _data.direction = _data.direction mod 360;
}

/// @description Creates a registered detonation attack area once.
function sc_projectile_detonate(_projectile)
{
    var _data = _projectile.projectile;

    if (_data.runtime.detonated || !is_struct(_data.detonation))
        return false;

    _data.runtime.detonated = true;

    sc_attack_area_create(
        _data.detonation.area,
        _data.source,
        _projectile.x,
        _projectile.y,
        _data.direction,
        _projectile.layer
    );

    return true;
}

/// @description Updates one travelling projectile with optional homing.
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

/// @description Returns the currently displayed baked frame of one projectile.
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

/// @description Creates a visual-only baked projectile deflection away from a shield.
function sc_projectile_fragment_create(_projectile, _target, _class_config)
{
    var _outward = point_direction(_target.x, _target.y, _projectile.x, _projectile.y);
    var _direction = _outward + random_range(-22, 22);
    var _spin = choose(-1, 1) * random_range(_class_config.deflect_spin_min, _class_config.deflect_spin_max);

    return instance_create_layer(_projectile.x, _projectile.y, _projectile.layer, o_projectile_fragment, {
        fragment_create: {
            sprite: sc_projectile_sprite_get(_projectile),
            direction: _direction,
            speed: _class_config.deflect_speed * random_range(0.85, 1.15),
            spin: _spin,
            scale: _class_config.deflect_scale,
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

    _data.visual.impact_script(_projectile.x, _projectile.y, _data.direction, _target);

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

/// @description Draws one projectile using its shared baked animation frames.
function sc_projectile_draw(_projectile)
{
    draw_sprite_ext(
        sc_projectile_sprite_get(_projectile), 0,
        _projectile.x, _projectile.y,
        1, 1, _projectile.draw_angle,
        c_white, 1
    );
}