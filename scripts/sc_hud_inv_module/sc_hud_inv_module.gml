/// @description Returns cargo indices containing equippable modules.
function sc_inventory_module_indices_get(_player)
{
    var _indices = [];
    var _slots = _player.inventory.slots;

    for (var _i = 0; _i < array_length(_slots); ++_i)
    {
        var _slot = _slots[_i];
        if (is_undefined(_slot)) continue;

        var _definition = variable_struct_get(global.data.items,_slot.key);
        if (_definition.type == ItemType.MODULE) array_push(_indices,_i);
    }

    return _indices;
}

/// @description Begins installing or replacing one module from cargo.
function sc_player_module_install_begin(_player, _slot_index, _replacing = false)
{
    var _installation = _player.inventory.installation;
    var _slot = _player.inventory.slots[_slot_index];

    if (_installation.active || is_undefined(_slot)) return false;

    var _definition = variable_struct_get(global.data.items, _slot.key);
    if (_definition.type != ItemType.MODULE) return false;

    var _module = _definition.module;

    switch (_module.slot)
    {
        case ModuleSlot.ARMOUR:
            if (!is_undefined(_player.inventory.equipment.armour) && !_replacing) return false;
        break;

        default: return false;
    }

    var _item = {
        key: _slot.key,
        name: _slot.name,
        grade: _slot.grade
    };

    var _removed = sc_player_inventory_slot_remove(_player, _slot_index, 1);
    if (_removed.amount <= 0) return false;

    _installation.active = true;
    _installation.replacing = _replacing;
    _installation.slot = _module.slot;
    _installation.item = _item;
    _installation.duration = _module.install_duration;
    _installation.remaining = _module.install_duration;
    _installation.cancelled_remaining = 0;
    return true;
}

/// @description Clears completed installation runtime.
function sc_player_module_install_clear(_player)
{
    var _installation = _player.inventory.installation;

    _installation.active = false;
    _installation.replacing = false;
    _installation.slot = -1;
    _installation.item = undefined;
    _installation.duration = 0;
    _installation.remaining = 0;
}

/// @description Cancels installation and returns its reserved module to cargo.
function sc_player_module_install_cancel(_player)
{
    var _installation = _player.inventory.installation;
    if (!_installation.active) return false;

    var _item = _installation.item;
    var _returned = sc_player_inventory_add(_player, _item.key, 1, _item.grade);

    if (_returned.accepted <= 0) return false;

    sc_player_module_install_clear(_player);
    _installation.cancelled_remaining = 90;
    return true;
}

/// @description Completes the currently installing module.
function sc_player_module_install_complete(_player)
{
    var _installation = _player.inventory.installation;
    if (!_installation.active) return false;

    var _item = _installation.item;
    var _definition = variable_struct_get(global.data.items, _item.key);

    switch (_installation.slot)
    {
        case ModuleSlot.ARMOUR:
            var _maximum = round(
                _player.ship.stats.base.armour_max
                * _definition.module.effectiveness
                * sc_item_grade_multiplier_get(_item.grade)
            );

            _player.inventory.equipment.armour = {
                key: _item.key,
                name: _item.name,
                grade: _item.grade
            };

            _player.defence.armour.maximum = _maximum;
            _player.defence.armour.current = _maximum;
        break;

        default:
            return false;
    }

    sc_player_module_install_clear(_player);
    return true;
}

/// @description Updates timed player-module installation.
function sc_player_module_install_update(_player)
{
    var _installation = _player.inventory.installation;

    if (_installation.cancelled_remaining > 0)
        _installation.cancelled_remaining--;

    if (!_installation.active) return;

    if (_player.movement.speed > 0.05)
    {
        sc_player_module_install_cancel(_player);
        return;
    }

    _installation.remaining--;

    if (_installation.remaining <= 0)
        sc_player_module_install_complete(_player);
}

/// @description Opens armour-module replacement confirmation.
function sc_inventory_module_replace_open(_hud, _slot_index)
{
    var _replace = _hud.inventory.replace;

    _replace.active = true;
    _replace.source_slot = _slot_index;
}

/// @description Closes armour-module replacement confirmation.
function sc_inventory_module_replace_close(_hud)
{
    var _replace = _hud.inventory.replace;

    _replace.active = false;
    _replace.source_slot = -1;
}

/// @description Updates armour-module replacement confirmation.
function sc_inventory_module_replace_update(_hud, _mouse_x, _mouse_y, _pressed)
{
    var _replace = _hud.inventory.replace;
    if (!_replace.active) return false;

    if (!_pressed) return true;

    if (point_in_rectangle(_mouse_x, _mouse_y, 565, 480, 755, 524))
    {
        sc_player_module_install_begin(
            global.player_id,
            _replace.source_slot,
            true
        );

        sc_inventory_module_replace_close(_hud);
        return true;
    }

    if (point_in_rectangle(_mouse_x, _mouse_y, 805, 480, 995, 524))
    {
        sc_inventory_module_replace_close(_hud);
        return true;
    }

    return true;
}

