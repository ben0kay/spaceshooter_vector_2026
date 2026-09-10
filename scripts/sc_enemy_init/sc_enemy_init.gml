/// @description Creates faction doctrine with an optional enemy-specific retarget override.
function sc_enemy_init_doctrine_create(_data)
{
    var _doctrine = variable_clone(
        sc_faction_doctrine_get(_data.identity.faction)
    );

    if (variable_struct_exists(_data, "retarget_script"))
        _doctrine.engagement.retarget.script = _data.retarget_script;

    return _doctrine;
}

/// @description Creates global rear-damage settings with an optional enemy override.
function sc_enemy_init_rear_damage_create(_data)
{
    var _rear_damage = variable_clone(global.config.enemy.rear_damage);

    if (variable_struct_exists(_data, "rear_damage"))
    {
        var _override = _data.rear_damage;
        _rear_damage.arc = _override.arc;
        _rear_damage.multiplier = _override.multiplier;
    }

    _rear_damage.arc = clamp(_rear_damage.arc, 0, 360);
    _rear_damage.multiplier = max(1, _rear_damage.multiplier);

    return _rear_damage;
}

/// @description Creates awareness settings with normalized perception defaults.
function sc_enemy_init_awareness_controller_create(_data)
{
    var _awareness = variable_clone(_data.awareness_controller);
    var _config = global.config.enemy.perception;

    _awareness.detection_line_of_sight =
        variable_struct_exists(_awareness, "detection_line_of_sight")
        ? _awareness.detection_line_of_sight
        : _config.line_of_sight.enabled;

    _awareness.asteroid_concealment =
        variable_struct_exists(_awareness, "asteroid_concealment")
        ? _awareness.asteroid_concealment
        : _config.asteroid_concealment.enabled;

    return _awareness;
}

/// @description Creates the main runtime structure shared by every enemy.
function sc_enemy_init_runtime_create(_enemy, _enemy_key, _data)
{
    var _radius = _data.visual.radius;

    return {
        key: _enemy_key,
        identity: variable_clone(_data.identity),
        doctrine: sc_enemy_init_doctrine_create(_data),
        reward: variable_clone(_data.reward),

        state: EnemyState.IDLE,
        target_id: noone,
        target_distance_sq: 0,
        stats: undefined,
        defence: undefined,
        rear_damage: sc_enemy_init_rear_damage_create(_data),

        // Controllers define how this enemy moves and responds to awareness.
        movement_controller: variable_clone(_data.movement_controller),
        awareness_controller: sc_enemy_init_awareness_controller_create(_data),

        movement: {
            velocity_x: 0,
            velocity_y: 0,
            spawn_x: _enemy.x,
            spawn_y: _enemy.y,
            orbit_direction: 0,
            strafe_phase: random(2 * pi),

            command: {
                active: false,
                direction: 0,
                speed_scale: 1,
                apply_friction: true,
                facing_mode: EnemyFacingMode.TARGET,
                face_direction: 0
            },

            wander: {
                active: false,
                target_x: _enemy.x,
                target_y: _enemy.y,
                next_move_tick: GAME_TICK + irandom_range(30, 90)
            },

            obstacle: {
                active: false,
                target_id: noone,
                direction: 0,
                side: 0,
                next_check_tick: GAME_TICK
            },

            // Only specialized movement styles provide additional runtime data.
            behaviour_runtime:
                variable_struct_exists(_data.movement_controller, "runtime")
                ? variable_clone(_data.movement_controller.runtime)
                : {}
        },

        collision: {
            radius_forward: _radius * _data.collision.radius_forward_scale,
            radius_side: _radius * _data.collision.radius_side_scale,
            blocks_player: _data.collision.blocks_player
        },

        alert: {
            attempts: 0,
            next_attempt_tick: 0
        },

        engagement: {
            rejected: []
        },

        // Stores the selected low-health response and its current progress.
        critical_response: {
            attempts: 0,
            next_attempt_tick: 0,
            used: false,
            selected: -1,
            direction: 0,
            target_id: noone,
            option: undefined,
            movement_script: undefined,
            arrival_script: undefined,
            arrived: false,
            sheltered: false,
            returning: false,
            return_x: 0,
            return_y: 0
        },

        awareness: {
            memory_until: 0,
            last_known_x: _enemy.x,
            last_known_y: _enemy.y,
            arrived: false,
            search_until: 0
        },

        visual: variable_clone(_data.visual),
        hardpoints: variable_clone(_data.hardpoints),
        thrusters: variable_clone(_data.thrusters),
        attack_controller: variable_clone(_data.attack_controller),

        // Utility channels are optional systems such as repair or clearance beams.
        utility_controller: variable_struct_exists(_data, "utility_controller")
            ? variable_clone(_data.utility_controller)
            : undefined
    };
}

