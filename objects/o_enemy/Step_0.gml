/// @description Updates the enemy state and synchronizes its rotated collision mask.
if (!initialized || !GAMEPLAY_ACTIVE) exit;

sc_enemy_perception_update(id);
sc_enemy_visual_update(id);

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
        // Future stunned behaviour.
    break;

    case EnemyState.DEAD:
        // Future death pipeline.
    break;
}

image_angle = draw_angle;