/// @description Draws armour-module replacement confirmation.
function sc_inventory_module_replace_draw(_hud, _origin_x, _origin_y)
{
    var _replace = _hud.inventory.replace;
    if (!_replace.active) return;

    var _player = global.player_id;
    var _palette = _hud.data.palette;
    var _item = _player.inventory.slots[_replace.source_slot];

    if (is_undefined(_item))
    {
        sc_inventory_module_replace_close(_hud);
        return;
    }

    var _integrity = round(
        _player.defence.armour.current
        / max(1, _player.defence.armour.maximum)
        * 100
    );

    var _grade_colour = sc_item_grade_colour_get(_item.grade);
    var _x = _origin_x + 505;
    var _y = _origin_y + 305;
    var _width = 550;
    var _height = 250;

    draw_set_alpha(0.82);
    draw_set_colour(c_black);
    draw_rectangle(
        _origin_x + 32,
        _origin_y + 155,
        _origin_x + _hud.data.inventory.width - 32,
        _origin_y + _hud.data.inventory.height - 24,
        false
    );

    draw_set_alpha(0.98);
    draw_set_colour(_palette.background);
    draw_rectangle(_x, _y, _x + _width, _y + _height, false);

    draw_set_colour(_palette.accent);
    draw_rectangle(_x, _y, _x + _width, _y + _height, true);
    draw_line(_x + 20, _y + 58, _x + _width - 20, _y + 58);

    draw_set_colour(_palette.accent);
    draw_text(_x + 22, _y + 24, "CONFIRM MODULE REPLACEMENT");

    draw_set_colour(_palette.text);
    draw_text(_x + 22, _y + 82, "CURRENT ARMOUR INTEGRITY");
    draw_text(_x + 22, _y + 116, "REPLACEMENT MODULE");

    draw_set_halign(fa_right);
    draw_set_colour(_palette.warning);
    draw_text(_x + _width - 22, _y + 82, string(_integrity) + "%");

    draw_set_colour(_grade_colour);
    draw_text(_x + _width - 22, _y + 116, _item.name);
    draw_text(_x + _width - 22, _y + 140, sc_item_grade_name_get(_item.grade));
    draw_set_halign(fa_left);

    draw_set_colour(_palette.void);
    draw_rectangle(_origin_x + 565, _origin_y + 480, _origin_x + 755, _origin_y + 524, false);
    draw_rectangle(_origin_x + 805, _origin_y + 480, _origin_x + 995, _origin_y + 524, false);

    draw_set_colour(_palette.accent);
    draw_rectangle(_origin_x + 565, _origin_y + 480, _origin_x + 755, _origin_y + 524, true);

    draw_set_colour(_palette.outline);
    draw_rectangle(_origin_x + 805, _origin_y + 480, _origin_x + 995, _origin_y + 524, true);

    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);

    draw_set_colour(_palette.accent);
    draw_text(_origin_x + 660, _origin_y + 502, "REPLACE");

    draw_set_colour(_palette.text);
    draw_text(_origin_x + 900, _origin_y + 502, "CANCEL");

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_alpha(1);
    draw_set_colour(c_white);
}

/// @description Draws installation progress beside the player ship.
function sc_player_module_install_world_draw(_player)
{
    var _installation = _player.inventory.installation;
    if (!_installation.active && _installation.cancelled_remaining <= 0) return;

    var _x = _player.x + 75;
    var _y = _player.y - 70;

    if (_installation.cancelled_remaining > 0)
    {
        var _flash = ((_installation.cancelled_remaining div 8) mod 2) == 0;

        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_alpha(_flash ? 1 : 0.35);
        draw_set_colour(c_red);
        draw_circle(_x, _y, 15, true);
        draw_text(_x, _y, "!");
        draw_text(_x, _y + 27, "INSTALLATION CANCELLED");
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        draw_set_alpha(1);
        draw_set_colour(c_white);
        return;
    }

    var _progress = 1 - _installation.remaining / max(1, _installation.duration);
    var _width = 110;

    draw_set_alpha(0.9);
    draw_set_colour(make_colour_rgb(5, 18, 24));
    draw_rectangle(_x, _y, _x + _width, _y + 28, false);

    draw_set_colour(c_aqua);
    draw_rectangle(_x, _y, _x + _width, _y + 28, true);
    draw_circle(_x + 14, _y + 14, 7, true);
    draw_line_width(_x + 10, _y + 18, _x + 18, _y + 10, 2);

    draw_set_colour(make_colour_rgb(18, 45, 52));
    draw_rectangle(_x + 28, _y + 11, _x + _width - 8, _y + 18, false);

    draw_set_colour(c_aqua);
    draw_rectangle(_x + 28, _y + 11, _x + 28 + (_width - 36) * _progress, _y + 18, false);

    draw_set_alpha(1);
    draw_set_colour(c_white);
}

/// @description Draws active module installation on the permanent HUD.
function sc_player_module_install_hud_draw(_hud)
{
    if (!instance_exists(global.player_id)) return;

    var _installation = global.player_id.inventory.installation;
    if (!_installation.active) return;

    var _palette = _hud.data.palette;
    var _progress = 1 - _installation.remaining / max(1, _installation.duration);
    var _width = 300;
    var _x = (display_get_gui_width() - _width) * 0.5;
    var _y = display_get_gui_height() - 145;

    draw_set_alpha(0.92);
    draw_set_colour(_palette.background);
    draw_rectangle(_x, _y, _x + _width, _y + 46, false);

    draw_set_colour(_palette.outline);
    draw_rectangle(_x, _y, _x + _width, _y + 46, true);

    draw_set_colour(_palette.accent);
    draw_text(_x + 12, _y + 10, "INSTALLING " + _installation.item.name);

    draw_set_colour(_palette.void);
    draw_rectangle(_x + 12, _y + 31, _x + _width - 12, _y + 38, false);

    draw_set_colour(_palette.accent);
    draw_rectangle(_x + 12, _y + 31, _x + 12 + (_width - 24) * _progress, _y + 38, false);

    draw_set_alpha(1);
    draw_set_colour(c_white);
}