/// @description Initializes shield, armour and hull from the calculated final stats.
function sc_enemy_init_defence(_enemy)
{
    var _runtime = _enemy.enemy;
    var _final = _runtime.stats.final;

    _runtime.defence = {
        shield: { current: _final.shield_max, maximum: _final.shield_max },
        armour: { current: _final.armour_max, maximum: _final.armour_max },
        hull: { current: _final.hull_max, maximum: _final.hull_max }
    };
}

/// @description Connects cached sprites and faction effects to the enemy visual runtime.
function sc_enemy_init_visual_runtime(_enemy, _cache)
{
    var _runtime = _enemy.enemy;

    _runtime.visual.runtime = {
        body_sprite: is_struct(_cache) ? _cache.body : -1,
        damage_layers: is_struct(_cache) ? _cache.damage_layers : undefined,
        core_sprite: is_struct(_cache) ? _cache.core : -1,
        thrust_sprite: is_struct(_cache) ? _cache.thrust : -1,
        shield_sprite: is_struct(_cache) ? _cache.shield : -1,
        damage_fx: sc_faction_damage_fx_get(_runtime.identity.faction),
        shield_hit_alpha: 0,
        core_angle: 0,
        core_alpha: 1,
        motion_phase: random(2 * pi)
    };
}

/// @description Initializes cached sprites, aiming and ownership for every hardpoint.
function sc_enemy_init_hardpoints(_enemy, _cache)
{
    var _runtime = _enemy.enemy;

    for (var _i = 0; _i < array_length(_runtime.hardpoints); ++_i)
    {
        var _hardpoint = _runtime.hardpoints[_i];
        var _sprite = is_struct(_cache)
            && _i < array_length(_cache.hardpoints)
            ? _cache.hardpoints[_i]
            : -1;

        if (!variable_struct_exists(_hardpoint, "rotation"))
        {
            _hardpoint.rotation = {
                mode: HardpointRotation.FIXED,
                turn_speed: 0,
                arc: 0,
                return_to_rest: true
            };
        }

        // Utility-controlled hardpoints are claimed later by the utility controller.
        _hardpoint.runtime = {
            sprite: _sprite,
            recoil: 0,
            aim_angle: _enemy.draw_angle + _hardpoint.angle,
            utility_controlled: false
        };
    }
}

/// @description Initializes the active state and animation phase of every thruster.
function sc_enemy_init_thrusters(_enemy)
{
    var _thrusters = _enemy.enemy.thrusters;

    for (var _i = 0; _i < array_length(_thrusters); ++_i)
    {
        _thrusters[_i].runtime = {
            active: false,
            power: 0,
            phase: irandom(359)
        };
    }
}

/// @description Initializes one enemy from registered data and final stats.
function sc_enemy_init(_enemy, _enemy_key)
{
    // Validate and retrieve the registered enemy definition.
    if (!variable_struct_exists(global.data.enemies, _enemy_key))
    {
        show_debug_message(
            "ENEMY INITIALIZATION ERROR - unknown key: "
            + _enemy_key
        );

        return false;
    }

    var _data = variable_struct_get(global.data.enemies, _enemy_key);

    // Create the shared runtime before calculating its final stats.
    _enemy.enemy = sc_enemy_init_runtime_create(
        _enemy,
        _enemy_key,
        _data
    );

    if (!sc_enemy_stats_init(_enemy, _data.stats_base))
        return false;

    var _runtime = _enemy.enemy;
    var _cache = sc_enemy_visual_cache_get(_enemy_key);

    // Establish initial facing before entity and hardpoint initialization.
    _enemy.draw_angle = 0;
    _runtime.movement.command.facing_mode =
        _runtime.movement_controller.facing.default_mode;

    if (!sc_entity_init(
        _enemy,
        _runtime.identity.faction,
        sc_enemy_damage,
        _runtime.collision,
        true,
        sc_enemy_knockback_apply
    ))
        return false;

    // Attach defence, cached visuals and per-component runtime data.
    sc_enemy_init_defence(_enemy);
    sc_enemy_init_visual_runtime(_enemy, _cache);
    sc_enemy_init_hardpoints(_enemy, _cache);
    sc_enemy_init_thrusters(_enemy);

    // Utility initialization happens after attacks and claims its own hardpoints.
    if (!sc_enemy_attack_controller_init(_enemy))
        return false;

    if (is_struct(_runtime.utility_controller)
    && !sc_enemy_utility_controller_init(_enemy))
        return false;

    _enemy.initialized = true;
    global.level.enemies_alive++;

    show_debug_message(
        "ENEMY INITIALIZED - "
        + _runtime.identity.name
    );

    return true;
}