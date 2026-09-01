function sc_ship_select(_owner_id, _spawn_x, _spawn_y)
{
    var _select = {
        owner_id: _owner_id,
        available_ships: [],
        selected_index: 0,

        spawn: {
            x: _spawn_x,
            y: _spawn_y
        },

        layout: {
            card_width: 430,
            card_height: 570,
            card_gap: 28,
            deploy_width: 360,
            deploy_height: 76
        }
    };

    for (var _i = 0; _i < array_length(global.profile.unlocked_ship_keys); _i++)
    {
        var _key = global.profile.unlocked_ship_keys[_i];
        if (!variable_struct_exists(global.data.ships, _key)) continue;

        array_push(_select.available_ships, _key);

        if (_key == global.profile.selected_ship_key)
            _select.selected_index = array_length(_select.available_ships) - 1;
    }

    if (array_length(_select.available_ships) <= 0)
    {
        show_debug_message("SHIP SELECT ERROR - profile has no valid unlocked ships");
        return undefined;
    }

    _select.cancel = method(_select, function()
    {
        global.LevelState = LevelState.EXITING;
        global.GameState = GameState.MENU;
        room_goto(r_menu_main);
    });

    _select.confirm = method(_select, function()
    {
        var _ship_key = available_ships[selected_index];
        var _player = instance_create_layer(spawn.x, spawn.y, "Instances", o_player, {
            ship_key: _ship_key
        });

        if (!instance_exists(_player) || !_player.initialized)
        {
            show_debug_message("SHIP SELECT ERROR - player creation failed");
            global.LevelState = LevelState.FAILED;
            return false;
        }

        global.profile.selected_ship_key = _ship_key;
        sc_profile_save();

        global.level.player = _player;
        global.level.selected_ship_key = _ship_key;
        global.level.ship_selector = noone;
        global.level.initialized = true;

        global.PlayerState = PlayerState.ACTIVE;
        global.LevelState = LevelState.PLAYING;

        // Insert deployment audio and effects here.

        show_debug_message("SHIP SELECTED - " + _ship_key);
        instance_destroy(owner_id);
        return true;
    });

    _select.update = method(_select, function()
    {
        if (global.LevelState != LevelState.SHIP_SELECT) return;

        var _count = array_length(available_ships);

        if (keyboard_check_pressed(vk_left))
            selected_index = (selected_index - 1 + _count) mod _count;

        if (keyboard_check_pressed(vk_right))
            selected_index = (selected_index + 1) mod _count;

        if (keyboard_check_pressed(vk_escape))
        {
            cancel();
            return;
        }

        if (keyboard_check_pressed(vk_enter))
        {
            confirm();
            return;
        }

        if (!mouse_check_button_pressed(mb_left)) return;

        var _gui_w = display_get_gui_width();
        var _gui_h = display_get_gui_height();
        var _total_w = _count * layout.card_width + (_count - 1) * layout.card_gap;
        var _start_x = (_gui_w - _total_w) * 0.5;
        var _card_y = _gui_h * 0.23;
        var _deploy_x1 = (_gui_w - layout.deploy_width) * 0.5;
        var _deploy_y1 = min(_card_y + layout.card_height + 42, _gui_h - layout.deploy_height - 45);
        var _mx = device_mouse_x_to_gui(0);
        var _my = device_mouse_y_to_gui(0);

        for (var _i = 0; _i < _count; _i++)
        {
            var _x1 = _start_x + _i * (layout.card_width + layout.card_gap);

            if (_mx < _x1 || _mx > _x1 + layout.card_width) continue;
            if (_my < _card_y || _my > _card_y + layout.card_height) continue;

            selected_index = _i;
            return;
        }

        if (_mx >= _deploy_x1 && _mx <= _deploy_x1 + layout.deploy_width &&
            _my >= _deploy_y1 && _my <= _deploy_y1 + layout.deploy_height)
        {
            confirm();
        }
    });

    _select.draw_ship = method(_select, function(_ship, _x, _y)
    {
        var _radius = 62 * _ship.visual.scale;
        var _primary = _ship.visual.colour_primary;
        var _secondary = _ship.visual.colour_secondary;

        draw_set_colour(make_colour_rgb(4, 12, 23));
        draw_circle(_x, _y, _radius * 1.1, false);

        draw_set_colour(_primary);
        draw_triangle(_x + _radius, _y, _x - _radius * 0.72, _y - _radius * 0.58, _x - _radius * 0.32, _y, false);
        draw_triangle(_x + _radius, _y, _x - _radius * 0.32, _y, _x - _radius * 0.72, _y + _radius * 0.58, false);

        draw_set_colour(_secondary);
        draw_line_width(_x - _radius * 0.36, _y - _radius * 0.35, _x + _radius * 0.38, _y, 3);
        draw_line_width(_x - _radius * 0.36, _y + _radius * 0.35, _x + _radius * 0.38, _y, 3);

        draw_set_colour(c_white);
        draw_circle(_x, _y, _radius * 0.16, false);
    });

    _select.draw = method(_select, function()
    {
        if (global.LevelState != LevelState.SHIP_SELECT) return;

        var _gui_w = display_get_gui_width();
        var _gui_h = display_get_gui_height();
        var _gui_cx = _gui_w * 0.5;
        var _count = array_length(available_ships);
        var _total_w = _count * layout.card_width + (_count - 1) * layout.card_gap;
        var _start_x = (_gui_w - _total_w) * 0.5;
        var _card_y = _gui_h * 0.23;
        var _deploy_x1 = (_gui_w - layout.deploy_width) * 0.5;
        var _deploy_y1 = min(_card_y + layout.card_height + 42, _gui_h - layout.deploy_height - 45);
        var _mx = device_mouse_x_to_gui(0);
        var _my = device_mouse_y_to_gui(0);
        var _aqua = make_colour_rgb(35, 220, 255);
        var _panel = make_colour_rgb(7, 19, 34);
        var _panel_selected = make_colour_rgb(12, 38, 58);

        draw_set_alpha(0.9);
        draw_set_colour(c_black);
        draw_rectangle(0, 0, _gui_w, _gui_h, false);
        draw_set_alpha(1);

        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);

        draw_set_colour(_aqua);
        draw_text(_gui_cx, _gui_h * 0.075, "SELECT COMBAT CHASSIS");

        draw_set_colour(c_ltgray);
        draw_text(_gui_cx, _gui_h * 0.135, "CHOOSE A SHIP FOR THIS DEPLOYMENT");

        for (var _i = 0; _i < _count; _i++)
        {
            var _ship_key = available_ships[_i];
            var _ship = variable_struct_get(global.data.ships, _ship_key);
            var _stats = _ship.stats_base;
            var _x1 = _start_x + _i * (layout.card_width + layout.card_gap);
            var _x2 = _x1 + layout.card_width;
            var _y2 = _card_y + layout.card_height;
            var _cx = (_x1 + _x2) * 0.5;
            var _selected = selected_index == _i;
            var _hover = _mx >= _x1 && _mx <= _x2 && _my >= _card_y && _my <= _y2;
            var _colour = _ship.visual.colour_primary;

            draw_set_colour(_selected ? _panel_selected : _panel);
            draw_roundrect(_x1, _card_y, _x2, _y2, false);

            draw_set_colour(_selected || _hover ? c_white : _colour);
            draw_roundrect(_x1, _card_y, _x2, _y2, true);

            draw_ship(_ship, _cx, _card_y + 135);

            draw_set_colour(c_white);
            draw_text(_cx, _card_y + 245, string_upper(_ship.identity.name));

            draw_set_colour(c_ltgray);
            draw_text_ext(_cx, _card_y + 290, _ship.identity.description, 24, layout.card_width - 60);

            draw_set_colour(_colour);
            draw_text(_cx, _card_y + 385, "HULL      " + string(_stats.hull_max));
            draw_text(_cx, _card_y + 420, "ARMOUR    " + string(_stats.armour_max));
            draw_text(_cx, _card_y + 455, "SHIELD    " + string(_stats.shield_max));
            draw_text(_cx, _card_y + 490, "SPEED     " + string(_stats.speed_max));

            draw_set_colour(_selected ? c_white : c_gray);
            draw_text(_cx, _card_y + 540, _selected ? "[ SELECTED ]" : "SELECT");
        }

        var _deploy_hover = _mx >= _deploy_x1 && _mx <= _deploy_x1 + layout.deploy_width &&
            _my >= _deploy_y1 && _my <= _deploy_y1 + layout.deploy_height;

        draw_set_colour(_deploy_hover ? make_colour_rgb(15, 55, 75) : _panel);
        draw_roundrect(_deploy_x1, _deploy_y1, _deploy_x1 + layout.deploy_width, _deploy_y1 + layout.deploy_height, false);

        draw_set_colour(_deploy_hover ? c_white : _aqua);
        draw_roundrect(_deploy_x1, _deploy_y1, _deploy_x1 + layout.deploy_width, _deploy_y1 + layout.deploy_height, true);
        draw_text(_gui_cx, _deploy_y1 + layout.deploy_height * 0.5, "DEPLOY");

        draw_set_colour(c_gray);
        draw_text(_gui_cx, _gui_h - 25, "ARROW KEYS TO SELECT     ENTER TO DEPLOY     ESCAPE TO RETURN");

        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        draw_set_alpha(1);
        draw_set_colour(c_white);
    });

    return _select;
}