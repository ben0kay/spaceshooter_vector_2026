/*
PLAYER RADIAL COMMAND

Hold Delete to open the world-space loadout radial beside the player.
Double-tap Delete to deploy the selected physical drone.
*/

/// @description Returns one radial category's world-space direction.
function sc_player_radial_category_angle(_category)
{
    switch (_category)
    {
        case PlayerRadialCategory.PRIMARY: return 270;
        case PlayerRadialCategory.SECONDARY: return 0;
        case PlayerRadialCategory.EQUIPMENT: return 180;
        case PlayerRadialCategory.DRONE: return 90;
    }

    return 0;
}

/// @description Returns one radial category's displayed name.
function sc_player_radial_category_name(_category)
{
    switch (_category)
    {
        case PlayerRadialCategory.PRIMARY: return "PRIMARY";
        case PlayerRadialCategory.SECONDARY: return "SECONDARY";
        case PlayerRadialCategory.EQUIPMENT: return "EQUIPMENT";
        case PlayerRadialCategory.DRONE: return "DRONES";
    }

    return "";
}

/// @description Returns weapon entries from one ship-loadout slot array.
function sc_player_radial_weapon_entries_get(_slots)
{
    var _entries = [];

    for (var _i = 0; _i < array_length(_slots); ++_i)
    {
        var _key = _slots[_i];
        if (is_undefined(_key)) continue;

        var _weapon = variable_struct_get(
            global.data.weapons,
            _key
        );

        array_push(_entries,{
            key: _key,
            name: _weapon.identity.name,
            slot_index: _i,
            drone_key: "",
            equipment_key: "",
            docked: 0,
            total: 0
        });
    }

    return _entries;
}

/// @description Returns unique physical drone types assigned to launch-bay slots.
function sc_player_radial_drone_entries_get(_player)
{
    var _slots = _player.inventory.drone_bay.slots;
    var _entries = [];

    for (var _i = 0; _i < array_length(_slots); ++_i)
    {
        var _slot = _slots[_i];
        var _item = undefined;

        if (_slot.state == DroneSlotState.DOCKED)
            _item = _slot.item;
        else if (instance_exists(_slot.active_id))
            _item = _slot.active_id.drone.deployment.payload;

        if (!is_struct(_item)) continue;

        var _existing = -1;

        for (var _j = 0; _j < array_length(_entries); ++_j)
        {
            if (_entries[_j].drone_key == _item.drone_key)
            {
                _existing = _j;
                break;
            }
        }

        if (_existing < 0)
        {
            array_push(_entries,{
                key: _item.key,
                name: _item.name,
                slot_index: _i,
                drone_key: _item.drone_key,
                equipment_key: _item.equipment_key,
                docked: _slot.state == DroneSlotState.DOCKED ? 1 : 0,
                total: 1
            });
        }
        else
        {
            _entries[_existing].total++;

            if (_slot.state == DroneSlotState.DOCKED)
                _entries[_existing].docked++;
        }
    }

    return _entries;
}

/// @description Returns the available entries for one radial category.
function sc_player_radial_entries_get(_player,_category)
{
    var _loadout = _player.ship.loadout;

    switch (_category)
    {
        case PlayerRadialCategory.PRIMARY:
            return sc_player_radial_weapon_entries_get(
                _loadout.primary_slots
            );

        case PlayerRadialCategory.SECONDARY:
            return sc_player_radial_weapon_entries_get(
                _loadout.secondary_slots
            );

        case PlayerRadialCategory.EQUIPMENT:
            return sc_player_radial_weapon_entries_get(
                _loadout.equipment_slots
            );

        case PlayerRadialCategory.DRONE:
            return sc_player_radial_drone_entries_get(_player);
    }

    return [];
}

/// @description Returns whether one radial entry is currently selected.
function sc_player_radial_entry_selected(_player,_category,_entry)
{
    var _loadout = _player.ship.loadout;

    switch (_category)
    {
        case PlayerRadialCategory.PRIMARY:
            return _loadout.primary == _entry.key;

        case PlayerRadialCategory.SECONDARY:
            return _loadout.secondary == _entry.key;

        case PlayerRadialCategory.EQUIPMENT:
            return _loadout.equipment == _entry.key;

        case PlayerRadialCategory.DRONE:
            return _player.inventory.drone_bay.selected.drone_key
                == _entry.drone_key;
    }

    return false;
}

