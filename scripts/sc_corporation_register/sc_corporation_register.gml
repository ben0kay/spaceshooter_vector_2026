/// @description Registers all Corporation faction content.
function sc_enemy_faction_corporation_register_all()
{
    if (!sc_faction_register_corporation()) return false;
    if (!sc_enemy_faction_corporation_projectiles_register()) return false;
    if (!sc_enemy_faction_corporation_weapons_register()) return false;
    if (!sc_enemy_faction_corporation_ships_register()) return false;
    return true;
}

/// @description Registers every Corporation projectile.
function sc_enemy_faction_corporation_projectiles_register()
{
    if (!sc_projectile_register_corporation_plasma()) return false;
    if (!sc_projectile_register_corporation_rocket()) return false;
    return true;
}

/// @description Registers every Corporation weapon.
function sc_enemy_faction_corporation_weapons_register()
{
    if (!sc_weapon_register_corporation_plasma()) return false;
    if (!sc_weapon_register_corporation_rocket()) return false;
    return true;
}

/// @description Registers every Corporation enemy ship.
function sc_enemy_faction_corporation_ships_register()
{
    if (!sc_enemy_register_corporation_interceptor()) return false;
    if (!sc_enemy_register_corporation_support_battleship()) return false;
    return true;
}