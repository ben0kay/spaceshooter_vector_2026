#region AUTHOR SCHEMA

/*
ENEMY ATTACK CONTROLLER AUTHORING SCHEMA

attack_controller: {
    selection: AttackSelection.WEIGHTED,       // Default: WEIGHTED
    max_active_channels: 1,                    // Default: 1

    channels: [                                // Optional: omission creates "main"
        {
            key: "main",
            selection: AttackSelection.WEIGHTED
        }
    ],

    attacks: [
        {
            key: "attack_key",                 // Required
            channel: "main",                   // Required with explicit channels
            weight: 100,                       // Default: 100
            hardpoint_group: "weapons",        // Required
            weapon_key: "weapon_key",          // Required

            conditions: {                      // Optional: omitted condition = unrestricted
                asteroid_target: true,
                line_of_sight: true,            // Boolean or { solids:true, asteroids:true }
                range_min: 0,
                range_max: 1200,
                shield_ratio_min: 0,
                shield_ratio_max: 1,
                armour_ratio_min: 0,
                armour_ratio_max: 1,
                hull_ratio_min: 0,
                hull_ratio_max: 1
            },

            aim: {
                mode: AimMode.MOUNT,            // Default: MOUNT
                prediction_strength: 0,         // Default: 0
                angle_offset: 0,                // Default: 0
                inaccuracy: 0,                  // Default: 0
                fire_tolerance: 360,            // Default: 360
                world_direction: 0              // Default: 0
            },

            shot: {
                pattern: ShotPattern.SINGLE,    // Default: SINGLE
                amount: 1,                      // Default: 1
                angle_total: 0                  // Default: 0
            },

            telegraph: {                        // Entire block optional
                duration: 30,                   // Default: 30
                aim_lock_remaining: 0,          // Default: 0
                track_during_active: true,      // Default: true
                scale: 0.2,                     // Default: 0.2
                particle_interval: 1,           // Default: 1
                draw_script: sc_attack_telegraph_energy_draw,
                particle_script: sc_particles_attack_telegraph_emit
            },

            firing: {
                order: HardpointFireOrder.ALL,  // Default: ALL
                interval: 0,                    // Default: 0
                volley_max: 1,                  // Default: 1
                duration: 60,                   // Default: 60, beams only
                cooldown: 120,                  // Default: 120

                direction_pattern: {            // Entire block optional
                    type: VolleyDirectionPattern.FIXED,
                    start_offset: 0,
                    angle_total: 360,
                    angle_step: 15,
                    offsets: [-30,30],
                    rotation_offset_per_attack: 0
                }
            }
        }
    ],

    sequences: {                               // Entire block optional
        enabled: false,                        // Default: false
        selection: AttackSelection.WEIGHTED,   // Default: WEIGHTED

        entries: [
            {
                key: "sequence_key",            // Required
                weight: 100,                    // Default: 100

                conditions: {                   // Optional; fallback = first attack conditions
                    line_of_sight: true,
                    range_min: 0,
                    range_max: 1200,
                    shield_ratio_min: 0,
                    shield_ratio_max: 1,
                    armour_ratio_min: 0,
                    armour_ratio_max: 1,
                    hull_ratio_min: 0,
                    hull_ratio_max: 1
                },

                modifiers: {
                    fire_rate_multiplier: 1,        // Default: 1
                    damage_multiplier: 1,           // Default: 1
                    projectile_speed_multiplier: 1 // Default: 1
                },

                steps: [
                    {
                        attack_key: "attack_key",    // Required
                        repeat_amount: 1,            // Default: 1
                        gap_after: 0                 // Default: 0
                    }
                ],

                cooldown: 180                       // Default: 180
            }
        ]
    }
}

INTERNAL FIELDS - NEVER AUTHOR THESE

attack_lookup
activation_counts
runtime
sequence_runtime
hardpoint_indices
step.attack
*/

#endregion

/// @description Applies defaults to one optional volley-direction pattern.
function sc_enemy_attack_direction_defaults_apply(_pattern)
{
    if (!variable_struct_exists(_pattern,"type"))
        _pattern.type = VolleyDirectionPattern.FIXED;

    if (!variable_struct_exists(_pattern,"rotation_offset_per_attack"))
        _pattern.rotation_offset_per_attack = 0;

    switch (_pattern.type)
    {
        case VolleyDirectionPattern.FIXED:
            if (!variable_struct_exists(_pattern,"start_offset"))
                _pattern.start_offset = 0;
        break;

        case VolleyDirectionPattern.RADIAL:
            if (!variable_struct_exists(_pattern,"start_offset"))
                _pattern.start_offset = 0;

            if (!variable_struct_exists(_pattern,"angle_total"))
                _pattern.angle_total = 360;
        break;

        case VolleyDirectionPattern.SWEEP:
            if (!variable_struct_exists(_pattern,"angle_total"))
                _pattern.angle_total = 180;

            if (!variable_struct_exists(_pattern,"start_offset"))
                _pattern.start_offset = -_pattern.angle_total * 0.5;
        break;

        case VolleyDirectionPattern.ZIGZAG:
            if (!variable_struct_exists(_pattern,"start_offset"))
                _pattern.start_offset = 0;

            if (!variable_struct_exists(_pattern,"angle_step"))
                _pattern.angle_step = 15;
        break;

        case VolleyDirectionPattern.ALTERNATE:
            if (!variable_struct_exists(_pattern,"start_offset"))
                _pattern.start_offset = 0;

            if (!variable_struct_exists(_pattern,"offsets"))
                _pattern.offsets = [-30,30];
        break;
    }
}

/// @description Applies centralized defaults to one enemy attack definition.
function sc_enemy_attack_defaults_apply(_enemy_key,_attack,_explicit_channels)
{
    if (!variable_struct_exists(_attack,"key")
    || !variable_struct_exists(_attack,"hardpoint_group")
    || !variable_struct_exists(_attack,"weapon_key"))
    {
        show_debug_message("ENEMY ATTACK ERROR - incomplete attack definition: " + _enemy_key);
        return false;
    }

    if (_explicit_channels
    && !variable_struct_exists(_attack,"channel"))
    {
        show_debug_message(
            "ENEMY ATTACK ERROR - missing channel on "
            + _enemy_key + ": " + _attack.key
        );

        return false;
    }

    if (!variable_struct_exists(_attack,"weight"))
        _attack.weight = 100;

    if (!variable_struct_exists(_attack,"aim"))
        _attack.aim = {};

    var _aim = _attack.aim;

    if (!variable_struct_exists(_aim,"mode"))
        _aim.mode = AimMode.MOUNT;

    if (!variable_struct_exists(_aim,"prediction_strength"))
        _aim.prediction_strength = 0;

    if (!variable_struct_exists(_aim,"angle_offset"))
        _aim.angle_offset = 0;

    if (!variable_struct_exists(_aim,"inaccuracy"))
        _aim.inaccuracy = 0;

    if (!variable_struct_exists(_aim,"fire_tolerance"))
        _aim.fire_tolerance = 360;

    if (!variable_struct_exists(_aim,"world_direction"))
        _aim.world_direction = 0;

    if (!variable_struct_exists(_attack,"shot"))
        _attack.shot = {};

    var _shot = _attack.shot;

    if (!variable_struct_exists(_shot,"pattern"))
        _shot.pattern = ShotPattern.SINGLE;

    if (!variable_struct_exists(_shot,"amount"))
        _shot.amount = 1;

    if (!variable_struct_exists(_shot,"angle_total"))
        _shot.angle_total = 0;

    if (!variable_struct_exists(_attack,"firing"))
        _attack.firing = {};

    var _firing = _attack.firing;

    if (!variable_struct_exists(_firing,"order"))
        _firing.order = HardpointFireOrder.ALL;

    if (!variable_struct_exists(_firing,"interval"))
        _firing.interval = 0;

    if (!variable_struct_exists(_firing,"volley_max"))
        _firing.volley_max = 1;

    if (!variable_struct_exists(_firing,"duration"))
        _firing.duration = 60;

    if (!variable_struct_exists(_firing,"cooldown"))
        _firing.cooldown = 120;

    if (variable_struct_exists(_firing,"direction_pattern"))
        sc_enemy_attack_direction_defaults_apply(_firing.direction_pattern);

    if (variable_struct_exists(_attack,"telegraph"))
    {
        var _telegraph = _attack.telegraph;

        if (!variable_struct_exists(_telegraph,"duration"))
            _telegraph.duration = 30;

        if (!variable_struct_exists(_telegraph,"aim_lock_remaining"))
            _telegraph.aim_lock_remaining = 0;

        if (!variable_struct_exists(_telegraph,"track_during_active"))
            _telegraph.track_during_active = true;

        if (!variable_struct_exists(_telegraph,"scale"))
            _telegraph.scale = 0.2;

        if (!variable_struct_exists(_telegraph,"particle_interval"))
            _telegraph.particle_interval = 1;

        if (!variable_struct_exists(_telegraph,"draw_script"))
            _telegraph.draw_script = sc_attack_telegraph_energy_draw;

        if (!variable_struct_exists(_telegraph,"particle_script"))
            _telegraph.particle_script = sc_particles_attack_telegraph_emit;
    }

    return true;
}

