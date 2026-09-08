/*
DERELICTS AND SCANNING DRONES

Derelicts inherit stationary structure behavior.
Scanner drones reveal hidden derelict cargo before salvage becomes available.
*/

/// @description Registers the first test derelict.
function sc_world_structure_register_derelict()
{
    return sc_world_structure_register({
        identity: {
            key: "derelict_test",
            name: "Unknown Derelict"
        },

        derelict: {
            hull: 300,
            interaction_radius: 650,
            tether_range: 1500,
            scan_distance: 190,
            scan_duration: 300
        },

        visual: {
            canvas_width: 560,
            canvas_height: 340,
            palette: sc_faction_palette_get(Faction.REBEL),
            draw_script: sc_derelict_test_primitive_draw,

            motion: {
                side_amount: 1.5,
                side_speed: 0.005,
                forward_amount: 1,
                forward_speed: 0.004,
                angle_amount: 0.15,
                angle_speed: 0.003
            }
        },

        collision: {
            broad_radius: 240,

            parts: [
                { key: "hull", shape: StructureCollisionShape.RECTANGLE, forward: 0, side: 0, width: 350, height: 115, angle: 0 },
                { key: "wreck_front", shape: StructureCollisionShape.RECTANGLE, forward: 165, side: -25, width: 150, height: 80, angle: -12 },
                { key: "wreck_rear", shape: StructureCollisionShape.RECTANGLE, forward: -170, side: 20, width: 125, height: 135, angle: 8 }
            ]
        }
    });
}

/// @description Draws the first damaged derelict fallback.
function sc_derelict_test_primitive_draw(_x, _y, _visual)
{
    var _p = _visual.palette;
    var _dark = merge_colour(_p.hull_dark, c_black, 0.5);
    var _rust = make_colour_rgb(122, 70, 38);
    var _damage = make_colour_rgb(34, 28, 25);

    draw_set_colour(_dark);
    draw_rectangle(_x - 210, _y - 58, _x + 175, _y + 58, false);

    draw_set_colour(_p.hull_mid);
    draw_triangle(_x - 205, _y - 48, _x + 205, _y - 30, _x + 145, _y + 43, false);
    draw_triangle(_x - 185, _y + 47, _x + 145, _y + 43, _x - 35, _y + 78, false);

    draw_set_colour(_p.hull_light);
    draw_rectangle(_x - 110, _y - 43, _x + 20, _y + 38, false);

    draw_set_colour(_damage);
    draw_triangle(_x + 88, _y - 47, _x + 145, _y - 35, _x + 105, _y + 18, false);
    draw_triangle(_x - 185, _y + 18, _x - 125, _y + 52, _x - 150, _y - 12, false);

    draw_set_colour(_rust);
    draw_line_width(_x - 160, _y - 38, _x - 55, _y + 42, 7);
    draw_line_width(_x + 20, _y - 38, _x + 115, _y + 32, 5);

    draw_set_colour(_p.outline);
    draw_line_width(_x - 210, _y - 58, _x + 175, _y - 58, 3);
    draw_line_width(_x - 210, _y + 58, _x + 145, _y + 58, 3);

    for (var _i = 0; _i < 5; ++_i)
    {
        var _panel_x = _x - 92 + _i * 48;

        draw_set_colour(_dark);
        draw_rectangle(_panel_x, _y - 25, _panel_x + 32, _y + 24, false);

        draw_set_colour(_p.outline);
        draw_rectangle(_panel_x, _y - 25, _panel_x + 32, _y + 24, true);
    }

    draw_set_colour(_p.energy);
    draw_set_alpha(0.45);
    draw_line_width(_x - 80, _y, _x - 15, _y, 3);

    draw_set_alpha(1);
    draw_set_colour(c_white);
}

/// @description Initializes hidden cargo and defence for one derelict.
function sc_derelict_init(_derelict)
{
    var _definition = _derelict.structure.data.derelict;

    _derelict.structure.damage_script = sc_derelict_damage;
    _derelict.derelict = {
        state: DerelictState.UNKNOWN,
        scanner_id: noone,
        scan_progress: 0,
        scan_duration: _definition.scan_duration,
        hull: {
            current: _definition.hull,
            maximum: _definition.hull
        },

        loot: [
            { key: "item_refined_iron", amount: 2, grade: undefined },
            { key: "item_copper_wire", amount: 3, grade: undefined },
            { key: "item_circuit_board", amount: 1, grade: undefined },
            { key: "item_armour_plate", amount: 1, grade: ItemGrade.COMMON }
        ],

        health_bar_remaining: 0
    };

    return true;
}

