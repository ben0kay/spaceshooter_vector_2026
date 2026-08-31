initialized = false;

if (!variable_instance_exists(id, "ship_key"))
{
    show_debug_message("PLAYER INITIALIZATION ERROR - ship_key creation variable missing");
    instance_destroy();
    exit;
}

if (!sc_player_init(id, ship_key))
    instance_destroy();
