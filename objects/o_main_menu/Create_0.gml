if (!is_struct(global.profile))
{
    room_goto(r_boot);
    exit;
}

global.GameState = GameState.MENU;
global.LevelState = LevelState.NONE;
global.PlayerState = PlayerState.INITIALIZING;

menu = sc_menu_main();