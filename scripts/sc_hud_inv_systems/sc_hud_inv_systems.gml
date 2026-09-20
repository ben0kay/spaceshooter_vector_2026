/// @description Returns the inventory struct key used by one ship-system module type.
function sc_player_module_system_key_get(_system)
{
    switch (_system)
    {
        case ShipSystemType.ENGINES: return "engines";
        case ShipSystemType.THRUSTERS: return "thrusters";
        case ShipSystemType.SHIELD_GENERATOR: return "shield_generator";
        case ShipSystemType.REACTOR: return "reactor";
        case ShipSystemType.COOLING: return "cooling";
        case ShipSystemType.WEAPONS: return "weapons";
        case ShipSystemType.SENSORS: return "sensors";
        case ShipSystemType.DRONE_BAY: return "drone_bay";
    }

    return "";
}

/// @description Returns cargo indices containing fixed-quality ship-system modules.
function sc_inventory_module_indices_get(_player)
{
    var _indices = [];
    var _slots = _player.inventory.slots;

    for (var _i = 0; _i < array_length(_slots); ++_i)
    {
        var _item = _slots[_i];
        if (is_undefined(_item)) continue;

        var _definition = variable_struct_get(global.data.items,_item.key);
        if (_definition.type == ItemType.MODULE) array_push(_indices,_i);
    }

    return _indices;
}

/// @description Rebuilds player stat modifiers from every installed system module.
function sc_player_module_modifiers_rebuild(_player)
{
    var _systems = _player.inventory.modules;
    var _system_names = variable_struct_get_names(_systems);
    var _modifiers = [];

    for (var _i = 0; _i < array_length(_system_names); ++_i)
    {
        var _sockets = variable_struct_get(_systems,_system_names[_i]);

        for (var _socket_index = 0; _socket_index < array_length(_sockets); ++_socket_index)
        {
            var _installed = _sockets[_socket_index];
            if (is_undefined(_installed)) continue;

            var _definition = variable_struct_get(global.data.items,_installed.key);
            var _module_modifiers = _definition.module.modifiers;

            for (var _modifier_index = 0; _modifier_index < array_length(_module_modifiers); ++_modifier_index)
                array_push(_modifiers,variable_clone(_module_modifiers[_modifier_index]));
        }
    }

    _player.ship.stats.modifiers.modules = _modifiers;
    _player.ship.stats.dirty = true;
    return sc_player_stats_recalculate(_player);
}

/// @description Returns whether one cargo module is compatible with a system socket.
function sc_player_module_compatible(_item_key,_system)
{
    var _definition = variable_struct_get(global.data.items,_item_key);

    return _definition.type == ItemType.MODULE
        && _definition.module.system == _system;
}

/// @description Installs or replaces one fixed-quality ship-system module.
function sc_player_module_install(_player, _cargo_slot, _system, _socket_index)
{
    var _cargo_item = _player.inventory.slots[_cargo_slot];
    if (is_undefined(_cargo_item)) return false;
    if (!sc_player_module_compatible(_cargo_item.key, _system)) return false;

    var _system_key = sc_player_module_system_key_get(_system);
    if (_system_key == "") return false;

    var _sockets = variable_struct_get(_player.inventory.modules, _system_key);
    if (_socket_index < 0 || _socket_index >= array_length(_sockets)) return false;

    var _installed = _sockets[_socket_index];
    var _new_key = _cargo_item.key;
    var _new_name = _cargo_item.name;

    if (!is_undefined(_installed))
    {
        var _return_space = sc_player_inventory_space_get(
            _player,
            _installed.key
        );

        var _source_slot_will_empty = _cargo_item.amount <= 1;

        if (_return_space <= 0 && !_source_slot_will_empty)
            return false;
    }

    var _removed = sc_player_inventory_slot_remove(
        _player,
        _cargo_slot,
        1
    );

    if (_removed.amount <= 0) return false;

    if (!is_undefined(_installed))
    {
        var _returned = sc_player_inventory_add(
            _player,
            _installed.key,
            1
        );

        if (_returned.accepted <= 0)
        {
            sc_player_inventory_add(
                _player,
                _new_key,
                1
            );

            return false;
        }
    }

    _sockets[_socket_index] = {
        key: _new_key,
        name: _new_name
    };

    sc_player_module_modifiers_rebuild(_player);
    return true;
}

/// @description Removes one installed module and returns it to cargo.
function sc_player_module_remove(_player,_system,_socket_index)
{
    var _system_key = sc_player_module_system_key_get(_system);
    if (_system_key == "") return false;

    var _sockets = variable_struct_get(_player.inventory.modules,_system_key);
    if (_socket_index < 0 || _socket_index >= array_length(_sockets)) return false;

    var _installed = _sockets[_socket_index];
    if (is_undefined(_installed)) return false;

    var _returned = sc_player_inventory_add(_player,_installed.key,1);
    if (_returned.accepted <= 0) return false;

    _sockets[_socket_index] = undefined;
    sc_player_module_modifiers_rebuild(_player);
    return true;
}

/// @description Returns one installed system module.
function sc_player_module_get(_player,_system,_socket_index)
{
    var _system_key = sc_player_module_system_key_get(_system);
    if (_system_key == "") return undefined;

    var _sockets = variable_struct_get(_player.inventory.modules,_system_key);
    if (_socket_index < 0 || _socket_index >= array_length(_sockets)) return undefined;

    return _sockets[_socket_index];
}

