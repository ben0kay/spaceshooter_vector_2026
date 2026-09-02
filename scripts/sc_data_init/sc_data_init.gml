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
	
	if (!sc_enemy_register_all()) return false;
    if (!sc_plyr_ships_register_all()) return false;

    show_debug_message("SPACE SHOOTER VECTOR 2026 - DATA INITIALIZED");
    return true;
}
/// @description Registers one projectile definition.
function sc_projectile_register(_data)
{
    var _key = _data.identity.key;

    if (variable_struct_exists(global.data.projectiles, _key))
    {
        show_debug_message("PROJECTILE REGISTRATION ERROR - duplicate key: " + _key);
        return false;
    }

    variable_struct_set(global.data.projectiles, _key, _data);
    return true;
}

/// @description Registers one weapon definition.
function sc_weapon_register(_data)
{
    var _key = _data.identity.key;

    if (variable_struct_exists(global.data.weapons, _key))
    {
        show_debug_message("WEAPON REGISTRATION ERROR - duplicate key: " + _key);
        return false;
    }

    variable_struct_set(global.data.weapons, _key, _data);
    return true;
}

/// @description Registers one validated enemy definition.
function sc_enemy_register(_data)
{
    var _key = _data.identity.key;

    if (variable_struct_exists(global.data.enemies, _key))
    {
        show_debug_message("ENEMY REGISTRATION ERROR - duplicate key: " + _key);
        return false;
    }

    var _stats = _data.stats_base;

    if (_stats.combat_range > _stats.detection_range || _stats.detection_range > _stats.forget_range)
    {
        show_debug_message("ENEMY REGISTRATION ERROR - invalid range order: " + _key);
        return false;
    }

    variable_struct_set(global.data.enemies, _key, _data);
    return true;
}

/// @description Registers one validated ship definition.
function sc_ship_register(_ship)
{
    if (!is_struct(_ship) || !variable_struct_exists(_ship, "identity") || !variable_struct_exists(_ship.identity, "key"))
    {
        show_debug_message("SHIP REGISTRATION ERROR - invalid ship definition");
        return false;
    }

    var _key = _ship.identity.key;

    if (variable_struct_exists(global.data.ships, _key))
    {
        show_debug_message("SHIP REGISTRATION ERROR - duplicate key: " + _key);
        return false;
    }

    variable_struct_set(global.data.ships, _key, _ship);
    return true;
}

