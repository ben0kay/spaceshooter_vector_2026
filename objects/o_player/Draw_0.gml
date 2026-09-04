/// @description Draws the player according to its current state.
if (!initialized) exit;

switch (global.PlayerState)
{
    case PlayerState.INITIALIZING:
        sc_player_draw_ship(id, c_white, 0.5, false, false);
    break;

    case PlayerState.ACTIVE:
    case PlayerState.INVENTORY:
        sc_player_draw_ship(id, c_white, 1, true, true);
    break;

    case PlayerState.DASHING:
        sc_player_dash_ghosts_draw(id);
        sc_player_draw_ship(id, c_white, 1, true, true);
    break;

    case PlayerState.STUNNED:
        sc_player_draw_ship(id, merge_colour(c_white, c_aqua, 0.35), 1, true, true);
    break;

    case PlayerState.DISABLED:
        sc_player_draw_ship(id, c_gray, 1, false, true);
    break;

    case PlayerState.DESTROYED:
        sc_player_draw_ship(id, make_colour_rgb(65, 70, 75), 0.65, false, false);
    break;
}