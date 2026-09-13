/*
POINT DEFENCE DRONE

Shared owner-relative patrol and hostile interceptable-projectile defence.
The behaviour is faction-neutral and can later serve enemy drone definitions.
*/

/// @description Chooses a new owner-relative patrol position.
function sc_drone_point_defence_patrol_choose(_drone)
{
    var _data = _drone.drone;
    var _movement = _data.definition.movement;
    var _runtime = _data.runtime;

    _runtime.patrol_angle = random(360);
    _runtime.patrol_distance = random_range(
        _movement.patrol_radius_min,
        _movement.patrol_radius_max
    );

    _runtime.next_reposition_tick =
        GAME_TICK
        +irandom_range(
            _movement.reposition_interval_min,
            _movement.reposition_interval_max
        );

    return true;
}

/// @description Returns whether a projectile remains a valid hostile interception target.
function sc_drone_point_defence_target_valid(_drone,_target)
{
    if (!instance_exists(_target)
    || !_target.initialized)
        return false;

    var _projectile = _target.projectile;

    if (_projectile.state != ProjectileState.ACTIVE
    || _projectile.runtime.destroyed
    || !is_struct(_projectile.defence)
    || _projectile.source.faction == _drone.entity.faction)
        return false;

    var _owner = _drone.drone.owner_id;
    var _range = _drone.drone.definition.targeting.range;

    return sc_point_distance_sq(
        _owner.x,
        _owner.y,
        _target.x,
        _target.y
    ) <= sqr(_range);
}

/// @description Finds the hostile interceptable projectile closest to the protected owner.
function sc_drone_point_defence_target_find(_drone)
{
    var _data = _drone.drone;
    var _owner = _data.owner_id;
    var _range = _data.definition.targeting.range;
    var _target = noone;
    var _best_distance_sq = sqr(_range);
    var _amount = instance_number(o_interceptable_projectile);

    for (var _i = 0; _i < _amount; ++_i)
    {
        var _candidate = instance_find(
            o_interceptable_projectile,
            _i
        );

        if (!sc_drone_point_defence_target_valid(
            _drone,
            _candidate
        ))
            continue;

        var _distance_sq = sc_point_distance_sq(
            _owner.x,
            _owner.y,
            _candidate.x,
            _candidate.y
        );

        if (_distance_sq >= _best_distance_sq)
            continue;

        _best_distance_sq = _distance_sq;
        _target = _candidate;
    }

    return _target;
}

/// @description Fires one interception round toward the selected projectile.
function sc_drone_point_defence_fire(_drone,_target)
{
    var _data = _drone.drone;
    var _weapon = _data.definition.weapon;
    var _target_data = _target.projectile;

    var _distance = point_distance(
        _drone.x,
        _drone.y,
        _target.x,
        _target.y
    );

    var _lead_time =
        _distance
        /max(1,_weapon.speed)
        *_weapon.lead_strength;

    var _target_x =
        _target.x
        +lengthdir_x(
            _target_data.movement.speed*_lead_time,
            _target_data.direction
        );

    var _target_y =
        _target.y
        +lengthdir_y(
            _target_data.movement.speed*_lead_time,
            _target_data.direction
        );

    var _direction = point_direction(
        _drone.x,
        _drone.y,
        _target_x,
        _target_y
    );

    _drone.draw_angle = _direction;

    var _delivery = {
        projectile: {
            scale: _weapon.scale,
            speed: _weapon.speed,
            life: _weapon.life
        },

        guidance: 0,
        damage: _weapon.damage
    };

    var _source = {
        owner_id: _drone,
        faction: _drone.entity.faction,
        damage_multiplier: 1
    };

    var _layer = sc_weapon_delivery_layer_get(
        _drone,
        AttackDelivery.PROJECTILE
    );

    var _projectile = sc_projectile_create(
        _weapon.projectile_key,
        _source,
        _delivery,
        _drone.x+lengthdir_x(16,_direction),
        _drone.y+lengthdir_y(16,_direction),
        _direction,
        _layer
    );

    if (!instance_exists(_projectile))
        return false;

    _data.runtime.next_fire_tick =
        GAME_TICK
        +max(1,round(_weapon.fire_interval));

    return true;
}

