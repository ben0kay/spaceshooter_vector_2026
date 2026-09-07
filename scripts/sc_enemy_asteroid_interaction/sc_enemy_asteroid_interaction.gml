/// @description Returns the first obstacle blocking a ship-sized movement corridor.
function sc_enemy_obstacle_route_probe(_enemy,_direction,_distance,_include_asteroids)
{
    var _data=_enemy.enemy;
    var _config=global.config.enemy.asteroid;
    var _clearance=max(
        _data.collision.radius_forward,
        _data.collision.radius_side
    )+_config.clearance_margin;

    var _spacing=max(12,_clearance*_config.sample_spacing_scale);
    var _start=max(8,_clearance*0.65);

    for (var _distance_current=_start; _distance_current<=_distance; _distance_current+=_spacing)
    {
        var _x=_enemy.x+lengthdir_x(_distance_current,_direction);
        var _y=_enemy.y+lengthdir_y(_distance_current,_direction);
        var _solid=collision_circle(_x,_y,_clearance,o_solid,false,true);

        if (instance_exists(_solid))
            return _solid;

        if (_include_asteroids)
        {
            var _asteroid=collision_circle(_x,_y,_clearance,o_asteroid,false,true);

            if (instance_exists(_asteroid))
                return _asteroid;
        }
    }

    return noone;
}

/// @description Returns whether one obstacle is an asteroid.
function sc_enemy_obstacle_is_asteroid(_obstacle)
{
    return instance_exists(_obstacle)
        && _obstacle.object_index==o_asteroid;
}

/// @description Stops an enemy movement command without changing its strategic target.
function sc_enemy_obstacle_stop(_enemy)
{
    var _command=_enemy.enemy.movement.command;
    _command.active=false;
    _command.apply_friction=true;
}

/// @description Chooses and caches a clear direction around nearby obstacles.
function sc_enemy_obstacle_avoid_direction_select(_enemy,_desired_direction,_look_ahead,_include_asteroids)
{
    var _data=_enemy.enemy;
    var _runtime=_data.movement.obstacle;
    var _config=global.config.enemy.asteroid;
    var _angles=_config.candidate_angles;
    var _selected_direction=0;
    var _selected_side=0;
    var _selected_score=infinity;

    for (var _i=0; _i<array_length(_angles); ++_i)
    {
        var _offset=_angles[_i];
        var _direction=_desired_direction+_offset;

        if (instance_exists(sc_enemy_obstacle_route_probe(
            _enemy,
            _direction,
            _look_ahead,
            _include_asteroids
        )))
            continue;

        var _side=sign(_offset);
        var _score=abs(_offset);

        if (_runtime.side!=0 && _side!=_runtime.side)
            _score+=_config.side_switch_penalty;

        if (_score>=_selected_score)
            continue;

        _selected_score=_score;
        _selected_direction=_direction;
        _selected_side=_side;
    }

    if (_selected_score==infinity)
        return false;

    _runtime.active=true;
    _runtime.direction=_selected_direction;
    _runtime.side=_selected_side;

    _data.movement.command.direction=_selected_direction;
    return true;
}

/// @description Separates an enemy from an obstacle only after an overlap occurs.
function sc_enemy_obstacle_overlap_resolve(_enemy,_include_asteroids)
{
    _enemy.image_angle=_enemy.draw_angle;

    var _obstacle=instance_place(_enemy.x,_enemy.y,o_solid);

    if (!instance_exists(_obstacle) && _include_asteroids)
        _obstacle=instance_place(_enemy.x,_enemy.y,o_asteroid);

    if (!instance_exists(_obstacle))
        return false;

    var _movement=_enemy.enemy.movement;
    var _normal;

    if (point_distance(_obstacle.x,_obstacle.y,_enemy.x,_enemy.y)>0.01)
        _normal=point_direction(_obstacle.x,_obstacle.y,_enemy.x,_enemy.y);
    else if (abs(_movement.velocity_x)+abs(_movement.velocity_y)>0.01)
        _normal=point_direction(0,0,-_movement.velocity_x,-_movement.velocity_y);
    else
        _normal=_enemy.draw_angle+180;

    for (var _i=0; _i<128; ++_i)
    {
        _enemy.x+=lengthdir_x(2,_normal);
        _enemy.y+=lengthdir_y(2,_normal);

        var _solid_overlap=place_meeting(_enemy.x,_enemy.y,o_solid);
        var _asteroid_overlap=_include_asteroids
            && place_meeting(_enemy.x,_enemy.y,o_asteroid);

        if (!_solid_overlap && !_asteroid_overlap)
        {
            _movement.velocity_x=0;
            _movement.velocity_y=0;
            return true;
        }
    }

    _movement.velocity_x=0;
    _movement.velocity_y=0;
    return true;
}

/// @description Returns whether an enemy is committed to destroying a blocking asteroid.
function sc_enemy_asteroid_destroy_active(_enemy)
{
    var _data=_enemy.enemy;
    var _runtime=_data.movement.obstacle;

    return _data.movement_controller.asteroid_response==AsteroidResponse.DESTROY
        && _runtime.active
        && sc_enemy_obstacle_is_asteroid(_runtime.target_id);
}