/// @description Returns the Systems-tab layout and displayed ship systems.
function sc_inventory_systems_data()
{
    return {
        cards: [
            { system: ShipSystemType.ENGINES, key: "engines", name: "ENGINES", x: 45, y: 175 },
            { system: ShipSystemType.THRUSTERS, key: "thrusters", name: "THRUSTERS", x: 465, y: 175 },
            { system: ShipSystemType.SHIELD_GENERATOR, key: "shield_generator", name: "SHIELD GENERATOR", x: 45, y: 305 },
            { system: ShipSystemType.REACTOR, key: "reactor", name: "REACTOR", x: 465, y: 305 },
            { system: ShipSystemType.COOLING, key: "cooling", name: "COOLING", x: 45, y: 435 },
            { system: ShipSystemType.WEAPONS, key: "weapons", name: "WEAPONS", x: 465, y: 435 },
            { system: ShipSystemType.SENSORS, key: "sensors", name: "SENSORS", x: 45, y: 565 },
            { system: ShipSystemType.DRONE_BAY, key: "drone_bay", name: "DRONE BAY", x: 465, y: 565 }
        ],

        card_width: 400,
        card_height: 115,

        socket: {
            offset_x: 232,
            offset_y: 56,
            size: 42,
            gap: 8,
            count: 3
        },

        inspector: {
            x: 895,
            y: 175,
            width: 820,
            height: 505
        },

        storage: {
            x: 45,
            y: 755,
            width: 1670,
            height: 115,
            columns: 18,
            slot_size: 74,
            gap: 10
        }
    };
}

/// @description Returns the system card beneath panel-local coordinates.
function sc_inventory_systems_card_at_position(_mouse_x,_mouse_y)
{
    var _data = sc_inventory_systems_data();

    for (var _i = 0; _i < array_length(_data.cards); ++_i)
    {
        var _card = _data.cards[_i];

        if (point_in_rectangle(
            _mouse_x,_mouse_y,
            _card.x,_card.y,
            _card.x + _data.card_width,
            _card.y + _data.card_height
        ))
            return _i;
    }

    return -1;
}

/// @description Returns the module-storage cargo slot beneath panel-local coordinates.
function sc_inventory_systems_storage_at_position(_player,_mouse_x,_mouse_y)
{
    var _data = sc_inventory_systems_data();
    var _storage = _data.storage;
    var _indices = sc_inventory_module_indices_get(_player);
    var _stride = _storage.slot_size + _storage.gap;
    var _column = floor((_mouse_x - _storage.x)/_stride);
    var _row = floor((_mouse_y - _storage.y)/_stride);

    if (_column < 0 || _column >= _storage.columns || _row < 0) return -1;

    var _list_index = _row*_storage.columns + _column;
    if (_list_index >= array_length(_indices)) return -1;

    var _x = _storage.x + _column*_stride;
    var _y = _storage.y + _row*_stride;

    if (_mouse_x > _x + _storage.slot_size
    || _mouse_y > _y + _storage.slot_size)
        return -1;

    return _indices[_list_index];
}

/// @description Returns the system card and socket beneath panel-local coordinates.
function sc_inventory_systems_socket_at_position(_mouse_x,_mouse_y)
{
    var _data = sc_inventory_systems_data();
    var _socket = _data.socket;

    for (var _card_index = 0; _card_index < array_length(_data.cards); ++_card_index)
    {
        var _card = _data.cards[_card_index];

        for (var _socket_index = 0; _socket_index < _socket.count; ++_socket_index)
        {
            var _x = _card.x + _socket.offset_x + _socket_index*(_socket.size + _socket.gap);
            var _y = _card.y + _socket.offset_y;

            if (point_in_rectangle(
                _mouse_x,_mouse_y,
                _x,_y,
                _x + _socket.size,
                _y + _socket.size
            ))
                return {
                    card_index: _card_index,
                    socket_index: _socket_index
                };
        }
    }

    return undefined;
}

/// @description Updates system selection, module inspection, installation and removal.
function sc_inventory_systems_update(_hud, _mouse_x, _mouse_y, _pressed, _released)
{
    var _player = global.player_id;
    var _runtime = _hud.inventory;
    var _data = sc_inventory_systems_data();

    if (_pressed)
    {
        var _cargo_slot = sc_inventory_systems_storage_at_position(
            _player,
            _mouse_x,
            _mouse_y
        );

        if (_cargo_slot >= 0)
        {
            _runtime.selected_slot = _cargo_slot;
            _runtime.selected_system_module_slot = _cargo_slot;
            _runtime.drag.active = true;
            _runtime.drag.source_slot = _cargo_slot;
            return;
        }

        var _target = sc_inventory_systems_socket_at_position(
            _mouse_x,
            _mouse_y
        );

        if (!is_undefined(_target))
        {
            _runtime.selected_system = _target.card_index;
            _runtime.selected_system_module_slot = -1;

            var _card = _data.cards[_target.card_index];
            var _installed = sc_player_module_get(
                _player,
                _card.system,
                _target.socket_index
            );

            if (!is_undefined(_installed))
                sc_player_module_remove(
                    _player,
                    _card.system,
                    _target.socket_index
                );

            return;
        }

        var _card_index = sc_inventory_systems_card_at_position(
            _mouse_x,
            _mouse_y
        );

        if (_card_index >= 0)
        {
            _runtime.selected_system = _card_index;
            _runtime.selected_system_module_slot = -1;
        }
    }

    if (!_runtime.drag.active || !_released) return;

    var _target = sc_inventory_systems_socket_at_position(
        _mouse_x,
        _mouse_y
    );

    if (!is_undefined(_target))
    {
        var _card = _data.cards[_target.card_index];

        if (sc_player_module_install(
            _player,
            _runtime.drag.source_slot,
            _card.system,
            _target.socket_index
        ))
        {
            _runtime.selected_system = _target.card_index;
            _runtime.selected_system_module_slot = -1;
        }
    }

    _runtime.drag.active = false;
    _runtime.drag.source_slot = -1;
}