/// @description Applies one selected radial loadout entry.
function sc_player_radial_entry_select(_player,_category,_entry)
{
    var _loadout = _player.ship.loadout;

    switch (_category)
    {
        case PlayerRadialCategory.PRIMARY:
            sc_player_debug_weapon_disable(_player);
            sc_player_weapon_runtime_release(_player.combat.primary);
            _loadout.primary = _entry.key;
            _loadout.primary_slot = _entry.slot_index;
            _player.combat.primary.hardpoint_cursor = 0;
            _player.combat.primary.next_fire_tick = GAME_TICK;
        break;

        case PlayerRadialCategory.SECONDARY:
            sc_player_weapon_runtime_release(_player.combat.secondary);
            _loadout.secondary = _entry.key;
            _loadout.secondary_slot = _entry.slot_index;
            _player.combat.secondary.hardpoint_cursor = 0;
            _player.combat.secondary.next_fire_tick = GAME_TICK;
        break;

        case PlayerRadialCategory.EQUIPMENT:
            sc_player_weapon_runtime_release(_player.combat.equipment);
            _loadout.equipment = _entry.key;
            _loadout.equipment_slot = _entry.slot_index;
            _player.combat.equipment.next_fire_tick = GAME_TICK;
        break;

        case PlayerRadialCategory.DRONE:
            sc_player_drone_selection_set(
                _player,
                _entry.drone_key,
                _entry.equipment_key
            );
        break;
    }

    return true;
}

/// @description Updates radial hover and left-click selection.
function sc_player_radial_selection_update(_player)
{
    var _config = GCFG.player.radial;
    var _runtime = _player.combat.radial;
    var _mouse_x = _player.aim.world_x;
    var _mouse_y = _player.aim.world_y;
    var _centre_x = _player.x+_config.dock_offset_x;
    var _centre_y = _player.y+_config.dock_offset_y;
    var _main_hover = PlayerRadialCategory.NONE;

    for (var _category = PlayerRadialCategory.PRIMARY;
    _category <= PlayerRadialCategory.DRONE;
    ++_category)
    {
        var _angle = sc_player_radial_category_angle(_category);
        var _x = _centre_x+lengthdir_x(_config.main_radius,_angle);
        var _y = _centre_y+lengthdir_y(_config.main_radius,_angle);

        if (point_distance(_mouse_x,_mouse_y,_x,_y)
        <= _config.node_radius)
        {
            _main_hover = _category;
            break;
        }
    }

    if (_main_hover != PlayerRadialCategory.NONE)
    {
        _runtime.category = _main_hover;
        _runtime.entries = sc_player_radial_entries_get(
            _player,
            _main_hover
        );
    }

    _runtime.hover_index = -1;

    if (_runtime.category == PlayerRadialCategory.NONE)
        return;

    var _entries = _runtime.entries;
    var _amount = array_length(_entries);
    var _base_angle = sc_player_radial_category_angle(
        _runtime.category
    );

    for (var _i = 0; _i < _amount; ++_i)
    {
        var _offset = (
            _i-(_amount-1)*0.5
        )*_config.submenu_spread;

        var _angle = _base_angle+_offset;
        var _x = _centre_x+lengthdir_x(
            _config.submenu_radius,
            _angle
        );

        var _y = _centre_y+lengthdir_y(
            _config.submenu_radius,
            _angle
        );

        if (point_distance(_mouse_x,_mouse_y,_x,_y)
        <= _config.child_radius)
        {
            _runtime.hover_index = _i;
            break;
        }
    }

    if (global.input.action.ui_select_pressed
    && _runtime.hover_index >= 0)
    {
        sc_player_radial_entry_select(
            _player,
            _runtime.category,
            _entries[_runtime.hover_index]
        );
    }
}

/// @description Updates Delete hold and double-tap command recognition.
function sc_player_radial_command_update(_player)
{
    var _config = GCFG.player.radial;
    var _input = global.input.action;
    var _runtime = _player.combat.radial;
    var _deployed = false;

    if (_runtime.tap_remaining > 0)
        _runtime.tap_remaining--;

    if (_input.drone_command_pressed)
    {
        if (_runtime.tap_remaining > 0
        && !_runtime.open)
        {
            _runtime.tap_remaining = 0;
            _deployed = sc_player_drone_selected_deploy(_player);
        }
        else
        {
            _runtime.tap_remaining =
                _config.double_tap_window;
        }
    }

    if (_input.drone_command_held)
    {
        _runtime.hold_frames++;

        if (_runtime.hold_frames >= _config.hold_threshold)
        {
            if (!_runtime.open)
            {
                _runtime.open = true;
                _runtime.category = PlayerRadialCategory.NONE;
                _runtime.hover_index = -1;
                _runtime.entries = [];
            }

            _runtime.tap_remaining = 0;
            sc_player_radial_selection_update(_player);
        }
    }

    if (_input.drone_command_released)
    {
        _runtime.open = false;
        _runtime.hold_frames = 0;
        _runtime.category = PlayerRadialCategory.NONE;
        _runtime.hover_index = -1;
        _runtime.entries = [];
    }

    if (!_deployed)
        sc_player_weapon_runtime_release(
            _player.combat.drone
        );

    _runtime.block_combat =
        _runtime.open
        || _input.drone_command_held;

    return _runtime.block_combat;
}