/// @description Applies centralized defaults to one authored attack sequence.
function sc_enemy_attack_sequence_defaults_apply(_enemy_key,_sequence)
{
    if (!variable_struct_exists(_sequence,"key")
    || !variable_struct_exists(_sequence,"steps")
    || !is_array(_sequence.steps)
    || array_length(_sequence.steps) <= 0)
    {
        show_debug_message("ENEMY ATTACK ERROR - invalid sequence: " + _enemy_key);
        return false;
    }

    if (!variable_struct_exists(_sequence,"weight"))
        _sequence.weight = 100;

    if (!variable_struct_exists(_sequence,"cooldown"))
        _sequence.cooldown = 180;

    if (!variable_struct_exists(_sequence,"modifiers"))
        _sequence.modifiers = {};

    var _modifiers = _sequence.modifiers;

    if (!variable_struct_exists(_modifiers,"fire_rate_multiplier"))
        _modifiers.fire_rate_multiplier = 1;

    if (!variable_struct_exists(_modifiers,"damage_multiplier"))
        _modifiers.damage_multiplier = 1;

    if (!variable_struct_exists(_modifiers,"projectile_speed_multiplier"))
        _modifiers.projectile_speed_multiplier = 1;

    _modifiers.fire_rate_multiplier =
        max(0.01,_modifiers.fire_rate_multiplier);

    _modifiers.damage_multiplier =
        max(0,_modifiers.damage_multiplier);

    _modifiers.projectile_speed_multiplier =
        max(0,_modifiers.projectile_speed_multiplier);

    for (var _i = 0; _i < array_length(_sequence.steps); ++_i)
    {
        var _step = _sequence.steps[_i];

        if (!variable_struct_exists(_step,"attack_key"))
        {
            show_debug_message(
                "ENEMY ATTACK ERROR - sequence step missing attack key: "
                + _enemy_key + " / " + _sequence.key
            );

            return false;
        }

        if (!variable_struct_exists(_step,"repeat_amount"))
            _step.repeat_amount = 1;

        if (!variable_struct_exists(_step,"gap_after"))
            _step.gap_after = 0;

        _step.repeat_amount = max(1,round(_step.repeat_amount));
        _step.gap_after = max(0,round(_step.gap_after));
    }

    return true;
}

/// @description Applies defaults and validates one enemy attack controller.
function sc_enemy_attack_controller_defaults_apply(_enemy_key,_controller)
{
    if (!is_struct(_controller)
    || !variable_struct_exists(_controller,"attacks")
    || !is_array(_controller.attacks)
    || array_length(_controller.attacks) <= 0)
    {
        show_debug_message("ENEMY ATTACK ERROR - no attacks: " + _enemy_key);
        return false;
    }

    if (!variable_struct_exists(_controller,"selection"))
        _controller.selection = AttackSelection.WEIGHTED;

    if (!variable_struct_exists(_controller,"max_active_channels"))
        _controller.max_active_channels = 1;

    var _explicit_channels = variable_struct_exists(_controller,"channels");

    for (var _i = 0; _i < array_length(_controller.attacks); ++_i)
    {
        if (!sc_enemy_attack_defaults_apply(
            _enemy_key,
            _controller.attacks[_i],
            _explicit_channels
        ))
            return false;
    }

    if (!variable_struct_exists(_controller,"sequences"))
        return true;

    var _sequences = _controller.sequences;

    if (!variable_struct_exists(_sequences,"enabled"))
        _sequences.enabled = false;

    if (!variable_struct_exists(_sequences,"selection"))
        _sequences.selection = AttackSelection.WEIGHTED;

    if (!_sequences.enabled)
        return true;

    if (!variable_struct_exists(_sequences,"entries")
    || !is_array(_sequences.entries)
    || array_length(_sequences.entries) <= 0)
    {
        show_debug_message("ENEMY ATTACK ERROR - enabled sequences contain no entries: " + _enemy_key);
        return false;
    }

    for (var _i = 0; _i < array_length(_sequences.entries); ++_i)
    {
        if (!sc_enemy_attack_sequence_defaults_apply(
            _enemy_key,
            _sequences.entries[_i]
        ))
            return false;
    }

    return true;
}

/// @description Creates one independent enemy attack-channel runtime.
function sc_enemy_attack_runtime_create()
{
    return {
        phase: EnemyAttackPhase.IDLE,
        current_attack: -1,
        next_attack_index: 0,
        hardpoint_cursor: 0,
        volley_count: 0,
        activation_index: 0,
        next_fire_tick: 0,
        cooldown_until: 0,
        attack_end_tick: 0,
        telegraph_start_tick: 0,
        telegraph_end_tick: 0,
        next_telegraph_particle_tick: 0,
        active_deliveries: []
    };
}

/// @description Makes one channel available to existing shared attack functions.
function sc_enemy_attack_channel_bind(_controller, _channel)
{
    _controller.selection = _channel.selection;
    _controller.attacks = _channel.attacks;
    _controller.runtime = _channel.runtime;
}

/// @description Initializes optional authored attack sequences.
function sc_enemy_attack_sequences_init(_enemy)
{
    var _controller = _enemy.enemy.attack_controller;

    if (!variable_struct_exists(_controller,"sequences")
    || !_controller.sequences.enabled)
        return true;

    var _sequences = _controller.sequences;

    for (var _s = 0; _s < array_length(_sequences.entries); ++_s)
    {
        var _sequence = _sequences.entries[_s];

        for (var _i = 0; _i < array_length(_sequence.steps); ++_i)
        {
            var _step = _sequence.steps[_i];

            if (!variable_struct_exists(_controller.attack_lookup,_step.attack_key))
            {
                show_debug_message(
                    "ENEMY ATTACK ERROR - unknown sequence attack "
                    + _step.attack_key + " on " + _enemy.enemy.key
                );

                return false;
            }

            _step.attack = variable_struct_get(
                _controller.attack_lookup,
                _step.attack_key
            );
        }
    }

    var _channel = {
        key: "sequence",
        selection: AttackSelection.SEQUENTIAL,
        attacks: [],
        runtime: sc_enemy_attack_runtime_create()
    };

    array_push(_controller.channels,_channel);

    _controller.sequence_runtime = {
        channel: _channel,
        current_sequence: -1,
        next_sequence_index: 0,
        step_index: 0,
        repeat_index: 0,
        active_step: false,
        next_step_tick: 0,
        cooldown_until: 0,

        modifiers: {
            fire_rate_multiplier: 1,
            damage_multiplier: 1,
            projectile_speed_multiplier: 1
        }
    };

    return true;
}

