/*
SHIP COMMAND INVENTORY

Actual carried items belong to player.inventory.
Interface selection and the baked window belong to o_hud_level.
Static panel, tabs and empty cargo slots are baked once.
Items, quantities, selection and descriptions are drawn dynamically.
*/

/// @description Creates the player's persistent cargo inventory foundation.
function sc_player_inventory_create()
{
    var _columns = 8;
    var _rows = 5;

    return {
        columns: _columns,
        rows: _rows,
        slots: array_create(_columns * _rows, undefined)
    };
}

/// @description Opens or closes Ship Command without affecting other player states.
function sc_inventory_toggle(_hud)
{
    if (!instance_exists(global.player_id)) return false;

    var _player = global.player_id;
    var _runtime = _hud.inventory;

    if (global.PlayerState == PlayerState.INVENTORY)
    {
        _runtime.drag.active = false;
        _runtime.drag.source_slot = -1;
        _runtime.open = false;

        global.PlayerState = PlayerState.ACTIVE;
        sc_player_combat_permission_update(_player);
        return true;
    }

    if (global.PlayerState != PlayerState.ACTIVE) return false;

    sc_player_control_suspend(_player);

    _runtime.open = true;
    global.PlayerState = PlayerState.INVENTORY;
    return true;
}

/// @description Returns the cargo slot beneath panel-local coordinates.
function sc_inventory_slot_at_position(_data, _mouse_x, _mouse_y)
{
    var _grid = _data.grid;
    var _column = floor((_mouse_x - _grid.x) / (_grid.slot_size + _grid.gap));
    var _row = floor((_mouse_y - _grid.y) / (_grid.slot_size + _grid.gap));

    if (_column < 0 || _column >= _grid.columns || _row < 0 || _row >= _grid.rows)
        return -1;

    var _slot_x = _grid.x + _column * (_grid.slot_size + _grid.gap);
    var _slot_y = _grid.y + _row * (_grid.slot_size + _grid.gap);

    if (_mouse_x > _slot_x + _grid.slot_size || _mouse_y > _slot_y + _grid.slot_size)
        return -1;

    return _row * _grid.columns + _column;
}

/// @description Moves, merges or swaps two cargo slots.
function sc_player_inventory_slots_move(_player, _source_index, _target_index)
{
    if (!instance_exists(_player)
    || _source_index == _target_index
    || _source_index < 0
    || _target_index < 0)
        return false;

    var _slots = _player.inventory.slots;

    if (_source_index >= array_length(_slots)
    || _target_index >= array_length(_slots))
        return false;

    var _source = _slots[_source_index];
    var _target = _slots[_target_index];

    if (is_undefined(_source)) return false;

    if (is_undefined(_target))
    {
        _slots[_target_index] = _source;
        _slots[_source_index] = undefined;
        return true;
    }

    if (_source.key != _target.key)
    {
        _slots[_source_index] = _target;
        _slots[_target_index] = _source;
        return true;
    }

    var _definition = variable_struct_get(global.data.items, _source.key);
    var _space = max(0, _definition.cargo.stack_max - _target.amount);
    var _moved = min(_source.amount, _space);

    if (_moved <= 0) return false;

    _target.amount += _moved;
    _source.amount -= _moved;
    _slots[_target_index] = _target;
    _slots[_source_index] = _source.amount > 0 ? _source : undefined;
    return true;
}

/// @description Sorts occupied cargo slots alphabetically.
function sc_player_inventory_sort(_player)
{
    if (!instance_exists(_player)) return false;

    var _slots = _player.inventory.slots;
    var _occupied = [];

    for (var _i = 0; _i < array_length(_slots); _i++)
        if (!is_undefined(_slots[_i])) array_push(_occupied, _slots[_i]);

    for (var _a = 0; _a < array_length(_occupied) - 1; _a++)
    {
        for (var _b = _a + 1; _b < array_length(_occupied); _b++)
        {
            var _name_a = string_lower(_occupied[_a].name);
            var _name_b = string_lower(_occupied[_b].name);

            if (_name_b < _name_a)
            {
                var _swap = _occupied[_a];
                _occupied[_a] = _occupied[_b];
                _occupied[_b] = _swap;
            }
        }
    }

    for (var _i = 0; _i < array_length(_slots); _i++)
        _slots[_i] = _i < array_length(_occupied) ? _occupied[_i] : undefined;

    return true;
}

