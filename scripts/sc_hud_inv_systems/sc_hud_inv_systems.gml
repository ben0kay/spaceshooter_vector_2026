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

/// @description Installs one fixed-quality module from cargo into an empty system socket.
function sc_player_module_install(_player,_cargo_slot,_system,_socket_index)
{
    var _cargo_item = _player.inventory.slots[_cargo_slot];
    if (is_undefined(_cargo_item)) return false;
    if (!sc_player_module_compatible(_cargo_item.key,_system)) return false;

    var _system_key = sc_player_module_system_key_get(_system);
    if (_system_key == "") return false;

    var _sockets = variable_struct_get(_player.inventory.modules,_system_key);
    if (_socket_index < 0 || _socket_index >= array_length(_sockets)) return false;
    if (!is_undefined(_sockets[_socket_index])) return false;

    var _removed = sc_player_inventory_slot_remove(_player,_cargo_slot,1);
    if (_removed.amount <= 0) return false;

    _sockets[_socket_index] = {
        key: _cargo_item.key,
        name: _cargo_item.name
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