/// @description Initializes backward-compatible independent attack channels.
function sc_enemy_attack_controller_init(_enemy)
{
    var _data = _enemy.enemy;
    var _controller = _data.attack_controller;
    var _source_attacks = _controller.attacks;

    _controller.attack_lookup = {};
    _controller.activation_counts = {};

    for (var _i = 0; _i < array_length(_source_attacks); ++_i)
    {
        var _attack = _source_attacks[_i];

        variable_struct_set(
            _controller.attack_lookup,
            _attack.key,
            _attack
        );

        variable_struct_set(
            _controller.activation_counts,
            _attack.key,
            0
        );
    }

    if (!variable_struct_exists(_controller,"channels"))
    {
        _controller.channels = [{
            key: "main",
            selection: _controller.selection,
            attacks: _source_attacks,
            runtime: sc_enemy_attack_runtime_create()
        }];
    }
    else
    {
        if (array_length(_controller.channels) <= 0)
        {
            show_debug_message("ENEMY ATTACK ERROR - no channels: " + _data.key);
            return false;
        }

        for (var _i = 0; _i < array_length(_controller.channels); ++_i)
        {
            var _channel = _controller.channels[_i];

            if (!variable_struct_exists(_channel,"selection"))
                _channel.selection = _controller.selection;

            _channel.attacks = [];
            _channel.runtime = sc_enemy_attack_runtime_create();
        }

        for (var _i = 0; _i < array_length(_source_attacks); ++_i)
        {
            var _attack = _source_attacks[_i];

            if (!variable_struct_exists(_attack,"channel"))
            {
                show_debug_message(
                    "ENEMY ATTACK ERROR - missing channel on "
                    + _data.key + ": " + _attack.key
                );

                return false;
            }

            var _assigned = false;

            for (var _c = 0; _c < array_length(_controller.channels); ++_c)
            {
                var _channel = _controller.channels[_c];

                if (_channel.key != _attack.channel) continue;

                array_push(_channel.attacks,_attack);
                _assigned = true;
                break;
            }

            if (!_assigned)
            {
                show_debug_message(
                    "ENEMY ATTACK ERROR - unknown channel "
                    + _attack.channel + " on " + _data.key
                );

                return false;
            }
        }
    }

    var _channel_count = array_length(_controller.channels);

    _controller.max_active_channels = variable_struct_exists(_controller,"max_active_channels")
        ? clamp(round(_controller.max_active_channels),1,_channel_count)
        : 1;

    for (var _c = 0; _c < _channel_count; ++_c)
    {
        var _channel = _controller.channels[_c];

        if (array_length(_channel.attacks) <= 0)
        {
            show_debug_message(
                "ENEMY ATTACK ERROR - empty channel "
                + _channel.key + " on " + _data.key
            );

            return false;
        }

        for (var _i = 0; _i < array_length(_channel.attacks); ++_i)
        {
            var _attack = _channel.attacks[_i];
            _attack.hardpoint_indices = [];

            for (var _h = 0; _h < array_length(_data.hardpoints); ++_h)
            {
                if (_data.hardpoints[_h].group == _attack.hardpoint_group)
                    array_push(_attack.hardpoint_indices,_h);
            }

            if (array_length(_attack.hardpoint_indices) <= 0)
            {
                show_debug_message(
                    "ENEMY ATTACK ERROR - no hardpoints for "
                    + _attack.key + " on " + _data.key
                );

                return false;
            }
        }
    }

    if (!sc_enemy_attack_sequences_init(_enemy))
        return false;

    sc_enemy_attack_channel_bind(_controller,_controller.channels[0]);
    return true;
}

/// @description Returns whether one channel is telegraphing or actively attacking.
function sc_enemy_attack_channel_active(_channel)
{
    var _phase = _channel.runtime.phase;

    return _phase == EnemyAttackPhase.TELEGRAPH
        || _phase == EnemyAttackPhase.ACTIVE;
}

/// @description Returns whether one attack runtime currently locks its aim.
function sc_enemy_attack_runtime_aim_locked(_attack, _runtime)
{
    if (!variable_struct_exists(_attack, "telegraph")) return false;

    switch (_runtime.phase)
    {
        case EnemyAttackPhase.TELEGRAPH:
            return GAME_TICK >=
                _runtime.telegraph_end_tick
                - _attack.telegraph.aim_lock_remaining;

        case EnemyAttackPhase.ACTIVE:
            return !_attack.telegraph.track_during_active;
    }

    return false;
}

/// @description Returns whether any fixed participating hardpoint locks the enemy hull.
function sc_enemy_attack_aim_locked(_enemy)
{
    var _controller = _enemy.enemy.attack_controller;

    for (var _c = 0; _c < array_length(_controller.channels); _c++)
    {
        var _channel = _controller.channels[_c];
        var _runtime = _channel.runtime;

        if (_runtime.current_attack < 0) continue;

        var _attack = _channel.attacks[_runtime.current_attack];
        if (!sc_enemy_attack_runtime_aim_locked(_attack, _runtime)) continue;

        for (var _i = 0; _i < array_length(_attack.hardpoint_indices); _i++)
        {
            var _hardpoint = _enemy.enemy.hardpoints[_attack.hardpoint_indices[_i]];

            if (_hardpoint.rotation.mode == HardpointRotation.FIXED)
                return true;
        }
    }

    return false;
}

/// @description Returns whether a rotating hardpoint is locked by any active channel.
function sc_enemy_attack_hardpoint_aim_locked(_enemy, _hardpoint_index)
{
    var _controller = _enemy.enemy.attack_controller;

    for (var _c = 0; _c < array_length(_controller.channels); _c++)
    {
        var _channel = _controller.channels[_c];
        var _runtime = _channel.runtime;

        if (_runtime.current_attack < 0) continue;

        var _attack = _channel.attacks[_runtime.current_attack];
        if (!sc_enemy_attack_runtime_aim_locked(_attack, _runtime)) continue;

        for (var _i = 0; _i < array_length(_attack.hardpoint_indices); _i++)
        {
            if (_attack.hardpoint_indices[_i] != _hardpoint_index) continue;

            return _enemy.enemy.hardpoints[_hardpoint_index].rotation.mode
                == HardpointRotation.TARGET;
        }
    }

    return false;
}

/// @description Releases deliveries and resets one attack channel.
function sc_enemy_attack_channel_cancel(_channel)
{
    var _runtime = _channel.runtime;

    for (var _i = 0; _i < array_length(_runtime.active_deliveries); _i++)
    {
        var _delivery = _runtime.active_deliveries[_i].delivery_id;
        if (instance_exists(_delivery)) sc_beam_release(_delivery);
    }

    _runtime.active_deliveries = [];
    _runtime.phase = EnemyAttackPhase.IDLE;
    _runtime.current_attack = -1;
    _runtime.hardpoint_cursor = 0;
    _runtime.volley_count = 0;
    _runtime.attack_end_tick = 0;
    _runtime.telegraph_start_tick = 0;
    _runtime.telegraph_end_tick = 0;
    _runtime.next_telegraph_particle_tick = 0;
}

/// @description Cancels every active attack channel belonging to an enemy.
function sc_enemy_attack_cancel(_enemy)
{
    var _controller = _enemy.enemy.attack_controller;

    for (var _c = 0; _c < array_length(_controller.channels); ++_c)
        sc_enemy_attack_channel_cancel(_controller.channels[_c]);

    if (variable_struct_exists(_controller,"sequence_runtime"))
    {
        var _sequence = _controller.sequence_runtime;

        _sequence.current_sequence = -1;
        _sequence.step_index = 0;
        _sequence.repeat_index = 0;
        _sequence.active_step = false;
        _sequence.next_step_tick = 0;
        _sequence.cooldown_until = GAME_TICK + 15;
    }

    sc_enemy_attack_channel_bind(_controller,_controller.channels[0]);
}

