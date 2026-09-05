/// @description Updates player movement, hardpoint and dash-ghost runtime.
function sc_player_movement_runtime_update(_player)
{
    var _hardpoints = _player.ship.hardpoints.primary;

    for (var _i = 0; _i < array_length(_hardpoints); _i++)
    {
        var _runtime = _hardpoints[_i].runtime;

        if (_runtime.recoil > 0.01)
            _runtime.recoil = lerp(_runtime.recoil, 0, 0.28);
        else
            _runtime.recoil = 0;

        if (_runtime.muzzle_flash > 0)
            _runtime.muzzle_flash--;
    }

    var _dash = _player.movement.dash;

    if (_dash.cooldown_remaining > 0) _dash.cooldown_remaining--;
    if (_dash.double_tap_remaining > 0) _dash.double_tap_remaining--;

    var _write = 0;

    for (var _i = 0; _i < _dash.ghost_count; _i++)
    {
        var _ghost = _dash.ghosts[_i];
        _ghost.life--;

        if (_ghost.life <= 0) continue;

        _dash.ghosts[_write] = _ghost;
        _write++;
    }

    for (var _i = _write; _i < _dash.ghost_count; _i++)
        _dash.ghosts[_i] = undefined;

    _dash.ghost_count = _write;
}

/// @description Reads and normalizes centralized movement input.
function sc_player_input_update(_player)
{
    var _movement = _player.movement;
    var _input = global.input.action;

    _movement.input_x = _input.move_right - _input.move_left;
    _movement.input_y = _input.move_down - _input.move_up;
    _movement.moving = _movement.input_x != 0 || _movement.input_y != 0;

    if (!_movement.moving) return;

    var _length = point_distance(0, 0, _movement.input_x, _movement.input_y);
    _movement.input_x /= _length;
    _movement.input_y /= _length;
}

/// @description Updates player mouse aiming and visual rotation.
function sc_player_aim_update(_player)
{
    var _aim = _player.aim;
    var _turn_speed = _player.ship.stats.final.turn_speed;

    _aim.world_x = mouse_x;
    _aim.world_y = mouse_y;
    _aim.direction = point_direction(_player.x, _player.y, _aim.world_x, _aim.world_y);

    var _turn = angle_difference(_aim.direction, _player.draw_angle);
    _player.draw_angle += clamp(_turn, -_turn_speed, _turn_speed);
    _player.draw_angle = _player.draw_angle mod 360;
}

/// @description Applies cheap axis-separated movement against ordinary solids.
function sc_player_solid_move_basic(_player)
{
    var _movement = _player.movement;
    var _collision = _player.ship.collision;
    var _extent = max(_collision.radius_forward, _collision.radius_side);
    var _next_x = _player.x + _movement.velocity_x;
    var _next_y = _player.y + _movement.velocity_y;

    if (!place_meeting(_next_x, _player.y, o_solid))
        _player.x = _next_x;
    else
        _movement.velocity_x = 0;

    if (!place_meeting(_player.x, _next_y, o_solid))
        _player.y = _next_y;
    else
        _movement.velocity_y = 0;

    _player.x = clamp(_player.x, _extent, room_width - _extent);
    _player.y = clamp(_player.y, _extent, room_height - _extent);
    _movement.speed = point_distance(0, 0, _movement.velocity_x, _movement.velocity_y);
}

/// @description Separates the player from any asteroid already overlapping its rotated mask.
function sc_player_asteroid_overlap_resolve(_player)
{
    var _movement = _player.movement;
    var _asteroid = instance_place(_player.x, _player.y, o_asteroid);

    if (!instance_exists(_asteroid))
    {
        _movement.safe_x = _player.x;
        _movement.safe_y = _player.y;
        return false;
    }

    var _impact_asteroid = _asteroid;

    // This loop runs only during an exceptional existing overlap.
    for (var _i = 0; _i < 96; _i++)
    {
        var _normal;

        if (point_distance(_asteroid.x, _asteroid.y, _player.x, _player.y) > 0.01)
            _normal = point_direction(_asteroid.x, _asteroid.y, _player.x, _player.y);
        else if (_movement.speed > 0.01)
            _normal = point_direction(0, 0, -_movement.velocity_x, -_movement.velocity_y);
        else
            _normal = _player.draw_angle + 180;

        _player.x += lengthdir_x(2, _normal);
        _player.y += lengthdir_y(2, _normal);

        _asteroid = instance_place(_player.x, _player.y, o_asteroid);

        if (!instance_exists(_asteroid))
        {
            _movement.safe_x = _player.x;
            _movement.safe_y = _player.y;
            sc_player_asteroid_bounce(_player, _impact_asteroid);
            return true;
        }
    }

    // Absolute fallback: return to the last confirmed clear position.
    _player.x = _movement.safe_x;
    _player.y = _movement.safe_y;
    _movement.velocity_x = 0;
    _movement.velocity_y = 0;
    _movement.speed = 0;
    return true;
}

