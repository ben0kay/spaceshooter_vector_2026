/// @description Updates HUD, inventory and debug interfaces.
if (global.LevelState != LevelState.PLAYING
&& global.LevelState != LevelState.DEBUG)
    exit;

if (global.input.action.debug_enemy_spawn_pressed)
{
    if (hud.debug_weapon_test.open)
    {
        hud.debug_weapon_test.open = false;
        global.LevelState = LevelState.PLAYING;
    }

    sc_debug_enemy_spawn_toggle(hud);
    exit;
}

if (global.input.action.debug_weapon_test_pressed)
{
    if (hud.debug_enemy_spawn.open)
    {
        hud.debug_enemy_spawn.open = false;
        global.LevelState = LevelState.PLAYING;
    }

    sc_debug_weapon_test_toggle(hud);
    exit;
}

if (global.LevelState == LevelState.DEBUG)
{
    if (hud.debug_enemy_spawn.open)
        sc_debug_enemy_spawn_update(hud);
    else if (hud.debug_weapon_test.open)
        sc_debug_weapon_test_update(hud);

    exit;
}

sc_hud_level_update(hud);
sc_hud_minimap_update(hud);

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