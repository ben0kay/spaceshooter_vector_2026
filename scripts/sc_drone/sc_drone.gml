/*
DRONE RUNTIME

The generic drone object resolves a registered definition and delegates
role-specific behaviour through update and draw callbacks.
*/

/// @description Initializes one deployed registered drone.
function sc_drone_init(_drone,_create)
{
    if (!is_struct(_create)
    || !variable_struct_exists(_create,"key")
    || !variable_struct_exists(global.data.drones,_create.key)
    || !instance_exists(_create.owner_id))
        return false;

    var _definition = variable_struct_get(
        global.data.drones,
        _create.key
    );

    _drone.draw_angle = 0;

    _drone.drone = {
        key: _create.key,
        definition: _definition,
        role: _definition.role,
        state: DroneState.TRAVELLING,

        owner_id: _create.owner_id,
        target_id: variable_struct_exists(_create,"target_id")
            ? _create.target_id
            : noone,

        movement: {
            speed: _definition.movement.speed
        },

        runtime: {
            cleaned: false
        }
    };

    return true;
}

/// @description Moves one drone toward a world position.
function sc_drone_move_toward(_drone,_x,_y,_speed)
{
    var _distance = point_distance(
        _drone.x,
        _drone.y,
        _x,
        _y
    );

    if (_distance <= _speed)
    {
        _drone.x = _x;
        _drone.y = _y;
        return true;
    }

    var _direction = point_direction(
        _drone.x,
        _drone.y,
        _x,
        _y
    );

    _drone.x += lengthdir_x(_speed,_direction);
    _drone.y += lengthdir_y(_speed,_direction);
    _drone.draw_angle = _direction;
    return false;
}

/// @description Updates one generic drone through its registered behaviour.
function sc_drone_update(_drone)
{
    var _data = _drone.drone;

    if (!instance_exists(_data.owner_id))
    {
        instance_destroy(_drone);
        return false;
    }

    return _data.definition.behaviour.update_script(
        _drone
    );
}

/// @description Draws one generic drone through its registered behaviour.
function sc_drone_draw(_drone)
{
    _drone.drone.definition.behaviour.draw_script(
        _drone
    );
}

/// @description Sends one scanner drone back to its owner.
function sc_drone_scanner_return_begin(_drone)
{
    var _data = _drone.drone;
    _data.state = DroneState.RETURNING;

    if (instance_exists(_data.target_id))
    {
        var _runtime = _data.target_id.derelict;

        if (_runtime.state == DerelictState.SCANNING)
        {
            _runtime.state = DerelictState.UNKNOWN;
            _runtime.scan_progress = 0;
        }

        _runtime.scanner_id = noone;
    }

    return true;
}

/// @description Updates one derelict scanner drone.
function sc_drone_scanner_update(_drone)
{
    var _data = _drone.drone;
    var _definition = _data.definition;
    var _speed = _data.movement.speed;

    if (_data.state != DroneState.RETURNING
    && !instance_exists(_data.target_id))
    {
        sc_drone_scanner_return_begin(_drone);
        return false;
    }

    switch (_data.state)
    {
        case DroneState.TRAVELLING:
        {
            var _target = _data.target_id;
            var _distance = _target.structure.data.derelict.scan_distance;
            var _direction = point_direction(
                _target.x,
                _target.y,
                _drone.x,
                _drone.y
            );

            var _destination_x =
                _target.x
                +lengthdir_x(_distance,_direction);

            var _destination_y =
                _target.y
                +lengthdir_y(_distance,_direction);

            if (sc_drone_move_toward(
                _drone,
                _destination_x,
                _destination_y,
                _speed
            ))
                _data.state = DroneState.WORKING;
        }
        break;

        case DroneState.WORKING:
        {
            var _target = _data.target_id;
            var _owner = _data.owner_id;
            var _derelict = _target.structure.data.derelict;

            if (sc_point_distance_sq(
                _owner.x,
                _owner.y,
                _target.x,
                _target.y
            ) > sqr(_derelict.tether_range))
            {
                sc_drone_scanner_return_begin(_drone);
                break;
            }

            _drone.draw_angle = point_direction(
                _drone.x,
                _drone.y,
                _target.x,
                _target.y
            );

            _target.derelict.scan_progress++;

            if (_target.derelict.scan_progress
            >= _target.derelict.scan_duration)
            {
                _target.derelict.scan_progress =
                    _target.derelict.scan_duration;

                _target.derelict.state =
                    DerelictState.REVEALED;

                _target.derelict.scanner_id = noone;
                _data.state = DroneState.RETURNING;
            }
        }
        break;

        case DroneState.RETURNING:
        {
            var _owner = _data.owner_id;
            var _return_speed =
                _speed
                *_definition.movement.return_speed_multiplier;

            if (sc_drone_move_toward(
                _drone,
                _owner.x,
                _owner.y,
                _return_speed
            ))
                instance_destroy(_drone);
        }
        break;
    }

    return true;
}

