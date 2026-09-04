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
        global.PlayerState = PlayerState.ACTIVE;
        _runtime.open = false;
        return true;
    }

    if (global.PlayerState != PlayerState.ACTIVE) return false;

    sc_player_continuous_weapon_release(_player);

    _player.movement.input_x = 0;
    _player.movement.input_y = 0;
    _player.movement.velocity_x = 0;
    _player.movement.velocity_y = 0;
    _player.movement.speed = 0;
    _player.movement.moving = false;
    _player.movement.boost.active = false;
    _player.combat.weapons_allowed = false;

    global.PlayerState = PlayerState.INVENTORY;
    _runtime.open = true;
    return true;
}

/// @description Updates Ship Command input and cargo-slot selection while open.
function sc_inventory_update(_hud)
{
    var _runtime = _hud.inventory;
    var _data = _hud.data.inventory;

    if (keyboard_check_pressed(ord("E")))
    {
        sc_inventory_toggle(_hud);
        return;
    }

    var _gui_width = display_get_gui_width();
    var _gui_height = display_get_gui_height();
    var _panel_x = floor((_gui_width - _data.width) * 0.5);
    var _panel_y = floor((_gui_height - _data.height) * 0.5);
    var _mouse_x = device_mouse_x_to_gui(0) - _panel_x;
    var _mouse_y = device_mouse_y_to_gui(0) - _panel_y;

    if (mouse_check_button_pressed(mb_left)
    && _mouse_y >= _data.tab_y
    && _mouse_y < _data.tab_y + _data.tab_height)
    {
        for (var _i = 0; _i < array_length(_data.tabs); _i++)
        {
            var _tab_x = _data.tab_x + _i * (_data.tab_width + _data.tab_gap);

            if (_mouse_x >= _tab_x && _mouse_x < _tab_x + _data.tab_width)
            {
                _runtime.tab = _i;
                return;
            }
        }
    }

    if (_runtime.tab != InventoryTab.CARGO || !mouse_check_button_pressed(mb_left)) return;

    var _grid = _data.grid;
    var _column = floor((_mouse_x - _grid.x) / (_grid.slot_size + _grid.gap));
    var _row = floor((_mouse_y - _grid.y) / (_grid.slot_size + _grid.gap));

    if (_column < 0 || _column >= _grid.columns || _row < 0 || _row >= _grid.rows) return;

    var _slot_x = _grid.x + _column * (_grid.slot_size + _grid.gap);
    var _slot_y = _grid.y + _row * (_grid.slot_size + _grid.gap);

    if (_mouse_x <= _slot_x + _grid.slot_size && _mouse_y <= _slot_y + _grid.slot_size)
        _runtime.selected_slot = _row * _grid.columns + _column;
}

