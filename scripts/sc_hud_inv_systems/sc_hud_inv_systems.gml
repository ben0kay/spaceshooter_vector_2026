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

/// @description Returns the Systems-tab layout and displayed ship systems.
function sc_inventory_systems_data()
{
    return {
        cards: [
            { system: ShipSystemType.ENGINES, key: "engines", name: "ENGINES", x: 45, y: 175 },
            { system: ShipSystemType.THRUSTERS, key: "thrusters", name: "THRUSTERS", x: 685, y: 175 },
            { system: ShipSystemType.SHIELD_GENERATOR, key: "shield_generator", name: "SHIELD GENERATOR", x: 45, y: 330 },
            { system: ShipSystemType.REACTOR, key: "reactor", name: "REACTOR", x: 685, y: 330 },
            { system: ShipSystemType.COOLING, key: "cooling", name: "COOLING", x: 45, y: 485 },
            { system: ShipSystemType.WEAPONS, key: "weapons", name: "WEAPONS", x: 685, y: 485 },
            { system: ShipSystemType.SENSORS, key: "sensors", name: "SENSORS", x: 45, y: 640 },
            { system: ShipSystemType.DRONE_BAY, key: "drone_bay", name: "DRONE BAY", x: 685, y: 640 }
        ],

        card_width: 600,
        card_height: 135,

        socket: {
            offset_x: 510,
            offset_y: 48,
            size: 70
        },

        storage: {
            x: 1335,
            y: 240,
            width: 380,
            height: 555,
            columns: 4,
            slot_size: 74,
            gap: 10
        }
    };
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

/// @description Returns the system card whose socket contains panel-local coordinates.
function sc_inventory_systems_socket_at_position(_mouse_x,_mouse_y)
{
    var _data = sc_inventory_systems_data();
    var _cards = _data.cards;
    var _socket = _data.socket;

    for (var _i = 0; _i < array_length(_cards); ++_i)
    {
        var _card = _cards[_i];
        var _x = _card.x + _socket.offset_x;
        var _y = _card.y + _socket.offset_y;

        if (point_in_rectangle(
            _mouse_x,_mouse_y,
            _x,_y,
            _x + _socket.size,
            _y + _socket.size
        ))
            return _i;
    }

    return -1;
}

/// @description Updates Systems-tab module installation and removal.
function sc_inventory_systems_update(_hud,_mouse_x,_mouse_y,_pressed,_released)
{
    var _player = global.player_id;
    var _runtime = _hud.inventory;
    var _data = sc_inventory_systems_data();

    if (_pressed)
    {
        var _cargo_slot = sc_inventory_systems_storage_at_position(
            _player,_mouse_x,_mouse_y
        );

        if (_cargo_slot >= 0)
        {
            _runtime.selected_slot = _cargo_slot;
            _runtime.drag.active = true;
            _runtime.drag.source_slot = _cargo_slot;
            return;
        }

        var _card_index = sc_inventory_systems_socket_at_position(
            _mouse_x,_mouse_y
        );

        if (_card_index >= 0)
        {
            var _card = _data.cards[_card_index];
            var _installed = sc_player_module_get(
                _player,_card.system,0
            );

            if (!is_undefined(_installed))
                sc_player_module_remove(_player,_card.system,0);
        }
    }

    if (!_runtime.drag.active || !_released) return;

    var _card_index = sc_inventory_systems_socket_at_position(
        _mouse_x,_mouse_y
    );

    if (_card_index >= 0)
    {
        var _card = _data.cards[_card_index];

        sc_player_module_install(
            _player,
            _runtime.drag.source_slot,
            _card.system,
            0
        );
    }

    _runtime.drag.active = false;
    _runtime.drag.source_slot = -1;
}

/// @description Draws one Systems-tab ship-system card and its module socket.
function sc_inventory_systems_card_draw(_hud,_player,_card,_data,_origin_x,_origin_y)
{
    var _palette = _hud.data.palette;
    var _socket = _data.socket;
    var _system = variable_struct_get(_player.ship.systems,_card.key);
    var _installed = sc_player_module_get(_player,_card.system,0);
    var _x = _origin_x + _card.x;
    var _y = _origin_y + _card.y;
    var _socket_x = _x + _socket.offset_x;
    var _socket_y = _y + _socket.offset_y;
    var _condition = round(_system.condition_current/max(1,_system.condition_max)*100);
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
    draw_rectangle(_x,_y,_x + _data.card_width,_y + _data.card_height,false);

    draw_set_colour(_status_colour);
    draw_set_alpha(0.7);
    draw_rectangle(_x,_y,_x + _data.card_width,_y + _data.card_height,true);
    draw_line(_x + 14,_y + 37,_x + _data.card_width - 14,_y + 37);

    draw_set_alpha(1);
    draw_set_colour(_palette.text);
    draw_text(_x + 16,_y + 19,_card.name);

    draw_set_halign(fa_right);
    draw_set_colour(_status_colour);
    draw_text(_x + _data.card_width - 16,_y + 19,_status);
    draw_set_halign(fa_left);

    draw_set_colour(_palette.muted);
    draw_text(_x + 16,_y + 58,"CONDITION");
    draw_text(_x + 16,_y + 84,"MODULE");

    draw_set_colour(_palette.text);
    draw_text(_x + 115,_y + 58,string(_condition) + "%");

    if (_system.disruption.remaining > 0)
    {
        draw_set_colour(_palette.warning);
        draw_text(
            _x + 200,
            _y + 58,
            "DISRUPTION // " + string(ceil(_system.disruption.remaining/60)) + "s"
        );
    }

    if (_card.system == ShipSystemType.COOLING)
    {
        var _base = _player.ship.stats.base.weapon_cooling_rate;
        var _final = _player.ship.stats.final.weapon_cooling_rate;

        draw_set_colour(_palette.muted);
        draw_text(_x + 16,_y + 110,"WEAPON COOLING");

        draw_set_colour(_palette.text);
        draw_text(
            _x + 150,
            _y + 110,
            string_format(_base,1,2) + "  >  "
        );

        draw_set_colour(_final > _base ? _palette.accent : _palette.text);
        draw_text(_x + 224,_y + 110,string_format(_final,1,2));
    }
    else
    {
        draw_set_colour(_palette.muted);
        draw_text(_x + 16,_y + 110,"LIVE VALUES PENDING");
    }

    draw_set_colour(_palette.void);
    draw_rectangle(
        _socket_x,_socket_y,
        _socket_x + _socket.size,
        _socket_y + _socket.size,
        false
    );

    draw_set_colour(is_undefined(_installed) ? _palette.outline : _palette.accent);
    draw_rectangle(
        _socket_x,_socket_y,
        _socket_x + _socket.size,
        _socket_y + _socket.size,
        true
    );

    if (is_undefined(_installed))
    {
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_colour(_palette.muted);
        draw_text(
            _socket_x + _socket.size*0.5,
            _socket_y + _socket.size*0.5,
            "+"
        );
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
    }
    else
    {
        var _sprite = sc_resource_pickup_visual_cache_get(_installed.key,0);

        if (sprite_exists(_sprite))
            draw_sprite_ext(
                _sprite,0,
                _socket_x + _socket.size*0.5,
                _socket_y + _socket.size*0.5,
                1.05,1.05,0,c_white,1
            );

        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_colour(_palette.accent);
        draw_text(
            _socket_x + _socket.size*0.5,
            _socket_y + _socket.size + 10,
            "INSTALLED"
        );
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
    }
}

/// @description Draws carried modules in the Systems-tab module storage.
function sc_inventory_systems_storage_draw(_hud,_player,_origin_x,_origin_y)
{
    var _palette = _hud.data.palette;
    var _data = sc_inventory_systems_data();
    var _storage = _data.storage;
    var _indices = sc_inventory_module_indices_get(_player);
    var _x = _origin_x + _storage.x;
    var _y = _origin_y + 175;

    draw_set_alpha(0.96);
    draw_set_colour(_palette.background);
    draw_rectangle(
        _x,_y,
        _x + _storage.width,
        _y + _storage.height + 65,
        false
    );

    draw_set_colour(_palette.outline);
    draw_rectangle(
        _x,_y,
        _x + _storage.width,
        _y + _storage.height + 65,
        true
    );

    draw_set_colour(_palette.accent);
    draw_text(_x + 16,_y + 24,"SYSTEM MODULE STORAGE");

    draw_set_colour(_palette.muted);
    draw_text(_x + 16,_y + 50,"DRAG MODULE INTO A COMPATIBLE SOCKET");

    var _stride = _storage.slot_size + _storage.gap;

    for (var _i = 0; _i < array_length(_indices); ++_i)
    {
        var _column = _i mod _storage.columns;
        var _row = floor(_i/_storage.columns);
        var _slot_index = _indices[_i];
        var _item = _player.inventory.slots[_slot_index];
        var _slot_x = _origin_x + _storage.x + _column*_stride;
        var _slot_y = _origin_y + _storage.y + _row*_stride;
        var _sprite = sc_resource_pickup_visual_cache_get(_item.key,_i mod 4);
        var _dragged = _hud.inventory.drag.active
            && _hud.inventory.drag.source_slot == _slot_index;

        draw_set_alpha(_dragged ? 0.3 : 1);
        draw_set_colour(_palette.void);
        draw_rectangle(
            _slot_x,_slot_y,
            _slot_x + _storage.slot_size,
            _slot_y + _storage.slot_size,
            false
        );

        draw_set_colour(_palette.accent);
        draw_rectangle(
            _slot_x,_slot_y,
            _slot_x + _storage.slot_size,
            _slot_y + _storage.slot_size,
            true
        );

        if (sprite_exists(_sprite))
            draw_sprite_ext(
                _sprite,0,
                _slot_x + _storage.slot_size*0.5,
                _slot_y + _storage.slot_size*0.5,
                1.1,1.1,0,c_white,
                _dragged ? 0.3 : 1
            );

        draw_set_halign(fa_right);
        draw_set_colour(_palette.text);
        draw_text(
            _slot_x + _storage.slot_size - 5,
            _slot_y + _storage.slot_size - 9,
            "x" + string(_item.amount)
        );
        draw_set_halign(fa_left);
    }
}

/// @description Draws the complete live ship-systems and module interface.
function sc_inventory_systems_draw(_hud,_origin_x,_origin_y)
{
    var _player = global.player_id;
    var _palette = _hud.data.palette;
    var _data = sc_inventory_systems_data();
    var _cards = _data.cards;

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

    for (var _i = 0; _i < array_length(_cards); ++_i)
        sc_inventory_systems_card_draw(
            _hud,_player,_cards[_i],_data,_origin_x,_origin_y
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