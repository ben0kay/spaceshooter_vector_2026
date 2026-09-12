/// @description Returns squared distance between two points without a square root.
function sc_point_distance_sq(_x1, _y1, _x2, _y2)
{
    var _dx = _x2 - _x1;
    var _dy = _y2 - _y1;
    return _dx * _dx + _dy * _dy;
}

/// @description Creates one short-lived attack area.
function sc_attack_area_create(_definition, _source, _damage, _x, _y, _direction, _layer, _scale = 1)
{
    var _area = instance_create_layer(_x, _y, _layer, o_attack_area, {
        attack_area_create: {
            delivery_type: AttackDelivery.AREA,
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

/// @description Creates one continuously maintained beam area.
function sc_beam_create(_definition, _source, _damage, _x, _y, _direction, _layer, _scale = 1)
{
    var _beam = instance_create_layer(_x, _y, _layer, o_attack_area, {
        attack_area_create: {
            delivery_type: AttackDelivery.BEAM,
            definition: _definition,
            source: _source,
            damage: _damage,
            direction: _direction,
            scale: _scale
        }
    });

    _beam.depth = -20;
    return _beam;
}

/// @description Initializes one attack-area instance using its delivery lifecycle.
function sc_attack_area_init(_area, _create)
{
    switch (_create.delivery_type)
    {
        case AttackDelivery.AREA:
            return sc_attack_area_standard_init(_area, _create);

        case AttackDelivery.BEAM:
            return sc_beam_init(_area, _create);
    }

    show_debug_message("ATTACK AREA ERROR - unsupported delivery type");
    return false;
}

/// @description Initializes one ordinary timed circle, capsule or cone.
function sc_attack_area_standard_init(_area,_create)
{
    var _definition = variable_clone(_create.definition);
    var _geometry = variable_clone(_definition.geometry);
    var _source_behaviour = _definition.behaviour;
    var _scale = max(0.01,_create.scale);
    var _interval = max(0,round(_source_behaviour.tick_interval));
    var _falloff_distance = 1;

    switch (_definition.shape)
    {
        case AttackAreaShape.CIRCLE:
            _geometry.radius *= _scale;
            _falloff_distance = _geometry.radius;
        break;

        case AttackAreaShape.CAPSULE:
            _geometry.length *= _scale;
            _geometry.radius *= _scale;
            _falloff_distance = _geometry.length;
        break;

        case AttackAreaShape.CONE:
            _geometry.range *= _scale;
            _falloff_distance = _geometry.range;
        break;
    }

    // Optional travelling damage edge for circular attacks.
    var _ring = variable_struct_exists(_source_behaviour,"expanding_ring")
        ? variable_clone(_source_behaviour.expanding_ring)
        : { enabled: false, start_radius: 0, thickness: 1 };

    _ring.enabled = _definition.shape == AttackAreaShape.CIRCLE && _ring.enabled;
    _ring.start_radius = clamp(_ring.start_radius*_scale,0,_falloff_distance);
    _ring.thickness = max(1,_ring.thickness*_scale);

    var _occlusion = variable_clone(GCFG.damage.area_occlusion);
    var _occlusion_supported = _definition.shape == AttackAreaShape.CIRCLE;
    var _occlusion_default = _occlusion_supported && _create.damage.type == DamageType.EXPLOSIVE;

    _occlusion.asteroids = _occlusion.asteroids && _occlusion_default;

    if (_occlusion_supported && variable_struct_exists(_source_behaviour,"occlusion"))
        _occlusion.asteroids = _source_behaviour.occlusion.asteroids;

    var _duration = max(1,round(_source_behaviour.duration));

    _area.attack_area = {
        delivery_type: AttackDelivery.AREA,
        source: _create.source,
        direction: _create.direction,
        shape: _definition.shape,
        geometry: _geometry,

        damage: sc_damage_packet_create(_create.damage,_create.source),

        behaviour: {
            duration: _duration,
            tick_interval: _ring.enabled ? max(1,_interval) : _interval,
            hit_once: _source_behaviour.hit_once,
            max_targets: _source_behaviour.max_targets,
            falloff_minimum: clamp(_source_behaviour.falloff_minimum,0,1),
            falloff_exponent: max(0.01,_source_behaviour.falloff_exponent),
            falloff_distance: max(1,_falloff_distance),
            expanding_ring: _ring,
            occlusion: _occlusion
        },

        visual: variable_clone(_definition.visual),

        runtime: {
            life: _duration,
            elapsed: 0,
            ring_radius: _ring.start_radius,
            next_damage_tick: GAME_TICK+(_ring.enabled ? 1 : _interval),
            hit_ids: []
        }
    };

    _area.draw_angle = _create.direction;
    _area.initialized = true;

    if (variable_struct_exists(_area.attack_area.visual,"shockwave"))
    {
        sc_shockwave_create(
            _area.x,_area.y,_area.layer,
            _area.attack_area.visual.shockwave,
            _falloff_distance
        );
    }

    // Ordinary areas damage immediately. Expanding rings wait for their edge.
    if (!_ring.enabled)
        sc_attack_area_damage_apply(_area);

    return true;
}

/// @description Initializes one continuously maintained capsule or cone area.
function sc_beam_init(_area, _create)
{
    var _definition = variable_clone(_create.definition);
    var _shape = _definition.shape;
    var _geometry = variable_clone(_definition.geometry);
    var _source_behaviour = _definition.behaviour;
    var _scale = max(0.01, _create.scale);
    var _interval = max(1, round(_source_behaviour.tick_interval));

    var _behaviour = {
        release_duration: max(1, round(_source_behaviour.release_duration)),
        tick_interval: _interval,
        hit_once: false,
        max_targets: _source_behaviour.max_targets
    };

    var _runtime = {
        next_damage_tick: GAME_TICK + _interval,
        refreshed_tick: GAME_TICK,
        releasing: false,
        release_alpha: 1,
        hit_ids: [],

        impact_active: false,
        impact_target_id: noone,
        impact_overlap: 0,
        contact_length: 0,
        visual_length: 0
    };

    switch (_shape)
    {
        case AttackAreaShape.CAPSULE:
            _runtime.maximum_length = _geometry.length * _scale;
            _runtime.growth_length = 0;
            _runtime.hit_length = 0;

            _geometry.length = 0;
            _geometry.radius *= _scale;

            _behaviour.growth_speed = max(0, _source_behaviour.growth_speed * _scale);
            _behaviour.piercing = _source_behaviour.piercing;
            _behaviour.blocks_on_solids = _source_behaviour.blocks_on_solids;
        break;

        case AttackAreaShape.CONE:
            _geometry.range *= _scale;
        break;
    }

    _area.attack_area = {
        delivery_type: AttackDelivery.BEAM,
        source: _create.source,
        direction: _create.direction,
        shape: _shape,
        geometry: _geometry,
        damage: sc_damage_packet_create(_create.damage, _create.source),
        behaviour: _behaviour,
        visual: variable_clone(_definition.visual),
        runtime: _runtime
    };

    _area.draw_angle = _create.direction;
    _area.initialized = true;
    return true;
}

/// @description Keeps one beam attached to its firing mount.
function sc_beam_sustain(_beam, _x, _y, _direction)
{
    if (!instance_exists(_beam)) return false;

    var _data = _beam.attack_area;

    _beam.x = _x;
    _beam.y = _y;
    _beam.draw_angle = _direction;

    _data.direction = _direction;
    _data.runtime.refreshed_tick = GAME_TICK;
    _data.runtime.releasing = false;
    _data.runtime.release_alpha = 1;
    return true;
}

/// @description Ends beam damage and begins its visual fade.
function sc_beam_release(_beam)
{
    if (!instance_exists(_beam)) return false;

    _beam.attack_area.runtime.releasing = true;
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

/// @description Collects possible entities and interceptable projectiles.
function sc_attack_area_candidates_get(_area)
{
    var _data = _area.attack_area;
    var _geometry = _data.geometry;
    var _list = ds_list_create();

    switch (_data.shape)
    {
        case AttackAreaShape.CIRCLE:
        {
            var _radius = _data.behaviour.expanding_ring.enabled
                ? min(
                    _geometry.radius,
                    _data.runtime.ring_radius
                    + _data.behaviour.expanding_ring.thickness*0.5
                )
                : _geometry.radius;

            collision_circle_list(
                _area.x,_area.y,_radius,
                o_entity,false,true,
                _list,false
            );

            collision_circle_list(
                _area.x,_area.y,_radius,
                o_interceptable_projectile,false,true,
                _list,false
            );
        }
        break;

        case AttackAreaShape.CAPSULE:
        {
            var _end_x = _area.x+lengthdir_x(_geometry.length,_data.direction);
            var _end_y = _area.y+lengthdir_y(_geometry.length,_data.direction);
            var _radius = _geometry.radius;

            collision_rectangle_list(
                min(_area.x,_end_x)-_radius,
                min(_area.y,_end_y)-_radius,
                max(_area.x,_end_x)+_radius,
                max(_area.y,_end_y)+_radius,
                o_entity,false,true,
                _list,false
            );

            collision_rectangle_list(
                min(_area.x,_end_x)-_radius,
                min(_area.y,_end_y)-_radius,
                max(_area.x,_end_x)+_radius,
                max(_area.y,_end_y)+_radius,
                o_interceptable_projectile,false,true,
                _list,false
            );
        }
        break;

        case AttackAreaShape.CONE:
            collision_circle_list(
                _area.x,_area.y,_geometry.range,
                o_entity,false,true,
                _list,false
            );

            collision_circle_list(
                _area.x,_area.y,_geometry.range,
                o_interceptable_projectile,false,true,
                _list,false
            );
        break;
    }

    return _list;
}

/// @description Performs the exact shape test after broad-phase collection.
function sc_attack_area_target_inside(_area,_target)
{
    var _data = _area.attack_area;
    var _geometry = _data.geometry;
    var _target_radius = sc_attack_area_target_radius_get(_target);

    switch (_data.shape)
    {
        case AttackAreaShape.CIRCLE:
        {
            var _distance_sq = sc_point_distance_sq(
                _area.x,_area.y,
                _target.x,_target.y
            );

            var _ring = _data.behaviour.expanding_ring;

            if (_ring.enabled)
            {
                var _half = _ring.thickness*0.5;
                var _outer = _data.runtime.ring_radius+_half+_target_radius;
                var _inner = max(0,_data.runtime.ring_radius-_half-_target_radius);

                return _distance_sq <= _outer*_outer
                    && _distance_sq >= _inner*_inner;
            }

            var _radius = _geometry.radius+_target_radius;
            return _distance_sq <= _radius*_radius;
        }

        case AttackAreaShape.CAPSULE:
        {
            var _end_x = _area.x+lengthdir_x(_geometry.length,_data.direction);
            var _end_y = _area.y+lengthdir_y(_geometry.length,_data.direction);
            var _radius = _geometry.radius+_target_radius;

            return sc_attack_area_point_segment_distance_sq(
                _target.x,_target.y,
                _area.x,_area.y,
                _end_x,_end_y
            ) <= _radius*_radius;
        }

        case AttackAreaShape.CONE:
        {
            var _distance = point_distance(_area.x,_area.y,_target.x,_target.y);
            if (_distance > _geometry.range+_target_radius) return false;

            var _target_direction = point_direction(
                _area.x,_area.y,
                _target.x,_target.y
            );

            return abs(angle_difference(_target_direction,_data.direction))
                <= _geometry.angle*0.5;
        }
    }

    return false;
}

/// @description Returns whether an asteroid blocks a circular area from one target.
function sc_attack_area_asteroid_occluded(_area, _target)
{
    var _data = _area.attack_area;
    var _occlusion = _data.behaviour.occlusion;

    if (!_occlusion.asteroids
    || global.level.asteroids_alive <= 0)
        return false;

    var _line_x = _target.x - _area.x;
    var _line_y = _target.y - _area.y;
    var _line_length_sq =
        _line_x * _line_x
        + _line_y * _line_y;

    if (_line_length_sq <= 0.001)
        return false;

    var _asteroids = ds_list_create();

    collision_line_list(
        _area.x,
        _area.y,
        _target.x,
        _target.y,
        o_asteroid,
        false,
        true,
        _asteroids,
        false
    );

    var _blocked = false;
    var _count = ds_list_size(_asteroids);

    for (var _i = 0; _i < _count; ++_i)
    {
        var _asteroid = _asteroids[| _i];

        if (_asteroid == _target
        || !_asteroid.initialized)
            continue;

        var _relative_x =
            _asteroid.x
            - _area.x;

        var _relative_y =
            _asteroid.y
            - _area.y;

        var _progress = (
            _relative_x * _line_x
            + _relative_y * _line_y
        ) / _line_length_sq;

        // The asteroid centre must lie toward and before the target.
        if (_progress <= 0
        || _progress >= 1)
            continue;

        var _nearest_x =
            _area.x
            + _line_x * _progress;

        var _nearest_y =
            _area.y
            + _line_y * _progress;

        var _radius =
            _asteroid.asteroid.visual.radius
            * _occlusion.radius_scale;

        if (sc_point_distance_sq(
            _asteroid.x,
            _asteroid.y,
            _nearest_x,
            _nearest_y
        ) <= _radius * _radius)
        {
            _blocked = true;
            break;
        }
    }

    ds_list_destroy(_asteroids);
    return _blocked;
}

/// @description Returns an area damage packet scaled by distance and asteroid cover.
function sc_attack_area_damage_packet_get(_area, _target)
{
    var _data = _area.attack_area;

    if (_data.delivery_type == AttackDelivery.BEAM)
        return _data.damage;

    var _behaviour = _data.behaviour;
    var _multiplier = 1;

    if (_behaviour.falloff_minimum < 1)
    {
        var _distance = point_distance(
            _area.x,
            _area.y,
            _target.x,
            _target.y
        );

        var _distance_ratio = clamp(
            _distance
            / _behaviour.falloff_distance,
            0,
            1
        );

        _multiplier *= lerp(
            1,
            _behaviour.falloff_minimum,
            power(
                _distance_ratio,
                _behaviour.falloff_exponent
            )
        );
    }

    if (sc_attack_area_asteroid_occluded(
        _area,
        _target
    ))
    {
        _multiplier *=
            _behaviour
            .occlusion
            .blocked_damage_multiplier;
    }

    if (_multiplier >= 1)
        return _data.damage;

    return sc_damage_packet_scaled(
        _data.damage,
        _multiplier
    );
}

/// @description Applies one damage tick to opposing entities inside the area.
function sc_attack_area_damage_apply(_area)
{
    var _data = _area.attack_area;
    var _behaviour = _data.behaviour;
    var _source = _data.source;
    var _candidates = sc_attack_area_candidates_get(_area);
    var _count = ds_list_size(_candidates);
    var _targets_hit = 0;

    for (var _i = 0; _i < _count; ++_i)
    {
        var _target = _candidates[| _i];

        if (_target == _source.owner_id)
            continue;

        if (_target.entity.faction == _source.faction)
            continue;

        if (_behaviour.hit_once
        && sc_attack_area_target_was_hit(_data, _target))
            continue;

        if (!sc_attack_area_target_inside(_area, _target))
            continue;

        var _packet = sc_attack_area_damage_packet_get(
            _area,
            _target
        );

        var _knockback_direction = _data.direction;

        if (_data.shape == AttackAreaShape.CIRCLE)
        {
            var _dx = _target.x - _area.x;
            var _dy = _target.y - _area.y;

            if (abs(_dx) + abs(_dy) > 0.001)
            {
                _knockback_direction = point_direction(
                    0,
                    0,
                    _dx,
                    _dy
                );
            }
        }

        var _impact = {
            x: _area.x,
            y: _area.y,
            direction: _knockback_direction
        };

        var _result = _target.entity.damage_script(
            _target,
            _packet,
            _impact
        );

        if (!is_struct(_result))
            continue;
		
		sc_heat_signature_mining_try(
		    _area,
		    _target,
		    _packet
		);

        sc_entity_knockback_apply(
            _target,
            _packet.knockback_force,
            _knockback_direction
        );

        if (_behaviour.hit_once)
            array_push(
                _data.runtime.hit_ids,
                _target
            );

        ++_targets_hit;

        if (_behaviour.max_targets > 0
        && _targets_hit >= _behaviour.max_targets)
            break;
    }

    ds_list_destroy(_candidates);
    return _targets_hit;
}

/// @description Updates one ordinary area or maintained beam.
function sc_attack_area_update(_area)
{
    var _data = _area.attack_area;

    switch (_data.delivery_type)
    {
        case AttackDelivery.AREA:
            sc_attack_area_standard_update(_area, _data);
        break;

        case AttackDelivery.BEAM:
            sc_beam_update(_area, _data);
        break;
    }
}

/// @description Updates one ordinary short-lived attack area.
function sc_attack_area_standard_update(_area,_data)
{
    var _behaviour = _data.behaviour;
    var _runtime = _data.runtime;
    var _ring = _behaviour.expanding_ring;

    _runtime.elapsed++;

    if (_ring.enabled)
    {
        var _progress = clamp(
            _runtime.elapsed/_behaviour.duration,
            0,1
        );

        _runtime.ring_radius = lerp(
            _ring.start_radius,
            _data.geometry.radius,
            _progress
        );
    }

    if (_behaviour.tick_interval > 0 && GAME_TICK >= _runtime.next_damage_tick)
    {
        sc_attack_area_damage_apply(_area);
        _runtime.next_damage_tick = GAME_TICK+_behaviour.tick_interval;
    }

    if (variable_struct_exists(_data.visual,"particle_script"))
        _data.visual.particle_script(_area,_data);

    _runtime.life--;

    if (_runtime.life <= 0)
        instance_destroy(_area);
}

/// @description Returns the beam distance where the nearest opposing entity begins.
function sc_beam_entity_hit_length_get(_area, _data, _maximum_length)
{
    if (_data.behaviour.piercing) return _maximum_length;

    var _source = _data.source;
    var _runtime = _data.runtime;
    var _impact = _data.visual.impact;
    var _candidates = sc_attack_area_candidates_get(_area);
    var _count = ds_list_size(_candidates);
    var _direction_x = lengthdir_x(1, _data.direction);
    var _direction_y = lengthdir_y(1, _data.direction);
    var _closest = _maximum_length;

    for (var _i = 0; _i < _count; ++_i)
    {
        var _target = _candidates[| _i];

        if (_target == _source.owner_id
        || _target.entity.faction == _source.faction)
            continue;

        var _relative_x = _target.x - _area.x;
        var _relative_y = _target.y - _area.y;
        var _forward = _relative_x * _direction_x + _relative_y * _direction_y;

        if (_forward < 0 || _forward > _closest)
            continue;

        var _side = abs(
            _relative_x * -_direction_y
            + _relative_y * _direction_x
        );

        var _target_radius = sc_attack_area_target_radius_get(_target);
        var _combined_radius = _data.geometry.radius + _target_radius;
        if (_side > _combined_radius) continue;

        var _entry = max(
            0,
            _forward - sqrt(max(
                0,
                _combined_radius * _combined_radius
                - _side * _side
            ))
        );

        if (_entry >= _closest)
            continue;

        _closest = _entry;
        _runtime.impact_active = true;
        _runtime.impact_target_id = _target;
        _runtime.impact_overlap = min(
            _impact.overlap_max,
            _target_radius * _impact.overlap_ratio
        );
    }

    ds_list_destroy(_candidates);
    return _closest;
}

/// @description Returns the approximate beam distance to the nearest solid mask.
function sc_beam_solid_hit_length_get(_area, _data, _maximum_length)
{
    if (!_data.behaviour.blocks_on_solids) return _maximum_length;

    var _end_x = _area.x + lengthdir_x(_maximum_length, _data.direction);
    var _end_y = _area.y + lengthdir_y(_maximum_length, _data.direction);
    var _solids = ds_list_create();

    collision_line_list(
        _area.x, _area.y,
        _end_x, _end_y,
        o_solid, false, true,
        _solids, false
    );

    var _runtime = _data.runtime;
    var _impact = _data.visual.impact;
    var _count = ds_list_size(_solids);
    var _direction_x = lengthdir_x(1, _data.direction);
    var _direction_y = lengthdir_y(1, _data.direction);
    var _closest = _maximum_length;

    for (var _i = 0; _i < _count; ++_i)
    {
        var _solid = _solids[| _i];
        var _centre_x = (_solid.bbox_left + _solid.bbox_right) * 0.5;
        var _centre_y = (_solid.bbox_top + _solid.bbox_bottom) * 0.5;
        var _half_width = (_solid.bbox_right - _solid.bbox_left) * 0.5;
        var _half_height = (_solid.bbox_bottom - _solid.bbox_top) * 0.5;
        var _extent = point_distance(0, 0, _half_width, _half_height) + _data.geometry.radius;
        var _forward = (_centre_x - _area.x) * _direction_x + (_centre_y - _area.y) * _direction_y;
        var _entry = max(0, _forward - _extent);

        if (_entry >= _closest)
            continue;

        _closest = _entry;
        _runtime.impact_active = true;
        _runtime.impact_target_id = noone;
        _runtime.impact_overlap = _impact.solid_overlap;
    }

    ds_list_destroy(_solids);
    return _closest;
}

/// @description Resolves separate damaging, contact and visible beam lengths.
function sc_beam_hit_length_update(_area, _data)
{
    var _runtime = _data.runtime;
    var _length = _runtime.growth_length;

    _runtime.impact_active = false;
    _runtime.impact_target_id = noone;
    _runtime.impact_overlap = 0;

    _data.geometry.length = _length;
    _length = sc_beam_entity_hit_length_get(_area, _data, _length);
    _length = sc_beam_solid_hit_length_get(_area, _data, _length);

    _runtime.hit_length = _length;
    _runtime.contact_length = _length;
    _runtime.visual_length = _runtime.impact_active
        ? min(_runtime.growth_length, _length + _runtime.impact_overlap)
        : _length;

    _data.geometry.length = _length;
}

/// @description Draws one capsule beam through the shared layered renderer.
function sc_attack_area_beam_layered_draw(_area, _data)
{
    var _runtime = _data.runtime;
    var _length = _runtime.visual_length;
    var _end_x = _area.x + lengthdir_x(_length, _data.direction);
    var _end_y = _area.y + lengthdir_y(_length, _data.direction);

    sc_visual_beam_layered_draw(
        _area.x, _area.y,
        _end_x, _end_y,
        _data.geometry.radius,
        _data.visual.style,
        _data.visual.palette,
        _runtime.release_alpha,
        real(_area.id)
    );
}

/// @description Draws one generic white-hot flare at the beam's visual endpoint.
function sc_beam_impact_draw(_area, _data)
{
    var _runtime = _data.runtime;
    if (!_runtime.impact_active) return;

    var _impact = _data.visual.impact;
    var _palette = _data.visual.palette;
    var _alpha = _runtime.release_alpha;
    var _pulse = 0.9 + sin(GAME_TICK * 0.5) * 0.1;
    var _radius = _data.geometry.radius * _impact.radius_scale * _pulse;
    var _x = _area.x + lengthdir_x(_runtime.visual_length, _data.direction);
    var _y = _area.y + lengthdir_y(_runtime.visual_length, _data.direction);

    gpu_set_blendmode(bm_add);

    draw_set_alpha(_alpha * 0.2);
    draw_set_colour(_palette.glow);
    draw_circle(_x, _y, _radius * 2.4, false);

    draw_set_alpha(_alpha * 0.6);
    draw_set_colour(_palette.energy);
    draw_circle(_x, _y, _radius * 1.45, false);

    draw_set_alpha(_alpha);
    draw_set_colour(_palette.core);
    draw_circle(_x, _y, _radius, false);

    draw_set_colour(c_white);
    draw_circle(_x, _y, max(2, _radius * 0.45), false);

    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
    draw_set_colour(c_white);
}

/// @description Updates one maintained capsule or cone delivery.
function sc_beam_update(_area,_data)
{
    var _behaviour = _data.behaviour;
    var _runtime = _data.runtime;

    if (GAME_TICK-_runtime.refreshed_tick > 1)
        _runtime.releasing = true;

    if (_runtime.releasing)
    {
        _runtime.release_alpha -= 1/_behaviour.release_duration;

        if (_runtime.release_alpha <= 0)
            instance_destroy(_area);

        return;
    }

    if (_data.shape == AttackAreaShape.CAPSULE)
    {
        _runtime.growth_length = min(
            _runtime.maximum_length,
            _runtime.growth_length+_behaviour.growth_speed
        );

        sc_beam_hit_length_update(_area,_data);
    }

    if (GAME_TICK >= _runtime.next_damage_tick)
    {
        sc_attack_area_damage_apply(_area);
        _runtime.next_damage_tick = GAME_TICK+_behaviour.tick_interval;
    }

    if (variable_struct_exists(_data.visual,"particle_script"))
        _data.visual.particle_script(_area,_data);

    if (variable_struct_exists(_data.visual,"origin"))
        sc_particles_beam_origin_emit(_area,_data);

    if (_data.shape == AttackAreaShape.CAPSULE)
        sc_particles_beam_impact_emit(_area,_data);
}

/// @description Draws one registered short-lived attack-area visual.
function sc_attack_area_draw(_area)
{
    var _data = _area.attack_area;
    _data.visual.draw_script(_area, _data);

    if (_data.delivery_type == AttackDelivery.BEAM
    && _data.shape == AttackAreaShape.CAPSULE)
        sc_beam_impact_draw(_area, _data);

    draw_set_alpha(1);
    draw_set_colour(c_white);
    gpu_set_blendmode(bm_normal);
}