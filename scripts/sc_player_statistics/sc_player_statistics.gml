/*
PLAYER STATISTICS

Stores persistent event-based counters inside the active player profile.

Categories and keys are created dynamically. Gameplay systems call semantic
helpers so one event can update totals and detailed breakdowns together.
*/

/// @description Creates a clean persistent statistics collection.
function sc_player_statistics_default()
{
    return {
        totals: {},
        kills_by_faction: {},
        kills_by_enemy: {},
        kills_by_class: {},
        kills_by_rank: {},
        kills_by_grade: {},
        resources_collected: {},
        asteroids_by_material: {},
        asteroids_by_size: {},
        derelict_items_looted: {},
        derelicts_by_key: {}
    };
}

/// @description Adds an amount to one dynamically keyed statistic.
function sc_player_statistics_add(_category,_key,_amount = 1)
{
    var _statistics = global.profile.statistics;

    if (!variable_struct_exists(_statistics,_category))
        variable_struct_set(
            _statistics,
            _category,
            {}
        );

    var _counters = variable_struct_get(
        _statistics,
        _category
    );

    var _current = variable_struct_exists(_counters,_key)
        ? variable_struct_get(_counters,_key)
        : 0;

    variable_struct_set(
        _counters,
        _key,
        _current + _amount
    );

    return _current + _amount;
}

/// @description Returns one statistic or zero when it has never occurred.
function sc_player_statistics_get(_category,_key)
{
    var _statistics = global.profile.statistics;

    if (!variable_struct_exists(_statistics,_category))
        return 0;

    var _counters = variable_struct_get(
        _statistics,
        _category
    );

    return variable_struct_exists(_counters,_key)
        ? variable_struct_get(_counters,_key)
        : 0;
}

/// @description Records every relevant counter belonging to one player kill.
function sc_player_statistics_enemy_killed(_enemy)
{
    var _data = _enemy.enemy;
    var _identity = _data.identity;
    var _grade = _data.grade;

    sc_player_statistics_add(
        "totals",
        "enemies_killed",
        1
    );

    sc_player_statistics_add(
        "kills_by_faction",
        string(_identity.faction),
        1
    );

    sc_player_statistics_add(
        "kills_by_enemy",
        _data.key,
        1
    );

    sc_player_statistics_add(
        "kills_by_class",
        string(_identity.ship_class),
        1
    );

    sc_player_statistics_add(
        "kills_by_rank",
        string(_identity.rank),
        1
    );

    sc_player_statistics_add(
        "kills_by_grade",
        string(_grade.grade),
        1
    );

    if (_grade.graded)
    {
        sc_player_statistics_add(
            "totals",
            "graded_enemies_killed",
            1
        );
    }

    return true;
}

/// @description Records items successfully collected from world pickups.
function sc_player_statistics_resource_collected(_item_key,_amount)
{
    if (_amount <= 0) return false;

    sc_player_statistics_add(
        "totals",
        "resources_collected",
        _amount
    );

    sc_player_statistics_add(
        "resources_collected",
        _item_key,
        _amount
    );

    return true;
}

/// @description Records one asteroid destroyed by the player.
function sc_player_statistics_asteroid_destroyed(_asteroid)
{
    var _data = _asteroid.asteroid;

    sc_player_statistics_add(
        "totals",
        "asteroids_destroyed",
        1
    );

    sc_player_statistics_add(
        "asteroids_by_material",
        _data.key,
        1
    );

    sc_player_statistics_add(
        "asteroids_by_size",
        string(_data.size),
        1
    );

    return true;
}

/// @description Records items successfully transferred from a derelict.
function sc_player_statistics_derelict_items_looted(_item_key,_amount)
{
    if (_amount <= 0) return false;

    sc_player_statistics_add(
        "totals",
        "derelict_items_looted",
        _amount
    );

    sc_player_statistics_add(
        "derelict_items_looted",
        _item_key,
        _amount
    );

    return true;
}

/// @description Records one derelict completely emptied by the player.
function sc_player_statistics_derelict_looted(_derelict)
{
    var _key = _derelict.structure.key;

    sc_player_statistics_add(
        "totals",
        "derelicts_looted",
        1
    );

    sc_player_statistics_add(
        "derelicts_by_key",
        _key,
        1
    );

    return true;
}