/*
SECTOR PERSISTENCE

Procedural sector content regenerates from its deterministic seed.
Only mutable differences are stored inside the active player profile.

Current support:
- Destroyed procedural asteroids
- Damaged asteroid health
- Partial asteroid extraction progress

Reserved foundations:
- Enemies
- Structures
- Pickups
- Mutable environmental fields
*/

/// @description Returns the profile-storage key for one sector coordinate.
function sc_sector_state_key(_sector_x, _sector_y)
{
    return "sector_" + string(_sector_x) + "_" + string(_sector_y);
}

/// @description Creates a clean serializable state for one generated sector.
function sc_sector_state_default(_sector_seed)
{
    return {
        state_version: SECTOR_STATE_VERSION,
        generation_version: SECTOR_GENERATION_VERSION,
        generation_seed: _sector_seed,

        visited: true,
        visit_count: 0,
        last_saved_at: 0,

        asteroids: {
            destroyed: {},
            damaged: {}
        },

        // Future persistence serializers plug into these collections.
        enemies: {},
        structures: {},
        pickups: [],
        environment: {}
    };
}

/// @description Returns one sector state, creating or replacing incompatible data.
function sc_sector_state_get(_sector_x, _sector_y, _sector_seed)
{
    var _states = global.profile.sector_states;
    var _key = sc_sector_state_key(_sector_x, _sector_y);
    var _replace = !variable_struct_exists(_states, _key);

    if (!_replace)
    {
        var _existing = variable_struct_get(_states, _key);

        _replace = !is_struct(_existing)
            || !variable_struct_exists(_existing, "state_version")
            || !variable_struct_exists(_existing, "generation_version")
            || !variable_struct_exists(_existing, "generation_seed")
            || _existing.state_version != SECTOR_STATE_VERSION
            || _existing.generation_version != SECTOR_GENERATION_VERSION
            || _existing.generation_seed != _sector_seed;
    }

    if (_replace)
    {
        variable_struct_set(
            _states,
            _key,
            sc_sector_state_default(_sector_seed)
        );
    }

    return variable_struct_get(_states, _key);
}

/// @description Prepares runtime persistence before deterministic generation begins.
function sc_sector_persistence_prepare(_sector_seed)
{
    var _sector = global.game.sector;
    var _state = sc_sector_state_get(
        _sector.x,
        _sector.y,
        _sector_seed
    );

    _state.visited = true;
    _state.visit_count++;

    _sector.persistence = {
        state: _state,
        asteroid_id_next: 0,
        structure_id_next: 0,
        restoring: false
    };

    return true;
}

/// @description Supplies a stable ID for one deterministically generated structure.
function sc_sector_persistence_structure_id_take(_prefix = "structure")
{
    var _persistence = global.game.sector.persistence;
    var _persistent_id =
        _prefix
        + "_"
        + string(_persistence.structure_id_next);

    _persistence.structure_id_next++;
    return _persistent_id;
}

/// @description Supplies the next stable procedural asteroid ID during generation.
function sc_sector_persistence_asteroid_id_take()
{
    var _persistence = global.game.sector.persistence;
    var _persistent_id = _persistence.asteroid_id_next;

    _persistence.asteroid_id_next++;
    return _persistent_id;
}

/// @description Records one procedural asteroid as permanently destroyed.
function sc_sector_persistence_asteroid_destroyed_add(_asteroid)
{
    if (!sc_sector_campaign_active()) return false;

    var _persistent_id = _asteroid.asteroid.persistent_id;
    if (_persistent_id < 0) return false;

    var _state = global.game.sector.persistence.state;
    var _key = string(_persistent_id);

    variable_struct_set(
        _state.asteroids.destroyed,
        _key,
        true
    );

    return true;
}

/// @description Captures only damaged living asteroid deltas before leaving a sector.
function sc_sector_persistence_asteroids_capture()
{
    var _state = global.game.sector.persistence.state;
    var _damaged = {};
    var _count = instance_number(o_asteroid);

    for (var _i = 0; _i < _count; ++_i)
    {
        var _asteroid = instance_find(o_asteroid, _i);
        if (!instance_exists(_asteroid) || !_asteroid.initialized) continue;

        var _data = _asteroid.asteroid;
        if (_data.persistent_id < 0) continue;

        var _health_changed =
            _data.health.current < _data.health.maximum;

        var _yield_changed =
            _data.yield.remaining < _data.yield.total
            || _data.yield.progress > 0;

        if (!_health_changed && !_yield_changed) continue;

        variable_struct_set(
            _damaged,
            string(_data.persistent_id),
            {
                health: _data.health.current,
                yield_remaining: _data.yield.remaining,
                yield_progress: _data.yield.progress
            }
        );
    }

    _state.asteroids.damaged = _damaged;
    return true;
}

