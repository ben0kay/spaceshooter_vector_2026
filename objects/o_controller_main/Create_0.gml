if (instance_number(o_controller_main) > 1)
{
    instance_destroy();
    exit;
}

persistent = true;

if (!sc_game_init())
{
    show_debug_message("GAME INITIALIZATION FAILED");
    game_end();
    exit;
}

global.GameState = GameState.PLAYING;
room_goto(r_combat_test);
