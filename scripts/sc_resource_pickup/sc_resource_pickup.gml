/*
GENERIC WORLD RESOURCE PICKUP

One object supports every cargo resource.
Pickups drift outward, attract to the player and remain when cargo is full.
*/

/// @description Creates one drifting resource pickup with optional launch control.
function sc_resource_pickup_spawn(
    _x,
    _y,
    _layer,
    _item_key,
    _amount,
    _launch = undefined,
    _grade = undefined
)
{
    if (_amount <= 0
    || !variable_struct_exists(global.data.items, _item_key))
        return noone;

    var _config = GCFG.asteroid.pickup;
    var _direction = random(360);
    var _speed_multiplier = 1;
	var _lifetime_multiplier = 1;

    if (is_struct(_launch))
    {
        if (variable_struct_exists(_launch, "direction"))
            _direction = _launch.direction;

        if (variable_struct_exists(_launch, "speed_multiplier"))
            _speed_multiplier = max(0, _launch.speed_multiplier);
		
		if (variable_struct_exists(_launch, "lifetime_multiplier"))
			_lifetime_multiplier = max(1, _launch.lifetime_multiplier);
    }

    var _speed = random_range(
        _config.launch_speed_min,
        _config.launch_speed_max
    ) * _speed_multiplier;

    return instance_create_layer(_x, _y, _layer, o_resource_pickup, {
        resource_pickup_create: {
            item_key: _item_key,
            grade: _grade,
            amount: max(1, floor(_amount)),
            velocity_x: lengthdir_x(_speed, _direction),
            velocity_y: lengthdir_y(_speed, _direction),
			lifetime_multiplier: _lifetime_multiplier,
        }
    });
}

/// @description Initializes one generic resource pickup.
function sc_resource_pickup_init(_pickup, _create)
{
    if (!is_struct(_create)
    || !variable_struct_exists(global.data.items, _create.item_key))
        return false;

    var _item = variable_struct_get(
        global.data.items,
        _create.item_key
    );

    var _grade = undefined;

    if (sc_item_grade_supported(_item))
    {
        _grade = is_undefined(_create.grade)
            ? ItemGrade.COMMON
            : _create.grade;
    }

    var _config = GCFG.asteroid.pickup;

    _pickup.resource_pickup = {
        item_key: _create.item_key,
        grade: _grade,
        amount: max(1, floor(_create.amount)),
        velocity_x: _create.velocity_x,
        velocity_y: _create.velocity_y,
        variant: irandom(3),
        phase: random(360),
        spin_speed: random_range(-0.9, 0.9),
        attraction_tick: GAME_TICK + _config.attraction_delay,
        expire_tick: GAME_TICK + round(
	    _config.lifetime * _create.lifetime_multiplier
	),
        full_feedback_tick: 0,
    };

    _pickup.initialized = true;
    return true;
}

/// @description Periodically merges one pickup with a nearby matching pickup.
function sc_resource_pickup_merge_update(_pickup)
{
    var _config = GCFG.asteroid.pickup;
    var _data = _pickup.resource_pickup;

    if (_data.amount >= _config.merge_amount_max
    || instance_number(o_resource_pickup) <= 1
    || !sc_update_due(_pickup, _config.merge_interval))
        return false;

    var _target = noone;
    var _distance_best = sqr(_config.merge_range);
    var _count = instance_number(o_resource_pickup);

    for (var _i = 0; _i < _count; _i++)
    {
        var _other = instance_find(o_resource_pickup, _i);

        if (!instance_exists(_other)
        || _other == _pickup
        || _other.id <= _pickup.id
        || !_other.initialized
        || _other.resource_pickup.item_key != _data.item_key
        || _other.resource_pickup.grade != _data.grade)
            continue;

        var _dx = _other.x - _pickup.x;
        var _dy = _other.y - _pickup.y;
        var _distance_squared = _dx * _dx + _dy * _dy;

        if (_distance_squared <= _distance_best)
        {
            _distance_best = _distance_squared;
            _target = _other;
        }
    }

    if (!instance_exists(_target)) return false;

    var _target_data = _target.resource_pickup;
    var _space = _config.merge_amount_max - _data.amount;
    var _moved = min(_space, _target_data.amount);

    if (_moved <= 0) return false;

    var _combined = _data.amount + _moved;

    // Retain a weighted portion of both pickups' momentum.
    _data.velocity_x = (
        _data.velocity_x * _data.amount
        + _target_data.velocity_x * _moved
    ) / _combined;

    _data.velocity_y = (
        _data.velocity_y * _data.amount
        + _target_data.velocity_y * _moved
    ) / _combined;

    _data.amount = _combined;
	_data.expire_tick = max(
        _data.expire_tick,
        _target_data.expire_tick
    );
    _target_data.amount -= _moved;

    if (_target_data.amount <= 0)
        instance_destroy(_target);

    return true;
}

