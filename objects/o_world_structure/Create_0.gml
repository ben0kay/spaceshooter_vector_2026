/// @description Initializes one registered static world structure.
initialized = sc_world_structure_init(id, structure_create);

if (!initialized)
    instance_destroy();