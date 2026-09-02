/// @description Creates the expandable content registries.
function sc_data_init()
{
    global.data = {
        factions: array_create(Faction.ALIEN + 1, undefined),
        ships: {},
        enemies: {},
        weapons: {},
        projectiles: {},
        attacks: {}
    };

    if (!sc_faction_register_simulant()) return false;

    if (!sc_ship_register_shard()) return false;
    if (!sc_ship_register_fighter()) return false;
    if (!sc_ship_register_bastion()) return false;

    if (!sc_projectile_register_shard_pulse()) return false;
    if (!sc_weapon_register_shard_pulse()) return false;

    if (!sc_projectile_register_simulant_pulse()) return false;
    if (!sc_weapon_register_simulant_pulse()) return false;
    if (!sc_enemy_register_twin_fighter()) return false;

    show_debug_message("SPACE SHOOTER VECTOR 2026 - DATA INITIALIZED");
    return true;
}