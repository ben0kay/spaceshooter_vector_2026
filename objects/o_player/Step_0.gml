/// @description Updates the player state and rotated collision mask.
if (!initialized || !GAMEPLAY_ACTIVE) exit;

movement.previous_x = x;
movement.previous_y = y;
movement.previous_angle = draw_angle;

sc_player_movement_runtime_update(id);

if (global.PlayerState != PlayerState.DESTROYED)
{
    sc_player_resources_update(id);
    sc_player_defence_update(id);
    sc_player_shield_focus_update(id);
}

switch (global.PlayerState)
{
    case PlayerState.ACTIVE:
        sc_player_update_active(id);
    break;

    case PlayerState.INVENTORY:
        sc_player_combat_permission_update(id);
    break;

    case PlayerState.DASHING:
        sc_player_update_dashing(id);
    break;

    case PlayerState.STUNNED:
        sc_player_update_stunned(id);
    break;

    case PlayerState.DISABLED:
        sc_player_update_disabled(id);
    break;

    case PlayerState.DESTROYED:
        sc_player_update_destroyed(id);
    break;
}

image_angle = draw_angle;