initialized = false;

if (!sc_enemy_init(id, enemy_key))
{
    instance_destroy();
    exit;
}

sc_optimization_enemy_init(id);

health_bar = sc_health_bar_create(true);
health_bar.width = max(72, enemy.visual.radius * 1.35);