/// @description Removes an amount from one cargo slot and updates cargo totals.
function sc_player_inventory_slot_remove(_player, _slot_index, _amount)
{
    var _result = { key: "", amount: 0 };

    if (!instance_exists(_player)
    || _slot_index < 0
    || _slot_index >= array_length(_player.inventory.slots))
        return _result;

    var _slot = _player.inventory.slots[_slot_index];
    if (is_undefined(_slot)) return _result;

    var _definition = variable_struct_get(global.data.items, _slot.key);
    var _removed = min(_slot.amount, max(0, floor(_amount)));

    if (_removed <= 0) return _result;

    _slot.amount -= _removed;

    _player.resources.cargo.amount = max(
        0,
        _player.resources.cargo.amount - _removed
    );

    _player.resources.cargo.weight = max(
        0,
        _player.resources.cargo.weight - _removed * _definition.cargo.weight
    );

    _player.inventory.slots[_slot_index] = _slot.amount > 0 ? _slot : undefined;

    _result.key = _slot.key;
    _result.amount = _removed;
    return _result;
}

/// @description Drops the selected cargo stack behind the player.
function sc_inventory_selected_drop(_hud)
{
    if (!instance_exists(global.player_id)) return false;

    var _player = global.player_id;
    var _slot_index = _hud.inventory.selected_slot;
    var _slot = _player.inventory.slots[_slot_index];

    if (is_undefined(_slot)) return false;

    var _removed = sc_player_inventory_slot_remove(
        _player,
        _slot_index,
        _slot.amount
    );

    if (_removed.amount <= 0) return false;

    var _direction = _player.draw_angle + 180;
    var _distance = 190;

    var _pickup = sc_resource_pickup_spawn(
        _player.x + lengthdir_x(_distance, _direction),
        _player.y + lengthdir_y(_distance, _direction),
        _player.layer,
        _removed.key,
        _removed.amount
    );

    if (!instance_exists(_pickup))
    {
        sc_player_inventory_add(_player, _removed.key, _removed.amount);
        return false;
    }

    return true;
}

/// @description Updates Ship Command buttons and cargo dragging.
function sc_inventory_update(_hud)
{
    var _runtime = _hud.inventory;
    var _data = _hud.data.inventory;
    var _buttons = _runtime.buttons;
    var _player = global.player_id;

    if (global.input.action.inventory_pressed)
    {
        sc_inventory_toggle(_hud);
        return;
    }

    var _panel_x = floor((display_get_gui_width() - _data.width) * 0.5);
    var _panel_y = floor((display_get_gui_height() - _data.height) * 0.5);
    var _mouse_x = device_mouse_x_to_gui(0) - _panel_x;
    var _mouse_y = device_mouse_y_to_gui(0) - _panel_y;
    var _pressed = global.input.action.ui_select_pressed;
    var _released = global.input.action.ui_select_released;

    if (sc_gui_button_update(_buttons.close, _mouse_x, _mouse_y, _pressed))
    {
        sc_inventory_toggle(_hud);
        return;
    }

    for (var _i = 0; _i < array_length(_buttons.tabs); _i++)
    {
        var _button = _buttons.tabs[_i];
        _button.selected = _runtime.tab == _button.id;

        if (sc_gui_button_update(_button, _mouse_x, _mouse_y, _pressed))
        {
            _runtime.drag.active = false;
            _runtime.drag.source_slot = -1;
            _runtime.tab = _button.id;
            return;
        }
    }

    if (_runtime.tab != InventoryTab.CARGO) return;

    var _selected = _player.inventory.slots[_runtime.selected_slot];
    _buttons.sort.enabled = true;
    _buttons.transfer.enabled = false;
    _buttons.drop.enabled = !is_undefined(_selected);

    if (sc_gui_button_update(_buttons.sort, _mouse_x, _mouse_y, _pressed))
    {
        sc_player_inventory_sort(_player);
        _runtime.selected_slot = 0;
        return;
    }

    sc_gui_button_update(_buttons.transfer, _mouse_x, _mouse_y, _pressed);

    if (sc_gui_button_update(_buttons.drop, _mouse_x, _mouse_y, _pressed))
    {
        sc_inventory_selected_drop(_hud);
        return;
    }

    if (_pressed)
    {
        var _slot = sc_inventory_slot_at_position(_data, _mouse_x, _mouse_y);

        if (_slot >= 0)
        {
            _runtime.selected_slot = _slot;

            if (!is_undefined(_player.inventory.slots[_slot]))
            {
                _runtime.drag.active = true;
                _runtime.drag.source_slot = _slot;
            }
        }
    }

    if (_runtime.drag.active && _released)
    {
        var _target = sc_inventory_slot_at_position(_data, _mouse_x, _mouse_y);

        if (_target >= 0)
        {
            sc_player_inventory_slots_move(
                _player,
                _runtime.drag.source_slot,
                _target
            );

            _runtime.selected_slot = _target;
        }

        _runtime.drag.active = false;
        _runtime.drag.source_slot = -1;
    }
}