/// @description Reflects player velocity away from an asteroid impact.
function sc_player_asteroid_bounce(_player, _asteroid)
{
    var _movement = _player.movement;
    var _config = global.config.player_collision;
    var _speed = point_distance(0, 0, _movement.velocity_x, _movement.velocity_y);

    if (_speed <= 0) return false;

    var _incoming = point_direction(0, 0, _movement.velocity_x, _movement.velocity_y);
    var _normal = point_direction(_asteroid.x, _asteroid.y, _player.x, _player.y);
    var _direction = (2 * _normal - _incoming + 180) mod 360;
    var _bounce_speed = max(_config.asteroid_bounce_min, _speed * _config.asteroid_bounce);

    _movement.velocity_x = lengthdir_x(_bounce_speed, _direction);
    _movement.velocity_y = lengthdir_y(_bounce_speed, _direction);
    _movement.speed = _bounce_speed;

    // Collision particles, sound and light camera feedback can plug in here.
    return true;
}

/// @description Moves through an asteroid-bearing level with speed-based substeps.
function sc_player_solid_move_asteroids(_player)
{
    var _movement = _player.movement;
    var _collision = _player.ship.collision;
    var _config = global.config.player_collision;
    var _extent = max(_collision.radius_forward, _collision.radius_side);
    var _speed = point_distance(0, 0, _movement.velocity_x, _movement.velocity_y);
    var _steps = _speed > _config.dash_substep_threshold
        ? max(1, ceil(_speed / _config.movement_step_max))
        : 1;

    var _step_x = _movement.velocity_x / _steps;
    var _step_y = _movement.velocity_y / _steps;

    for (var _i = 0; _i < _steps; _i++)
    {
        var _candidate_x = _player.x;
        var _candidate_y = _player.y;
        var _next_x = _player.x + _step_x;
        var _next_y = _player.y + _step_y;

        if (!place_meeting(_next_x, _player.y, o_solid))
            _candidate_x = _next_x;
        else
        {
            _movement.velocity_x = 0;
            _step_x = 0;
        }

        if (!place_meeting(_candidate_x, _next_y, o_solid))
            _candidate_y = _next_y;
        else
        {
            _movement.velocity_y = 0;
            _step_y = 0;
        }

        var _asteroid = instance_place(_candidate_x, _candidate_y, o_asteroid);

        if (instance_exists(_asteroid))
        {
            sc_player_asteroid_bounce(_player, _asteroid);
            break;
        }

        _player.x = _candidate_x;
        _player.y = _candidate_y;
        _movement.safe_x = _player.x;
        _movement.safe_y = _player.y;
    }

    _player.x = clamp(_player.x, _extent, room_width - _extent);
    _player.y = clamp(_player.y, _extent, room_height - _extent);
    _movement.speed = point_distance(0, 0, _movement.velocity_x, _movement.velocity_y);
}

/// @description Selects the cheapest movement collision route for the current level.
function sc_player_solid_move(_player)
{
    var _movement = _player.movement;
    _player.image_angle = _player.draw_angle;

    // Must happen before the stationary return because rotation can cause overlap.
    if (global.level.asteroids_alive > 0)
        sc_player_asteroid_overlap_resolve(_player);

    if (_movement.velocity_x == 0 && _movement.velocity_y == 0)
    {
        _movement.speed = 0;
        return;
    }

    if (global.level.asteroids_alive <= 0)
    {
        sc_player_solid_move_basic(_player);
        _movement.safe_x = _player.x;
        _movement.safe_y = _player.y;
        return;
    }

    sc_player_solid_move_asteroids(_player);
}