/// @description Stops at an asteroid while periodically checking whether its combat target is visible.
function sc_enemy_asteroid_destroy_hold(_enemy)
{
    var _data=_enemy.enemy;
    var _runtime=_data.movement.obstacle;
    var _movement=_data.movement;
    var _command=_movement.command;
    var _target=_runtime.target_id;

    if (!sc_enemy_obstacle_is_asteroid(_target))
        return false;

    var _config=global.config.enemy.asteroid;

    if (GAME_TICK>=_runtime.next_check_tick)
    {
        var _lazy=_data.optimization.lazy_factor;
        _runtime.next_check_tick=GAME_TICK+max(
            1,
            round(_config.destroy_visibility_interval*_lazy)
        );

        if (instance_exists(_data.target_id)
        && sc_enemy_attack_line_of_sight_clear_to(_enemy,_data.target_id))
        {
            sc_enemy_attack_cancel(_enemy);
            _runtime.active=false;
            _runtime.target_id=noone;
            return false;
        }
    }

    sc_enemy_obstacle_stop(_enemy);

    _movement.velocity_x*=0.55;
    _movement.velocity_y*=0.55;

    _command.facing_mode=EnemyFacingMode.COMMAND;
    _command.face_direction=point_direction(
        _enemy.x,
        _enemy.y,
        _target.x,
        _target.y
    );

    return true;
}

/// @description Applies navigation behaviour around structures and asteroids.
function sc_enemy_obstacle_response_apply(_enemy)
{
    var _data=_enemy.enemy;
    var _command=_data.movement.command;
    var _movement=_data.movement;
    var _runtime=_movement.obstacle;
    var _response=_data.movement_controller.asteroid_response;
    var _include_asteroids=_response!=AsteroidResponse.IGNORE;

    if (_runtime.active
    && sc_enemy_obstacle_is_asteroid(_runtime.target_id)
    && _response==AsteroidResponse.DESTROY)
    {
        if (instance_exists(_runtime.target_id))
        {
            sc_enemy_asteroid_destroy_hold(_enemy);
            return;
        }

        sc_enemy_attack_cancel(_enemy);
        _runtime.active=false;
        _runtime.target_id=noone;
    }

    var _speed=point_distance(
        0,0,
        _movement.velocity_x,
        _movement.velocity_y
    );

    if (!_command.active && _speed<=0.01)
    {
        _runtime.active=false;
        _runtime.target_id=noone;
        return;
    }

    if (GAME_TICK<_runtime.next_check_tick)
    {
        if (!_runtime.active)
            return;

        var _target_is_asteroid=sc_enemy_obstacle_is_asteroid(
            _runtime.target_id
        );

        if (_target_is_asteroid
        && _response!=AsteroidResponse.AVOID)
            sc_enemy_obstacle_stop(_enemy);
        else if (_command.active)
            _command.direction=_runtime.direction;

        return;
    }

    var _config=global.config.enemy.asteroid;
    var _lazy=_data.optimization.lazy_factor;

    _runtime.next_check_tick=GAME_TICK+max(
        1,
        round(_config.check_interval*_lazy)
    );

    if (sc_enemy_obstacle_overlap_resolve(_enemy,_include_asteroids))
    {
        _runtime.active=false;
        _runtime.target_id=noone;
        return;
    }

    var _clearance=max(
        _data.collision.radius_forward,
        _data.collision.radius_side
    )+_config.clearance_margin;

    var _look_ahead=_clearance
        +_config.look_ahead_base
        +_speed*_config.look_ahead_speed;

    var _desired_direction=_command.active
        ? _command.direction
        : point_direction(
            0,0,
            _movement.velocity_x,
            _movement.velocity_y
        );

    var _obstacle=sc_enemy_obstacle_route_probe(
        _enemy,
        _desired_direction,
        _look_ahead,
        _include_asteroids
    );

    if (!instance_exists(_obstacle))
    {
        _runtime.active=false;
        _runtime.target_id=noone;
        _runtime.direction=_desired_direction;
        return;
    }

    _runtime.active=true;
    _runtime.target_id=_obstacle;

    var _target_is_asteroid=sc_enemy_obstacle_is_asteroid(_obstacle);

    if (!_command.active)
    {
        _movement.velocity_x=0;
        _movement.velocity_y=0;

        if (!_target_is_asteroid
        || _response!=AsteroidResponse.DESTROY)
        {
            _runtime.active=false;
            _runtime.target_id=noone;
        }

        return;
    }

    if (!_target_is_asteroid)
    {
        if (!sc_enemy_obstacle_avoid_direction_select(
            _enemy,
            _desired_direction,
            _look_ahead,
            _include_asteroids
        ))
            sc_enemy_obstacle_stop(_enemy);

        return;
    }

    switch (_response)
    {
        case AsteroidResponse.AVOID:
            if (!sc_enemy_obstacle_avoid_direction_select(
                _enemy,
                _desired_direction,
                _look_ahead,
                true
            ))
                sc_enemy_obstacle_stop(_enemy);
        break;

        case AsteroidResponse.STOP:
            sc_enemy_obstacle_stop(_enemy);
        break;

        case AsteroidResponse.DESTROY:
            sc_enemy_attack_cancel(_enemy);
            sc_enemy_asteroid_destroy_hold(_enemy);
        break;
    }
}