/// @description Applies direct projectile damage to one derelict hull.
function sc_derelict_damage(_derelict, _packet, _impact = undefined)
{
    var _runtime = _derelict.derelict;
    if (_runtime.state == DerelictState.DESTROYED) return false;

    var _result = sc_damage_resolve(_packet, 0, 0, _runtime.hull.current);

    _runtime.hull.current = _result.hull;
    _runtime.health_bar_remaining = 120;

    if (_runtime.hull.current <= 0)
    {
        _runtime.hull.current = 0;
        _runtime.state = DerelictState.DESTROYED;
        instance_destroy(_derelict);
    }

    return _result;
}

/// @description Updates temporary derelict visual runtime.
function sc_derelict_update(_derelict)
{
    var _runtime = _derelict.derelict;

    if (_runtime.health_bar_remaining > 0)
        _runtime.health_bar_remaining--;

    if (_runtime.state == DerelictState.SCANNING
    && !instance_exists(_runtime.scanner_id))
    {
        _runtime.state = DerelictState.UNKNOWN;
        _runtime.scan_progress = 0;
        _runtime.scanner_id = noone;
    }
}

/// @description Draws derelict health and scanning progress.
function sc_derelict_runtime_draw(_derelict)
{
    var _runtime = _derelict.derelict;

    if (_runtime.health_bar_remaining > 0)
    {
        var _ratio = _runtime.hull.current / _runtime.hull.maximum;
        var _width = 180;
        var _x = _derelict.x - _width * 0.5;
        var _y = _derelict.y - 150;

        draw_set_colour(c_black);
        draw_rectangle(_x - 2, _y - 2, _x + _width + 2, _y + 10, false);

        draw_set_colour(make_colour_rgb(45, 205, 215));
        draw_rectangle(_x, _y, _x + _width * _ratio, _y + 8, false);
    }

    if (_runtime.state == DerelictState.SCANNING)
    {
        var _ratio = _runtime.scan_progress / _runtime.scan_duration;
        var _width = 220;
        var _x = _derelict.x - _width * 0.5;
        var _y = _derelict.y + 150;

        draw_set_colour(c_black);
        draw_rectangle(_x - 2, _y - 2, _x + _width + 2, _y + 12, false);

        draw_set_colour(make_colour_rgb(0, 225, 240));
        draw_rectangle(_x, _y, _x + _width * _ratio, _y + 10, false);

        draw_set_halign(fa_center);
        draw_set_colour(make_colour_rgb(175, 255, 255));
        draw_text(_derelict.x, _y + 24, "SCANNING  " + string(round(_ratio * 100)) + "%");
        draw_set_halign(fa_left);
    }

    draw_set_colour(c_white);
    draw_set_alpha(1);
}

/// @description Begins scanning one unknown derelict.
function sc_derelict_scan_begin(_derelict, _player)
{
    var _runtime = _derelict.derelict;

    if (_runtime.state != DerelictState.UNKNOWN
    || sc_player_inventory_item_count(_player, "item_scanning_drone") <= 0)
        return false;

    var _drone = instance_create_layer(
        _player.x,
        _player.y,
        _derelict.layer,
        o_drone,
        {
            drone_create: {
                role: DroneRole.SCANNER,
                owner_id: _player,
                target_id: _derelict
            }
        }
    );

    if (!instance_exists(_drone)) return false;

    _runtime.state = DerelictState.SCANNING;
    _runtime.scanner_id = _drone;
    _runtime.scan_progress = 0;
    return true;
}

/// @description Creates HUD runtime for derelict interaction.
function sc_derelict_hud_init(_hud)
{
    _hud.derelict = {
        nearby_id: noone,
        active_id: noone,
        next_scan_tick: GAME_TICK,
        scan_interval: 10,
        open: false
    };
}

/// @description Finds the nearest interactable derelict.
function sc_derelict_nearest_find(_player)
{
    var _nearest = noone;
    var _nearest_distance = 999999999999;
    var _count = instance_number(o_derelict);

    for (var _i = 0; _i < _count; ++_i)
    {
        var _derelict = instance_find(o_derelict, _i);
        var _state = _derelict.derelict.state;
        var _radius = _derelict.structure.data.derelict.interaction_radius;
        var _distance = sc_point_distance_sq(_player.x, _player.y, _derelict.x, _derelict.y);

        if (_state == DerelictState.DEPLETED
        || _state == DerelictState.DESTROYED
        || _distance > sqr(_radius)
        || _distance >= _nearest_distance)
            continue;

        _nearest = _derelict;
        _nearest_distance = _distance;
    }

    return _nearest;
}