/// @description Returns the live readout rows for one selected ship system.
function sc_inventory_systems_readout_get(_hud,_player,_card)
{
    var _stats = _player.ship.stats.final;
    var _rows = [];

    switch (_card.system)
    {
        //==================================================
        // ENGINES
        //==================================================
        case ShipSystemType.ENGINES:
            array_push(_rows,{ label: "MAXIMUM SPEED", value: string_format(_stats.speed_max,1,2) });
            array_push(_rows,{ label: "ACCELERATION", value: string_format(_stats.acceleration,1,2) });
            array_push(_rows,{ label: "DECELERATION", value: string_format(_stats.deceleration,1,2) });

            array_push(_rows,{
                label: "BOOST SPEED",
                value: string_format(_stats.speed_max*_stats.boost_speed_multiplier,1,2)
            });

            array_push(_rows,{
                label: "MOVEMENT FUEL COST",
                value: string_format(_stats.fuel_movement_cost,1,3) + " / STEP"
            });

            array_push(_rows,{
                label: "BOOST FUEL COST",
                value: string_format(_stats.fuel_boost_cost,1,3) + " / STEP"
            });
        break;


        //==================================================
        // THRUSTERS
        //==================================================
        case ShipSystemType.THRUSTERS:
            array_push(_rows,{ label: "TURN SPEED", value: string_format(_stats.turn_speed,1,2) });
            array_push(_rows,{ label: "REVERSE SPEED", value: string(round(_stats.directional_speed_min*100)) + "%" });
            array_push(_rows,{ label: "REVERSE THRUST", value: string(round(_stats.directional_thrust_min*100)) + "%" });

            array_push(_rows,{
                label: "DASH SPEED",
                value: string_format(_stats.dash_speed,1,2)
            });

            array_push(_rows,{
                label: "DASH DURATION",
                value: string_format(_stats.dash_duration/60,1,2) + "s"
            });

            array_push(_rows,{
                label: "DASH COOLDOWN",
                value: string_format(_stats.dash_cooldown/60,1,2) + "s"
            });

            array_push(_rows,{
                label: "DASH FUEL COST",
                value: string_format(_stats.fuel_dash_cost,1,2)
            });
        break;


        //==================================================
        // SHIELD GENERATOR
        //==================================================
        case ShipSystemType.SHIELD_GENERATOR:
            array_push(_rows,{
                label: "SHIELD CAPACITY",
                value: string(round(_player.defence.shield.current))
                    + " / "
                    + string(round(_player.defence.shield.maximum))
            });

            array_push(_rows,{
                label: "RECHARGE RATE",
                value: string_format(_stats.shield_recharge_rate,1,2) + " / STEP"
            });

            array_push(_rows,{
                label: "RECHARGE DELAY REMAINING",
                value: string_format(_player.defence.shield.recharge_delay_remaining/60,1,1) + "s"
            });

            array_push(_rows,{
                label: "RECHARGE DELAY",
                value: string_format(_stats.shield_recharge_delay/60,1,1) + "s"
            });

            array_push(_rows,{
                label: "RECHARGE ENERGY COST",
                value: string_format(_stats.shield_energy_cost,1,2) + " / STEP"
            });

            array_push(_rows,{
                label: "FOCUS ARC",
                value: string(round(_stats.shield_focus_arc)) + " DEG"
            });

            array_push(_rows,{
                label: "FOCUS ENERGY COST",
                value: string_format(_stats.shield_focus_energy_cost,1,2) + " / STEP"
            });
        break;


        //==================================================
        // REACTOR
        //==================================================
        case ShipSystemType.REACTOR:
            array_push(_rows,{
                label: "ENERGY",
                value: string(round(_player.resources.energy.current))
                    + " / "
                    + string(round(_player.resources.energy.maximum))
            });

            array_push(_rows,{
                label: "ENERGY REGENERATION",
                value: string_format(_stats.energy_regeneration,1,2) + " / STEP"
            });

            array_push(_rows,{
                label: "RECHARGE DELAY REMAINING",
                value: string_format(_player.resources.energy.recharge_delay_remaining/60,1,1) + "s"
            });

            array_push(_rows,{
                label: "RECHARGE DELAY",
                value: string_format(_stats.energy_recharge_delay/60,1,1) + "s"
            });
        break;


        //==================================================
        // COOLING
        //==================================================
        case ShipSystemType.COOLING:
            array_push(_rows,{
                label: "PRIMARY HEAT",
                value: string(round(_player.combat.primary.heat.current))
                    + " / "
                    + string(round(_stats.weapon_heat_maximum))
            });

            array_push(_rows,{
                label: "SECONDARY HEAT",
                value: string(round(_player.combat.secondary.heat.current))
                    + " / "
                    + string(round(_stats.weapon_heat_maximum))
            });

            array_push(_rows,{
                label: "COOLING RATE",
                value: string_format(_stats.weapon_cooling_rate*_stats.cooling_efficiency,1,2) + " / STEP"
            });

            array_push(_rows,{
                label: "COOLING EFFICIENCY",
                value: string(round(_stats.cooling_efficiency*100)) + "%"
            });

            array_push(_rows,{
                label: "HEAT GENERATION",
                value: string(round(_stats.weapon_heat_generation_multiplier*100)) + "%"
            });

            array_push(_rows,{
                label: "COOLING DELAY MULTIPLIER",
                value: string(round(_stats.weapon_cooling_delay_multiplier*100)) + "%"
            });

            array_push(_rows,{
                label: "CHANNEL COOLING DELAYS",
                value: "P "
                    + string_format(_player.combat.primary.heat.cooling_delay_remaining/60,1,1)
                    + "s / S "
                    + string_format(_player.combat.secondary.heat.cooling_delay_remaining/60,1,1)
                    + "s"
            });
        break;


        //==================================================
        // WEAPONS
        //==================================================
        case ShipSystemType.WEAPONS:
            array_push(_rows,{
                label: "PRIMARY FIRE COOLDOWN",
                value: string_format(
                    max(0,_player.combat.primary.next_fire_tick - GAME_TICK)/60,
                    1,2
                ) + "s"
            });

            array_push(_rows,{
                label: "SECONDARY FIRE COOLDOWN",
                value: string_format(
                    max(0,_player.combat.secondary.next_fire_tick - GAME_TICK)/60,
                    1,2
                ) + "s"
            });

            array_push(_rows,{
                label: "DAMAGE MULTIPLIER",
                value: string(round(_stats.damage_multiplier*100)) + "%"
            });

            array_push(_rows,{
                label: "FIRE RATE MULTIPLIER",
                value: string(round(_stats.fire_rate_multiplier*100)) + "%"
            });

            array_push(_rows,{
                label: "WEAPON SPREAD",
                value: string(round(_stats.weapon_spread_multiplier*100)) + "%"
            });

            array_push(_rows,{
                label: "WEAPON RECOIL",
                value: string(round(_stats.weapon_recoil_multiplier*100)) + "%"
            });

            array_push(_rows,{
                label: "FIRE WHILE BOOST / DASH",
                value: (_stats.weapons_while_boosting ? "YES" : "NO")
                    + " / "
                    + (_stats.weapons_while_dashing ? "YES" : "NO")
            });
        break;


        //==================================================
        // SENSORS
        //==================================================
        case ShipSystemType.SENSORS:
            var _radar = _player.inventory.equipment.targeting;

            array_push(_rows,{
                label: "RADAR ARRAY",
                value: is_undefined(_radar) ? "NOT INSTALLED" : _radar.name
            });

            array_push(_rows,{
                label: "CURRENT RADAR RANGE",
                value: is_undefined(_radar)
                    ? "OFFLINE"
                    : string(round(_hud.minimap.range))
            });
        break;


        //==================================================
        // DRONE BAY
        //==================================================
        case ShipSystemType.DRONE_BAY:
            var _slots = _player.inventory.drone_bay.slots;
            var _occupied = 0;
            var _deployed = 0;
            var _docked = 0;
            var _returning = 0;

            for (var _i = 0; _i < array_length(_slots); ++_i)
            {
                if (!is_undefined(_slots[_i].item)) _occupied++;
                if (_slots[_i].active_id != noone) _deployed++;
                if (_slots[_i].state == DroneSlotState.DOCKED) _docked++;
                if (_slots[_i].state == DroneSlotState.RETURNING) _returning++;
            }

            array_push(_rows,{
                label: "DRONE SLOTS",
                value: string(_occupied) + " / " + string(array_length(_slots))
            });

            array_push(_rows,{
                label: "DEPLOYED DRONES",
                value: string(_deployed)
            });

            array_push(_rows,{
                label: "DOCKED DRONES",
                value: string(_docked)
            });

            array_push(_rows,{
                label: "RETURNING DRONES",
                value: string(_returning)
            });
        break;
    }


    //==================================================
    // COMMON SYSTEM INFORMATION
    //==================================================

    var _duration_resistance = clamp(
        _stats.system_disruption_resistance
        + variable_struct_get(
            _stats,
            _card.key + "_disruption_resistance"
        ),
        0,
        0.9
    );

    var _strength_resistance = clamp(
        _stats.system_disruption_strength_resistance
        + variable_struct_get(
            _stats,
            _card.key + "_disruption_strength_resistance"
        ),
        0,
        0.9
    );

    array_push(_rows,{
        label: "DISRUPTION DEFENCE",
        value: "TIME "
            + string(round(_duration_resistance*100))
            + "% / STR "
            + string(round(_strength_resistance*100))
            + "% / REC "
            + string(round(_stats.system_recovery_multiplier*100))
            + "%"
    });

    return _rows;
}

