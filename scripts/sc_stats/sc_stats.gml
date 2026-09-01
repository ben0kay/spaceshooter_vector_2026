/// @description Applies ordered stat modifiers: current + add, then multiply.
function sc_stats_modifiers_apply(_final, _modifiers)
{
    for (var _i = 0; _i < array_length(_modifiers); _i++)
    {
        var _modifier = _modifiers[_i];
        if (!is_struct(_modifier) || !variable_struct_exists(_modifier, "stat")) continue;

        var _stat = _modifier.stat;
        if (!variable_struct_exists(_final, _stat)) continue;

        var _value = variable_struct_get(_final, _stat);
        var _add = variable_struct_exists(_modifier, "add") ? _modifier.add : 0;
        var _multiply = variable_struct_exists(_modifier, "multiply") ? _modifier.multiply : 1;

        variable_struct_set(_final, _stat, (_value + _add) * _multiply);
    }
}