/// @description Initializes one deployed drone.
initialized = sc_drone_init(id, drone_create);

if (!initialized)
    instance_destroy();