/// @description Draws the static Ship Command window before baking.
function sc_inventory_body_primitive_draw(_hud_data)
{
    var _data = _hud_data.inventory;
    var _palette = _hud_data.palette;
    var _grid = _data.grid;

    sc_hud_panel_primitive_draw(_data.width, _data.height, 30, _palette);

    // Header
    draw_set_colour(_palette.void);
    draw_set_alpha(0.95);
    draw_rectangle(34, 24, _data.width - 34, 84, false);

    draw_set_colour(_palette.panel_light);
    draw_set_alpha(0.8);
    draw_rectangle(34, 24, _data.width - 34, 84, true);

    draw_set_colour(_palette.accent);
    draw_set_alpha(0.9);
    draw_line_width(52, 72, 280, 72, 2);
    draw_line_width(_data.width - 280, 72, _data.width - 52, 72, 2);

    // Tabs
    for (var _i = 0; _i < array_length(_data.tabs); _i++)
    {
        var _x = _data.tab_x + _i * (_data.tab_width + _data.tab_gap);

        draw_set_colour(_palette.void);
        draw_set_alpha(0.92);
        draw_rectangle(_x, _data.tab_y, _x + _data.tab_width, _data.tab_y + _data.tab_height, false);

        draw_set_colour(_palette.outline);
        draw_set_alpha(0.8);
        draw_rectangle(_x, _data.tab_y, _x + _data.tab_width, _data.tab_y + _data.tab_height, true);
    }

    // Cargo area
    draw_set_colour(_palette.void);
    draw_set_alpha(0.9);
    draw_rectangle(_grid.x - 18, _grid.y - 18, _grid.x + _grid.width + 18, _grid.y + _grid.height + 18, false);

    draw_set_colour(_palette.panel_light);
    draw_set_alpha(0.65);
    draw_rectangle(_grid.x - 18, _grid.y - 18, _grid.x + _grid.width + 18, _grid.y + _grid.height + 18, true);

    for (var _row = 0; _row < _grid.rows; _row++)
    {
        for (var _column = 0; _column < _grid.columns; _column++)
        {
            var _x = _grid.x + _column * (_grid.slot_size + _grid.gap);
            var _y = _grid.y + _row * (_grid.slot_size + _grid.gap);

            draw_set_colour(_palette.background);
            draw_set_alpha(1);
            draw_rectangle(_x, _y, _x + _grid.slot_size, _y + _grid.slot_size, false);

            draw_set_colour(_palette.outline);
            draw_set_alpha(0.58);
            draw_rectangle(_x, _y, _x + _grid.slot_size, _y + _grid.slot_size, true);

            draw_set_colour(_palette.panel_light);
            draw_set_alpha(0.28);
            draw_line(_x + 5, _y + 5, _x + 15, _y + 5);
            draw_line(_x + 5, _y + 5, _x + 5, _y + 15);
        }
    }

    // Selected-item information panel
    var _info = _data.info;

    draw_set_colour(_palette.void);
    draw_set_alpha(0.9);
    draw_rectangle(_info.x, _info.y, _info.x + _info.width, _info.y + _info.height, false);

    draw_set_colour(_palette.panel_light);
    draw_set_alpha(0.65);
    draw_rectangle(_info.x, _info.y, _info.x + _info.width, _info.y + _info.height, true);

    draw_set_colour(_palette.accent);
    draw_set_alpha(0.75);
    draw_line_width(_info.x + 18, _info.y + 50, _info.x + _info.width - 18, _info.y + 50, 1);

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
    var _gui_width = display_get_gui_width();
    var _gui_height = display_get_gui_height();
    var _x = floor((_gui_width - _data.width) * 0.5);
    var _y = floor((_gui_height - _data.height) * 0.5);

    // Darken gameplay without covering the permanent HUD.
    draw_set_alpha(0.55);
    draw_set_colour(c_black);
    draw_rectangle(0, 0, _gui_width, _gui_height, false);

    draw_set_alpha(1);
    draw_set_colour(c_white);
    draw_sprite(_hud.cache.inventory_body, 0, _x, _y);

    draw_set_font(-1);
    draw_set_halign(fa_left);
    draw_set_valign(fa_middle);

    draw_set_colour(_palette.core);
    draw_text(_x + 54, _y + 49, "SHIP COMMAND");

    draw_set_halign(fa_right);
    draw_set_colour(_palette.muted);
    draw_text(_x + _data.width - 54, _y + 49, "[E] CLOSE");

    // Tabs and selected-tab glow
    draw_set_halign(fa_center);

    for (var _i = 0; _i < array_length(_data.tabs); _i++)
    {
        var _tab_x = _x + _data.tab_x + _i * (_data.tab_width + _data.tab_gap);
        var _selected = _runtime.tab == _i;

        if (_selected)
        {
            draw_set_colour(_palette.accent);
            draw_set_alpha(0.14);
            draw_rectangle(_tab_x + 2, _y + _data.tab_y + 2, _tab_x + _data.tab_width - 2, _y + _data.tab_y + _data.tab_height - 2, false);

            draw_set_alpha(1);
            draw_line_width(_tab_x + 14, _y + _data.tab_y + _data.tab_height - 3, _tab_x + _data.tab_width - 14, _y + _data.tab_y + _data.tab_height - 3, 2);
        }

        draw_set_alpha(1);
        draw_set_colour(_selected ? _palette.core : _palette.text);
        draw_text(_tab_x + _data.tab_width * 0.5, _y + _data.tab_y + _data.tab_height * 0.5, _data.tabs[_i]);
    }

    if (_runtime.tab == InventoryTab.CARGO)
        sc_inventory_cargo_draw(_hud, _x, _y);
    else
    {
        draw_set_colour(_palette.muted);
        draw_set_halign(fa_center);
        draw_text(_x + _data.width * 0.5, _y + 360, _data.tabs[_runtime.tab] + " INTERFACE NOT INSTALLED");
    }

    draw_set_alpha(1);
    draw_set_colour(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

/// @description Draws player cargo stacks, selection and capacity information.
function sc_inventory_cargo_draw(_hud, _origin_x, _origin_y)
{
    var _player = global.player_id;
    var _inventory = _player.inventory;
    var _runtime = _hud.inventory;
    var _data = _hud.data.inventory;
    var _grid = _data.grid;
    var _info = _data.info;
    var _palette = _hud.data.palette;

    draw_set_halign(fa_left);
    draw_set_valign(fa_middle);
    draw_set_colour(_palette.text);
    draw_text(_origin_x + _grid.x, _origin_y + _grid.y - 34, "CARGO HOLD");

    for (var _i = 0; _i < array_length(_inventory.slots); _i++)
    {
        var _column = _i mod _grid.columns;
        var _row = floor(_i / _grid.columns);
        var _slot_x = _origin_x + _grid.x + _column * (_grid.slot_size + _grid.gap);
        var _slot_y = _origin_y + _grid.y + _row * (_grid.slot_size + _grid.gap);
        var _item = _inventory.slots[_i];

        if (_i == _runtime.selected_slot)
        {
            draw_set_colour(_palette.accent);
            draw_set_alpha(0.18);
            draw_rectangle(_slot_x + 2, _slot_y + 2, _slot_x + _grid.slot_size - 2, _slot_y + _grid.slot_size - 2, false);

            draw_set_alpha(1);
            draw_rectangle(_slot_x, _slot_y, _slot_x + _grid.slot_size, _slot_y + _grid.slot_size, true);
        }

        if (is_undefined(_item)) continue;

        // Item sprites and registered item colours plug in here later.
        draw_set_colour(_palette.energy);
        draw_set_alpha(0.8);
        draw_circle(_slot_x + _grid.slot_size * 0.5, _slot_y + _grid.slot_size * 0.45, 10, false);

        draw_set_halign(fa_right);
        draw_set_colour(_palette.core);
        draw_text(_slot_x + _grid.slot_size - 5, _slot_y + _grid.slot_size - 9, string(_item.amount));
    }

    var _selected = _inventory.slots[_runtime.selected_slot];
    var _info_x = _origin_x + _info.x;
    var _info_y = _origin_y + _info.y;

    draw_set_halign(fa_left);
    draw_set_colour(_palette.core);
    draw_text(_info_x + 18, _info_y + 27, is_undefined(_selected) ? "EMPTY CARGO SLOT" : string_upper(_selected.name));

    draw_set_colour(_palette.muted);
    draw_text(_info_x + 18, _info_y + 78, is_undefined(_selected)
        ? "Select a stored item to inspect it."
        : "Item information and actions will appear here.");

    var _cargo = _player.resources.cargo;
    draw_set_colour(_palette.text);
    draw_text(_info_x + 18, _info_y + _info.height - 52,
        "MASS  " + string(_cargo.weight) + " / " + string(_cargo.capacity));

    draw_set_colour(_palette.accent);
    draw_text(_info_x + 18, _info_y + _info.height - 25,
        "SLOTS  " + string(array_length(_inventory.slots)));
}