/// @description Draws one selectable ship-system card and its three module sockets.
function sc_inventory_systems_card_draw(_hud, _player, _card, _card_index, _data, _origin_x, _origin_y)
{
    var _palette = _hud.data.palette;
    var _socket = _data.socket;
    var _system = variable_struct_get(_player.ship.systems, _card.key);
    var _x = _origin_x + _card.x;
    var _y = _origin_y + _card.y;
    var _condition = round(_system.condition_current/max(1, _system.condition_max)*100);
    var _selected = _hud.inventory.selected_system == _card_index;
    var _status = "ONLINE";
    var _status_colour = _palette.accent;
    var _dragging = _hud.inventory.drag.active;
    var _drag_compatible = false;

    if (_dragging)
    {
        var _drag_item = _player.inventory.slots[
            _hud.inventory.drag.source_slot
        ];

        if (!is_undefined(_drag_item))
            _drag_compatible = sc_player_module_compatible(
                _drag_item.key,
                _card.system
            );
    }

    if (!_system.enabled || _system.condition_current <= 0)
    {
        _status = "OFFLINE";
        _status_colour = _palette.danger;
    }
    else if (_system.disruption.remaining > 0)
    {
        _status = "DISRUPTED";
        _status_colour = _palette.warning;
    }

    draw_set_alpha(0.96);
    draw_set_colour(_selected ? _palette.panel_light : _palette.background);
    draw_rectangle(
        _x,
        _y,
        _x + _data.card_width,
        _y + _data.card_height,
        false
    );

    draw_set_colour(_selected ? _palette.accent : _status_colour);
    draw_set_alpha(_selected ? 1 : 0.65);
    draw_rectangle(
        _x,
        _y,
        _x + _data.card_width,
        _y + _data.card_height,
        true
    );

    draw_line(
        _x + 14,
        _y + 37,
        _x + _data.card_width - 14,
        _y + 37
    );

    draw_set_alpha(1);
    draw_set_colour(_palette.text);
    draw_text(_x + 16, _y + 19, _card.name);

    draw_set_halign(fa_right);
    draw_set_colour(_status_colour);
    draw_text(
        _x + _data.card_width - 16,
        _y + 19,
        _status
    );
    draw_set_halign(fa_left);

    draw_set_colour(_palette.muted);
    draw_text(_x + 16, _y + 61, "CONDITION");

    draw_set_colour(_palette.text);
    draw_text(
        _x + 112,
        _y + 61,
        string(_condition) + "%"
    );

    if (_system.disruption.remaining > 0)
    {
        draw_set_colour(_palette.warning);
        draw_text(
            _x + 16,
            _y + 87,
            "DISRUPTION // "
                + string_format(_system.disruption.remaining/60, 1, 1)
                + "s"
        );
    }

    for (var _socket_index = 0; _socket_index < _socket.count; ++_socket_index)
    {
        var _installed = sc_player_module_get(
            _player,
            _card.system,
            _socket_index
        );

        var _socket_x = _x
            + _socket.offset_x
            + _socket_index*(_socket.size + _socket.gap);

        var _socket_y = _y + _socket.offset_y;
        var _socket_colour = is_undefined(_installed)
            ? _palette.outline
            : _palette.accent;

        var _socket_alpha = 1;

        if (_dragging)
        {
            _socket_colour = _drag_compatible
                ? _palette.warning
                : _palette.outline;

            _socket_alpha = _drag_compatible ? 1 : 0.25;
        }

        draw_set_alpha(_socket_alpha);
        draw_set_colour(_palette.void);
        draw_rectangle(
            _socket_x,
            _socket_y,
            _socket_x + _socket.size,
            _socket_y + _socket.size,
            false
        );

        draw_set_colour(_socket_colour);
        draw_rectangle(
            _socket_x,
            _socket_y,
            _socket_x + _socket.size,
            _socket_y + _socket.size,
            true
        );

        if (is_undefined(_installed))
        {
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            draw_set_colour(_drag_compatible ? _palette.warning : _palette.muted);
            draw_text(
                _socket_x + _socket.size*0.5,
                _socket_y + _socket.size*0.5,
                "+"
            );
        }
        else
        {
            var _sprite = sc_resource_pickup_visual_cache_get(
                _installed.key,
                0
            );

            if (sprite_exists(_sprite))
                draw_sprite_ext(
                    _sprite,
                    0,
                    _socket_x + _socket.size*0.5,
                    _socket_y + _socket.size*0.5,
                    0.68,
                    0.68,
                    0,
                    c_white,
                    _socket_alpha
                );
        }
    }

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_alpha(1);
    draw_set_colour(c_white);
}

