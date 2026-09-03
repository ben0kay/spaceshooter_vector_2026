/// @description Updates enemy gameplay and visible visual effects.
if (!initialized || !GAMEPLAY_ACTIVE) exit;

sc_optimization_enemy_update(id);

if (enemy.state != EnemyState.STUNNED && enemy.state != EnemyState.DEAD)
    sc_enemy_perception_update(id);

sc_enemy_hardpoint_update(id);

switch (enemy.state)
{
    case EnemyState.IDLE:
        sc_enemy_update_idle(id);
    break;

    case EnemyState.CHASING:
        sc_enemy_update_chasing(id);
    break;

    case EnemyState.ATTACKING:
        sc_enemy_update_attacking(id);
    break;

    case EnemyState.STUNNED:
        sc_enemy_update_stunned(id);
    break;

    case EnemyState.DEAD:
        // Death currently resolves immediately inside sc_enemy_die().
    break;
}

if (enemy.optimization.render_active)
    sc_enemy_visual_update(id);
else
    enemy.visual.runtime.shield_hit_alpha = 0;

image_angle = draw_angle;