/// @description Resolves whether the player may currently fire weapons.
function sc_player_combat_permission_update(_player)
{
    var _stats = _player.ship.stats.final;
    var _state = global.PlayerState;

    switch (_state)
    {
        case PlayerState.ACTIVE:
            _player.combat.weapons_allowed =
                !_player.movement.boost.active ||
                _stats.weapons_while_boosting > 0;
        break;

        case PlayerState.DASHING:
            _player.combat.weapons_allowed = _stats.weapons_while_dashing > 0;
        break;

        default:
            _player.combat.weapons_allowed = false;
        break;
    }
}

/// @description Attempts to spend one player resource.
function sc_player_resource_spend(_player, _type, _amount)
{
    if (_type == ResourceType.NONE || _amount <= 0) return true;

    var _resource;

    switch (_type)
    {
        case ResourceType.ENERGY: _resource = _player.resources.energy; break;
        case ResourceType.FUEL: _resource = _player.resources.fuel; break;
        case ResourceType.BULLETS: _resource = _player.resources.bullets; break;
        case ResourceType.EXPLOSIVES: _resource = _player.resources.explosives; break;
        default: return false;
    }

    if (_resource.current < _amount) return false;

    _resource.current = max(0, _resource.current - _amount);

    if (_type == ResourceType.ENERGY)
        _resource.recharge_delay_remaining = max(0, round(_player.ship.stats.final.energy_recharge_delay));

    return true;
}

/// @description Regenerates player energy and optional passive fuel.
function sc_player_resources_update(_player)
{
    var _resources = _player.resources;
    var _stats = _player.ship.stats.final;
    var _energy = _resources.energy;
    var _fuel = _resources.fuel;

    if (_energy.recharge_delay_remaining > 0)
        _energy.recharge_delay_remaining--;
    else if (_energy.current < _energy.maximum)
        _energy.current = min(_energy.maximum, _energy.current + _stats.energy_regeneration);

    if (_stats.fuel_regeneration > 0 && _fuel.current < _fuel.maximum)
        _fuel.current = min(_fuel.maximum, _fuel.current + _stats.fuel_regeneration);
}

/// @description Updates acceleration, directional efficiency and held-Shift boost.
function sc_player_normal_movement_update(_player)
{
    var _movement = _player.movement;
    var _stats = _player.ship.stats.final;

    _movement.boost.active = global.input.action.dash_held && _movement.moving;

    if (_movement.moving)
    {
        var _fuel_cost = _movement.boost.active ? _stats.fuel_boost_cost : _stats.fuel_movement_cost;

        if (!sc_player_resource_spend(_player, ResourceType.FUEL, _fuel_cost))
        {
            _movement.moving = false;
            _movement.boost.active = false;
        }
    }

    var _alignment = 1;

    if (_movement.moving)
    {
        var _travel_direction = _movement.speed > 0.05
            ? point_direction(0, 0, _movement.velocity_x, _movement.velocity_y)
            : point_direction(0, 0, _movement.input_x, _movement.input_y);

        _alignment = (dcos(angle_difference(_travel_direction, _player.draw_angle)) + 1) * 0.5;
    }

    var _speed_max = _stats.speed_max * lerp(_stats.directional_speed_min, 1, _alignment);
    if (_movement.boost.active) _speed_max *= _stats.boost_speed_multiplier;

    var _target_vx = _movement.moving ? _movement.input_x * _speed_max : 0;
    var _target_vy = _movement.moving ? _movement.input_y * _speed_max : 0;
    var _change = _movement.moving ? _stats.acceleration : _stats.deceleration;

    _movement.velocity_x += clamp(_target_vx - _movement.velocity_x, -_change, _change);
    _movement.velocity_y += clamp(_target_vy - _movement.velocity_y, -_change, _change);

    if (abs(_movement.velocity_x) < 0.001) _movement.velocity_x = 0;
    if (abs(_movement.velocity_y) < 0.001) _movement.velocity_y = 0;

    sc_player_solid_move(_player);
}

/// @description Releases the player's currently active beam.
function sc_player_continuous_weapon_release(_player)
{
    var _runtime = _player.combat.primary;
    var _active = _runtime.active_delivery_id;

    if (!instance_exists(_active))
    {
        _runtime.active_delivery_id = noone;
        return false;
    }

    sc_beam_release(_active);
    _runtime.active_delivery_id = noone;
    return true;
}

