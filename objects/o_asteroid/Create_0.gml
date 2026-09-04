/// @description Initializes one generic asteroid and registers it with the level.
initialized = false;
level_counted = false;

if (!is_struct(asteroid_create) || !sc_asteroid_init(id, asteroid_create))
{
    show_debug_message("ASTEROID INITIALIZATION ERROR");
    instance_destroy();
    exit;
}

global.level.asteroids_alive++;
level_counted = true;