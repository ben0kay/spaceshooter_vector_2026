/// @description Releases one active continuous weapon delivery.
function sc_player_weapon_runtime_release(_runtime)
{
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

/// @description Releases the player's active Primary delivery.
function sc_player_continuous_weapon_release(_player)
{
    return sc_player_weapon_runtime_release(
        _player.combat.primary
    );
}

/// @description Releases every continuously maintained player delivery.
function sc_player_continuous_weapons_release(_player)
{
    var _released = false;

    if (sc_player_weapon_runtime_release(_player.combat.primary))
        _released = true;

    if (sc_player_weapon_runtime_release(_player.combat.secondary))
        _released = true;

    if (sc_player_weapon_runtime_release(_player.combat.equipment))
        _released = true;

    return _released;
}

/// @description Returns the next valid weapon slot in a cycling loadout.
function sc_player_weapon_slot_cycle(_slots,_current,_amount)
{
    var _count = array_length(_slots);
    if (_count <= 0 || _amount == 0) return _current;

    var _direction = sign(_amount);

    for (var _i = 1; _i <= _count; ++_i)
    {
        var _slot = ((_current + _direction * _i) mod _count + _count) mod _count;

        if (!is_undefined(_slots[_slot]))
            return _slot;
    }

    return _current;
}

/// @description Cycles the player's Primary or Secondary loadout.
function sc_player_weapon_selection_update(_player)
{
    var _input = global.input.action;
    var _loadout = _player.ship.loadout;
    var _changed = false;

    if (_input.primary_cycle != 0)
    {
        var _debug_disabled = sc_player_debug_weapon_disable(_player);
        var _slot = sc_player_weapon_slot_cycle(
            _loadout.primary_slots,
            _loadout.primary_slot,
            _input.primary_cycle
        );

        if (_slot != _loadout.primary_slot)
        {
            sc_player_weapon_runtime_release(_player.combat.primary);

            _loadout.primary_slot = _slot;
            _loadout.primary = _loadout.primary_slots[_slot];

            _player.combat.primary.hardpoint_cursor = 0;
            _player.combat.primary.next_fire_tick = GAME_TICK;

            show_debug_message(
                "PLAYER PRIMARY SELECTED - "
                + variable_struct_get(
                    global.data.weapons,
                    _loadout.primary
                ).identity.name
            );

            _changed = true;
        }

        return _changed || _debug_disabled;
    }

    if (_input.secondary_cycle != 0)
    {
        var _slot = sc_player_weapon_slot_cycle(
            _loadout.secondary_slots,
            _loadout.secondary_slot,
            _input.secondary_cycle
        );

        if (_slot == _loadout.secondary_slot)
            return false;

        sc_player_weapon_runtime_release(_player.combat.secondary);

        _loadout.secondary_slot = _slot;
        _loadout.secondary = _loadout.secondary_slots[_slot];

        _player.combat.secondary.hardpoint_cursor = 0;
        _player.combat.secondary.next_fire_tick = GAME_TICK;

        show_debug_message(
            "PLAYER SECONDARY SELECTED - "
            + variable_struct_get(
                global.data.weapons,
                _loadout.secondary
            ).identity.name
        );

        return true;
    }

    return false;
}

/// @description Pays one player weapon's resource cost.
function sc_player_weapon_cost_pay(_player,_weapon,_debug)
{
    if (_debug) return true;

    return sc_player_resource_spend(
        _player,
        _weapon.resource.type,
        _weapon.resource.cost
    );
}

/// @description Updates one shared player weapon channel.
function sc_player_weapon_channel_update(
    _player,
    _runtime,
    _weapon_key,
    _fire,
    _debug = false,
    _shot_override = undefined,
    _firing_override = undefined
)
{
    if (!_player.combat.weapons_allowed
    || !_fire
    || is_undefined(_weapon_key))
    {
        sc_player_weapon_runtime_release(_runtime);
        return false;
    }

    var _weapon = variable_struct_get(
        global.data.weapons,
        _weapon_key
    );

    var _shot = is_undefined(_shot_override)
        ? _weapon.shot
        : _shot_override;

    var _firing = is_undefined(_firing_override)
        ? _weapon.firing
        : _firing_override;

    var _angle = _player.draw_angle;
    var _muzzle_x = _player.x;
    var _muzzle_y = _player.y;
    var _hardpoint = undefined;
    var _hardpoint_runtime = undefined;

    switch (_firing.mount_mode)
    {
        case WeaponMountMode.HARDPOINT:
            var _hardpoints = _player.ship.hardpoints.primary;
            var _hardpoint_count = array_length(_hardpoints);

            if (_hardpoint_count <= 0)
                return false;

            _runtime.hardpoint_cursor =
                _runtime.hardpoint_cursor
                mod _hardpoint_count;

            _hardpoint = _hardpoints[_runtime.hardpoint_cursor];
            _hardpoint_runtime = _hardpoint.runtime;
            _angle += _hardpoint.angle;

            var _mount_x = _player.x
                + lengthdir_x(_hardpoint.x,_player.draw_angle)
                + lengthdir_x(_hardpoint.y,_player.draw_angle + 90)
                - lengthdir_x(_hardpoint_runtime.recoil,_angle);

            var _mount_y = _player.y
                + lengthdir_y(_hardpoint.x,_player.draw_angle)
                + lengthdir_y(_hardpoint.y,_player.draw_angle + 90)
                - lengthdir_y(_hardpoint_runtime.recoil,_angle);

            _muzzle_x = _mount_x
                + lengthdir_x(_hardpoint.muzzle_forward,_angle);

            _muzzle_y = _mount_y
                + lengthdir_y(_hardpoint.muzzle_forward,_angle);
        break;

        case WeaponMountMode.CENTRE:
            var _centre_forward =
                _firing.centre_forward
                * _player.ship.visual.radius;

            _muzzle_x += lengthdir_x(
                _centre_forward,
                _angle
            );

            _muzzle_y += lengthdir_y(
                _centre_forward,
                _angle
            );
        break;
    }

    if (_weapon.delivery.type == AttackDelivery.BEAM)
    {
        if (instance_exists(_runtime.active_delivery_id))
        {
            if (!sc_player_weapon_cost_pay(
                _player,
                _weapon,
                _debug
            ))
            {
                sc_player_weapon_runtime_release(_runtime);
                return false;
            }

            return sc_beam_sustain(
                _runtime.active_delivery_id,
                _muzzle_x,
                _muzzle_y,
                _angle
            );
        }

        if (GAME_TICK < _runtime.next_fire_tick)
            return false;

        if (!sc_player_weapon_cost_pay(
            _player,
            _weapon,
            _debug
        ))
            return false;

        var _beam = sc_weapon_fire(
            _player,
            _weapon_key,
            _shot,
            _muzzle_x,
            _muzzle_y,
            _angle,
            _player.ship.stats.final.damage_multiplier
        );

        if (!instance_exists(_beam))
            return false;

        _runtime.active_delivery_id = _beam;
        _runtime.next_fire_tick = GAME_TICK
            + max(1,round(_firing.interval));

        return true;
    }

    if (GAME_TICK < _runtime.next_fire_tick)
        return false;

    if (!sc_player_weapon_cost_pay(
        _player,
        _weapon,
        _debug
    ))
        return false;

    var _delivery = sc_weapon_fire(
        _player,
        _weapon_key,
        _shot,
        _muzzle_x,
        _muzzle_y,
        _angle,
        _player.ship.stats.final.damage_multiplier
    );

    if (!_delivery)
        return false;

    if (_firing.mount_mode == WeaponMountMode.HARDPOINT)
    {
        _hardpoint_runtime.recoil = _firing.recoil;
        _hardpoint_runtime.muzzle_flash =
            _firing.muzzle_flash_duration;

        _hardpoint_runtime.muzzle_flash_max = max(
            1,
            _firing.muzzle_flash_duration
        );

        _runtime.hardpoint_cursor =
            (_runtime.hardpoint_cursor + 1)
            mod array_length(_player.ship.hardpoints.primary);
    }

    var _fire_rate =
        _player.ship.stats.final.fire_rate_multiplier;

    _runtime.next_fire_tick = GAME_TICK
        + max(
            1,
            round(_firing.interval / _fire_rate)
        );

    return true;
}

/// @description Fires the selected Primary or temporary F2 weapon.
function sc_player_primary_weapon_update(_player)
{
    var _debug = _player.combat.debug_weapon;
    var _debug_active = _debug.enabled;

    var _weapon_key = _debug_active
        ? _debug.weapon_key
        : _player.ship.loadout.primary;

    return sc_player_weapon_channel_update(
        _player,
        _player.combat.primary,
        _weapon_key,
        global.input.action.fire_primary,
        _debug_active,
        _debug_active ? _debug.shot : undefined,
        _debug_active ? _debug.firing : undefined
    );
}

/// @description Fires the currently selected Secondary weapon.
function sc_player_secondary_weapon_update(_player)
{
    return sc_player_weapon_channel_update(
        _player,
        _player.combat.secondary,
        _player.ship.loadout.secondary,
        global.input.action.fire_secondary
    );
}

/// @description Activates the currently equipped player equipment.
function sc_player_equipment_update(_player)
{
    return sc_player_weapon_channel_update(
        _player,
        _player.combat.equipment,
        _player.ship.loadout.equipment,
        global.input.action.equipment_pressed
    );
}