/// @description Completes the currently bound attack and begins its cooldown.
function sc_enemy_attack_finish(_enemy,_cooldown)
{
    var _controller = _enemy.enemy.attack_controller;
    var _runtime = _controller.runtime;

    var _attack = _runtime.current_attack >= 0
        ? _controller.attacks[_runtime.current_attack]
        : undefined;

    for (var _i = 0; _i < array_length(_runtime.active_deliveries); _i++)
    {
        var _delivery = _runtime.active_deliveries[_i].delivery_id;
        if (instance_exists(_delivery))
            sc_beam_release(_delivery);
    }

    _runtime.active_deliveries = [];
    _runtime.phase = EnemyAttackPhase.COOLDOWN;
    _runtime.current_attack = -1;
    _runtime.hardpoint_cursor = 0;
    _runtime.volley_count = 0;
    _runtime.attack_end_tick = 0;
    _runtime.telegraph_start_tick = 0;
    _runtime.telegraph_end_tick = 0;
    _runtime.next_telegraph_particle_tick = 0;
    _runtime.cooldown_until = GAME_TICK + max(1,round(_cooldown));

    if (!is_undefined(_attack)
    && variable_struct_exists(_attack,"finish_script"))
        _attack.finish_script(_enemy,_attack);
}

/// @description Returns the current combat target without replacing the strategic player target.
function sc_enemy_attack_target_get(_enemy)
{
    if (sc_enemy_asteroid_destroy_active(_enemy))
        return _enemy.enemy.movement.obstacle.target_id;

    return _enemy.enemy.target_id;
}

/// @description Returns whether an attack requires any unobstructed target view.
function sc_enemy_attack_line_of_sight_required(_attack)
{
    if (!variable_struct_exists(_attack,"conditions")
    || !variable_struct_exists(_attack.conditions,"line_of_sight"))
        return false;

    return _attack.conditions.line_of_sight != false;
}

/// @description Checks a broad three-line corridor using supplied LOS rules.
function sc_enemy_attack_line_of_sight_clear_to(_enemy,_target,_line_of_sight = true)
{
    if (!instance_exists(_target)) return false;

    var _check_solids = true;
    var _check_asteroids = true;

    if (is_struct(_line_of_sight))
    {
        _check_solids = _line_of_sight.solids;
        _check_asteroids = _line_of_sight.asteroids;
    }

    var _target_collision = _target.entity.collision;
    var _width = min(
        _target_collision.radius_forward,
        _target_collision.radius_side
    )*GCFG.enemy.asteroid.line_of_sight_width_scale;

    var _direction = point_direction(
        _enemy.x,
        _enemy.y,
        _target.x,
        _target.y
    );

    for (var _side = -1; _side <= 1; ++_side)
    {
        var _offset = _width*_side;
        var _start_x = _enemy.x+lengthdir_x(_offset,_direction+90);
        var _start_y = _enemy.y+lengthdir_y(_offset,_direction+90);
        var _end_x = _target.x+lengthdir_x(_offset,_direction+90);
        var _end_y = _target.y+lengthdir_y(_offset,_direction+90);

        if (_check_asteroids
        && global.level.asteroids_alive > 0
        && collision_line(
            _start_x,_start_y,
            _end_x,_end_y,
            o_asteroid,false,true
        ) != noone)
            return false;

        if (_check_solids
        && collision_line(
            _start_x,_start_y,
            _end_x,_end_y,
            o_solid,false,true
        ) != noone)
            return false;
    }

    return true;
}

/// @description Checks line of sight to the enemy's current attack target.
function sc_enemy_attack_line_of_sight_clear(_enemy,_attack = undefined)
{
    var _target = sc_enemy_attack_target_get(_enemy);
    if (!instance_exists(_target)) return false;
    if (sc_enemy_asteroid_destroy_active(_enemy)) return true;

    var _line_of_sight = is_struct(_attack)
        ? _attack.conditions.line_of_sight
        : true;

    return sc_enemy_attack_line_of_sight_clear_to(
        _enemy,
        _target,
        _line_of_sight
    );
}

/// @description Returns whether one attack is a committed telegraphed beam.
function sc_enemy_attack_is_committed_beam(_attack)
{
    if (!variable_struct_exists(_attack, "telegraph")) return false;

    var _weapon = variable_struct_get(global.data.weapons, _attack.weapon_key);
    return _weapon.delivery.type == AttackDelivery.BEAM;
}

/// @description Returns the active attack currently controlling one enemy hardpoint.
function sc_enemy_attack_hardpoint_attack_get(_enemy, _hardpoint_index)
{
    var _channels = _enemy.enemy.attack_controller.channels;

    for (var _c = 0; _c < array_length(_channels); ++_c)
    {
        var _channel = _channels[_c];
        var _attack_index = _channel.runtime.current_attack;

        if (_attack_index < 0) continue;

        var _attack = _channel.attacks[_attack_index];
        var _indices = _attack.hardpoint_indices;

        for (var _i = 0; _i < array_length(_indices); ++_i)
        {
            if (_indices[_i] == _hardpoint_index)
                return _attack;
        }
    }

    return undefined;
}

/// @description Returns direct or predictive aim for one enemy attack.
function sc_enemy_attack_aim_direction_get(_enemy, _attack, _target, _x, _y)
{
    var _direct = point_direction(_x, _y, _target.x, _target.y);

    if (_attack.aim.mode != AimMode.TARGET_LEAD)
        return _direct;

    var _weapon = variable_struct_get(
        global.data.weapons,
        _attack.weapon_key
    );

    // Beams, areas and deployables do not require travel-time prediction.
    if (_weapon.delivery.type != AttackDelivery.PROJECTILE)
        return _direct;

    var _speed = _weapon.delivery.projectile.speed;
    if (_speed <= 0) return _direct;

    var _velocity_x = 0;
    var _velocity_y = 0;

    if (_target.object_index == o_player)
    {
        _velocity_x = _target.movement.velocity_x;
        _velocity_y = _target.movement.velocity_y;
    }
    else if (_target.object_index == o_enemy)
    {
        _velocity_x = _target.enemy.movement.velocity_x;
        _velocity_y = _target.enemy.movement.velocity_y;
    }

    var _strength = clamp(_attack.aim.prediction_strength, 0, 1);
    var _travel_time = point_distance(_x, _y, _target.x, _target.y) / _speed;

    var _predicted_x = _target.x + _velocity_x * _travel_time * _strength;
    var _predicted_y = _target.y + _velocity_y * _travel_time * _strength;

    return point_direction(
        _x,
        _y,
        _predicted_x,
        _predicted_y
    );
}

/// @description Returns whether one hardpoint is aimed close enough to its attack solution.
function sc_enemy_attack_hardpoint_aligned(_enemy, _attack, _hardpoint_index)
{
    var _target = sc_enemy_attack_target_get(_enemy);
    if (!instance_exists(_target)) return false;

    var _transform = { x: 0, y: 0, direction: 0 };

    sc_enemy_hardpoint_attack_transform(
        _enemy,
        _attack,
        _hardpoint_index,
        _transform
    );

    var _target_direction = sc_enemy_attack_aim_direction_get(
        _enemy,
        _attack,
        _target,
        _transform.x,
        _transform.y
    );

    return abs(angle_difference(
        _target_direction,
        _transform.direction
    )) <= _attack.aim.fire_tolerance;
}

/// @description Returns whether enough participating hardpoints are aligned to begin an attack.
function sc_enemy_attack_alignment_ready(_enemy, _attack)
{
    var _indices = _attack.hardpoint_indices;
    if (array_length(_indices) <= 0) return false;

    switch (_attack.firing.order)
    {
        case HardpointFireOrder.ALL:
            for (var _i = 0; _i < array_length(_indices); _i++)
            {
                if (!sc_enemy_attack_hardpoint_aligned(_enemy, _attack, _indices[_i]))
                    return false;
            }

            return true;

        case HardpointFireOrder.SEQUENTIAL:
            return sc_enemy_attack_hardpoint_aligned(
                _enemy,
                _attack,
                _indices[0]
            );

        case HardpointFireOrder.RANDOM:
            for (var _i = 0; _i < array_length(_indices); _i++)
            {
                if (sc_enemy_attack_hardpoint_aligned(_enemy, _attack, _indices[_i]))
                    return true;
            }

            return false;
    }

    return false;
}