/// @description Sends an expired point-defence drone back to its reserved slot.
function sc_drone_point_defence_return_begin(_drone)
{
    var _data = _drone.drone;

    _data.state = DroneState.RETURNING;
    _data.target_id = noone;
    sc_player_drone_return_begin(_drone);
    return true;
}

/// @description Updates owner-relative movement, lifetime and projectile interception.
function sc_drone_point_defence_update(_drone)
{
    var _data = _drone.drone;
    var _definition = _data.definition;
    var _runtime = _data.runtime;
    var _owner = _data.owner_id;

    if (_data.state == DroneState.RETURNING)
    {
        var _return_speed =
            _data.movement.speed
            *_definition.movement.return_speed_multiplier;

        if (sc_drone_move_toward(
            _drone,
            _owner.x,
            _owner.y,
            _return_speed
        ))
        {
            sc_player_drone_return_complete(_drone);
            instance_destroy(_drone);
        }

        return true;
    }

    _runtime.life_remaining--;

    if (_runtime.life_remaining <= 0)
    {
        sc_drone_point_defence_return_begin(_drone);
        return true;
    }

    if (GAME_TICK >= _runtime.next_reposition_tick)
        sc_drone_point_defence_patrol_choose(_drone);

    var _destination_x =
        _owner.x
        +lengthdir_x(
            _runtime.patrol_distance,
            _runtime.patrol_angle
        );

    var _destination_y =
        _owner.y
        +lengthdir_y(
            _runtime.patrol_distance,
            _runtime.patrol_angle
        );

    if (point_distance(
        _drone.x,
        _drone.y,
        _destination_x,
        _destination_y
    ) > _definition.movement.arrival_radius)
    {
        sc_drone_move_toward(
            _drone,
            _destination_x,
            _destination_y,
            _data.movement.speed
        );
    }
    else
    {
        sc_drone_point_defence_patrol_choose(_drone);
    }

    if (!sc_drone_point_defence_target_valid(
        _drone,
        _data.target_id
    ))
        _data.target_id = noone;

    if (GAME_TICK >= _runtime.next_scan_tick)
    {
        _runtime.next_scan_tick =
            GAME_TICK
            +max(1,_definition.targeting.scan_interval);

        _data.target_id =
            sc_drone_point_defence_target_find(_drone);
    }

    if (instance_exists(_data.target_id))
    {
        _drone.draw_angle = point_direction(
            _drone.x,
            _drone.y,
            _data.target_id.x,
            _data.target_id.y
        );

        if (GAME_TICK >= _runtime.next_fire_tick)
            sc_drone_point_defence_fire(
                _drone,
                _data.target_id
            );
    }

    return true;
}

/// @description Draws the point-defence drone's static body for visual baking.
function sc_drone_point_defence_body_draw(_x,_y,_radius,_angle,_visual)
{
    var _palette = _visual.palette;

    gpu_set_blendmode(bm_add);
    draw_set_colour(_palette.glow);
    draw_set_alpha(0.18);
    draw_circle(_x,_y,_radius*1.55,false);
    gpu_set_blendmode(bm_normal);

    draw_set_alpha(1);
    draw_set_colour(_palette.hull_dark);
    draw_circle(_x,_y,_radius,false);

    draw_set_colour(_palette.outline);
    draw_circle(_x,_y,_radius-1,true);

    for (var _side = -1; _side <= 1; _side += 2)
    {
        sc_visual_triangle(
            _x,_y,
            _radius,_angle,
            -0.45,0.25*_side,
            0,0.92*_side,
            0.45,0.25*_side,
            _palette.hull_mid,
            false
        );
    }

    draw_set_colour(_palette.energy);
    draw_line_width(
        _x+lengthdir_x(4,_angle),
        _y+lengthdir_y(4,_angle),
        _x+lengthdir_x(18,_angle),
        _y+lengthdir_y(18,_angle),
        3
    );

    draw_set_colour(_palette.core);
    draw_circle(_x,_y,3,false);

    draw_set_alpha(1);
    draw_set_colour(c_white);
}