/// @description Draws the static Ship Command window before baking.
function sc_inventory_body_primitive_draw(_hud_data)
{
    var _data = _hud_data.inventory;
    var _palette = _hud_data.palette;
    var _grid = _data.grid;
    var _info = _data.info;

    sc_hud_panel_primitive_draw(_data.width, _data.height, 30, _palette);

    draw_set_colour(_palette.void);
    draw_set_alpha(0.96);
    draw_rectangle(32, 22, _data.width - 32, 142, false);

    draw_set_colour(_palette.panel_light);
    draw_set_alpha(0.8);
    draw_rectangle(32, 22, _data.width - 32, 142, true);

    draw_set_colour(_palette.accent);
    draw_set_alpha(0.7);
    draw_line_width(52, 65, 330, 65, 2);
    draw_line_width(52, 132, _data.width - 52, 132, 2);

    // Decorative header circuitry.
    draw_set_alpha(0.35);
    draw_line_width(52, 34, 240, 34, 1);
    draw_line_width(240, 34, 256, 50, 1);
    draw_line_width(256, 50, 342, 50, 1);

    // Cargo panel.
    draw_set_colour(_palette.void);
    draw_set_alpha(0.92);
    draw_rectangle(32, 160, 860, 684, false);

    draw_set_colour(_palette.panel_light);
    draw_set_alpha(0.7);
    draw_rectangle(32, 160, 860, 684, true);

    draw_set_colour(_palette.accent);
    draw_set_alpha(0.7);
    draw_line_width(48, 176, 140, 176, 2);
    draw_line_width(48, 176, 48, 188, 2);

    // Cargo slots.
    for (var _row = 0; _row < _grid.rows; _row++)
    {
        for (var _column = 0; _column < _grid.columns; _column++)
        {
            var _x = _grid.x + _column * (_grid.slot_size + _grid.gap);
            var _y = _grid.y + _row * (_grid.slot_size + _grid.gap);

            draw_set_colour(_palette.background);
            draw_set_alpha(0.96);
            draw_rectangle(_x, _y, _x + _grid.slot_size, _y + _grid.slot_size, false);

            draw_set_colour(_palette.outline);
            draw_set_alpha(0.58);
            draw_rectangle(_x, _y, _x + _grid.slot_size, _y + _grid.slot_size, true);

            draw_set_colour(_palette.panel_light);
            draw_set_alpha(0.35);
            draw_line(_x + 5, _y + 5, _x + 17, _y + 5);
            draw_line(_x + 5, _y + 5, _x + 5, _y + 17);

            draw_set_colour(_palette.outline);
            draw_set_alpha(0.25);
            draw_line(_x + _grid.slot_size - 15, _y + _grid.slot_size - 5, _x + _grid.slot_size - 5, _y + _grid.slot_size - 5);
            draw_line(_x + _grid.slot_size - 5, _y + _grid.slot_size - 15, _x + _grid.slot_size - 5, _y + _grid.slot_size - 5);
        }
    }

    // Item inspector.
    draw_set_colour(_palette.void);
    draw_set_alpha(0.94);
    draw_rectangle(_info.x, _info.y, _info.x + _info.width, _info.y + _info.height, false);

    draw_set_colour(_palette.panel_light);
    draw_set_alpha(0.72);
    draw_rectangle(_info.x, _info.y, _info.x + _info.width, _info.y + _info.height, true);

    draw_set_colour(_palette.accent);
    draw_set_alpha(0.75);
    draw_line_width(_info.x + 18, _info.y + 48, _info.x + _info.width - 18, _info.y + 48, 1);
    draw_line_width(_info.x + 18, _info.y + 292, _info.x + _info.width - 18, _info.y + 292, 1);
    draw_line_width(_info.x + 18, _info.y + 392, _info.x + _info.width - 18, _info.y + 392, 1);

    draw_set_alpha(1);
    draw_set_colour(c_white);
}