/// @description Checks shared range, sight and defence-ratio conditions.
function sc_enemy_attack_conditions_met(_enemy,_conditions)
{
    var _data = _enemy.enemy;
    var _target = sc_enemy_attack_target_get(_enemy);
    var _destroying_asteroid = sc_enemy_asteroid_destroy_active(_enemy);

    if (!instance_exists(_target)) return false;
    if (!is_struct(_conditions)) return true;

    if (_destroying_asteroid
    && variable_struct_exists(_conditions,"asteroid_target")
    && !_conditions.asteroid_target)
        return false;

    if (!_destroying_asteroid)
    {
        var _dx = _target.x - _enemy.x;
        var _dy = _target.y - _enemy.y;
        var _distance_sq = _dx * _dx + _dy * _dy;

        if (variable_struct_exists(_conditions,"range_min")
        && _distance_sq < sqr(_conditions.range_min))
            return false;

        if (variable_struct_exists(_conditions,"range_max")
        && _distance_sq > sqr(_conditions.range_max))
            return false;

        if (variable_struct_exists(_conditions,"line_of_sight")
        && _conditions.line_of_sight != false
        && !sc_enemy_attack_line_of_sight_clear_to(
            _enemy,
            _target,
            _conditions.line_of_sight
        ))
            return false;
    }

    var _defence = _data.defence;

    var _shield_ratio = _defence.shield.maximum > 0
        ? _defence.shield.current / _defence.shield.maximum
        : 0;

    var _armour_ratio = _defence.armour.maximum > 0
        ? _defence.armour.current / _defence.armour.maximum
        : 0;

    var _hull_ratio = _defence.hull.maximum > 0
        ? _defence.hull.current / _defence.hull.maximum
        : 0;

    if (variable_struct_exists(_conditions,"shield_ratio_min") && _shield_ratio < _conditions.shield_ratio_min) return false;
    if (variable_struct_exists(_conditions,"shield_ratio_max") && _shield_ratio > _conditions.shield_ratio_max) return false;
    if (variable_struct_exists(_conditions,"armour_ratio_min") && _armour_ratio < _conditions.armour_ratio_min) return false;
    if (variable_struct_exists(_conditions,"armour_ratio_max") && _armour_ratio > _conditions.armour_ratio_max) return false;
    if (variable_struct_exists(_conditions,"hull_ratio_min") && _hull_ratio < _conditions.hull_ratio_min) return false;
    if (variable_struct_exists(_conditions,"hull_ratio_max") && _hull_ratio > _conditions.hull_ratio_max) return false;

    return true;
}

/// @description Returns whether an attack currently satisfies all firing conditions.
function sc_enemy_attack_can_use(_enemy,_attack)
{
    var _conditions = variable_struct_exists(_attack,"conditions")
        ? _attack.conditions
        : undefined;

    if (!sc_enemy_attack_conditions_met(_enemy,_conditions))
        return false;

    return sc_enemy_attack_alignment_ready(_enemy,_attack);
}

/// @description Chooses one currently usable attack using the registered selection method.
function sc_enemy_attack_select(_enemy)
{
    var _controller = _enemy.enemy.attack_controller;
    var _runtime = _controller.runtime;
    var _count = array_length(_controller.attacks);

    switch (_controller.selection)
    {
        case AttackSelection.SEQUENTIAL:
            for (var _offset = 0; _offset < _count; _offset++)
            {
                var _index = (_runtime.next_attack_index + _offset) mod _count;

                if (sc_enemy_attack_can_use(_enemy, _controller.attacks[_index]))
                {
                    _runtime.next_attack_index = (_index + 1) mod _count;
                    return _index;
                }
            }
        break;

        case AttackSelection.RANDOM:
            var _selected = -1;
            var _eligible_count = 0;

            for (var _i = 0; _i < _count; _i++)
            {
                if (!sc_enemy_attack_can_use(_enemy, _controller.attacks[_i])) continue;

                _eligible_count++;
                if (irandom(_eligible_count - 1) == 0) _selected = _i;
            }

            return _selected;

        case AttackSelection.WEIGHTED:
            var _weight_total = 0;

            for (var _i = 0; _i < _count; _i++)
            {
                var _attack = _controller.attacks[_i];
                if (sc_enemy_attack_can_use(_enemy, _attack))
                    _weight_total += _attack.weight;
            }

            if (_weight_total <= 0) return -1;

            var _roll = random(_weight_total);

            for (var _i = 0; _i < _count; _i++)
            {
                var _attack = _controller.attacks[_i];
                if (!sc_enemy_attack_can_use(_enemy, _attack)) continue;

                _roll -= _attack.weight;
                if (_roll <= 0) return _i;
            }
        break;

        default:
            for (var _i = 0; _i < _count; _i++)
            {
                if (sc_enemy_attack_can_use(_enemy, _controller.attacks[_i]))
                    return _i;
            }
        break;
    }

    return -1;
}

/// @description Resolves one hardpoint muzzle and attack direction into a reusable transform.
function sc_enemy_hardpoint_attack_transform(_enemy, _attack, _hardpoint_index, _transform)
{
    var _data = _enemy.enemy;
    var _target = sc_enemy_attack_target_get(_enemy);
    var _hardpoint = _data.hardpoints[_hardpoint_index];
    var _radius = _data.visual.radius;
    var _mount_angle = _hardpoint.runtime.aim_angle;
    var _forward = _hardpoint.forward * _radius;
    var _side = _hardpoint.side * _radius;
    var _recoil = _hardpoint.runtime.recoil;

    var _mount_x = _enemy.x
        + lengthdir_x(_forward, _enemy.draw_angle)
        + lengthdir_x(_side, _enemy.draw_angle + 90)
        - lengthdir_x(_recoil, _mount_angle);

    var _mount_y = _enemy.y
        + lengthdir_y(_forward, _enemy.draw_angle)
        + lengthdir_y(_side, _enemy.draw_angle + 90)
        - lengthdir_y(_recoil, _mount_angle);

    _transform.x = _mount_x
        + lengthdir_x(_hardpoint.muzzle_forward * _radius, _mount_angle);

    _transform.y = _mount_y
        + lengthdir_y(_hardpoint.muzzle_forward * _radius, _mount_angle);

    _transform.direction = _mount_angle;

    if (_hardpoint.rotation.mode == HardpointRotation.FIXED)
    {
        switch (_attack.aim.mode)
        {
            case AimMode.TARGET:
            case AimMode.TARGET_LEAD:
                if (instance_exists(_target))
                {
                    _transform.direction = sc_enemy_attack_aim_direction_get(
                        _enemy,
                        _attack,
                        _target,
                        _transform.x,
                        _transform.y
                    );
                }
            break;

            case AimMode.WORLD:
                _transform.direction = _attack.aim.world_direction;
            break;
        }
    }
    else if (_attack.aim.mode == AimMode.WORLD)
        _transform.direction = _attack.aim.world_direction;

    _transform.direction += _attack.aim.angle_offset;
    return _transform;
}


#region volley direction patterns to implement later
/*
VOLLEY DIRECTION PATTERNS

Optional. Omit direction_pattern for ordinary fire.

RADIAL
direction_pattern: {
    type: VolleyDirectionPattern.RADIAL,
    angle_total: 360,
    start_offset: 0,
    rotation_offset_per_attack: 0
}

SWEEP
direction_pattern: {
    type: VolleyDirectionPattern.SWEEP,
    angle_total: 180,
    start_offset: -90
}

ZIGZAG
direction_pattern: {
    type: VolleyDirectionPattern.ZIGZAG,
    angle_step: 18,
    start_offset: 0
}

ALTERNATE
direction_pattern: {
    type: VolleyDirectionPattern.ALTERNATE,
    offsets: [-35,35],
    start_offset: 0
}
*/

#endregion

