/// @description Registers all enemy factions and their content.
function sc_enemy_register_all()
{
    if (!sc_enemy_faction_simulant_register_all()) return false;
	if (!sc_enemy_faction_rebel_register_all()) return false;
	if (!sc_enemy_faction_corporation_register_all()) return false;

    // Register future enemy factions here.
    return true;
}