/// @description Draws one selected cargo module in the Systems inspector.
function sc_inventory_systems_module_inspector_draw(_hud, _player, _item, _origin_x, _origin_y)
{
    var _palette = _hud.data.palette;
    var _data = sc_inventory_systems_data();
    var _inspector = _data.inspector;
    var _definition = variable_struct_get(global.data.items, _item.key);
    var _module = _definition.module;
    var _modifiers = _module.modifiers;

    var _x = _origin_x + _inspector.x;
    var _y = _origin_y + _inspector.y;
    var _system_name = "UNKNOWN SYSTEM";

    for (var _i = 0; _i < array_length(_data.cards); ++_i)
    {
        if (_data.cards[_i].system == _module.system)
        {
            _system_name = _data.cards[_i].name;
            break;
        }
    }

    draw_set_alpha(0.96);
    draw_set_colour(_palette.background);
    draw_rectangle(
        _x,
        _y,
        _x + _inspector.width,
        _y + _inspector.height,
        false
    );

    draw_set_colour(_palette.accent);
    draw_rectangle(
        _x,
        _y,
        _x + _inspector.width,
        _y + _inspector.height,
        true
    );

    draw_set_colour(_palette.accent);
    draw_text(_x + 20, _y + 25, "SYSTEM MODULE INSPECTOR");

    draw_set_halign(fa_right);
    draw_set_colour(_palette.muted);
    draw_text(
        _x + _inspector.width - 20,
        _y + 25,
        "FIXED QUALITY"
    );
    draw_set_halign(fa_left);

    draw_set_colour(_palette.outline);
    draw_line(
        _x + 20,
        _y + 54,
        _x + _inspector.width - 20,
        _y + 54
    );

    var _sprite = sc_resource_pickup_visual_cache_get(_item.key, 0);

    draw_set_colour(_palette.void);
    draw_rectangle(
        _x + 20,
        _y + 78,
        _x + 124,
        _y + 182,
        false
    );

    draw_set_colour(_palette.accent);
    draw_rectangle(
        _x + 20,
        _y + 78,
        _x + 124,
        _y + 182,
        true
    );

    if (sprite_exists(_sprite))
        draw_sprite_ext(
            _sprite,
            0,
            _x + 72,
            _y + 130,
            1.45,
            1.45,
            0,
            c_white,
            1
        );

    draw_set_colour(_palette.text);
    draw_text(_x + 150, _y + 82, _item.name);

    draw_set_colour(_palette.muted);
    draw_text(_x + 150, _y + 112, "SYSTEM COMPATIBILITY");

    draw_set_colour(_palette.accent);
    draw_text(_x + 150, _y + 140, _system_name);

    draw_set_colour(_palette.muted);
    draw_text(_x + 150, _y + 170, "MODULES DO NOT HAVE ITEM GRADES");

    draw_set_colour(_palette.outline);
    draw_line(
        _x + 20,
        _y + 205,
        _x + _inspector.width - 20,
        _y + 205
    );

    draw_set_colour(_palette.accent);
    draw_text(_x + 20, _y + 228, "DESCRIPTION");

    draw_set_colour(_palette.text);
    draw_text_ext(
        _x + 20,
        _y + 260,
        _definition.description,
        22,
        _inspector.width - 40
    );

    draw_set_colour(_palette.outline);
    draw_line(
        _x + 20,
        _y + 332,
        _x + _inspector.width - 20,
        _y + 332
    );

    draw_set_colour(_palette.accent);
    draw_text(_x + 20, _y + 355, "MODULE EFFECTS");

    if (array_length(_modifiers) <= 0)
    {
        draw_set_colour(_palette.muted);
        draw_text(_x + 20, _y + 394, "NO STAT MODIFIERS");
    }
    else
    {
        for (var _modifier_index = 0; _modifier_index < array_length(_modifiers); ++_modifier_index)
        {
            var _modifier = _modifiers[_modifier_index];
            var _row_y = _y + 394 + _modifier_index*32;
            var _stat_name = string_upper(
                string_replace_all(_modifier.stat, "_", " ")
            );

            var _value = "";

            if (variable_struct_exists(_modifier, "add"))
            {
                var _add = _modifier.add;
                _value = (_add >= 0 ? "+" : "") + string(_add);
            }
            else if (variable_struct_exists(_modifier, "multiply"))
            {
                var _multiply = _modifier.multiply;
                var _percent = round((_multiply - 1)*100);
                _value = (_percent >= 0 ? "+" : "") + string(_percent) + "%";
            }

            draw_set_colour(_palette.muted);
            draw_text(_x + 20, _row_y, _stat_name);

            draw_set_halign(fa_right);
            draw_set_colour(_palette.text);
            draw_text(
                _x + _inspector.width - 20,
                _row_y,
                _value
            );
            draw_set_halign(fa_left);
        }
    }

    draw_set_halign(fa_right);
    draw_set_colour(_palette.muted);
    draw_text(
        _x + _inspector.width - 150,
        _y + _inspector.height - 35,
        "MASS"
    );

    draw_set_colour(_palette.text);
    draw_text(
        _x + _inspector.width - 90,
        _y + _inspector.height - 35,
        string(_definition.cargo.weight)
    );

    draw_set_colour(_palette.muted);
    draw_text(
        _x + _inspector.width - 55,
        _y + _inspector.height - 35,
        "QTY"
    );

    draw_set_colour(_palette.text);
    draw_text(
        _x + _inspector.width - 20,
        _y + _inspector.height - 35,
        string(_item.amount)
    );

    draw_set_halign(fa_left);
    draw_set_alpha(1);
    draw_set_colour(c_white);
    draw_set_valign(fa_top);
}

