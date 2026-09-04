/// @description Initializes one generic asteroid.
initialized = false;

if (!is_struct(asteroid_create) || !sc_asteroid_init(id, asteroid_create))
{
    show_debug_message("ASTEROID INITIALIZATION ERROR");
    instance_destroy();
    exit;
}