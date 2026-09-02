/// @description Returns squared distance between two points without a square root.
function sc_point_distance_sq(_x1, _y1, _x2, _y2)
{
    var _dx = _x2 - _x1;
    var _dy = _y2 - _y1;
    return _dx * _dx + _dy * _dy;
}

/// @description Creates one reusable scaled attack area.
function sc_attack_area_create(_definition, _source, _damage, _x, _y, _direction, _layer, _scale = 1)
{
    var _area = instance_create_layer(_x, _y, _layer, o_attack_area, {
        attack_area_create: {
            definition: _definition,
            source: _source,
            damage: _damage,
            direction: _direction,
            scale: _scale
        }
    });

    _area.depth = -20;
    return _area;
}

/// @description Initializes one scaled circle, capsule or cone attack area.
function sc_attack_area_init(_area, _create)
{
    var _definition = variable_clone(_create.definition);
    var _geometry = variable_clone(_definition.geometry);
    var _scale = max(0.01, _create.scale);
    var _interval = max(0, round(_definition.behaviour.tick_interval));

    switch (_definition.shape)
    {
        case AttackAreaShape.CIRCLE:
            _geometry.radius *= _scale;
        break;

        case AttackAreaShape.CAPSULE:
            _geometry.length *= _scale;
            _geometry.radius *= _scale;
        break;

        case AttackAreaShape.CONE:
            _geometry.range *= _scale;
        break;
    }

    _area.attack_area = {
        source: _create.source,
        direction: _create.direction,
        shape: _definition.shape,
        geometry: _geometry,
        damage: sc_damage_packet_create(_create.damage, _create.source),

        behaviour: {
            duration: max(1, round(_definition.behaviour.duration)),
            tick_interval: _interval,
            hit_once: _definition.behaviour.hit_once,
            max_targets: _definition.behaviour.max_targets
        },

        visual: variable_clone(_definition.visual),

        runtime: {
            life: max(1, round(_definition.behaviour.duration)),
            next_damage_tick: GAME_TICK + _interval,
            hit_ids: []
        }
    };

    _area.draw_angle = _create.direction;
    _area.initialized = true;

    sc_attack_area_damage_apply(_area);
    return true;
}

/// @description Returns a conservative circular radius for one elliptical entity.
function sc_attack_area_target_radius_get(_target)
{
    var _collision = _target.entity.collision;
    return max(_collision.radius_forward, _collision.radius_side);
}

/// @description Returns whether an entity has already been hit by this area.
function sc_attack_area_target_was_hit(_area_data, _target)
{
    var _hit_ids = _area_data.runtime.hit_ids;

    for (var _i = 0; _i < array_length(_hit_ids); _i++)
        if (_hit_ids[_i] == _target) return true;

    return false;
}

/// @description Returns squared distance from a point to a finite line segment.
function sc_attack_area_point_segment_distance_sq(_px, _py, _x1, _y1, _x2, _y2)
{
    var _vx = _x2 - _x1;
    var _vy = _y2 - _y1;
    var _length_sq = _vx * _vx + _vy * _vy;

    if (_length_sq <= 0)
        return sc_point_distance_sq(_px, _py, _x1, _y1);

    var _progress = clamp(((_px - _x1) * _vx + (_py - _y1) * _vy) / _length_sq, 0, 1);
    var _nearest_x = _x1 + _vx * _progress;
    var _nearest_y = _y1 + _vy * _progress;
    return sc_point_distance_sq(_px, _py, _nearest_x, _nearest_y);
}