/// @description Restores asteroid destruction, damage and extraction deltas.
function sc_sector_persistence_asteroids_restore()
{
    var _persistence = global.game.sector.persistence;
    var _state = _persistence.state;
    var _destroyed = _state.asteroids.destroyed;
    var _damaged = _state.asteroids.damaged;
    var _count = instance_number(o_asteroid);
    var _asteroids = [];

    for (var _i = 0; _i < _count; ++_i)
        array_push(_asteroids, instance_find(o_asteroid, _i));

    _persistence.restoring = true;

    for (var _i = 0; _i < array_length(_asteroids); ++_i)
    {
        var _asteroid = _asteroids[_i];
        if (!instance_exists(_asteroid) || !_asteroid.initialized) continue;

        var _data = _asteroid.asteroid;
        if (_data.persistent_id < 0) continue;

        var _key = string(_data.persistent_id);

        if (variable_struct_exists(_destroyed, _key))
        {
            sc_sector_asteroid_field_population_remove(_asteroid);
            instance_destroy(_asteroid);
            continue;
        }

        if (!variable_struct_exists(_damaged, _key)) continue;

        var _saved = variable_struct_get(_damaged, _key);

        _data.health.current = clamp(
            _saved.health,
            1,
            _data.health.maximum
        );

        _data.yield.remaining = clamp(
            _saved.yield_remaining,
            0,
            _data.yield.total
        );

        _data.yield.progress = max(
            0,
            _saved.yield_progress
        );

        var _ratio =
            _data.health.current
            / max(1, _data.health.maximum);

        _data.health.stage = _ratio <= 0.25
            ? 3
            : (_ratio <= 0.5
                ? 2
                : (_ratio <= 0.75 ? 1 : 0));
    }

    _persistence.restoring = false;
    return true;
}

/// @description Records one persistent structure as permanently destroyed.
function sc_sector_persistence_structure_destroyed_add(_structure)
{
    if (!sc_sector_campaign_active()) return false;

    var _runtime = _structure.structure;
    if (_runtime.persistent_id == "") return false;

    variable_struct_set(
        global.game.sector.persistence.state.structures,
        _runtime.persistent_id,
        {
            key: _runtime.key,
            destroyed: true,
            data: {}
        }
    );

    return true;
}

/// @description Captures custom state from every living persistent structure.
function sc_sector_persistence_structures_capture()
{
    var _records =
        global.game.sector.persistence.state.structures;

    var _count = instance_number(o_world_structure);

    for (var _i = 0; _i < _count; ++_i)
    {
        var _structure = instance_find(o_world_structure, _i);
        if (!instance_exists(_structure) || !_structure.initialized) continue;

        var _runtime = _structure.structure;
        var _persistent_id = _runtime.persistent_id;
        if (_persistent_id == "") continue;

        var _definition = _runtime.data;
        if (!variable_struct_exists(_definition, "persistence")) continue;

        var _persistence = _definition.persistence;
        if (is_undefined(_persistence.capture_script)) continue;

        var _data = _persistence.capture_script(_structure);
        if (!is_struct(_data)) continue;

        variable_struct_set(
            _records,
            _persistent_id,
            {
                key: _runtime.key,
                destroyed: false,
                data: _data
            }
        );
    }

    return true;
}

/// @description Restores or removes every persistent generated structure.
function sc_sector_persistence_structures_restore()
{
    var _persistence = global.game.sector.persistence;
    var _records = _persistence.state.structures;
    var _count = instance_number(o_world_structure);
    var _structures = [];

    for (var _i = 0; _i < _count; ++_i)
        array_push(_structures, instance_find(o_world_structure, _i));

    _persistence.restoring = true;

    for (var _i = 0; _i < array_length(_structures); ++_i)
    {
        var _structure = _structures[_i];
        if (!instance_exists(_structure) || !_structure.initialized) continue;

        var _runtime = _structure.structure;
        var _persistent_id = _runtime.persistent_id;

        if (_persistent_id == ""
        || !variable_struct_exists(_records, _persistent_id))
            continue;

        var _record = variable_struct_get(
            _records,
            _persistent_id
        );

        if (_record.destroyed)
        {
            instance_destroy(_structure);
            continue;
        }

        var _definition = _runtime.data;
        if (!variable_struct_exists(_definition, "persistence")) continue;

        var _structure_persistence = _definition.persistence;
        if (is_undefined(_structure_persistence.restore_script)) continue;

        _structure_persistence.restore_script(
            _structure,
            _record.data
        );
    }

    _persistence.restoring = false;
    return true;
}

/// @description Captures all currently supported mutable sector state.
function sc_sector_persistence_capture()
{
    if (!sc_sector_campaign_active()
    || !variable_struct_exists(global.game.sector, "persistence"))
        return false;

    sc_sector_persistence_asteroids_capture();
    sc_sector_persistence_structures_capture();

    var _state = global.game.sector.persistence.state;
    _state.last_saved_at = date_current_datetime();

    // Future capture functions:
    // sc_sector_persistence_enemies_capture();
    // sc_sector_persistence_pickups_capture();
    // sc_sector_persistence_environment_capture();

    return true;
}

/// @description Restores every currently supported sector-state category.
function sc_sector_persistence_restore()
{
    if (!sc_sector_campaign_active()
    || !variable_struct_exists(global.game.sector, "persistence"))
        return false;

    sc_sector_persistence_asteroids_restore();
    sc_sector_persistence_structures_restore();

    // Future restoration functions:
    // sc_sector_persistence_enemies_restore();
    // sc_sector_persistence_pickups_restore();
    // sc_sector_persistence_environment_restore();

    return true;
}