/// @description Draws the point-defence drone's dynamic protected radius and target.
function sc_drone_point_defence_draw(_drone)
{
    var _data = _drone.drone;
    var _definition = _data.definition;
    var _owner = _data.owner_id;
    var _palette = _definition.visual.palette;

    if (instance_exists(_owner))
    {
        var _range = _definition.targeting.range;
        var _pulse = 0.82+sin(GAME_TICK*0.05)*0.18;

        gpu_set_blendmode(bm_add);
        draw_set_colour(_palette.energy);
        draw_set_alpha(0.035*_pulse);
        draw_circle(_owner.x,_owner.y,_range,false);

        draw_set_alpha(0.13*_pulse);
        draw_circle(_owner.x,_owner.y,_range,true);

        for (var _i = 0; _i < 4; ++_i)
        {
            var _node_angle = GAME_TICK*0.08+_i*90;
            var _node_x = _owner.x+lengthdir_x(_range,_node_angle);
            var _node_y = _owner.y+lengthdir_y(_range,_node_angle);

            draw_set_alpha(0.35);
            draw_circle(_node_x,_node_y,2.5,false);
        }

        gpu_set_blendmode(bm_normal);
    }

    if (instance_exists(_data.target_id))
    {
        draw_set_colour(_palette.energy);
        draw_set_alpha(0.45);
        draw_circle(
            _data.target_id.x,
            _data.target_id.y,
            14+sin(GAME_TICK*0.18)*2,
            true
        );
    }

    draw_set_alpha(1);
    draw_set_colour(c_white);
}

/// @description Deploys the next docked physical point-defence drone.
function sc_drone_point_defence_deploy(
    _delivery,
    _source,
    _x,
    _y,
    _direction,
    _layer
)
{
    var _owner = _source.owner_id;
    var _drone_key = _delivery.drone.key;
    var _slot_index = sc_player_drone_docked_find(
        _owner,
        _drone_key
    );

    if (_slot_index < 0)
        return noone;

    var _payload = sc_player_drone_deploy_begin(
        _owner,
        _slot_index
    );

    var _drone = instance_create_layer(
        _x,
        _y,
        _layer,
        o_drone,
        {
            drone_create: {
                key: _drone_key,
                owner_id: _owner,
                slot_index: _slot_index,
                payload: _payload
            }
        }
    );

    if (!instance_exists(_drone))
    {
        sc_player_drone_deploy_cancel(
            _owner,
            _slot_index,
            _payload
        );

        return noone;
    }

    sc_player_drone_deploy_complete(
        _owner,
        _slot_index,
        _drone
    );

    var _data = _drone.drone;
    var _definition = _data.definition;

    _data.state = DroneState.WORKING;
    _data.runtime.life_remaining =
        max(1,round(_definition.lifetime.duration));

    _data.runtime.next_scan_tick = GAME_TICK;
    _data.runtime.next_fire_tick = GAME_TICK;
    _data.runtime.next_reposition_tick = GAME_TICK;
    _data.runtime.patrol_angle = random(360);

    _data.runtime.patrol_distance = random_range(
        _definition.movement.patrol_radius_min,
        _definition.movement.patrol_radius_max
    );

    return _drone;
}

/// @description Registers the player point-defence drone deployment equipment.
function sc_weapon_register_player_point_defence_drone()
{
    return sc_weapon_register({
        identity: {
            key: "equipment_point_defence_drone",
            name: "Point Defence Drone"
        },

        // Temporary free deployment until physical drone inventory is connected.
        resource: {
            type: ResourceType.ENERGY,
            cost: 0
        },

        delivery: {
            type: AttackDelivery.DEPLOYABLE,
            create_script: sc_drone_point_defence_deploy,

            drone: {
                key: "drone_player_point_defence"
            }
        },

        shot: {
            pattern: ShotPattern.SINGLE,
            amount: 1,
            angle_total: 0
        },

        firing: {
            mount_mode: WeaponMountMode.CENTRE,
            centre_forward: 0,
            interval: 60,
            recoil: 0,
            muzzle_flash_duration: 0
        },

        audio: {
            sound: noone,
            volume: 0,
            pitch_range: 0
        }
    });
}