/// @description Transfers one derelict cargo entry to the player.
function sc_derelict_loot_take(_derelict, _player, _index)
{
    var _loot = _derelict.derelict.loot;
    if (_index < 0 || _index >= array_length(_loot)) return false;

    var _entry = _loot[_index];
    var _grade = is_undefined(_entry.grade) ? ItemGrade.COMMON : _entry.grade;
    var _result = sc_player_inventory_add(_player, _entry.key, _entry.amount, _grade);

    _entry.amount = _result.remaining;

    if (_entry.amount <= 0)
        array_delete(_loot, _index, 1);

    if (array_length(_loot) <= 0)
        _derelict.derelict.state = DerelictState.DEPLETED;

    return _result.accepted > 0;
}

/// @description Transfers all fitting derelict cargo to the player.
function sc_derelict_loot_take_all(_derelict, _player)
{
    var _loot = _derelict.derelict.loot;

    for (var _i = array_length(_loot) - 1; _i >= 0; --_i)
        sc_derelict_loot_take(_derelict, _player, _i);
}

/// @description Opens one revealed derelict inventory.
function sc_derelict_interface_open(_hud, _derelict)
{
    sc_player_control_suspend(global.player_id);

    _hud.derelict.open = true;
    _hud.derelict.active_id = _derelict;
    global.PlayerState = PlayerState.DERELICT;
}

/// @description Closes the derelict salvage interface.
function sc_derelict_interface_close(_hud)
{
    _hud.derelict.open = false;
    _hud.derelict.active_id = noone;
    global.PlayerState = PlayerState.ACTIVE;
    sc_player_combat_permission_update(global.player_id);
}

/// @description Updates scanning prompts and the salvage interface.
function sc_derelict_interaction_update(_hud)
{
    var _runtime = _hud.derelict;

    if (global.PlayerState == PlayerState.DERELICT)
    {
        if (!instance_exists(_runtime.active_id)
        || global.input.action.interact_pressed
        || global.input.action.inventory_pressed)
        {
            sc_derelict_interface_close(_hud);
            return;
        }

        var _mouse_x = device_mouse_x_to_gui(0);
        var _mouse_y = device_mouse_y_to_gui(0);
        var _panel_x = (display_get_gui_width() - 980) * 0.5;
        var _panel_y = (display_get_gui_height() - 560) * 0.5;

        if (!global.input.action.ui_select_pressed) return;

        if (point_in_rectangle(_mouse_x, _mouse_y, _panel_x + 920, _panel_y + 18, _panel_x + 960, _panel_y + 58))
        {
            sc_derelict_interface_close(_hud);
            return;
        }

        var _loot = _runtime.active_id.derelict.loot;

        for (var _i = 0; _i < array_length(_loot); ++_i)
        {
            var _row_y = _panel_y + 150 + _i * 70;

            if (point_in_rectangle(_mouse_x, _mouse_y, _panel_x + 820, _row_y + 12, _panel_x + 930, _row_y + 52))
            {
                sc_derelict_loot_take(_runtime.active_id, global.player_id, _i);
                break;
            }
        }

        if (point_in_rectangle(_mouse_x, _mouse_y, _panel_x + 710, _panel_y + 490, _panel_x + 930, _panel_y + 535))
            sc_derelict_loot_take_all(_runtime.active_id, global.player_id);

        if (_runtime.active_id.derelict.state == DerelictState.DEPLETED)
            sc_derelict_interface_close(_hud);

        return;
    }

    if (global.PlayerState != PlayerState.ACTIVE) return;

    if (GAME_TICK >= _runtime.next_scan_tick)
    {
        _runtime.nearby_id = sc_derelict_nearest_find(global.player_id);
        _runtime.next_scan_tick = GAME_TICK + _runtime.scan_interval;
    }

    if (!global.input.action.interact_pressed
    || !instance_exists(_runtime.nearby_id))
        return;

    var _derelict = _runtime.nearby_id;

    switch (_derelict.derelict.state)
    {
        case DerelictState.UNKNOWN:
            sc_derelict_scan_begin(_derelict, global.player_id);
        break;

        case DerelictState.REVEALED:
            sc_derelict_interface_open(_hud, _derelict);
        break;
    }
}