/// @description Selects one temporary primary weapon using number keys 1-4.
function sc_player_weapon_selection_update(_player)
{
   var _input = global.input.action;
	var _slot = -1;

	if (_input.weapon_1_pressed) _slot = 0;
	else if (_input.weapon_2_pressed) _slot = 1;
	else if (_input.weapon_3_pressed) _slot = 2;
	else if (_input.weapon_4_pressed) _slot = 3;

    if (_slot < 0) return false;

    var _loadout = _player.ship.loadout;
    var _weapon_key = _loadout.primary_slots[_slot];

    if (is_undefined(_weapon_key))
    {
        show_debug_message("PLAYER WEAPON SLOT " + string(_slot + 1) + " IS EMPTY");
        return false;
    }

    if (_slot == _loadout.primary_slot) return false;

    sc_player_continuous_weapon_release(_player);

    _loadout.primary_slot = _slot;
    _loadout.primary = _weapon_key;
    _player.combat.primary.hardpoint_cursor = 0;
    _player.combat.primary.next_fire_tick = GAME_TICK;

    show_debug_message("PLAYER WEAPON SELECTED - " + variable_struct_get(global.data.weapons, _weapon_key).identity.name);
    return true;
}

/// @description Fires or maintains the player's held-LMB primary weapon.
function sc_player_primary_weapon_update(_player)
{
    var _runtime = _player.combat.primary;

    if (!_player.combat.weapons_allowed || !global.input.action.fire_primary)
    {
        sc_player_continuous_weapon_release(_player);
        return false;
    }

    var _weapon_key = _player.ship.loadout.primary;
    var _weapon = variable_struct_get(global.data.weapons, _weapon_key);
    var _hardpoints = _player.ship.hardpoints.primary;
    var _hardpoint = _hardpoints[_runtime.hardpoint_cursor];
    var _hardpoint_runtime = _hardpoint.runtime;
    var _angle = _player.draw_angle;
    var _muzzle_x = _player.x;
    var _muzzle_y = _player.y;

    switch (_weapon.firing.mount_mode)
    {
        case WeaponMountMode.HARDPOINT:
            _angle += _hardpoint.angle;

            var _mount_x = _player.x
                + lengthdir_x(_hardpoint.x, _player.draw_angle)
                + lengthdir_x(_hardpoint.y, _player.draw_angle + 90)
                - lengthdir_x(_hardpoint_runtime.recoil, _angle);

            var _mount_y = _player.y
                + lengthdir_y(_hardpoint.x, _player.draw_angle)
                + lengthdir_y(_hardpoint.y, _player.draw_angle + 90)
                - lengthdir_y(_hardpoint_runtime.recoil, _angle);

            _muzzle_x = _mount_x + lengthdir_x(_hardpoint.muzzle_forward, _angle);
            _muzzle_y = _mount_y + lengthdir_y(_hardpoint.muzzle_forward, _angle);
        break;

        case WeaponMountMode.CENTRE:
            var _centre_forward = _weapon.firing.centre_forward * _player.ship.visual.radius;
            _muzzle_x += lengthdir_x(_centre_forward, _angle);
            _muzzle_y += lengthdir_y(_centre_forward, _angle);
        break;
    }

    if (_weapon.delivery.type == AttackDelivery.BEAM)
    {
        if (instance_exists(_runtime.active_delivery_id))
        {
            if (!sc_player_resource_spend(_player, _weapon.resource.type, _weapon.resource.cost))
            {
                sc_player_continuous_weapon_release(_player);
                return false;
            }

            return sc_beam_sustain(_runtime.active_delivery_id, _muzzle_x, _muzzle_y, _angle);
        }

        if (GAME_TICK < _runtime.next_fire_tick) return false;

        if (!sc_player_resource_spend(_player, _weapon.resource.type, _weapon.resource.cost))
            return false;

        var _beam = sc_weapon_fire(
            _player, _weapon_key, _weapon.shot,
            _muzzle_x, _muzzle_y, _angle,
            _player.ship.stats.final.damage_multiplier
        );

        if (!instance_exists(_beam)) return false;

        _runtime.active_delivery_id = _beam;
        _runtime.next_fire_tick = GAME_TICK + max(1, round(_weapon.firing.interval));
        return true;
    }

    if (GAME_TICK < _runtime.next_fire_tick) return false;

    if (!sc_player_resource_spend(_player, _weapon.resource.type, _weapon.resource.cost))
        return false;

    var _delivery = sc_weapon_fire(
        _player, _weapon_key, _weapon.shot,
        _muzzle_x, _muzzle_y, _angle,
        _player.ship.stats.final.damage_multiplier
    );

    if (!_delivery) return false;

    if (_weapon.firing.mount_mode == WeaponMountMode.HARDPOINT)
    {
        _hardpoint_runtime.recoil = _weapon.firing.recoil;
        _hardpoint_runtime.muzzle_flash = _weapon.firing.muzzle_flash_duration;
        _hardpoint_runtime.muzzle_flash_max = max(1, _weapon.firing.muzzle_flash_duration);
        _runtime.hardpoint_cursor = (_runtime.hardpoint_cursor + 1) mod array_length(_hardpoints);
    }

    var _fire_rate = _player.ship.stats.final.fire_rate_multiplier;
    _runtime.next_fire_tick = GAME_TICK + max(1, round(_weapon.firing.interval / _fire_rate));

    // Insert weapon audio and detached muzzle particles here.
    return true;
}

