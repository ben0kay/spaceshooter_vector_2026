/// @description Updates HUD, inventory and debug interfaces.
if (global.LevelState != LevelState.PLAYING
&& global.LevelState != LevelState.DEBUG)
    exit;

if (global.input.action.debug_enemy_spawn_pressed)
{
    sc_debug_enemy_spawn_toggle(hud);
    exit;
}

if (global.LevelState == LevelState.DEBUG)
{
    sc_debug_enemy_spawn_update(hud);
    exit;
}

sc_hud_level_update(hud);

switch (global.PlayerState)
{
    case PlayerState.ACTIVE:
        if (global.input.action.inventory_pressed)
            sc_inventory_toggle(hud);
    break;

    case PlayerState.INVENTORY:
        sc_inventory_update(hud);
    break;
}