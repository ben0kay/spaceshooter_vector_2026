/// @description Registers all enemy factions and their content.
function sc_enemy_register_all()
{
    if (!sc_enemy_faction_simulant_register_all()) return false;

    // Register future enemy factions here.
    return true;
}

/// @description Registers all Simulant faction content.
function sc_enemy_faction_simulant_register_all()
{
    if (!sc_faction_register_simulant()) return false;
    if (!sc_enemy_faction_simulant_projectiles_register()) return false;
    if (!sc_enemy_faction_simulant_weapons_register()) return false;
    if (!sc_enemy_faction_simulant_ships_register()) return false;

    return true;
}

/// @description Registers every Simulant projectile.
function sc_enemy_faction_simulant_projectiles_register()
{
    if (!sc_projectile_register_simulant_pulse()) return false;
    if (!sc_projectile_register_simulant_rocket()) return false;
    return true;
}

/// @description Registers every Simulant weapon.
function sc_enemy_faction_simulant_weapons_register()
{
    if (!sc_weapon_register_simulant_pulse()) return false;
    if (!sc_weapon_register_simulant_thin_beam()) return false;
    if (!sc_weapon_register_simulant_dreadnaught_rocket()) return false;
    return true;
}

/// @description Registers every Simulant enemy ship.
function sc_enemy_faction_simulant_ships_register()
{
    if (!sc_enemy_register_twin_fighter()) return false;
	if (!sc_enemy_register_sim_skirmisher()) return false;
	if (!sc_enemy_register_sim_dreadwing()) return false;
	
	if (!sc_enemy_register_sim_dreadnaught()) return false;

    return true;
}