/// @description Returns the directional offset belonging to the current volley.
function sc_enemy_attack_volley_direction_offset_get(_attack,_runtime)
{
    if (!variable_struct_exists(_attack.firing,"direction_pattern"))
        return 0;

    var _pattern = _attack.firing.direction_pattern;
    var _index = _runtime.volley_count;
    var _amount = max(1,round(_attack.firing.volley_max));
    var _offset = 0;

    switch (_pattern.type)
    {
        case VolleyDirectionPattern.FIXED:
            _offset = _pattern.start_offset;
        break;

        case VolleyDirectionPattern.RADIAL:
            _offset =
                _pattern.start_offset
                + (_pattern.angle_total / _amount) * _index;
        break;

        case VolleyDirectionPattern.SWEEP:
            var _step = _amount > 1
                ? _pattern.angle_total / (_amount - 1)
                : 0;

            _offset = _pattern.start_offset + _step * _index;
        break;

        case VolleyDirectionPattern.ZIGZAG:
            if (_index <= 0)
                _offset = _pattern.start_offset;
            else
            {
                var _distance =
                    ceil(_index * 0.5)
                    * _pattern.angle_step;

                var _side = (_index mod 2 == 1)
                    ? 1
                    : -1;

                _offset =
                    _pattern.start_offset
                    + _distance * _side;
            }
        break;

        case VolleyDirectionPattern.ALTERNATE:
            var _offsets = _pattern.offsets;

            _offset = array_length(_offsets) > 0
                ? _pattern.start_offset
                    + _offsets[_index mod array_length(_offsets)]
                : _pattern.start_offset;
        break;
    }

    return _offset
        + _pattern.rotation_offset_per_attack
        * _runtime.activation_index;
}

/// @description Begins one selected attack on the currently bound channel.
function sc_enemy_attack_begin(_enemy,_attack_index)
{
    var _controller = _enemy.enemy.attack_controller;
    var _runtime = _controller.runtime;
    var _attack = _controller.attacks[_attack_index];
    var _activation_count = variable_struct_get(
        _controller.activation_counts,
        _attack.key
    );

    _runtime.current_attack = _attack_index;
    _runtime.hardpoint_cursor = 0;
    _runtime.volley_count = 0;
    _runtime.activation_index = _activation_count;
    _runtime.active_deliveries = [];
    _runtime.attack_end_tick = 0;

    variable_struct_set(
        _controller.activation_counts,
        _attack.key,
        _activation_count + 1
    );

    if (variable_struct_exists(_attack,"telegraph"))
    {
        _runtime.phase = EnemyAttackPhase.TELEGRAPH;
        _runtime.telegraph_start_tick = GAME_TICK;
        _runtime.telegraph_end_tick = GAME_TICK + max(1,round(_attack.telegraph.duration));
        _runtime.next_telegraph_particle_tick = GAME_TICK;
        return true;
    }

    return sc_enemy_attack_activate(_enemy,_attack);
}

/// @description Returns the active sequence-adjusted enemy fire rate.
function sc_enemy_attack_fire_rate_get(_enemy)
{
    var _controller = _enemy.enemy.attack_controller;
    var _fire_rate = _enemy.enemy.stats.final.fire_rate_multiplier;

    if (variable_struct_exists(_controller,"sequence_runtime")
    && _controller.sequence_runtime.current_sequence >= 0)
    {
        _fire_rate *=
            _controller.sequence_runtime.modifiers.fire_rate_multiplier;
    }

    return max(0.01,_fire_rate);
}

/// @description Fires one aligned hardpoint when its target corridor remains clear.
function sc_enemy_attack_fire_hardpoint(_enemy,_attack,_hardpoint_index)
{
    var _controller = _enemy.enemy.attack_controller;
    var _runtime = _controller.runtime;
    var _committed_beam = sc_enemy_attack_is_committed_beam(_attack);

    if (!_committed_beam)
    {
        if (!sc_enemy_attack_hardpoint_aligned(
            _enemy,
            _attack,
            _hardpoint_index
        ))
            return noone;

        if (sc_enemy_attack_line_of_sight_required(_attack)
        && !sc_enemy_attack_line_of_sight_clear(_enemy,_attack))
            return noone;
    }

    var _transform = { x: 0, y: 0, direction: 0 };

    sc_enemy_hardpoint_attack_transform(
        _enemy,
        _attack,
        _hardpoint_index,
        _transform
    );

    var _direction = _transform.direction
        + sc_enemy_attack_volley_direction_offset_get(_attack,_runtime)
        + random_range(
            -_attack.aim.inaccuracy,
            _attack.aim.inaccuracy
        );

    var _damage_multiplier =
        _enemy.enemy.stats.final.damage_multiplier;

    var _projectile_speed_multiplier = 1;

    if (variable_struct_exists(_controller,"sequence_runtime")
    && _controller.sequence_runtime.current_sequence >= 0)
    {
        var _modifiers =
            _controller.sequence_runtime.modifiers;

        _damage_multiplier *=
            _modifiers.damage_multiplier;

        _projectile_speed_multiplier =
            _modifiers.projectile_speed_multiplier;
    }

    var _delivery = sc_weapon_fire(
        _enemy,
        _attack.weapon_key,
        _attack.shot,
        _transform.x,
        _transform.y,
        _direction,
        _damage_multiplier,
        _projectile_speed_multiplier
    );

    if (instance_exists(_delivery))
    {
        var _hardpoint =
            _enemy.enemy.hardpoints[_hardpoint_index];

        var _recoil_scale =
            variable_struct_exists(_hardpoint,"recoil_scale")
            ? _hardpoint.recoil_scale
            : 0.14;

        _hardpoint.runtime.recoil =
            _enemy.enemy.visual.radius
            * _recoil_scale;
    }

    return _delivery;
}

/// @description Starts the selected enemy attack after any telegraph finishes.
function sc_enemy_attack_activate(_enemy, _attack)
{
    var _runtime = _enemy.enemy.attack_controller.runtime;
    var _weapon = variable_struct_get(global.data.weapons, _attack.weapon_key);

    _runtime.phase = EnemyAttackPhase.ACTIVE;
    _runtime.next_fire_tick = GAME_TICK;

    if (_weapon.delivery.type != AttackDelivery.BEAM) return true;

    _runtime.attack_end_tick = GAME_TICK + max(1, round(_attack.firing.duration));

    if (!sc_enemy_beam_attack_start(_enemy, _attack))
    {
        sc_enemy_attack_finish(_enemy, _attack.firing.cooldown / _enemy.enemy.stats.final.fire_rate_multiplier);
        return false;
    }

    return true;
}

/// @description Updates faction-coloured particles during an enemy attack telegraph.
function sc_enemy_attack_telegraph_update(_enemy, _attack)
{
    var _runtime = _enemy.enemy.attack_controller.runtime;
    var _telegraph = _attack.telegraph;

    if (GAME_TICK >= _runtime.telegraph_end_tick)
    {
        sc_enemy_attack_activate(_enemy, _attack);
        return;
    }

    if (GAME_TICK < _runtime.next_telegraph_particle_tick) return;

    _runtime.next_telegraph_particle_tick = GAME_TICK + max(1, round(_telegraph.particle_interval));

    var _progress = clamp(
        (GAME_TICK - _runtime.telegraph_start_tick)
        / max(1, _runtime.telegraph_end_tick - _runtime.telegraph_start_tick),
        0, 1
    );

    for (var _i = 0; _i < array_length(_attack.hardpoint_indices); _i++)
    {
        var _transform = { x: 0, y: 0, direction: 0 };
        sc_enemy_hardpoint_attack_transform(_enemy, _attack, _attack.hardpoint_indices[_i], _transform);
        _telegraph.particle_script(_enemy, _attack, _transform, _progress, _enemy.enemy.visual.palette, _telegraph);
    }
}

/// @description Draws every currently active channel telegraph.
function sc_enemy_attack_telegraph_draw(_enemy, _draw_x, _draw_y)
{
    var _data = _enemy.enemy;
    var _controller = _data.attack_controller;
    var _offset_x = _draw_x - _enemy.x;
    var _offset_y = _draw_y - _enemy.y;

    for (var _c = 0; _c < array_length(_controller.channels); _c++)
    {
        var _channel = _controller.channels[_c];
        var _runtime = _channel.runtime;

        if (_runtime.phase != EnemyAttackPhase.TELEGRAPH
        || _runtime.current_attack < 0)
            continue;

        var _attack = _channel.attacks[_runtime.current_attack];
        var _telegraph = _attack.telegraph;

        var _progress = clamp(
            (GAME_TICK - _runtime.telegraph_start_tick)
            / max(1, _runtime.telegraph_end_tick - _runtime.telegraph_start_tick),
            0,
            1
        );

        for (var _i = 0; _i < array_length(_attack.hardpoint_indices); _i++)
        {
            var _transform = { x: 0, y: 0, direction: 0 };

            sc_enemy_hardpoint_attack_transform(
                _enemy,
                _attack,
                _attack.hardpoint_indices[_i],
                _transform
            );

            _transform.x += _offset_x;
            _transform.y += _offset_y;

            _telegraph.draw_script(
                _enemy,
                _attack,
                _transform,
                _progress,
                _data.visual.palette,
                _telegraph
            );
        }
    }
}

