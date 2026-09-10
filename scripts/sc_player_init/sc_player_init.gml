/// @description Creates the campaign and currently active player loadouts.
function sc_player_init_loadout_create(_definition)
{
    var _campaign = variable_clone(_definition.starting_loadout);
    var _active = _campaign;

    if (global.config.debug.player_full_loadout
    && variable_struct_exists(_definition, "debug_loadout"))
        _active = variable_clone(_definition.debug_loadout);

    return {
        campaign: _campaign,
        active: _active
    };
}

/// @description Creates the registered ship runtime owned by the player.
function sc_player_init_ship_create(_ship_key, _definition, _loadout)
{
    return {
        key: _ship_key,
        identity: variable_clone(_definition.identity),
        collision: variable_clone(_definition.collision),
        systems: sc_ship_systems_runtime_create(_definition.systems),
        visual: variable_clone(_definition.visual),
        hardpoints: variable_clone(_definition.hardpoints),
        loadout: _loadout.active,
        visual_loadout: _loadout.campaign,
        stats: undefined
    };
}

/// @description Connects cached sprites and animation values to the ship visual runtime.
function sc_player_init_visual_runtime(_player, _definition, _cache)
{
    _player.ship.visual.runtime = {
        cache: _cache,
        thrust_power: 0,
        thrust_phase: irandom(359),
        shield_hit_alpha: 0,
        wing_fold: _definition.visual.wing.fold_idle,
        core_angle: 0,
        core_speed: _definition.visual.core.idle_speed
    };
}

/// @description Initializes runtime firing visuals for the primary hardpoints.
function sc_player_init_hardpoints(_player)
{
    var _hardpoints = _player.ship.hardpoints.primary;

    for (var _i = 0; _i < array_length(_hardpoints); ++_i)
    {
        _hardpoints[_i].runtime = {
            recoil: 0,
            muzzle_flash: 0,
            muzzle_flash_max: 1
        };
    }
}

/// @description Initializes the player's layered defence from final ship stats.
function sc_player_init_defence(_player)
{
    var _final = _player.ship.stats.final;

    _player.defence = {
        shield: {
            current: _final.shield_max,
            maximum: _final.shield_max,
            recharge_delay_remaining: 0
        },

        armour: {
            current: _final.armour_max,
            maximum: _final.armour_max
        },

        hull: {
            current: _final.hull_max,
            maximum: _final.hull_max
        }
    };
}

/// @description Initializes energy, fuel, ammunition and cargo from final stats.
function sc_player_init_resources(_player)
{
    var _final = _player.ship.stats.final;

    _player.resources = {
        energy: {
            current: _final.energy_max,
            maximum: _final.energy_max,
            recharge_delay_remaining: 0
        },

        fuel: {
            current: _final.fuel_max,
            maximum: _final.fuel_max
        },

        bullets: {
            current: _final.bullets_max,
            maximum: _final.bullets_max
        },

        explosives: {
            current: _final.explosives_max,
            maximum: _final.explosives_max
        },

        cargo: {
            amount: 0,
            weight: 0,
            capacity: _final.cargo_capacity
        }
    };
}

/// @description Creates the starting inventory and initial campaign items.
function sc_player_init_inventory(_player)
{
    _player.inventory = sc_player_inventory_create();
    sc_player_inventory_add(
        _player,
        "item_scanning_drone",
        3,
        ItemGrade.COMMON
    );
}

/// @description Creates player movement, boost and dash runtime values.
function sc_player_init_movement(_player)
{
    _player.movement = {
        input_x: 0,
        input_y: 0,
        velocity_x: 0,
        velocity_y: 0,
        speed: 0,
        moving: false,
        safe_x: _player.x,
        safe_y: _player.y,

        boost: {
            active: false
        },

        dash: {
            direction: 0,
            remaining: 0,
            cooldown_remaining: 0,
            double_tap_remaining: 0,
            invulnerable: false,

            ghosts: array_create(8, undefined),
            ghost_count: 0,
            ghost_limit: 8,
            ghost_interval: 2,
            ghost_life: 30,
            ghost_scale_min: 0.55,
            ghost_alpha_max: 0.78
        }
    };
}

/// @description Creates player weapon-channel, heat and focused-shield runtime values.
function sc_player_init_combat(_player)
{
    _player.combat = {
        weapons_allowed: true,

        primary: {
            hardpoint_cursor: 0,
            next_fire_tick: 0,
            active_delivery_id: noone
        },

        secondary: {
            hardpoint_cursor: 0,
            next_fire_tick: 0,
            active_delivery_id: noone
        },

        equipment: {
            hardpoint_cursor: 0,
            next_fire_tick: 0,
            active_delivery_id: noone
        },

        debug_weapon: {
            enabled: false,
            weapon_key: "",
            shot: undefined,
            firing: undefined
        },

        heat_signature: {
            next_mining_tick: 0
        },

        shield_focus: {
            active: false,
            protected_impact: false,
            impact_direction: 0
        }
    };
}

/// @description Creates the initial world-space player aiming values.
function sc_player_init_aim(_player)
{
    _player.aim = {
        world_x: _player.x,
        world_y: _player.y,
        direction: 0
    };
}

/// @description Initializes a player instance from a registered ship key.
function sc_player_init(_player, _ship_key)
{
    // Validate the player instance and requested registered ship.
    if (!instance_exists(_player) || !is_string(_ship_key))
    {
        show_debug_message(
            "PLAYER INITIALIZATION ERROR - invalid player or ship key"
        );

        return false;
    }

    if (!variable_struct_exists(global.data.ships, _ship_key))
    {
        show_debug_message(
            "PLAYER INITIALIZATION ERROR - unknown ship key: "
            + _ship_key
        );

        return false;
    }

    var _definition = variable_struct_get(global.data.ships, _ship_key);
    var _loadout = sc_player_init_loadout_create(_definition);
    var _cache = sc_ship_visual_cache_get(_ship_key);

    // Create the ship and its cached visual/hardpoint runtime.
    _player.ship = sc_player_init_ship_create(
        _ship_key,
        _definition,
        _loadout
    );

    sc_player_init_visual_runtime(
        _player,
        _definition,
        _cache
    );

    sc_player_init_hardpoints(_player);

    // Final stats must exist before defence and resources are created.
    if (!sc_player_stats_init(_player, _definition.stats_base))
        return false;

    _player.draw_angle = 0;

    if (!sc_entity_init(
        _player,
        Faction.PLAYER,
        sc_player_damage,
        _player.ship.collision,
        true,
        sc_player_knockback_apply
    ))
        return false;

    // Create the player's gameplay runtime in its original order.
    sc_player_init_defence(_player);
    sc_player_init_resources(_player);
    sc_player_init_inventory(_player);
    sc_player_init_movement(_player);
    sc_player_init_combat(_player);
    sc_player_init_aim(_player);

    _player.initialized = true;

    global.player_id = _player;
    global.PlayerState = PlayerState.ACTIVE;

    show_debug_message(
        "PLAYER INITIALIZED - "
        + _player.ship.identity.name
    );

    return true;
}