/// @description Updates normal player movement, weapon selection, boost and dash activation.
function sc_player_update_active(_player)
{
    sc_player_input_update(_player);
    sc_player_aim_update(_player);
    sc_player_weapon_selection_update(_player);

    if (sc_player_dash_input_update(_player))
    {
        sc_player_update_dashing(_player);
        return;
    }

    sc_player_normal_movement_update(_player);
    sc_player_combat_permission_update(_player);
    sc_player_primary_weapon_update(_player);
    sc_player_visual_update(_player);
}

/// @description Applies directional force to the player using ship gameplay mass.
function sc_player_knockback_apply(_player, _force, _direction)
{
    if (global.PlayerState == PlayerState.DESTROYED) return false;

    var _mass = _player.ship.stats.final.mass;
    var _impulse = max(0, _force) / max(0.1, _mass);

    _player.movement.velocity_x += lengthdir_x(_impulse, _direction);
    _player.movement.velocity_y += lengthdir_y(_impulse, _direction);
    return true;
}

/// @description Begins or extends a brief player movement and weapon disruption.
function sc_player_stagger_begin(_player, _effect)
{
    if (global.PlayerState == PlayerState.DESTROYED) return false;

    var _stagger = _player.entity.status.stagger;

    if (_stagger.remaining <= 0)
        _stagger.return_state = global.PlayerState;

    _stagger.remaining = max(_stagger.remaining, max(1, round(_effect.duration)));

    var _velocity_retained = 1 - clamp(_effect.strength, 0, 1);
    _player.movement.velocity_x *= _velocity_retained;
    _player.movement.velocity_y *= _velocity_retained;
    _player.movement.boost.active = false;

    sc_player_continuous_weapon_release(_player);
    global.PlayerState = PlayerState.STUNNED;
    sc_player_combat_permission_update(_player);

    // Insert brief stagger flash, particles or audio here later.
    return true;
}

/// @description Updates brief player stagger drift and restores the previous state.
function sc_player_update_stunned(_player)
{
    var _movement = _player.movement;
    var _stagger = _player.entity.status.stagger;

    _movement.boost.active = false;
    _movement.velocity_x = lerp(_movement.velocity_x, 0, 0.12);
    _movement.velocity_y = lerp(_movement.velocity_y, 0, 0.12);

    sc_player_solid_move(_player);
    sc_player_combat_permission_update(_player);
    sc_player_visual_update(_player);

    _stagger.remaining--;

    if (_stagger.remaining <= 0)
    {
        _stagger.remaining = 0;
        global.PlayerState = _stagger.return_state == PlayerState.DASHING
            ? PlayerState.ACTIVE
            : _stagger.return_state;
    }
}

/// @description Updates player drift while systems are disabled.
function sc_player_update_disabled(_player)
{
    var _movement = _player.movement;

    _movement.boost.active = false;
    _movement.velocity_x = lerp(_movement.velocity_x, 0, 0.05);
    _movement.velocity_y = lerp(_movement.velocity_y, 0, 0.05);

    sc_player_solid_move(_player);
    sc_player_combat_permission_update(_player);
    sc_player_visual_update(_player);
}

/// @description Holds the destroyed player in an inert state.
function sc_player_update_destroyed(_player)
{
    _player.movement.boost.active = false;
    _player.movement.velocity_x = 0;
    _player.movement.velocity_y = 0;
    _player.movement.speed = 0;

    sc_player_combat_permission_update(_player);
    sc_player_visual_update(_player);
}