/// @description Draws the reusable glowing energy-ball attack telegraph.
function sc_attack_telegraph_energy_draw(_enemy, _attack, _transform, _progress, _palette, _config)
{
    var _base_radius = _enemy.enemy.visual.radius * _config.scale;
    var _pulse = 1 + sin(GAME_TICK * lerp(0.18, 0.55, _progress)) * lerp(0.08, 0.18, _progress);
    var _radius = lerp(_base_radius * 0.18, _base_radius, _progress) * _pulse;
    var _orbit_radius = lerp(_base_radius * 1.5, _base_radius * 0.58, _progress);
    var _alpha = lerp(0.35, 1, _progress);
    var _rotation = GAME_TICK * lerp(3, 9, _progress);

    gpu_set_blendmode(bm_add);

    draw_set_colour(_palette.glow);
    draw_set_alpha(_alpha * 0.16);
    draw_circle(_transform.x, _transform.y, _radius * 2.6, false);

    draw_set_colour(_palette.accent);
    draw_set_alpha(_alpha * 0.3);
    draw_circle(_transform.x, _transform.y, _radius * 1.65, false);

    draw_set_colour(_palette.energy);
    draw_set_alpha(_alpha * 0.82);
    draw_circle(_transform.x, _transform.y, _radius, false);

    draw_set_colour(_palette.core);
    draw_set_alpha(_alpha);
    draw_circle(_transform.x, _transform.y, max(1.5, _radius * 0.32), false);

    for (var _i = 0; _i < 4; _i++)
    {
        var _angle = _rotation + _i * 90;
        var _spark_x = _transform.x + lengthdir_x(_orbit_radius, _angle);
        var _spark_y = _transform.y + lengthdir_y(_orbit_radius, _angle);

        draw_set_colour(_palette.energy);
        draw_set_alpha(_alpha * 0.75);
        draw_line_width(
            _spark_x,
            _spark_y,
            _transform.x + lengthdir_x(_radius, _angle),
            _transform.y + lengthdir_y(_radius, _angle),
            max(1, _base_radius * 0.08)
        );
    }

    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
    draw_set_colour(c_white);

    // Future: sc_attack_telegraph_cannon_charge_draw for sequential launcher lights.
}

/// @description Creates every beam delivery required by the selected enemy beam attack.
function sc_enemy_beam_attack_start(_enemy, _attack)
{
    var _runtime = _enemy.enemy.attack_controller.runtime;
    var _indices = _attack.hardpoint_indices;

    switch (_attack.firing.order)
    {
        case HardpointFireOrder.ALL:
            for (var _i = 0; _i < array_length(_indices); _i++)
            {
                var _beam = sc_enemy_attack_fire_hardpoint(_enemy, _attack, _indices[_i]);

                if (instance_exists(_beam))
                    array_push(_runtime.active_deliveries, {
                        hardpoint_index: _indices[_i],
                        delivery_id: _beam,
                        x: 0, y: 0, direction: 0
                    });
            }
        break;

        case HardpointFireOrder.SEQUENTIAL:
            var _index = _indices[_runtime.hardpoint_cursor];
            var _beam = sc_enemy_attack_fire_hardpoint(_enemy, _attack, _index);
            _runtime.hardpoint_cursor = (_runtime.hardpoint_cursor + 1) mod array_length(_indices);

            if (instance_exists(_beam))
                array_push(_runtime.active_deliveries, {
                    hardpoint_index: _index,
                    delivery_id: _beam,
                    x: 0, y: 0, direction: 0
                });
        break;

        case HardpointFireOrder.RANDOM:
            var _index = _indices[irandom(array_length(_indices) - 1)];
            var _beam = sc_enemy_attack_fire_hardpoint(_enemy, _attack, _index);

            if (instance_exists(_beam))
                array_push(_runtime.active_deliveries, {
                    hardpoint_index: _index,
                    delivery_id: _beam,
                    x: 0, y: 0, direction: 0
                });
        break;
    }

    return array_length(_runtime.active_deliveries) > 0;
}

/// @description Keeps all active enemy beams attached to their moving hardpoints.
function sc_enemy_beam_attack_sustain(_enemy, _attack)
{
    var _runtime = _enemy.enemy.attack_controller.runtime;

    for (var _i = array_length(_runtime.active_deliveries) - 1; _i >= 0; _i--)
    {
        var _active = _runtime.active_deliveries[_i];

        if (!instance_exists(_active.delivery_id))
        {
            array_delete(_runtime.active_deliveries, _i, 1);
            continue;
        }

        sc_enemy_hardpoint_attack_transform(_enemy, _attack, _active.hardpoint_index, _active);
        sc_beam_sustain(_active.delivery_id, _active.x, _active.y, _active.direction);
    }

    return array_length(_runtime.active_deliveries) > 0;
}

/// @description Updates telegraphs, gated projectile volleys and sustained beam attacks.
function sc_enemy_attack_channel_update(_enemy)
{
    var _data = _enemy.enemy;
    var _controller = _data.attack_controller;
    var _runtime = _controller.runtime;
    var _fire_rate = sc_enemy_attack_fire_rate_get(_enemy);

    if (_runtime.phase == EnemyAttackPhase.COOLDOWN)
    {
        if (GAME_TICK < _runtime.cooldown_until) return;
        _runtime.phase = EnemyAttackPhase.IDLE;
    }

    if (_runtime.phase == EnemyAttackPhase.IDLE)
    {
        var _selected = sc_enemy_attack_select(_enemy);

        if (_selected < 0)
        {
            _runtime.phase = EnemyAttackPhase.COOLDOWN;
            _runtime.cooldown_until = GAME_TICK + 15;
            return;
        }

        sc_enemy_attack_begin(_enemy,_selected);
        return;
    }

    var _attack = _controller.attacks[_runtime.current_attack];

    if (_runtime.phase == EnemyAttackPhase.TELEGRAPH)
    {
        sc_enemy_attack_telegraph_update(_enemy,_attack);
        return;
    }

    var _weapon = variable_struct_get(
        global.data.weapons,
        _attack.weapon_key
    );

    if (_weapon.delivery.type == AttackDelivery.BEAM)
    {
        if (GAME_TICK >= _runtime.attack_end_tick
        || !sc_enemy_beam_attack_sustain(_enemy,_attack))
        {
            sc_enemy_attack_finish(
                _enemy,
                _attack.firing.cooldown / _fire_rate
            );
        }

        return;
    }

    if (GAME_TICK < _runtime.next_fire_tick) return;

    var _indices = _attack.hardpoint_indices;

    switch (_attack.firing.order)
    {
        case HardpointFireOrder.ALL:
            for (var _i = 0; _i < array_length(_indices); ++_i)
                sc_enemy_attack_fire_hardpoint(_enemy,_attack,_indices[_i]);
        break;

        case HardpointFireOrder.SEQUENTIAL:
            var _index = _indices[_runtime.hardpoint_cursor];
            sc_enemy_attack_fire_hardpoint(_enemy,_attack,_index);

            _runtime.hardpoint_cursor =
                (_runtime.hardpoint_cursor + 1)
                mod array_length(_indices);
        break;

        case HardpointFireOrder.RANDOM:
            var _index = _indices[irandom(array_length(_indices) - 1)];
            sc_enemy_attack_fire_hardpoint(_enemy,_attack,_index);
        break;
    }

    _runtime.volley_count++;

    if (_runtime.volley_count >= _attack.firing.volley_max)
    {
        sc_enemy_attack_finish(
            _enemy,
            _attack.firing.cooldown / _fire_rate
        );
    }
    else
    {
        _runtime.next_fire_tick = GAME_TICK + max(
            1,
            round(_attack.firing.interval / _fire_rate)
        );
    }
}

