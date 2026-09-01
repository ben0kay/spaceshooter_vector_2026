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