/// @description Returns one of four visual damage stages.
function sc_player_damage_visual_stage(_current, _maximum)
{
    var _ratio = _maximum > 0 ? _current / _maximum : 0;

    if (_ratio > 0.75) return 0;
    if (_ratio > 0.5) return 1;
    if (_ratio > 0.25) return 2;
    return 3;
}

/// @description Emits registered ignition particles from every player thruster mount.
function sc_player_thrust_ignition_emit(_player, _power)
{
    var _visual = _player.ship.visual;
    var _thrust = _visual.thrust;
    var _radius = _visual.radius;
    var _angle = _player.draw_angle;
    var _direction = _angle + 180;

    for (var _i = 0; _i < array_length(_thrust.mounts); _i++)
    {
        var _mount = _thrust.mounts[_i];
        var _x = _player.x + lengthdir_x(_mount.forward * _radius, _angle) + lengthdir_x(_mount.side * _radius, _angle + 90);
        var _y = _player.y + lengthdir_y(_mount.forward * _radius, _angle) + lengthdir_y(_mount.side * _radius, _angle + 90);

        _thrust.ignition_script(_x, _y, _direction, _mount.scale, _power);
    }

    return true;
}

/// @description Updates visual animation and emits interpolated registered thrusters.
function sc_player_visual_update(_player)
{
    var _visual = _player.ship.visual;
    var _runtime = _visual.runtime;
    if (!is_struct(_runtime.cache)) return;

    var _movement = _player.movement;
    var _stats = _player.ship.stats.final;
    var _speed_ratio = _stats.speed_max > 0 ? clamp(_movement.speed / _stats.speed_max, 0, 1) : 0;
    var _alignment = 1;

    if (_movement.speed > 0.05)
    {
        var _travel_direction = point_direction(0, 0, _movement.velocity_x, _movement.velocity_y);
        _alignment = (dcos(angle_difference(_travel_direction, _player.draw_angle)) + 1) * 0.5;
    }

    var _thrust_alignment = lerp(_stats.directional_thrust_min, 1, _alignment);
    var _thrust_target = _speed_ratio * _thrust_alignment;
    var _was_active = _runtime.thrust_power > 0.05;

    _runtime.thrust_power = lerp(_runtime.thrust_power, _thrust_target, _thrust_target > _runtime.thrust_power ? 0.2 : 0.12);

    var _thrust_active = _runtime.thrust_power > 0.05;
    var _boosting = _movement.boost.active;
    var _dashing = global.PlayerState == PlayerState.DASHING;

    if (_thrust_active && !_was_active)
        sc_player_thrust_ignition_emit(_player, 1);

    if (_thrust_active)
    {
        var _thrust = _visual.thrust;
        var _radius = _visual.radius;
        var _distance = point_distance(_movement.previous_x, _movement.previous_y, _player.x, _player.y);
        var _spacing = _dashing ? 6 : 8;
        var _step_max = _dashing ? 4 : 3;
        var _steps = clamp(ceil(_distance / _spacing), 1, _step_max);
        var _angle_change = angle_difference(_player.draw_angle, _movement.previous_angle);

        for (var _step = 1; _step <= _steps; _step++)
        {
            var _amount = _step / _steps;
            var _base_x = lerp(_movement.previous_x, _player.x, _amount);
            var _base_y = lerp(_movement.previous_y, _player.y, _amount);
            var _angle = _movement.previous_angle + _angle_change * _amount;
            var _direction = _angle + 180;

            for (var _i = 0; _i < array_length(_thrust.mounts); _i++)
            {
                var _mount = _thrust.mounts[_i];
                var _x = _base_x + lengthdir_x(_mount.forward * _radius, _angle) + lengthdir_x(_mount.side * _radius, _angle + 90);
                var _y = _base_y + lengthdir_y(_mount.forward * _radius, _angle) + lengthdir_y(_mount.side * _radius, _angle + 90);

                _thrust.particle_script(_x, _y, _direction, _runtime.thrust_power, _mount.scale, _boosting, _dashing);
            }
        }
    }

    var _wing = _visual.wing;
    var _wing_target = _wing.fold_idle;

    if (_dashing)
        _wing_target = _wing.fold_dash;
    else if (_boosting)
        _wing_target = _wing.fold_boost;
    else if (_movement.moving)
        _wing_target = _wing.fold_moving;

    _runtime.wing_fold = lerp(_runtime.wing_fold, _wing_target, _wing.fold_response);

    var _core = _visual.core;
    var _core_target_speed = _core.idle_speed + _core.movement_speed * _speed_ratio;

    if (_dashing)
        _core_target_speed *= _core.dash_multiplier;
    else if (_boosting)
        _core_target_speed *= _core.boost_multiplier;

    _runtime.core_speed = lerp(_runtime.core_speed, _core_target_speed, _core.response);
    _runtime.core_angle = (_runtime.core_angle + _runtime.core_speed) mod 360;
    _runtime.shield_hit_alpha = max(0, _runtime.shield_hit_alpha - 0.06);
}

