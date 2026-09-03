/// @description Initializes one generic cosmetic shockwave.
initialized = false;

if (!is_struct(shockwave_create) || !sc_shockwave_init(id, shockwave_create))
    instance_destroy();