/// @description Draws the dynamic Ship Command contents.
function sc_inventory_draw(_hud)
{
    var _runtime = _hud.inventory;
    if (!_runtime.open || global.PlayerState != PlayerState.INVENTORY) return;

    var _data = _hud.data.inventory;
    var _palette = _hud.data.palette;
    var _x = floor((display_get_gui_width() - _data.width) * 0.5);
    var _y = floor((display_get_gui_height() - _data.height) * 0.5);

    draw_set_alpha(0.62);
    draw_set_colour(c_black);
    draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);

    draw_set_alpha(1);
    draw_set_colour(c_white);
    draw_sprite(_hud.cache.inventory_body, 0, _x, _y);

    draw_set_font(-1);
    draw_set_halign(fa_left);
    draw_set_valign(fa_middle);

    draw_set_colour(_palette.core);
    draw_text(_x + 54, _y + 49, "SHIP COMMAND");

    draw_set_colour(_palette.accent);
    draw_text(_x + 54, _y + 78, _data.tabs[_runtime.tab]);

    for (var _i = 0; _i < array_length(_runtime.buttons.tabs); _i++)
    {
        var _button = _runtime.buttons.tabs[_i];
        _button.selected = _runtime.tab == _button.id;
        sc_gui_button_draw(_button, _x, _y, _palette);
    }

    sc_gui_button_draw(_runtime.buttons.close, _x, _y, _palette);

    if (_runtime.tab == InventoryTab.CARGO)
        sc_inventory_cargo_draw(_hud, _x, _y);
    else
    {
        draw_set_colour(_palette.muted);
        draw_set_halign(fa_center);
        draw_text(_x + _data.width * 0.5, _y + 380, _data.tabs[_runtime.tab] + " INTERFACE NOT INSTALLED");
    }

    draw_set_alpha(1);
    draw_set_colour(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

/// @description Draws cargo cards, inspector, capacity and dragged stack.
function sc_inventory_cargo_draw(_hud, _origin_x, _origin_y)
{
    var _player = global.player_id;
    var _inventory = _player.inventory;
    var _runtime = _hud.inventory;
    var _data = _hud.data.inventory;
    var _grid = _data.grid;
    var _info = _data.info;
    var _capacity = _data.capacity;
    var _palette = _hud.data.palette;

    draw_set_halign(fa_left);
    draw_set_valign(fa_middle);
    draw_set_colour(_palette.accent);
    draw_text(_origin_x + 50, _origin_y + 176, "CARGO HOLD");

    for (var _i = 0; _i < array_length(_inventory.slots); _i++)
    {
        var _column = _i mod _grid.columns;
        var _row = floor(_i / _grid.columns);
        var _slot_x = _origin_x + _grid.x + _column * (_grid.slot_size + _grid.gap);
        var _slot_y = _origin_y + _grid.y + _row * (_grid.slot_size + _grid.gap);
        var _item = _inventory.slots[_i];
        var _selected = _i == _runtime.selected_slot;
        var _drag_source = _runtime.drag.active && _runtime.drag.source_slot == _i;

        if (_selected)
        {
            draw_set_alpha(0.14);
            draw_set_colour(_palette.accent);
            draw_rectangle(_slot_x + 2, _slot_y + 2, _slot_x + _grid.slot_size - 2, _slot_y + _grid.slot_size - 2, false);

            draw_set_alpha(1);
            draw_rectangle(_slot_x, _slot_y, _slot_x + _grid.slot_size, _slot_y + _grid.slot_size, true);
        }

        if (is_undefined(_item))
        {
            draw_set_alpha(0.3);
            draw_set_colour(_palette.outline);
            draw_line(_slot_x + 38, _slot_y + 46, _slot_x + 54, _slot_y + 46);
            draw_line(_slot_x + 46, _slot_y + 38, _slot_x + 46, _slot_y + 54);
            continue;
        }

        var _sprite = sc_resource_pickup_visual_cache_get(_item.key, _i mod 4);
        var _alpha = _drag_source ? 0.25 : 1;

        draw_set_alpha(_alpha);
        draw_set_halign(fa_center);
        draw_set_colour(_palette.text);
        draw_text(_slot_x + _grid.slot_size * 0.5, _slot_y + 14, string_upper(_item.name));

        if (sprite_exists(_sprite))
            draw_sprite_ext(_sprite, 0, _slot_x + 46, _slot_y + 52, 1.45, 1.45, 0, c_white, _alpha);

        draw_set_halign(fa_right);
        draw_set_colour(_palette.core);
        draw_text(_slot_x + 84, _slot_y + 79, "x" + string(_item.amount));
    }

    var _selected_item = _inventory.slots[_runtime.selected_slot];
    var _info_x = _origin_x + _info.x;
    var _info_y = _origin_y + _info.y;

    draw_set_alpha(1);
    draw_set_halign(fa_left);
    draw_set_colour(_palette.accent);
    draw_text(_info_x + 18, _info_y + 25, "ITEM INSPECTOR");

    if (is_undefined(_selected_item))
    {
        draw_set_colour(_palette.muted);
        draw_text(_info_x + 18, _info_y + 82, "EMPTY CARGO SLOT");
        draw_text_ext(_info_x + 18, _info_y + 120, "Select a stored item to inspect it.", 22, _info.width - 36);
    }
    else
    {
        var _definition = variable_struct_get(global.data.items, _selected_item.key);
        var _sprite = sc_resource_pickup_visual_cache_get(_selected_item.key, _runtime.selected_slot mod 4);

        if (sprite_exists(_sprite))
            draw_sprite_ext(_sprite, 0, _info_x + 75, _info_y + 112, 2.05, 2.05, 0, c_white, 1);

        draw_set_colour(_palette.core);
        draw_text(_info_x + 140, _info_y + 82, string_upper(_selected_item.name));

        draw_set_colour(_palette.muted);
        draw_text(_info_x + 140, _info_y + 108, "RAW RESOURCE");

        draw_set_colour(_palette.accent);
        draw_text(_info_x + 18, _info_y + 184, "DESCRIPTION");

        draw_set_colour(_palette.text);
        draw_text_ext(
            _info_x + 18,
            _info_y + 214,
            "Unprocessed material recovered from asteroid deposits.",
            22,
            _info.width - 36
        );

        draw_set_colour(_palette.accent);
        draw_text(_info_x + 18, _info_y + 316, "DETAILS");

        draw_set_colour(_palette.text);
        draw_text(_info_x + 18, _info_y + 346, "UNIT MASS");
        draw_text(_info_x + 18, _info_y + 372, "STACK SIZE");

        draw_set_halign(fa_right);
        draw_text(_info_x + _info.width - 18, _info_y + 346, string(_definition.cargo.weight));
        draw_text(_info_x + _info.width - 18, _info_y + 372, string(_selected_item.amount) + " / " + string(_definition.cargo.stack_max));
    }

    var _cargo = _player.resources.cargo;
    var _fraction = clamp(_cargo.weight / max(1, _cargo.capacity), 0, 1);
    var _bar_x = _origin_x + _capacity.x;
    var _bar_y = _origin_y + _capacity.y;

    draw_set_halign(fa_left);
    draw_set_colour(_palette.accent);
    draw_text(_bar_x, _bar_y - 21, "CARGO CAPACITY");

    draw_set_colour(_palette.background);
    draw_rectangle(_bar_x + 145, _bar_y, _bar_x + _capacity.width, _bar_y + _capacity.height, false);

    draw_set_colour(_palette.cargo);
    draw_rectangle(_bar_x + 145, _bar_y, _bar_x + 145 + (_capacity.width - 145) * _fraction, _bar_y + _capacity.height, false);

    draw_set_halign(fa_right);
    draw_set_colour(_palette.core);
    draw_text(_bar_x + _capacity.width, _bar_y - 21, string(_cargo.weight) + " / " + string(_cargo.capacity));

    sc_gui_button_draw(_runtime.buttons.sort, _origin_x, _origin_y, _palette);
    sc_gui_button_draw(_runtime.buttons.transfer, _origin_x, _origin_y, _palette);
    sc_gui_button_draw(_runtime.buttons.drop, _origin_x, _origin_y, _palette);

    if (_runtime.drag.active)
    {
        var _drag_item = _inventory.slots[_runtime.drag.source_slot];

        if (!is_undefined(_drag_item))
        {
            var _mouse_x = device_mouse_x_to_gui(0);
            var _mouse_y = device_mouse_y_to_gui(0);
            var _sprite = sc_resource_pickup_visual_cache_get(_drag_item.key, _runtime.drag.source_slot mod 4);

            draw_set_alpha(0.92);
            draw_set_colour(_palette.void);
            draw_circle(_mouse_x, _mouse_y, 34, false);

            draw_set_colour(_palette.accent);
            draw_circle(_mouse_x, _mouse_y, 34, true);

            if (sprite_exists(_sprite))
                draw_sprite_ext(_sprite, 0, _mouse_x, _mouse_y, 1.35, 1.35, 0, c_white, 1);

            draw_set_halign(fa_right);
            draw_set_colour(_palette.core);
            draw_text(_mouse_x + 32, _mouse_y + 25, "x" + string(_drag_item.amount));
        }
    }

    draw_set_alpha(1);
    draw_set_colour(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

/// @description Returns how many units of an item the player's cargo can accept.
function sc_player_inventory_space_get(_player, _item_key)
{
    if (!instance_exists(_player) || !variable_struct_exists(global.data.items, _item_key))
        return 0;

    var _definition = variable_struct_get(global.data.items, _item_key);
    var _inventory = _player.inventory;
    var _weight = _definition.cargo.weight;
    var _stack_max = _definition.cargo.stack_max;
    var _weight_space = floor((_player.resources.cargo.capacity - _player.resources.cargo.weight) / max(0.001, _weight));
    var _slot_space = 0;

    for (var _i = 0; _i < array_length(_inventory.slots); _i++)
    {
        var _slot = _inventory.slots[_i];

        if (is_undefined(_slot))
            _slot_space += _stack_max;
        else if (_slot.key == _item_key)
            _slot_space += max(0, _stack_max - _slot.amount);
    }

    return max(0, min(_weight_space, _slot_space));
}

/// @description Adds an item to existing stacks and then empty cargo slots.
function sc_player_inventory_add(_player, _item_key, _amount)
{
    var _result = { accepted: 0, remaining: max(0, floor(_amount)) };

    if (!instance_exists(_player)
    || _result.remaining <= 0
    || !variable_struct_exists(global.data.items, _item_key))
        return _result;

    var _definition = variable_struct_get(global.data.items, _item_key);
    var _inventory = _player.inventory;
    var _stack_max = _definition.cargo.stack_max;
    var _accepted = min(_result.remaining, sc_player_inventory_space_get(_player, _item_key));
    var _placing = _accepted;

    for (var _i = 0; _i < array_length(_inventory.slots) && _placing > 0; _i++)
    {
        var _slot = _inventory.slots[_i];

        if (is_undefined(_slot) || _slot.key != _item_key) continue;

        var _added = min(_placing, _stack_max - _slot.amount);
        _slot.amount += _added;
        _placing -= _added;
    }

    for (var _i = 0; _i < array_length(_inventory.slots) && _placing > 0; _i++)
    {
        if (!is_undefined(_inventory.slots[_i])) continue;

        var _added = min(_placing, _stack_max);
        _inventory.slots[_i] = {
            key: _item_key,
            name: _definition.identity.name,
            amount: _added
        };

        _placing -= _added;
    }

    _player.resources.cargo.amount += _accepted;
    _player.resources.cargo.weight += _accepted * _definition.cargo.weight;

    _result.accepted = _accepted;
    _result.remaining -= _accepted;
    return _result;
}