/// @description Draws one radial selection node.
function sc_player_radial_node_draw(
    _x,_y,_radius,_text,_selected,_hovered,_palette
)
{
    var _colour = _selected
        ? _palette.core
        : _palette.accent;

    gpu_set_blendmode(bm_add);
    draw_set_colour(_colour);
    draw_set_alpha(_hovered ? 0.22 : 0.09);
    draw_circle(_x,_y,_radius*1.35,false);
    gpu_set_blendmode(bm_normal);

    draw_set_colour(_palette.background);
    draw_set_alpha(0.92);
    draw_circle(_x,_y,_radius,false);

    draw_set_colour(_colour);
    draw_set_alpha(_hovered ? 1 : 0.65);
    draw_circle(_x,_y,_radius,true);

    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_colour(_hovered ? _palette.core : _palette.text);
    draw_set_alpha(1);
    draw_text(_x,_y,_text);
}

/// @description Draws the world-space loadout radial beside the player.
function sc_player_radial_draw(_player)
{
    var _runtime = _player.combat.radial;
    if (!_runtime.open) return;

    var _config = GCFG.player.radial;
    var _palette = global.level.hud.hud.data.palette;
    var _centre_x = _player.x+_config.dock_offset_x;
    var _centre_y = _player.y+_config.dock_offset_y;

    draw_set_colour(_palette.outline);
    draw_set_alpha(0.45);
    draw_line_width(
        _player.x+_player.ship.collision.radius_forward,
        _player.y,
        _centre_x,
        _centre_y,
        1
    );

    gpu_set_blendmode(bm_add);
    draw_set_colour(_palette.accent);
    draw_set_alpha(0.08);
    draw_circle(_centre_x,_centre_y,38,false);
    gpu_set_blendmode(bm_normal);

    draw_set_colour(_palette.background);
    draw_set_alpha(0.92);
    draw_circle(_centre_x,_centre_y,32,false);

    draw_set_colour(_palette.accent);
    draw_set_alpha(0.8);
    draw_circle(_centre_x,_centre_y,32,true);

    for (var _category = PlayerRadialCategory.PRIMARY;
    _category <= PlayerRadialCategory.DRONE;
    ++_category)
    {
        var _angle = sc_player_radial_category_angle(_category);
        var _x = _centre_x+lengthdir_x(_config.main_radius,_angle);
        var _y = _centre_y+lengthdir_y(_config.main_radius,_angle);

        draw_set_colour(_palette.outline);
        draw_set_alpha(0.32);
        draw_line_width(_centre_x,_centre_y,_x,_y,1);

        sc_player_radial_node_draw(
            _x,
            _y,
            _config.node_radius,
            sc_player_radial_category_name(_category),
            _runtime.category == _category,
            _runtime.category == _category,
            _palette
        );
    }

    if (_runtime.category != PlayerRadialCategory.NONE)
    {
        var _entries = _runtime.entries;
        var _amount = array_length(_entries);
        var _base_angle = sc_player_radial_category_angle(
            _runtime.category
        );

        for (var _i = 0; _i < _amount; ++_i)
        {
            var _entry = _entries[_i];
            var _offset = (
                _i-(_amount-1)*0.5
            )*_config.submenu_spread;

            var _angle = _base_angle+_offset;
            var _x = _centre_x+lengthdir_x(
                _config.submenu_radius,
                _angle
            );

            var _y = _centre_y+lengthdir_y(
                _config.submenu_radius,
                _angle
            );

            var _text = _entry.name;

            if (_runtime.category == PlayerRadialCategory.DRONE)
            {
                _text += "\n"
                    +string(_entry.docked)
                    +"/"
                    +string(_entry.total);
            }

            draw_set_colour(_palette.outline);
            draw_set_alpha(0.25);
            draw_line_width(_centre_x,_centre_y,_x,_y,1);

            sc_player_radial_node_draw(
                _x,
                _y,
                _config.child_radius,
                _text,
                sc_player_radial_entry_selected(
                    _player,
                    _runtime.category,
                    _entry
                ),
                _runtime.hover_index == _i,
                _palette
            );
        }
    }

    draw_set_alpha(1);
    draw_set_colour(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}