/// @description Collects possible entities using one inexpensive native broad-phase query.
function sc_attack_area_candidates_get(_area)
{
    var _data = _area.attack_area;
    var _geometry = _data.geometry;
    var _list = ds_list_create();

    switch (_data.shape)
    {
        case AttackAreaShape.CIRCLE:
            collision_circle_list(
                _area.x, _area.y,
                _geometry.radius,
                o_entity, false, true,
                _list, false
            );
        break;

        case AttackAreaShape.CAPSULE:
            var _end_x = _area.x + lengthdir_x(_geometry.length, _data.direction);
            var _end_y = _area.y + lengthdir_y(_geometry.length, _data.direction);
            var _radius = _geometry.radius;

            collision_rectangle_list(
                min(_area.x, _end_x) - _radius,
                min(_area.y, _end_y) - _radius,
                max(_area.x, _end_x) + _radius,
                max(_area.y, _end_y) + _radius,
                o_entity, false, true,
                _list, false
            );
        break;

        case AttackAreaShape.CONE:
            collision_circle_list(
                _area.x, _area.y,
                _geometry.range,
                o_entity, false, true,
                _list, false
            );
        break;
    }

    return _list;
}

/// @description Performs the exact shape test after broad-phase collection.
function sc_attack_area_target_inside(_area, _target)
{
    var _data = _area.attack_area;
    var _geometry = _data.geometry;
    var _target_radius = sc_attack_area_target_radius_get(_target);

    switch (_data.shape)
    {
        case AttackAreaShape.CIRCLE:
            var _radius = _geometry.radius + _target_radius;
            return sc_point_distance_sq(_area.x, _area.y, _target.x, _target.y) <= _radius * _radius;

        case AttackAreaShape.CAPSULE:
            var _end_x = _area.x + lengthdir_x(_geometry.length, _data.direction);
            var _end_y = _area.y + lengthdir_y(_geometry.length, _data.direction);
            var _radius = _geometry.radius + _target_radius;

            return sc_attack_area_point_segment_distance_sq(
                _target.x, _target.y,
                _area.x, _area.y,
                _end_x, _end_y
            ) <= _radius * _radius;

        case AttackAreaShape.CONE:
            var _distance = point_distance(_area.x, _area.y, _target.x, _target.y);
            if (_distance > _geometry.range + _target_radius) return false;

            var _target_direction = point_direction(_area.x, _area.y, _target.x, _target.y);
            return abs(angle_difference(_target_direction, _data.direction)) <= _geometry.angle * 0.5;
    }

    return false;
}

/// @description Applies one damage tick to valid opposing entities inside the area.
function sc_attack_area_damage_apply(_area)
{
    var _data = _area.attack_area;
    var _behaviour = _data.behaviour;
    var _source = _data.source;
    var _candidates = sc_attack_area_candidates_get(_area);
    var _count = ds_list_size(_candidates);
    var _targets_hit = 0;

    for (var _i = 0; _i < _count; _i++)
    {
        var _target = _candidates[| _i];

        if (_target == _source.owner_id) continue;
        if (_target.entity.faction == _source.faction) continue;
        if (_behaviour.hit_once && sc_attack_area_target_was_hit(_data, _target)) continue;
        if (!sc_attack_area_target_inside(_area, _target)) continue;

        var _result = _target.entity.damage_script(_target, _data.damage);
        if (!is_struct(_result)) continue;

        if (_behaviour.hit_once)
            array_push(_data.runtime.hit_ids, _target);

        _targets_hit++;

        if (_behaviour.max_targets > 0 && _targets_hit >= _behaviour.max_targets)
            break;
    }

    ds_list_destroy(_candidates);
    return _targets_hit;
}

/// @description Updates attack-area duration and optional repeated damage ticks.
function sc_attack_area_update(_area)
{
    var _data = _area.attack_area;
    var _runtime = _data.runtime;
    var _interval = _data.behaviour.tick_interval;

    if (_interval > 0 && GAME_TICK >= _runtime.next_damage_tick)
    {
        sc_attack_area_damage_apply(_area);
        _runtime.next_damage_tick = GAME_TICK + _interval;
    }

    _runtime.life--;

    if (_runtime.life <= 0)
        instance_destroy(_area);
}

/// @description Draws one registered short-lived attack-area visual.
function sc_attack_area_draw(_area)
{
    var _data = _area.attack_area;
    _data.visual.draw_script(_area, _data);

    draw_set_alpha(1);
    draw_set_colour(c_white);
    gpu_set_blendmode(bm_normal);
}