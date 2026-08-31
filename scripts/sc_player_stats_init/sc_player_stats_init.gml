/// @description Creates player stat runtime from immutable ship base stats.
function sc_player_stats_init(_player, _stats_base)
{
    _player.ship.stats =
    {
        base: variable_clone(_stats_base),
        modifiers:
        {
            persistent: variable_clone(global.profile.persistent_modifiers),
            local: [],
            temporary: []
        },
        final: {},
        dirty: true
    };

    return sc_player_stats_recalculate(_player);
}

/// @description Rebuilds final stats only when a modifier source changes.
function sc_player_stats_recalculate(_player)
{
    if (!instance_exists(_player) || !_player.ship.stats.dirty)
        return false;

    var _stats = _player.ship.stats;
    _stats.final = variable_clone(_stats.base);

    sc_player_stats_modifiers_apply(_stats.final, _stats.modifiers.persistent);
    sc_player_stats_modifiers_apply(_stats.final, _stats.modifiers.local);
    sc_player_stats_modifiers_apply(_stats.final, _stats.modifiers.temporary);

    _stats.dirty = false;
    return true;
}

/// @description Applies ordered stat modifiers: current + add, then multiply.
function sc_player_stats_modifiers_apply(_final, _modifiers)
{
    for (var _i = 0; _i < array_length(_modifiers); _i++)
    {
        var _modifier = _modifiers[_i];

        if (!is_struct(_modifier) || !variable_struct_exists(_modifier, "stat"))
            continue;

        var _stat = _modifier.stat;

        if (!variable_struct_exists(_final, _stat))
            continue;

        var _value = variable_struct_get(_final, _stat);
        var _add = variable_struct_exists(_modifier, "add") ? _modifier.add : 0;
        var _multiply = variable_struct_exists(_modifier, "multiply") ? _modifier.multiply : 1;

        variable_struct_set(_final, _stat, (_value + _add) * _multiply);
    }
}