/// @description Draws one scanner drone and its active scanning field.
function sc_drone_scanner_draw(_drone)
{
    var _data = _drone.drone;
    var _angle = _drone.draw_angle;
    var _aqua = make_colour_rgb(0,225,240);
    var _core = make_colour_rgb(185,255,255);

    if (_data.state == DroneState.WORKING
    && instance_exists(_data.target_id))
    {
        var _target = _data.target_id;
        var _direction = point_direction(
            _drone.x,
            _drone.y,
            _target.x,
            _target.y
        );

        var _half_width = 82;

        var _end_x1 =
            _target.x
            +lengthdir_x(_half_width,_direction-90);

        var _end_y1 =
            _target.y
            +lengthdir_y(_half_width,_direction-90);

        var _end_x2 =
            _target.x
            +lengthdir_x(_half_width,_direction+90);

        var _end_y2 =
            _target.y
            +lengthdir_y(_half_width,_direction+90);

        draw_set_colour(_aqua);
        draw_set_alpha(0.08);

        draw_triangle(
            _drone.x,
            _drone.y,
            _end_x1,
            _end_y1,
            _end_x2,
            _end_y2,
            false
        );

        draw_set_alpha(0.5);
        draw_line_width(
            _drone.x,
            _drone.y,
            _end_x1,
            _end_y1,
            1
        );

        draw_line_width(
            _drone.x,
            _drone.y,
            _end_x2,
            _end_y2,
            1
        );

        for (var _i = 0; _i < 5; ++_i)
        {
            var _phase = frac(
                GAME_TICK*0.012
                +_i/5
            );

            var _centre_x = lerp(
                _drone.x,
                _target.x,
                _phase
            );

            var _centre_y = lerp(
                _drone.y,
                _target.y,
                _phase
            );

            var _width = lerp(
                5,
                _half_width,
                _phase
            );

            draw_set_alpha((1-_phase)*0.75);

            draw_line_width(
                _centre_x+lengthdir_x(_width,_direction-90),
                _centre_y+lengthdir_y(_width,_direction-90),
                _centre_x+lengthdir_x(_width,_direction+90),
                _centre_y+lengthdir_y(_width,_direction+90),
                2
            );
        }
    }

    draw_set_alpha(1);
    draw_set_colour(make_colour_rgb(12,35,42));
    draw_circle(_drone.x,_drone.y,13,false);

    draw_set_colour(_aqua);
    draw_circle(_drone.x,_drone.y,11,true);

    draw_line_width(
        _drone.x+lengthdir_x(7,_angle),
        _drone.y+lengthdir_y(7,_angle),
        _drone.x+lengthdir_x(17,_angle),
        _drone.y+lengthdir_y(17,_angle),
        3
    );

    draw_set_colour(_core);
    draw_circle(_drone.x,_drone.y,3,false);

    draw_set_alpha(1);
    draw_set_colour(c_white);
}