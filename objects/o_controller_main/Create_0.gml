if (instance_number(o_controller_main) > 1)
{
    instance_destroy();
    exit;
}

persistent = true;
display_set_gui_size(1920, 1080);

if (!sc_game_init())
{
    show_debug_message("GAME INITIALIZATION FAILED");
    game_end();
    exit;
}