#region ATTACK SEQUENCE 

/// @description Captures one sequence's normalized combat modifiers.
function sc_enemy_attack_sequence_modifiers_capture(_sequence,_runtime)
{
    var _source = _sequence.modifiers;
    var _modifiers = _runtime.modifiers;

    _modifiers.fire_rate_multiplier =
        _source.fire_rate_multiplier;

    _modifiers.damage_multiplier =
        _source.damage_multiplier;

    _modifiers.projectile_speed_multiplier =
        _source.projectile_speed_multiplier;
}

/// @description Returns whether an authored sequence may begin.
function sc_enemy_attack_sequence_can_use(_enemy,_sequence)
{
    if (array_length(_sequence.steps) <= 0) return false;

    var _first_attack = _sequence.steps[0].attack;

    if (!variable_struct_exists(_sequence,"conditions"))
        return sc_enemy_attack_can_use(_enemy,_first_attack);

    if (!sc_enemy_attack_conditions_met(_enemy,_sequence.conditions))
        return false;

    return sc_enemy_attack_alignment_ready(_enemy,_first_attack);
}

/// @description Selects one currently usable authored attack sequence.
function sc_enemy_attack_sequence_select(_enemy)
{
    var _controller = _enemy.enemy.attack_controller;
    var _sequences = _controller.sequences;
    var _runtime = _controller.sequence_runtime;
    var _entries = _sequences.entries;
    var _count = array_length(_entries);

    switch (_sequences.selection)
    {
        case AttackSelection.SEQUENTIAL:
            for (var _offset = 0; _offset < _count; ++_offset)
            {
                var _index =
                    (_runtime.next_sequence_index + _offset)
                    mod _count;

                if (!sc_enemy_attack_sequence_can_use(_enemy,_entries[_index]))
                    continue;

                _runtime.next_sequence_index = (_index + 1) mod _count;
                return _index;
            }
        break;

        case AttackSelection.RANDOM:
            var _selected = -1;
            var _eligible_count = 0;

            for (var _i = 0; _i < _count; ++_i)
            {
                if (!sc_enemy_attack_sequence_can_use(_enemy,_entries[_i]))
                    continue;

                _eligible_count++;

                if (irandom(_eligible_count - 1) == 0)
                    _selected = _i;
            }

            return _selected;

        case AttackSelection.WEIGHTED:
            var _weight_total = 0;

            for (var _i = 0; _i < _count; ++_i)
            {
                var _sequence = _entries[_i];

                if (sc_enemy_attack_sequence_can_use(_enemy,_sequence))
                    _weight_total += _sequence.weight;
            }

            if (_weight_total <= 0) return -1;

            var _roll = random(_weight_total);

            for (var _i = 0; _i < _count; ++_i)
            {
                var _sequence = _entries[_i];

                if (!sc_enemy_attack_sequence_can_use(_enemy,_sequence))
                    continue;

                _roll -= _sequence.weight;
                if (_roll <= 0) return _i;
            }
        break;
    }

    return -1;
}

/// @description Begins the current step of an authored attack sequence.
function sc_enemy_attack_sequence_step_begin(_enemy)
{
    var _controller = _enemy.enemy.attack_controller;
    var _sequence_runtime = _controller.sequence_runtime;
    var _sequence = _controller.sequences.entries[
        _sequence_runtime.current_sequence
    ];

    var _step = _sequence.steps[_sequence_runtime.step_index];
    var _channel = _sequence_runtime.channel;

    sc_enemy_attack_channel_cancel(_channel);

    _channel.attacks = [_step.attack];
    _sequence_runtime.active_step = true;

    sc_enemy_attack_channel_bind(_controller,_channel);
    sc_enemy_attack_begin(_enemy,0);
}

/// @description Advances repetition, step or cooldown after a sequence attack ends.
function sc_enemy_attack_sequence_step_finish(_enemy)
{
    var _controller = _enemy.enemy.attack_controller;
    var _runtime = _controller.sequence_runtime;
    var _sequence = _controller.sequences.entries[
        _runtime.current_sequence
    ];

    var _step = _sequence.steps[_runtime.step_index];
    var _fire_rate = sc_enemy_attack_fire_rate_get(_enemy);
    var _gap = round(_step.gap_after / _fire_rate);

    _runtime.active_step = false;

    if (_runtime.repeat_index + 1 < _step.repeat_amount)
    {
        _runtime.repeat_index++;
        _runtime.next_step_tick = GAME_TICK + _gap;
        return;
    }

    _runtime.repeat_index = 0;
    _runtime.step_index++;

    if (_runtime.step_index < array_length(_sequence.steps))
    {
        _runtime.next_step_tick = GAME_TICK + _gap;
        return;
    }

    _runtime.current_sequence = -1;
    _runtime.step_index = 0;
    _runtime.cooldown_until = GAME_TICK + max(
        1,
        round(_sequence.cooldown / _fire_rate)
    );
}

/// @description Updates one enabled authored enemy attack sequence.
function sc_enemy_attack_sequence_update(_enemy)
{
    var _controller = _enemy.enemy.attack_controller;
    var _runtime = _controller.sequence_runtime;

    if (_runtime.active_step)
    {
        sc_enemy_attack_channel_bind(_controller,_runtime.channel);
        sc_enemy_attack_channel_update(_enemy);

        var _attack_runtime = _runtime.channel.runtime;

        if (_attack_runtime.phase == EnemyAttackPhase.COOLDOWN
        && _attack_runtime.current_attack < 0)
            sc_enemy_attack_sequence_step_finish(_enemy);

        return;
    }

    if (GAME_TICK < _runtime.cooldown_until
    || GAME_TICK < _runtime.next_step_tick)
        return;

    if (_runtime.current_sequence < 0)
    {
        var _selected = sc_enemy_attack_sequence_select(_enemy);

        if (_selected < 0)
        {
            _runtime.cooldown_until = GAME_TICK + 15;
            return;
        }

        _runtime.current_sequence = _selected;
        _runtime.step_index = 0;
        _runtime.repeat_index = 0;

        sc_enemy_attack_sequence_modifiers_capture(
            _controller.sequences.entries[_selected],
            _runtime
        );
    }

    sc_enemy_attack_sequence_step_begin(_enemy);
}

#endregion

/// @description Updates enabled sequences or every independent attack channel.
function sc_enemy_attack_update(_enemy)
{
    var _controller = _enemy.enemy.attack_controller;

    if (variable_struct_exists(_controller,"sequence_runtime"))
    {
        sc_enemy_attack_sequence_update(_enemy);
        sc_enemy_attack_channel_bind(_controller,_controller.channels[0]);
        return;
    }

    var _channels = _controller.channels;
    var _active_count = 0;

    for (var _c = 0; _c < array_length(_channels); ++_c)
    {
        if (sc_enemy_attack_channel_active(_channels[_c]))
            _active_count++;
    }

    for (var _c = 0; _c < array_length(_channels); ++_c)
    {
        var _channel = _channels[_c];
        var _runtime = _channel.runtime;
        var _was_active = sc_enemy_attack_channel_active(_channel);

        var _ready_to_start = _runtime.phase == EnemyAttackPhase.IDLE
            || (_runtime.phase == EnemyAttackPhase.COOLDOWN
            && GAME_TICK >= _runtime.cooldown_until);

        if (_ready_to_start
        && !_was_active
        && _active_count >= _controller.max_active_channels)
            continue;

        sc_enemy_attack_channel_bind(_controller,_channel);
        sc_enemy_attack_channel_update(_enemy);

        var _is_active = sc_enemy_attack_channel_active(_channel);

        if (!_was_active && _is_active)
            _active_count++;
        else if (_was_active && !_is_active)
            _active_count--;
    }

    sc_enemy_attack_channel_bind(_controller,_channels[0]);
}