/// @description Draws the contextual derelict prompt.
function sc_derelict_prompt_draw(_hud)
{
    if (global.PlayerState != PlayerState.ACTIVE
    || !instance_exists(_hud.derelict.nearby_id))
        return;

    var _derelict = _hud.derelict.nearby_id;
    var _state = _derelict.derelict.state;
    var _text = "";

    switch (_state)
    {
        case DerelictState.UNKNOWN:
            _text = sc_player_inventory_item_count(global.player_id, "item_scanning_drone") > 0
                ? "[F]  DEPLOY SCANNING DRONE"
                : "SCANNING DRONE REQUIRED";
        break;

        case DerelictState.SCANNING:
            _text = "DRONE SCAN IN PROGRESS";
        break;

        case DerelictState.REVEALED:
            _text = "[F]  VIEW DERELICT SALVAGE";
        break;
    }

    draw_set_halign(fa_center);
    draw_set_colour(make_colour_rgb(175, 255, 255));
    draw_text(display_get_gui_width() * 0.5, display_get_gui_height() - 150, _text);
    draw_set_halign(fa_left);
    draw_set_colour(c_white);
}

/// @description Draws the first derelict salvage-transfer interface.
function sc_derelict_interface_draw(_hud)
{
    var _runtime = _hud.derelict;
    if (!_runtime.open || !instance_exists(_runtime.active_id)) return;

    var _palette = _hud.data.palette;
    var _player = global.player_id;
    var _derelict = _runtime.active_id;
    var _loot = _derelict.derelict.loot;
    var _width = 980;
    var _height = 560;
    var _x = floor((display_get_gui_width() - _width) * 0.5);
    var _y = floor((display_get_gui_height() - _height) * 0.5);

    draw_set_alpha(0.97);
    draw_set_colour(_palette.background);
    draw_rectangle(_x, _y, _x + _width, _y + _height, false);

    draw_set_alpha(1);
    draw_set_colour(_palette.outline);
    draw_rectangle(_x, _y, _x + _width, _y + _height, true);
    draw_line(_x + 490, _y + 100, _x + 490, _y + 535);

    draw_set_colour(_palette.accent);
    draw_text(_x + 28, _y + 32, "SHIP CARGO");
    draw_text(_x + 520, _y + 32, "DERELICT SALVAGE");

    draw_set_colour(_palette.muted);
    draw_text(_x + 28, _y + 68, "MASS  " + string(round(_player.resources.cargo.weight)) + " / " + string(round(_player.resources.cargo.capacity)));
    draw_text(_x + 520, _y + 68, "SCAN COMPLETE // CONTENTS RECOVERABLE");

    draw_set_colour(make_colour_rgb(230, 100, 115));
    draw_rectangle(_x + 920, _y + 18, _x + 960, _y + 58, true);
    draw_set_halign(fa_center);
    draw_text(_x + 940, _y + 38, "X");
    draw_set_halign(fa_left);

    var _shown = 0;

    for (var _i = 0; _i < array_length(_player.inventory.slots) && _shown < 10; ++_i)
    {
        var _slot = _player.inventory.slots[_i];
        if (is_undefined(_slot)) continue;

        var _row_y = _y + 125 + _shown * 36;
        draw_set_colour(_palette.text);
        draw_text(_x + 30, _row_y, _slot.name);

        draw_set_halign(fa_right);
        draw_text(_x + 455, _row_y, "x" + string(_slot.amount));
        draw_set_halign(fa_left);
        _shown++;
    }

    for (var _i = 0; _i < array_length(_loot); ++_i)
    {
        var _entry = _loot[_i];
        var _definition = variable_struct_get(global.data.items, _entry.key);
        var _row_y = _y + 150 + _i * 70;

        draw_set_colour(_palette.panel);
        draw_rectangle(_x + 520, _row_y, _x + 940, _row_y + 62, false);

        draw_set_colour(_palette.outline);
        draw_rectangle(_x + 520, _row_y, _x + 940, _row_y + 62, true);

        draw_set_colour(_palette.text);
        draw_text(_x + 540, _row_y + 14, _definition.identity.name);
        draw_text(_x + 540, _row_y + 39, "QUANTITY  x" + string(_entry.amount));

        draw_set_colour(_palette.accent);
        draw_rectangle(_x + 820, _row_y + 12, _x + 930, _row_y + 52, true);
        draw_set_halign(fa_center);
        draw_text(_x + 875, _row_y + 32, "TAKE");
        draw_set_halign(fa_left);
    }

    draw_set_colour(_palette.accent);
    draw_rectangle(_x + 710, _y + 490, _x + 930, _y + 535, true);
    draw_set_halign(fa_center);
    draw_text(_x + 820, _y + 512, "TAKE ALL");
    draw_set_halign(fa_left);

    draw_set_alpha(1);
    draw_set_colour(c_white);
}