/// @description Draws the selected module or selected system's live information.
function sc_inventory_systems_inspector_draw(_hud, _player, _origin_x, _origin_y)
{
    var _module_slot = _hud.inventory.selected_system_module_slot;

    if (_module_slot >= 0
    && _module_slot < array_length(_player.inventory.slots))
    {
        var _module_item = _player.inventory.slots[_module_slot];

        if (!is_undefined(_module_item))
        {
            var _module_definition = variable_struct_get(
                global.data.items,
                _module_item.key
            );

            if (_module_definition.type == ItemType.MODULE)
            {
                sc_inventory_systems_module_inspector_draw(
                    _hud,
                    _player,
                    _module_item,
                    _origin_x,
                    _origin_y
                );

                return;
            }
        }

        _hud.inventory.selected_system_module_slot = -1;
    }

    var _palette = _hud.data.palette;
    var _data = sc_inventory_systems_data();
    var _inspector = _data.inspector;
    var _selected = clamp(
        _hud.inventory.selected_system,
        0,
        array_length(_data.cards) - 1
    );

    var _card = _data.cards[_selected];
    var _system = variable_struct_get(_player.ship.systems, _card.key);
    var _rows = sc_inventory_systems_readout_get(_hud, _player, _card);
    var _effectiveness = sc_ship_system_effectiveness_get(
        _player.ship,
        _card.key
    );

    var _condition = round(
        _system.condition_current
        / max(1, _system.condition_max)
        * 100
    );

    var _x = _origin_x + _inspector.x;
    var _y = _origin_y + _inspector.y;
    var _divider_x = _x + 430;
    var _status = "ONLINE";
    var _status_colour = _palette.accent;

    if (!_system.enabled || _system.condition_current <= 0)
    {
        _status = "OFFLINE";
        _status_colour = _palette.danger;
    }
    else if (_system.disruption.remaining > 0)
    {
        _status = "DISRUPTED";
        _status_colour = _palette.warning;
    }

    draw_set_alpha(0.96);
    draw_set_colour(_palette.background);
    draw_rectangle(
        _x,
        _y,
        _x + _inspector.width,
        _y + _inspector.height,
        false
    );

    draw_set_colour(_status_colour);
    draw_rectangle(
        _x,
        _y,
        _x + _inspector.width,
        _y + _inspector.height,
        true
    );

    draw_set_colour(_palette.accent);
    draw_text(
        _x + 20,
        _y + 25,
        "SYSTEM STATUS // " + _card.name
    );

    draw_set_halign(fa_right);
    draw_set_colour(_status_colour);
    draw_text(
        _x + _inspector.width - 20,
        _y + 25,
        _status
    );
    draw_set_halign(fa_left);

    draw_set_colour(_palette.outline);
    draw_line(
        _x + 20,
        _y + 54,
        _x + _inspector.width - 20,
        _y + 54
    );

    draw_line(
        _divider_x,
        _y + 70,
        _divider_x,
        _y + _inspector.height - 20
    );

    draw_set_colour(_palette.muted);
    draw_text(_x + 20, _y + 82, "CONDITION");
    draw_text(_x + 20, _y + 110, "EFFECTIVENESS");

    draw_set_halign(fa_right);
    draw_set_colour(_palette.text);
    draw_text(
        _divider_x - 20,
        _y + 82,
        string(_condition) + "%"
    );

    draw_text(
        _divider_x - 20,
        _y + 110,
        string(round(_effectiveness*100)) + "%"
    );
    draw_set_halign(fa_left);

    draw_set_colour(_palette.accent);
    draw_text(_x + 20, _y + 154, "LIVE SYSTEM VALUES");

    draw_set_colour(_palette.outline);
    draw_line(
        _x + 20,
        _y + 181,
        _divider_x - 20,
        _y + 181
    );

    for (var _i = 0; _i < array_length(_rows); ++_i)
    {
        var _row = _rows[_i];
        var _row_y = _y + 212 + _i*38;

        draw_set_colour(_palette.muted);
        draw_text(_x + 20, _row_y, _row.label);

        draw_set_halign(fa_right);
        draw_set_colour(_palette.text);
        draw_text(
            _divider_x - 20,
            _row_y,
            _row.value
        );
        draw_set_halign(fa_left);
    }

    var _module_x = _divider_x + 20;
    var _module_width = _inspector.width - 470;

    draw_set_colour(_palette.accent);
    draw_text(_module_x, _y + 82, "INSTALLED MODULES");

    for (var _socket_index = 0; _socket_index < 3; ++_socket_index)
    {
        var _installed = sc_player_module_get(
            _player,
            _card.system,
            _socket_index
        );

        var _slot_y = _y + 115 + _socket_index*120;

        draw_set_colour(_palette.void);
        draw_rectangle(
            _module_x,
            _slot_y,
            _module_x + _module_width,
            _slot_y + 102,
            false
        );

        draw_set_colour(
            is_undefined(_installed)
                ? _palette.outline
                : _palette.accent
        );

        draw_rectangle(
            _module_x,
            _slot_y,
            _module_x + _module_width,
            _slot_y + 102,
            true
        );

        draw_set_colour(_palette.muted);
        draw_text(
            _module_x + 12,
            _slot_y + 15,
            "SOCKET " + string(_socket_index + 1)
        );

        if (is_undefined(_installed))
        {
            draw_set_colour(_palette.muted);
            draw_text(
                _module_x + 12,
                _slot_y + 52,
                "EMPTY MODULE SOCKET"
            );

            continue;
        }

        var _definition = variable_struct_get(
            global.data.items,
            _installed.key
        );

        var _sprite = sc_resource_pickup_visual_cache_get(
            _installed.key,
            0
        );

        if (sprite_exists(_sprite))
            draw_sprite_ext(
                _sprite,
                0,
                _module_x + 40,
                _slot_y + 63,
                0.8,
                0.8,
                0,
                c_white,
                1
            );

        draw_set_colour(_palette.text);
        draw_text(
            _module_x + 78,
            _slot_y + 42,
            _installed.name
        );

        draw_set_colour(_palette.muted);
        draw_text_ext(
            _module_x + 78,
            _slot_y + 66,
            _definition.description,
            16,
            _module_width - 92
        );
    }

    draw_set_alpha(1);
    draw_set_colour(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

/// @description Draws carried modules in the Systems-tab bottom storage strip.
function sc_inventory_systems_storage_draw(_hud, _player, _origin_x, _origin_y)
{
    var _palette = _hud.data.palette;
    var _data = sc_inventory_systems_data();
    var _storage = _data.storage;
    var _indices = sc_inventory_module_indices_get(_player);
    var _selected = clamp(
        _hud.inventory.selected_system,
        0,
        array_length(_data.cards) - 1
    );

    var _selected_system = _data.cards[_selected].system;
    var _panel_x = _origin_x + _storage.x;
    var _panel_y = _origin_y + 700;

    draw_set_alpha(0.96);
    draw_set_colour(_palette.background);
    draw_rectangle(
        _panel_x,
        _panel_y,
        _panel_x + _storage.width,
        _origin_y + 885,
        false
    );

    draw_set_colour(_palette.outline);
    draw_rectangle(
        _panel_x,
        _panel_y,
        _panel_x + _storage.width,
        _origin_y + 885,
        true
    );

    draw_set_colour(_palette.accent);
    draw_text(
        _panel_x + 16,
        _panel_y + 18,
        "AVAILABLE SYSTEM MODULES"
    );

    draw_set_colour(_palette.muted);
    draw_text(
        _panel_x + 260,
        _panel_y + 18,
        "COMPATIBLE MODULES ARE HIGHLIGHTED FOR "
            + _data.cards[_selected].name
    );

    var _stride = _storage.slot_size + _storage.gap;

    for (var _i = 0; _i < array_length(_indices); ++_i)
    {
        var _column = _i mod _storage.columns;
        var _row = floor(_i/_storage.columns);
        var _slot_index = _indices[_i];
        var _item = _player.inventory.slots[_slot_index];
        var _compatible = sc_player_module_compatible(
            _item.key,
            _selected_system
        );

        var _slot_x = _origin_x
            + _storage.x
            + _column*_stride;

        var _slot_y = _origin_y
            + _storage.y
            + _row*_stride;

        var _sprite = sc_resource_pickup_visual_cache_get(
            _item.key,
            _i mod 4
        );

        var _dragged = _hud.inventory.drag.active
            && _hud.inventory.drag.source_slot == _slot_index;

        var _alpha = _dragged
            ? 0.25
            : (_compatible ? 1 : 0.32);

        draw_set_alpha(_alpha);
        draw_set_colour(_palette.void);
        draw_rectangle(
            _slot_x,
            _slot_y,
            _slot_x + _storage.slot_size,
            _slot_y + _storage.slot_size,
            false
        );

        draw_set_colour(
            _compatible
                ? _palette.accent
                : _palette.outline
        );

        draw_rectangle(
            _slot_x,
            _slot_y,
            _slot_x + _storage.slot_size,
            _slot_y + _storage.slot_size,
            true
        );

        if (sprite_exists(_sprite))
            draw_sprite_ext(
                _sprite,
                0,
                _slot_x + _storage.slot_size*0.5,
                _slot_y + _storage.slot_size*0.5,
                1.1,
                1.1,
                0,
                c_white,
                _alpha
            );

        draw_set_halign(fa_right);
        draw_set_colour(
            _compatible
                ? _palette.text
                : _palette.muted
        );

        draw_text(
            _slot_x + _storage.slot_size - 5,
            _slot_y + _storage.slot_size - 9,
            "x" + string(_item.amount)
        );

        draw_set_halign(fa_left);
    }

    draw_set_alpha(1);
    draw_set_colour(c_white);
}

/// @description Draws the complete live ship-systems and module interface.
function sc_inventory_systems_draw(_hud,_origin_x,_origin_y)
{
    var _player = global.player_id;
    var _palette = _hud.data.palette;
    var _data = sc_inventory_systems_data();

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);

    draw_set_alpha(0.98);
    draw_set_colour(_palette.background);
    draw_rectangle(
        _origin_x + 32,_origin_y + 155,
        _origin_x + _hud.data.inventory.width - 32,
        _origin_y + _hud.data.inventory.height - 24,
        false
    );

    for (var _i = 0; _i < array_length(_data.cards); ++_i)
        sc_inventory_systems_card_draw(
            _hud,
            _player,
            _data.cards[_i],
            _i,
            _data,
            _origin_x,
            _origin_y
        );

    sc_inventory_systems_inspector_draw(
        _hud,_player,_origin_x,_origin_y
    );

    sc_inventory_systems_storage_draw(
        _hud,_player,_origin_x,_origin_y
    );

    if (_hud.inventory.drag.active)
    {
        var _item = _player.inventory.slots[_hud.inventory.drag.source_slot];

        if (!is_undefined(_item))
        {
            var _definition = variable_struct_get(global.data.items,_item.key);

            if (_definition.type == ItemType.MODULE)
            {
                var _mouse_x = device_mouse_x_to_gui(0);
                var _mouse_y = device_mouse_y_to_gui(0);
                var _sprite = sc_resource_pickup_visual_cache_get(_item.key,0);

                draw_set_alpha(0.9);
                draw_set_colour(_palette.void);
                draw_circle(_mouse_x,_mouse_y,36,false);

                draw_set_colour(_palette.accent);
                draw_circle(_mouse_x,_mouse_y,36,true);

                if (sprite_exists(_sprite))
                    draw_sprite_ext(
                        _sprite,0,
                        _mouse_x,_mouse_y,
                        1.2,1.2,0,c_white,1
                    );
            }
        }
    }

    draw_set_alpha(1);
    draw_set_colour(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}