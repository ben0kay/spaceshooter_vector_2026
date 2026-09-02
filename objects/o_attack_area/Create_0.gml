/// @description Initializes one generic attack area.
initialized = false;

if (!is_struct(attack_area_create) || !sc_attack_area_init(id, attack_area_create))
    instance_destroy();