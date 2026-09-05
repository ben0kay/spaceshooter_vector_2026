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

/// @description Rebuilds final enemy stats, handling and ranges only when modifiers change.
function sc_enemy_stats_recalculate(_enemy)
{
    var _data = _enemy.enemy;
    var _stats = _data.stats;

    if (!_stats.dirty) return false;

    _stats.final = variable_clone(_stats.base);

    sc_stats_modifiers_apply(_stats.final, _stats.modifiers.difficulty);
    sc_stats_modifiers_apply(_stats.final.handling, _stats.modifiers.difficulty);
    sc_stats_modifiers_apply(_stats.final.range, _stats.modifiers.difficulty);

    sc_stats_modifiers_apply(_stats.final, _stats.modifiers.level);
    sc_stats_modifiers_apply(_stats.final.handling, _stats.modifiers.level);
    sc_stats_modifiers_apply(_stats.final.range, _stats.modifiers.level);

    sc_stats_modifiers_apply(_stats.final, _stats.modifiers.local);
    sc_stats_modifiers_apply(_stats.final.handling, _stats.modifiers.local);
    sc_stats_modifiers_apply(_stats.final.range, _stats.modifiers.local);

    sc_stats_modifiers_apply(_stats.final, _stats.modifiers.temporary);
    sc_stats_modifiers_apply(_stats.final.handling, _stats.modifiers.temporary);
    sc_stats_modifiers_apply(_stats.final.range, _stats.modifiers.temporary);

    var _final = _stats.final;
    var _handling = _final.handling;
    var _range = _final.range;

    _final.mass = max(0.1, _final.mass);
    _final.shield_max = max(0, _final.shield_max);
    _final.armour_max = max(0, _final.armour_max);
    _final.hull_max = max(1, _final.hull_max);
    _final.damage_multiplier = max(0, _final.damage_multiplier);
    _final.fire_rate_multiplier = max(0.01, _final.fire_rate_multiplier);

    _handling.speed_max = max(0, _handling.speed_max);
    _handling.acceleration = max(0, _handling.acceleration);
    _handling.friction_coeff = clamp(_handling.friction_coeff, 0, 1);
    _handling.turn_speed = max(0, _handling.turn_speed);
    _handling.directional_speed_min = clamp(_handling.directional_speed_min, 0, 1);
    _handling.directional_thrust_min = clamp(_handling.directional_thrust_min, 0, 1);

    _range.backaway = max(0, _range.backaway);
    _range.combat = max(0, _range.combat);
    _range.detection = max(0, _range.detection);
    _range.forget = max(0, _range.forget);
    _range.wander = max(0, _range.wander);
    _range.alert_share = max(0, _range.alert_share);

    _range.backaway_sq = sqr(_range.backaway);
    _range.combat_sq = sqr(_range.combat);
    _range.detection_sq = sqr(_range.detection);
    _range.forget_sq = sqr(_range.forget);
    _range.wander_sq = sqr(_range.wander);
    _range.alert_share_sq = sqr(_range.alert_share);

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