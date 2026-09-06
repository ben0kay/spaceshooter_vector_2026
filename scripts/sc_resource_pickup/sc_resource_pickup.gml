/*
GENERIC WORLD RESOURCE PICKUP

One object supports every cargo resource.
Pickups drift outward, attract to the player and remain when cargo is full.
*/

/// @description Creates one drifting resource pickup.
function sc_resource_pickup_spawn(_x, _y, _layer, _item_key, _amount)
{
    if (_amount <= 0 || !variable_struct_exists(global.data.items, _item_key))
        return noone;

    var _config = global.config.asteroid.pickup;
    var _direction = random(360);
    var _speed = random_range(_config.launch_speed_min, _config.launch_speed_max);

    return instance_create_layer(_x, _y, _layer, o_resource_pickup, {
        resource_pickup_create: {
            item_key: _item_key,
            amount: max(1, floor(_amount)),
            velocity_x: lengthdir_x(_speed, _direction),
            velocity_y: lengthdir_y(_speed, _direction)
        }
    });
}

/// @description Initializes one generic resource pickup.
function sc_resource_pickup_init(_pickup, _create)
{
    if (!is_struct(_create)
    || !variable_struct_exists(global.data.items, _create.item_key))
        return false;

    _pickup.resource_pickup = {
        item_key: _create.item_key,
        amount: max(1, floor(_create.amount)),
        velocity_x: _create.velocity_x,
        velocity_y: _create.velocity_y,
        variant: irandom(3),
        phase: random(360),
        spin_speed: random_range(-0.9, 0.9),
		full_feedback_tick: 0
    };

    _pickup.initialized = true;
    return true;
}

/// @description Moves, attracts and attempts to collect one resource pickup.
function sc_resource_pickup_update(_pickup)
{
    var _data = _pickup.resource_pickup;
    var _config = global.config.asteroid.pickup;

    _pickup.x += _data.velocity_x;
    _pickup.y += _data.velocity_y;
    _data.velocity_x *= _config.movement_decay;
    _data.velocity_y *= _config.movement_decay;

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
            _data.amount
        );

        if (_result.accepted > 0)
        {
            var _item = variable_struct_get(
                global.data.items,
                _data.item_key
            );

            sc_world_feedback_create(
                _player.x + random_range(-20, 20),
                _player.y - 36 + random_range(-8, 8),
                _player.layer,
                "+" + string(_result.accepted)
                    + " " + string_upper(_item.identity.name),
                _item.visual.colour,
                0.75
            );
        }

        _data.amount = _result.remaining;
		
		if (_result.accepted <= 0
			&& GAME_TICK >= _data.full_feedback_tick)
			{
			    sc_world_feedback_create(
			        _player.x,
			        _player.y - 48,
			        _player.layer,
			        "CARGO FULL",
			        make_colour_rgb(255, 110, 80),
			        0.75
			    );

			    _data.full_feedback_tick =
			        GAME_TICK + 90;
			}

        if (_data.amount <= 0)
            instance_destroy(_pickup);

        return;
    }

    if (_distance_squared > sqr(_config.attraction_range))
        return;

    var _direction = point_direction(
        _pickup.x,
        _pickup.y,
        _player.x,
        _player.y
    );

    _data.velocity_x +=
        lengthdir_x(
            _config.attraction_strength,
            _direction
        );

    _data.velocity_y +=
        lengthdir_y(
            _config.attraction_strength,
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
        _data.velocity_x =
            lengthdir_x(
                _config.attraction_speed_max,
                _direction
            );

        _data.velocity_y =
            lengthdir_y(
                _config.attraction_speed_max,
                _direction
            );
    }
}

/// @description Draws one cached rotating ore fragment.
function sc_resource_pickup_draw(_pickup)
{
    var _data = _pickup.resource_pickup;
    var _sprite = sc_resource_pickup_visual_cache_get(
        _data.item_key,
        _data.variant
    );

    var _time = GAME_TICK + _data.phase;
    var _bob = sin(_time * 0.055) * 2;
    var _angle = _data.phase + GAME_TICK * _data.spin_speed;
    var _scale = 0.82 + min(0.28, _data.amount * 0.025);
    var _pulse = 0.97 + sin(_time * 0.09) * 0.03;

    draw_sprite_ext(
        _sprite,
        0,
        _pickup.x,
        _pickup.y + _bob,
        _scale * _pulse,
        _scale * _pulse,
        _angle,
        c_white,
        1
    );
}