/// @description Applies one damage packet to the player's layered defence.
function sc_player_damage(_player, _packet)
{
    if (global.PlayerState == PlayerState.DESTROYED) return false;

    var _dash = _player.movement.dash;
    if (global.PlayerState == PlayerState.DASHING && _dash.invulnerable) return false;

    var _defence = _player.defence;
    var _result = sc_damage_resolve(_packet, _defence.shield.current, _defence.armour.current, _defence.hull.current);

    _defence.shield.current = _result.shield;
    _defence.armour.current = _result.armour;
    _defence.hull.current = _result.hull;

    if (_result.dealt.total <= 0) return false;

    _defence.shield.recharge_delay_remaining = _player.ship.stats.final.shield_recharge_delay;
    sc_health_bar_damage_show(_player.health_bar);

    if (_result.dealt.shield > 0)
        _player.ship.visual.runtime.shield_hit_alpha = 1;

    if (_defence.hull.current <= 0)
    {
        _defence.hull.current = 0;
        global.PlayerState = PlayerState.DESTROYED;
        sc_player_die(_player, _packet);
    }
    else if (_result.effect.type == DamageEffect.STAGGER && sc_damage_effect_triggered(_result.effect))
        sc_player_stagger_begin(_player, _result.effect);

    return _result;
}

/// @description Processes one player death immediately and disables the gameplay instance.
function sc_player_die(_player, _packet)
{
    var _movement = _player.movement;
    var _dash = _movement.dash;
    var _hardpoints = _player.ship.hardpoints.primary;

    sc_player_continuous_weapon_release(_player);

    _player.combat.weapons_allowed = false;
    _movement.boost.active = false;
    _movement.moving = false;
    _movement.input_x = 0;
    _movement.input_y = 0;
    _dash.remaining = 0;
    _dash.double_tap_remaining = 0;
    _dash.invulnerable = false;
    _dash.ghost_count = 0;

    for (var _i = 0; _i < array_length(_hardpoints); _i++)
    {
        _hardpoints[_i].runtime.recoil = 0;
        _hardpoints[_i].runtime.muzzle_flash = 0;
    }

    _player.ship.visual.death_script(_player);

    _movement.velocity_x = 0;
    _movement.velocity_y = 0;
    _movement.speed = 0;

    _player.mask_index = -1;
    _player.visible = false;
    global.player_id = noone;

    // Start the future defeat, respawn or spectator controller here.
    return true;
}

/// @description Recharges player shields by consuming available energy.
function sc_player_defence_update(_player)
{
    var _shield = _player.defence.shield;
    if (_shield.current >= _shield.maximum) return;

    if (_shield.recharge_delay_remaining > 0)
    {
        _shield.recharge_delay_remaining--;
        return;
    }

    var _stats = _player.ship.stats.final;
    var _restore = min(_stats.shield_recharge_rate, _shield.maximum - _shield.current);
    var _energy_cost = _restore * _stats.shield_energy_cost;

    if (!sc_player_resource_spend(_player, ResourceType.ENERGY, _energy_cost))
    {
        var _energy = _player.resources.energy;

        if (_stats.shield_energy_cost <= 0 || _energy.current <= 0)
            return;

        _restore = min(_restore, _energy.current / _stats.shield_energy_cost);
        _energy_cost = _restore * _stats.shield_energy_cost;

        if (_restore <= 0 || !sc_player_resource_spend(_player, ResourceType.ENERGY, _energy_cost))
            return;
    }

    _shield.current = min(_shield.maximum, _shield.current + _restore);
}

