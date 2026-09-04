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
        phase: random(360)
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
        var _result = sc_player_inventory_add(_player, _data.item_key, _data.amount);
        _data.amount = _result.remaining;

        if (_data.amount <= 0)
            instance_destroy(_pickup);

        return;
    }

    if (_distance_squared > sqr(_config.attraction_range)) return;

    var _direction = point_direction(_pickup.x, _pickup.y, _player.x, _player.y);
    _data.velocity_x += lengthdir_x(_config.attraction_strength, _direction);
    _data.velocity_y += lengthdir_y(_config.attraction_strength, _direction);

    var _speed = point_distance(0, 0, _data.velocity_x, _data.velocity_y);

    if (_speed > _config.attraction_speed_max)
    {
        _data.velocity_x = lengthdir_x(_config.attraction_speed_max, _direction);
        _data.velocity_y = lengthdir_y(_config.attraction_speed_max, _direction);
    }
}

/// @description Draws one resource pickup using its registered item colours.
function sc_resource_pickup_draw(_pickup)
{
    var _data = _pickup.resource_pickup;
    var _definition = variable_struct_get(global.data.items, _data.item_key);
    var _visual = _definition.visual;
    var _bob = sin((GAME_TICK + _data.phase) * 0.08) * 2;
    var _size = 7 + min(3, _data.amount * 0.35);

    draw_set_blend_mode(bm_add);
    draw_set_colour(_visual.glow);
    draw_set_alpha(0.18);
    draw_circle(_pickup.x, _pickup.y + _bob, _size * 2.2, false);

    draw_set_alpha(0.45);
    draw_circle(_pickup.x, _pickup.y + _bob, _size * 1.45, false);

    draw_set_blend_mode(bm_normal);
    draw_set_colour(_visual.colour);
    draw_set_alpha(0.95);
    draw_circle(_pickup.x, _pickup.y + _bob, _size, false);

    draw_set_colour(c_white);
    draw_set_alpha(0.8);
    draw_circle(_pickup.x - _size * 0.2, _pickup.y + _bob - _size * 0.2, _size * 0.32, false);

    draw_set_alpha(1);
    draw_set_colour(c_white);
}