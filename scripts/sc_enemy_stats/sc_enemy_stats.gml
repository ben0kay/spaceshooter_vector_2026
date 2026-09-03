/// @description Creates one enemy stat pipeline from immutable registered base stats.
function sc_enemy_stats_init(_enemy, _stats_base)
{
    _enemy.enemy.stats = {
        base: variable_clone(_stats_base),

        modifiers: {
            difficulty: [],
            level: [],
            local: [],
            temporary: []
        },

        final: {},
        dirty: true
    };

    return sc_enemy_stats_recalculate(_enemy);
}

/// @description Rebuilds final enemy stats only when modifiers change.
function sc_enemy_stats_recalculate(_enemy)
{
    var _data = _enemy.enemy;
    var _stats = _data.stats;

    if (!_stats.dirty) return false;

    _stats.final = variable_clone(_stats.base);

    sc_stats_modifiers_apply(_stats.final, _stats.modifiers.difficulty);
    sc_stats_modifiers_apply(_stats.final, _stats.modifiers.level);
    sc_stats_modifiers_apply(_stats.final, _stats.modifiers.local);
    sc_stats_modifiers_apply(_stats.final, _stats.modifiers.temporary);

    var _final = _stats.final;

    _final.shield_max = max(0, _final.shield_max);
    _final.armour_max = max(0, _final.armour_max);
    _final.hull_max = max(1, _final.hull_max);
    _final.speed_max = max(0, _final.speed_max);
    _final.acceleration = max(0, _final.acceleration);
    _final.friction = clamp(_final.friction, 0, 1);
    _final.turn_speed = max(0, _final.turn_speed);
    _final.retreat_range = max(0, _final.retreat_range);
    _final.detection_range = max(0, _final.detection_range);
    _final.combat_range = max(0, _final.combat_range);
    _final.forget_range = max(0, _final.forget_range);
    _final.damage_multiplier = max(0, _final.damage_multiplier);
    _final.fire_rate_multiplier = max(0.01, _final.fire_rate_multiplier);

    _final.retreat_range_sq = sqr(_final.retreat_range);
    _final.detection_range_sq = sqr(_final.detection_range);
    _final.combat_range_sq = sqr(_final.combat_range);
    _final.forget_range_sq = sqr(_final.forget_range);

    if (is_struct(_data.defence))
    {
        _data.defence.shield.maximum = _final.shield_max;
        _data.defence.armour.maximum = _final.armour_max;
        _data.defence.hull.maximum = _final.hull_max;

        _data.defence.shield.current = min(_data.defence.shield.current, _final.shield_max);
        _data.defence.armour.current = min(_data.defence.armour.current, _final.armour_max);
        _data.defence.hull.current = min(_data.defence.hull.current, _final.hull_max);
    }

    _stats.dirty = false;
    return true;
}

/// @description Adds one modifier to a named enemy modifier group.
function sc_enemy_stats_modifier_add(_enemy, _group, _modifier)
{
    var _modifiers = _enemy.enemy.stats.modifiers;

    if (!variable_struct_exists(_modifiers, _group))
    {
        show_debug_message("ENEMY STAT ERROR - unknown modifier group: " + _group);
        return false;
    }

    var _group_modifiers = variable_struct_get(_modifiers, _group);
    array_push(_group_modifiers, _modifier);
    variable_struct_set(_modifiers, _group, _group_modifiers);

    _enemy.enemy.stats.dirty = true;
    return sc_enemy_stats_recalculate(_enemy);
}

/// @description Clears one enemy modifier group.
function sc_enemy_stats_modifiers_clear(_enemy, _group)
{
    var _modifiers = _enemy.enemy.stats.modifiers;

    if (!variable_struct_exists(_modifiers, _group))
    {
        show_debug_message("ENEMY STAT ERROR - unknown modifier group: " + _group);
        return false;
    }

    variable_struct_set(_modifiers, _group, []);
    _enemy.enemy.stats.dirty = true;
    return sc_enemy_stats_recalculate(_enemy);
}