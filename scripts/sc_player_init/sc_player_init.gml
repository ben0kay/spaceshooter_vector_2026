/// @description Initializes a player instance from a registered ship key.
function sc_player_init(_player, _ship_key)
{
    if (!instance_exists(_player) || !is_string(_ship_key))
    {
        show_debug_message("PLAYER INITIALIZATION ERROR - invalid player or ship key");
        return false;
    }

    if (!variable_struct_exists(global.data.ships, _ship_key))
    {
        show_debug_message("PLAYER INITIALIZATION ERROR - unknown ship key: " + _ship_key);
        return false;
    }

    var _definition = variable_struct_get(global.data.ships, _ship_key);
    var _cache = sc_ship_visual_cache_get(_ship_key);

    _player.ship = {
        key: _ship_key,
        identity: variable_clone(_definition.identity),
        collision: variable_clone(_definition.collision),
		systems: sc_ship_systems_runtime_create(_definition.systems),
        visual: variable_clone(_definition.visual),
        hardpoints: variable_clone(_definition.hardpoints),
        loadout: variable_clone(_definition.starting_loadout),
        stats: undefined
    };

    _player.ship.visual.runtime = {
        cache: _cache,
        thrust_power: 0,
        thrust_phase: irandom(359),
        shield_hit_alpha: 0,
        wing_fold: _definition.visual.wing.fold_idle,
        core_angle: 0,
        core_speed: _definition.visual.core.idle_speed
    };

    var _primary_hardpoints = _player.ship.hardpoints.primary;

    for (var _i = 0; _i < array_length(_primary_hardpoints); _i++)
    {
        _primary_hardpoints[_i].runtime = {
            recoil: 0,
            muzzle_flash: 0,
            muzzle_flash_max: 1
        };
    }

    if (!sc_player_stats_init(_player, _definition.stats_base)) return false;

    var _final = _player.ship.stats.final;
    _player.draw_angle = 0;

    if (!sc_entity_init(_player, Faction.PLAYER, sc_player_damage, _player.ship.collision))
        return false;

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
		
	_player.inventory = sc_player_inventory_create();

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

    _player.combat = {
        weapons_allowed: true,

        primary: {
            hardpoint_cursor: 0,
            next_fire_tick: 0,
            active_delivery_id: noone
        }

        // MMB special and RMB frontal shield runtime go here later.
    };

    _player.aim = {
        world_x: _player.x,
        world_y: _player.y,
        direction: 0
    };

    _player.initialized = true;

    global.player_id = _player;
    global.PlayerState = PlayerState.ACTIVE;

    show_debug_message("PLAYER INITIALIZED - " + _player.ship.identity.name);
    return true;
}