/// @description Updates the main menu and provides temporary boss-test access.
menu.update();

if (keyboard_check_pressed(ord("B")))
{
    global.GameState = GameState.PLAYING;
    global.LevelState = LevelState.INITIALIZING;
    room_goto(r_boss_test);
}