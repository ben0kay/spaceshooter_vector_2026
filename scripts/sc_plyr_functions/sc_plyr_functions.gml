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

/// @description Reads and normalizes current WASD movement input.
function sc_player_input_update(_player)
{
    var _movement = _player.movement;

	_movement.input_x = keyboard_check(vk_right) - keyboard_check(vk_left);
	_movement.input_y = keyboard_check(vk_down) - keyboard_check(vk_up);
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

/// @description Moves the player with axis-separated native-mask solid collision.
function sc_player_solid_move(_player)
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

/// @description Starts a dash after a valid second Shift press.
function sc_player_dash_begin(_player)
{
    var _movement = _player.movement;
    var _dash = _movement.dash;
    var _stats = _player.ship.stats.final;

    if (_movement.speed > 0.05)
        _dash.direction = point_direction(0, 0, _movement.velocity_x, _movement.velocity_y);
    else if (_movement.moving)
        _dash.direction = point_direction(0, 0, _movement.input_x, _movement.input_y);
    else
        _dash.direction = _player.draw_angle;

    _movement.velocity_x = lengthdir_x(_stats.dash_speed, _dash.direction);
    _movement.velocity_y = lengthdir_y(_stats.dash_speed, _dash.direction);
    _movement.speed = _stats.dash_speed;
    _movement.boost.active = false;

    _dash.remaining = max(1, round(_stats.dash_duration));
    _dash.cooldown_remaining = max(1, round(_stats.dash_cooldown));
    _dash.double_tap_remaining = 0;
    _dash.invulnerable = _stats.dash_invulnerable > 0;
    _dash.ghost_count = 0;

    global.PlayerState = PlayerState.DASHING;
    sc_player_combat_permission_update(_player);

    // Insert player dash ignition particle burst and audio here.
    return true;
}

/// @description Processes first and second Shift presses.
function sc_player_dash_input_update(_player)
{
    var _movement = _player.movement;
    var _dash = _movement.dash;
    var _stats = _player.ship.stats.final;

    if (!keyboard_check_pressed(vk_shift) || !_movement.moving) return false;
    if (_dash.cooldown_remaining > 0) return false;

    if (_dash.double_tap_remaining > 0)
        return sc_player_dash_begin(_player);

    _dash.double_tap_remaining = max(1, round(_stats.dash_double_tap_window));
    return false;
}

/// @description Updates ordinary acceleration and held-Shift boost.
function sc_player_normal_movement_update(_player)
{
    var _movement = _player.movement;
    var _stats = _player.ship.stats.final;

    _movement.boost.active = keyboard_check(vk_shift) && _movement.moving;

    var _speed_max = _stats.speed_max;
    if (_movement.boost.active) _speed_max *= _stats.boost_speed_multiplier;

    var _target_vx = _movement.input_x * _speed_max;
    var _target_vy = _movement.input_y * _speed_max;
    var _change = _movement.moving ? _stats.acceleration : _stats.deceleration;

    _movement.velocity_x += clamp(_target_vx - _movement.velocity_x, -_change, _change);
    _movement.velocity_y += clamp(_target_vy - _movement.velocity_y, -_change, _change);

    if (abs(_movement.velocity_x) < 0.001) _movement.velocity_x = 0;
    if (abs(_movement.velocity_y) < 0.001) _movement.velocity_y = 0;

    sc_player_solid_move(_player);
}

/// @description Records one baked-sprite dash afterimage.
function sc_player_dash_ghost_record(_player)
{
    var _dash = _player.movement.dash;
    var _limit = _dash.ghost_limit;
    var _last = min(_dash.ghost_count, _limit - 1);

    for (var _i = _last; _i > 0; _i--)
        _dash.ghosts[_i] = _dash.ghosts[_i - 1];

    _dash.ghosts[0] = {
        x: _player.x,
        y: _player.y,
        angle: _player.draw_angle,
        life: _dash.ghost_life
    };

    _dash.ghost_count = min(_dash.ghost_count + 1, _limit);
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
    var _slot = -1;

    if (keyboard_check_pressed(ord("1"))) _slot = 0;
    else if (keyboard_check_pressed(ord("2"))) _slot = 1;
    else if (keyboard_check_pressed(ord("3"))) _slot = 2;
    else if (keyboard_check_pressed(ord("4"))) _slot = 3;

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

    if (!_player.combat.weapons_allowed || !mouse_check_button(mb_left))
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
            return sc_beam_sustain(_runtime.active_delivery_id, _muzzle_x, _muzzle_y, _angle);

        if (GAME_TICK < _runtime.next_fire_tick) return false;

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

/// @description Updates the short direction-locked player dash.
function sc_player_update_dashing(_player)
{
    var _movement = _player.movement;
    var _dash = _movement.dash;
    var _stats = _player.ship.stats.final;

    sc_player_aim_update(_player);

    if ((_dash.remaining mod _dash.ghost_interval) == 0)
        sc_player_dash_ghost_record(_player);

    sc_player_solid_move(_player);
    sc_player_combat_permission_update(_player);
    sc_player_primary_weapon_update(_player);
    sc_player_visual_update(_player);

    // Insert continuous player dash corridor particles here.

    _dash.remaining--;

    if (_dash.remaining > 0 && _movement.speed > 0.05) return;

    _movement.velocity_x *= _stats.dash_exit_speed_multiplier;
    _movement.velocity_y *= _stats.dash_exit_speed_multiplier;
    _movement.speed = point_distance(0, 0, _movement.velocity_x, _movement.velocity_y);

    _dash.remaining = 0;
    _dash.invulnerable = false;
    global.PlayerState = PlayerState.ACTIVE;
}

/// @description Updates player drift while temporarily stunned.
function sc_player_update_stunned(_player)
{
    var _movement = _player.movement;

    _movement.boost.active = false;
    _movement.velocity_x = lerp(_movement.velocity_x, 0, 0.12);
    _movement.velocity_y = lerp(_movement.velocity_y, 0, 0.12);

    sc_player_solid_move(_player);
    sc_player_combat_permission_update(_player);
    sc_player_visual_update(_player);
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

/// @description Updates player-only visual animation.
function sc_player_visual_update(_player)
{
    var _visual = _player.ship.visual;
    var _runtime = _visual.runtime;
    if (!is_struct(_runtime.cache)) return;

    var _movement = _player.movement;
    var _speed_max = _player.ship.stats.final.speed_max;
    var _speed_ratio = _speed_max > 0 ? clamp(_movement.speed / _speed_max, 0, 1) : 0;
    var _thrust_target = _speed_ratio;

    _runtime.thrust_power = lerp(_runtime.thrust_power, _thrust_target, _thrust_target > _runtime.thrust_power ? 0.2 : 0.12);

    var _wing = _visual.wing;
    var _wing_target = _wing.fold_idle;

    if (global.PlayerState == PlayerState.DASHING)
        _wing_target = _wing.fold_dash;
    else if (_movement.boost.active)
        _wing_target = _wing.fold_boost;
    else if (_movement.moving)
        _wing_target = _wing.fold_moving;

    _runtime.wing_fold = lerp(_runtime.wing_fold, _wing_target, _wing.fold_response);

    var _core = _visual.core;
    var _core_target_speed = _core.idle_speed + _core.movement_speed * _speed_ratio;

    if (global.PlayerState == PlayerState.DASHING)
        _core_target_speed *= _core.dash_multiplier;
    else if (_movement.boost.active)
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

    // _result.effect is ready for the upcoming timed-effect manager.
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

/// @description Updates player shield recharge after its damage delay expires.
function sc_player_defence_update(_player)
{
    var _shield = _player.defence.shield;
    if (_shield.current >= _shield.maximum) return;

    if (_shield.recharge_delay_remaining > 0)
    {
        _shield.recharge_delay_remaining--;
        return;
    }

    _shield.current = min(
        _shield.maximum,
        _shield.current + _player.ship.stats.final.shield_recharge_rate
    );
}

