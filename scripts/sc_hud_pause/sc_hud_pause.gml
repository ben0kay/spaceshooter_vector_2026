/// @description Creates the level pause-menu runtime.
function sc_pause_menu_create()
{
    return {
        width: 500,
        height: 430,

        buttons: {
            resume: sc_gui_button_create(
                "resume",
                55,170,
                390,54,
                "RESUME",
                GUIButtonStyle.PRIMARY
            ),

            main_menu: sc_gui_button_create(
                "main_menu",
                55,244,
                390,54,
                "EXIT TO MAIN MENU",
                GUIButtonStyle.STANDARD
            ),

            exit_game: sc_gui_button_create(
                "exit_game",
                55,318,
                390,54,
                "EXIT GAME",
                GUIButtonStyle.DANGER
            )
        }
    };
}

/// @description Enables or freezes every shared particle system.
function sc_pause_particles_set(_enabled)
{
    if (!variable_global_exists("particles")
    || !is_struct(global.particles))
        return;

    var _system = global.particles.system;
    var _impact_system = global.particles.impact_system;
    var _hud_system = global.particles.hud_system;

    if (part_system_exists(_system))
        part_system_automatic_update(_system,_enabled);

    if (part_system_exists(_impact_system))
        part_system_automatic_update(_impact_system,_enabled);

    if (part_system_exists(_hud_system))
        part_system_automatic_update(_hud_system,_enabled);
}

/// @description Opens the pause menu and freezes the level simulation.
function sc_pause_menu_open()
{
    if (global.GameState != GameState.PLAYING
    || global.LevelState != LevelState.PLAYING)
        return false;

    global.LevelState = LevelState.PAUSED;
    sc_pause_particles_set(false);
    return true;
}

/// @description Closes the pause menu and resumes the level simulation.
function sc_pause_menu_resume()
{
    if (global.LevelState != LevelState.PAUSED)
        return false;

    sc_pause_particles_set(true);
    global.LevelState = LevelState.PLAYING;
    return true;
}

/// @description Leaves the current level and returns to the main menu.
function sc_pause_menu_exit_to_main()
{
    sc_pause_particles_set(true);

    if (instance_exists(global.player_id))
        global.player_id.persistent = false;

    global.PlayerState = PlayerState.INITIALIZING;
    global.LevelState = LevelState.EXITING;
    global.GameState = GameState.MENU;

    room_goto(r_menu_main);
}

/// @description Updates pause-menu button interaction.
function sc_pause_menu_update(_hud)
{
    var _menu = _hud.pause_menu;
    var _panel_x = floor((display_get_gui_width() - _menu.width) * 0.5);
    var _panel_y = floor((display_get_gui_height() - _menu.height) * 0.5);
    var _mouse_x = device_mouse_x_to_gui(0) - _panel_x;
    var _mouse_y = device_mouse_y_to_gui(0) - _panel_y;
    var _pressed = mouse_check_button_pressed(mb_left);

    if (sc_gui_button_update(_menu.buttons.resume,_mouse_x,_mouse_y,_pressed))
    {
        sc_pause_menu_resume();
        return;
    }

    if (sc_gui_button_update(_menu.buttons.main_menu,_mouse_x,_mouse_y,_pressed))
    {
        sc_pause_menu_exit_to_main();
        return;
    }

    if (sc_gui_button_update(_menu.buttons.exit_game,_mouse_x,_mouse_y,_pressed))
        game_end();
}

/// @description Draws the paused-level overlay and vector menu.
function sc_pause_menu_draw(_hud)
{
    if (global.LevelState != LevelState.PAUSED)
        return;

    var _menu = _hud.pause_menu;
    var _palette = _hud.data.palette;
    var _gui_width = display_get_gui_width();
    var _gui_height = display_get_gui_height();
    var _x = floor((_gui_width - _menu.width) * 0.5);
    var _y = floor((_gui_height - _menu.height) * 0.5);
    var _x2 = _x + _menu.width;
    var _y2 = _y + _menu.height;
    var _centre_x = _x + _menu.width * 0.5;

    draw_set_alpha(0.7);
    draw_set_colour(c_black);
    draw_rectangle(0,0,_gui_width,_gui_height,false);

    draw_set_alpha(0.97);
    draw_set_colour(_palette.panel);
    draw_rectangle(_x,_y,_x2,_y2,false);

    draw_set_alpha(1);
    draw_set_colour(_palette.outline);
    draw_rectangle(_x,_y,_x2,_y2,true);

    draw_set_colour(_palette.accent);
    draw_line_width(_x + 24,_y,_x + 150,_y,3);
    draw_line_width(_x2 - 150,_y,_x2 - 24,_y,3);
    draw_line_width(_x + 24,_y2,_x + 105,_y2,2);
    draw_line_width(_x2 - 105,_y2,_x2 - 24,_y2,2);

    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_colour(_palette.core);
    draw_text(_centre_x,_y + 58,"LEVEL PAUSED");

    draw_set_colour(_palette.muted);
    draw_text(_centre_x,_y + 103,"SIMULATION SUSPENDED");

    sc_gui_button_draw(_menu.buttons.resume,_x,_y,_palette);
    sc_gui_button_draw(_menu.buttons.main_menu,_x,_y,_palette);
    sc_gui_button_draw(_menu.buttons.exit_game,_x,_y,_palette);

    draw_set_colour(_palette.muted);
    draw_text(_centre_x,_y2 - 28,"ESC  /  RESUME");

    draw_set_alpha(1);
    draw_set_colour(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}