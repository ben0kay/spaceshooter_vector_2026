initialized = false;

if (!is_struct(projectile_create) || !sc_projectile_init(id, projectile_create))
    instance_destroy();