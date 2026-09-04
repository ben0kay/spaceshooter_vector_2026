/// @description Updates HUD systems according to the current player state.
if (global.LevelState != LevelState.PLAYING) exit;

sc_hud_level_update(hud);

switch (global.PlayerState)
{
    case PlayerState.ACTIVE:
        if (keyboard_check_pressed(ord("E")))
            sc_inventory_toggle(hud);
    break;

    case PlayerState.INVENTORY:
        sc_inventory_update(hud);
    break;
}