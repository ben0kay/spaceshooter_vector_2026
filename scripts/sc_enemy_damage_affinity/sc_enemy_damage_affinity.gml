/// @description Applies either one whole-layer multiplier or sparse type entries.
function sc_enemy_damage_affinity_layer_apply(_lookup,_definition)
{
    if (is_real(_definition))
    {
        var _multiplier = max(0,_definition);

        for (var _i = 0; _i < array_length(_lookup); ++_i)
            _lookup[_i] = _multiplier;

        return _lookup;
    }

    for (var _i = 0; _i < array_length(_definition); ++_i)
    {
        var _entry = _definition[_i];
        var _type = _entry.type;

        if (_type < 0 || _type >= array_length(_lookup))
            continue;

        _lookup[_type] = max(0,_entry.multiplier);
    }

    return _lookup;
}

/// @description Creates fast per-layer damage-affinity lookup tables for one enemy.
function sc_enemy_damage_affinity_create(_definition = undefined)
{
    var _type_count = array_length(GCFG.damage.types);
    var _affinity = {
        shield: array_create(_type_count,1),
        armour: array_create(_type_count,1),
        hull: array_create(_type_count,1)
    };

    if (!is_struct(_definition))
        return _affinity;

    // Apply broad damage-type affinities across every layer first.
    if (variable_struct_exists(_definition,"all"))
    {
        _affinity.shield = sc_enemy_damage_affinity_layer_apply(
            _affinity.shield,
            _definition.all
        );

        _affinity.armour = sc_enemy_damage_affinity_layer_apply(
            _affinity.armour,
            _definition.all
        );

        _affinity.hull = sc_enemy_damage_affinity_layer_apply(
            _affinity.hull,
            _definition.all
        );
    }

    // Individual layers override matching broad affinities.
    if (variable_struct_exists(_definition,"shield"))
        _affinity.shield = sc_enemy_damage_affinity_layer_apply(
            _affinity.shield,
            _definition.shield
        );

    if (variable_struct_exists(_definition,"armour"))
        _affinity.armour = sc_enemy_damage_affinity_layer_apply(
            _affinity.armour,
            _definition.armour
        );

    if (variable_struct_exists(_definition,"hull"))
        _affinity.hull = sc_enemy_damage_affinity_layer_apply(
            _affinity.hull,
            _definition.hull
        );

    return _affinity;
}

/// @description Returns one enemy's compiled multiplier for a damage type and defence layer.
function sc_enemy_damage_affinity_multiplier_get(_affinity,_type,_layer)
{
    switch (_layer)
    {
        case DefenceLayer.SHIELD: return _affinity.shield[_type];
        case DefenceLayer.ARMOUR: return _affinity.armour[_type];
        case DefenceLayer.HULL: return _affinity.hull[_type];
    }

    return 1;
}