/// @description Moves, merges, attracts and attempts to collect one resource pickup.
function sc_resource_pickup_update(_pickup)
{
    var _data = _pickup.resource_pickup;
    var _config = GCFG.asteroid.pickup;

    if (GAME_TICK >= _data.expire_tick)
    {
        instance_destroy(_pickup);
        return;
    }

    _pickup.x += _data.velocity_x;
    _pickup.y += _data.velocity_y;

    sc_particles_resource_pickup_trail_emit(_pickup);

    _data.velocity_x *= _config.movement_decay;
    _data.velocity_y *= _config.movement_decay;

    sc_resource_pickup_merge_update(_pickup);

    if (!instance_exists(global.player_id)
    || global.PlayerState == PlayerState.DESTROYED)
        return;

    var _player = global.player_id;
    var _dx = _player.x - _pickup.x;
    var _dy = _player.y - _pickup.y;
    var _distance_squared = _dx * _dx + _dy * _dy;

    if (_distance_squared <= sqr(_config.collect_range))
    {
        var _result = sc_player_inventory_add(
            _player,
            _data.item_key,
            _data.amount,
            _data.grade
        );

        if (_result.accepted > 0)
        {
            sc_player_statistics_resource_collected(
                _data.item_key,
                _result.accepted
            );

            var _item = variable_struct_get(
                global.data.items,
                _data.item_key
            );

            var _colour = is_undefined(_data.grade)
                ? _item.visual.colour
                : sc_item_grade_colour_get(_data.grade);

            sc_world_feedback_create(
                _player.x + random_range(-20, 20),
                _player.y - 36 + random_range(-8, 8),
                _player.layer,
                "+" + string(_result.accepted)
                    + " " + string_upper(_item.identity.name),
                _colour,
                0.9
            );
        }

        _data.amount = _result.remaining;

        if (_result.accepted <= 0
        && sc_timer_ready(_data.full_feedback_tick))
        {
            sc_world_feedback_create(
                _player.x,
                _player.y - 48,
                _player.layer,
                "CARGO FULL",
                make_colour_rgb(255, 110, 80),
                0.9
            );

            _data.full_feedback_tick = sc_timer_after(90);
        }

        if (_data.amount <= 0)
            instance_destroy(_pickup);

        return;
    }

    if (GAME_TICK < _data.attraction_tick
    || _distance_squared > sqr(_config.attraction_range))
        return;

    var _distance = sqrt(_distance_squared);
    var _proximity = 1 - clamp(
        _distance / _config.attraction_range,
        0,
        1
    );

    var _strength = lerp(
        _config.attraction_strength_min,
        _config.attraction_strength_max,
        _proximity
    );

    var _direction = point_direction(
        _pickup.x,
        _pickup.y,
        _player.x,
        _player.y
    );

    _data.velocity_x += lengthdir_x(
        _strength,
        _direction
    );

    _data.velocity_y += lengthdir_y(
        _strength,
        _direction
    );

    var _speed = point_distance(
        0,
        0,
        _data.velocity_x,
        _data.velocity_y
    );

    if (_speed > _config.attraction_speed_max)
    {
        _data.velocity_x = lengthdir_x(
            _config.attraction_speed_max,
            _direction
        );

        _data.velocity_y = lengthdir_y(
            _config.attraction_speed_max,
            _direction
        );
    }
}

/// @description Draws one cached pickup with quantity scaling and lifetime fading.
function sc_resource_pickup_draw(_pickup)
{
    var _data = _pickup.resource_pickup;
    var _config = GCFG.asteroid.pickup;

    var _sprite = sc_resource_pickup_visual_cache_get(
        _data.item_key,
        _data.variant
    );

    var _time = GAME_TICK + _data.phase;
    var _bob = sin(_time * 0.055) * 2;
    var _angle = _data.phase + GAME_TICK * _data.spin_speed;

    var _quantity_growth =
        ln(max(1, _data.amount))
        / ln(10)
        * _config.scale_per_decade;

    var _scale = min(
        _config.scale_max,
        _config.scale_base + _quantity_growth
    );

    var _pulse = 0.97 + sin(_time * 0.09) * 0.03;
    var _remaining = max(0, _data.expire_tick - GAME_TICK);

    var _alpha = _remaining < _config.fade_duration
        ? _remaining / max(1, _config.fade_duration)
        : 1;

    draw_sprite_ext(
        _sprite,
        0,
        _pickup.x,
        _pickup.y + _bob,
        _scale * _pulse,
        _scale * _pulse,
        _angle,
        c_white,
        _alpha
    );
}

/// @description Registers the shared world-item motion trail.
function sc_particles_resource_pickup_register()
{
    var _trail = sc_particles_type_create();
    if (!part_type_exists(_trail)) return false;

    part_type_sprite(_trail, s_blur, false, false, false);
    part_type_size(_trail, 0.07, 0.13, -0.003, 0.01);
    part_type_alpha3(_trail, 0.55, 0.25, 0);
    part_type_speed(_trail, 0.1, 0.45, -0.015, 0);
    part_type_direction(_trail, 0, 359, 0, 0);
    part_type_life(_trail, 8, 14);
    part_type_blend(_trail, true);

    return sc_particles_group_register(
        "resource_pickup",
        { trail: _trail }
    );
}

/// @description Emits one grade-coloured trail particle behind a moving pickup.
function sc_particles_resource_pickup_trail_emit(_pickup)
{
    var _data = _pickup.resource_pickup;
    var _config = GCFG.asteroid.pickup;

    if (!sc_update_due(_pickup, _config.trail_interval))
    return;

    var _speed = point_distance(
        0,
        0,
        _data.velocity_x,
        _data.velocity_y
    );

    if (_speed < _config.trail_speed_min
    || !sc_optimization_circle_visible(
        _pickup.x,
        _pickup.y,
        32,
        64
    ))
        return;

    var _group = sc_particles_group_get("resource_pickup");
    if (!is_struct(_group)) return;

    var _colour = is_undefined(_data.grade)
        ? c_white
        : sc_item_grade_colour_get(_data.grade);

    var _direction = point_direction(
        0,
        0,
        _data.velocity_x,
        _data.velocity_y
    );

    var _x = _pickup.x - lengthdir_x(10, _direction);
    var _y = _pickup.y - lengthdir_y(10, _direction);

    part_type_colour3(
        _group.trail,
        _colour,
        _colour,
        c_white
    );

    part_type_direction(
        _group.trail,
        _direction + 165,
        _direction + 195,
        0,
        0
    );

    part_particles_create(
        global.particles.system,
        _x,
        _y,
        _group.trail,
        1
    );
}