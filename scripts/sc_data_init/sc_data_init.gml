/// @description Creates the expandable content registries.
function sc_data_init()
{
    global.data = {
        factions: array_create(Faction.AUTOMATED + 1, undefined),
        ships: {},
        enemies: {},
        weapons: {},
        projectiles: {},
        attacks: {},
        items: {},
        asteroids: {}
    };

    if (!sc_item_register_all()) return false;
    if (!sc_asteroid_register_all()) return false;
	if (!sc_projectiles_shared_register_all()) return false;
    if (!sc_enemy_register_all()) return false;
    if (!sc_plyr_register_all()) return false;

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

    if (!variable_struct_exists(_data.identity, "threat_value")
    || _data.identity.threat_value < 0)
    {
        show_debug_message("ENEMY REGISTRATION ERROR - invalid threat value: " + _key);
        return false;
    }

    if (!variable_struct_exists(_data.stats_base, "mass")
    || _data.stats_base.mass <= 0)
    {
        show_debug_message("ENEMY REGISTRATION ERROR - invalid mass: " + _key);
        return false;
    }

    var _range = _data.stats_base.range;

    if (_range.backaway > _range.combat
    || _range.combat > _range.detection
    || _range.detection > _range.forget)
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
    if (!is_struct(_ship)
    || !variable_struct_exists(_ship, "identity")
    || !variable_struct_exists(_ship.identity, "key"))
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

    if (!variable_struct_exists(_ship, "systems") || !sc_ship_systems_validate(_ship.systems))
    {
        show_debug_message("SHIP REGISTRATION ERROR - invalid internal systems: " + _key);
        return false;
    }

    variable_struct_set(global.data.ships, _key, _ship);
    return true;
}

