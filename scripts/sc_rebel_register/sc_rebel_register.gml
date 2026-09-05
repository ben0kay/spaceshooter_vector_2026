/// @description Registers all Rebel faction content.
function sc_enemy_faction_rebel_register_all()
{
    if (!sc_faction_register_rebel()) return false;
    if (!sc_enemy_faction_rebel_weapons_register()) return false;
    if (!sc_enemy_faction_rebel_ships_register()) return false;
    return true;
}

/// @description Registers every Rebel weapon.
function sc_enemy_faction_rebel_weapons_register()
{
    if (!sc_weapon_register_rebel_minigun()) return false;
    return true;
}

/// @description Registers every Rebel enemy ship.
function sc_enemy_faction_rebel_ships_register()
{
    if (!sc_enemy_register_rebel_gunship()) return false;
    return true;
}