initialized = false;

if (!variable_instance_exists(id, "ship_key"))
{
    show_debug_message("PLAYER INITIALIZATION ERROR - ship_key creation variable missing");
    instance_destroy();
    exit;
}

if (!sc_player_init(id, ship_key))
{
    instance_destroy();
    exit;
}

health_bar = sc_health_bar_create(true);
health_bar.width = max(72, ship.collision.radius * 2.2);