/// @description Creates the player stat pipeline from immutable ship base stats.
function sc_player_stats_init(_player, _stats_base)
{
    _player.ship.stats = {
        base: variable_clone(_stats_base),

        modifiers: {
            level: [],
            persistent: variable_clone(global.profile.persistent_modifiers),
            equipment: [],
            modules: [],
            local: [],
            temporary: []
        },

        final: {},
        dirty: true
    };

    return sc_player_stats_recalculate(_player);
}

/// @description Rebuilds final player stats only when a modifier source changes.
function sc_player_stats_recalculate(_player)
{
    var _stats = _player.ship.stats;
    if (!_stats.dirty) return false;

    _stats.final = variable_clone(_stats.base);

    sc_stats_modifiers_apply(_stats.final, _stats.modifiers.level);
    sc_stats_modifiers_apply(_stats.final, _stats.modifiers.persistent);
    sc_stats_modifiers_apply(_stats.final, _stats.modifiers.equipment);
    sc_stats_modifiers_apply(_stats.final, _stats.modifiers.modules);
    sc_stats_modifiers_apply(_stats.final, _stats.modifiers.local);
    sc_stats_modifiers_apply(_stats.final, _stats.modifiers.temporary);
	_stats.final.mass = max(0.1, _stats.final.mass);

    _stats.dirty = false;
    return true;
}