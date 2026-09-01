/// @description Creates the expandable content registries.
function sc_data_init()
{
    global.data = {
        factions: array_create(Faction.ALIEN + 1, undefined),
        ships: {},
        enemies: {},
        weapons: {},
        projectiles: {},
        attacks: {}
    };

    if (!sc_faction_register_simulant()) return false;

    if (!sc_ship_register_shard()) return false;
    if (!sc_ship_register_fighter()) return false;
    if (!sc_ship_register_bastion()) return false;

//move this
    if (!sc_projectile_register_simulant_pulse()) return false;
    if (!sc_weapon_register_simulant_pulse()) return false;
    if (!sc_enemy_register_twin_fighter()) return false;

    show_debug_message("SPACE SHOOTER VECTOR 2026 - DATA INITIALIZED");
    return true;
}

/// @description Registers one validated ship definition.
function sc_ship_register(_ship)
{
    if (!is_struct(_ship) || !variable_struct_exists(_ship, "identity") || !variable_struct_exists(_ship.identity, "key"))
    {
        show_debug_message("SHIP REGISTRATION ERROR - invalid ship definition");
        return false;
    }

    var _key = _ship.identity.key;

    if (variable_struct_exists(global.data.ships, _key))
    {
        show_debug_message("SHIP REGISTRATION ERROR - duplicate key: " + _key);
        return false;
    }

    variable_struct_set(global.data.ships, _key, _ship);
    return true;
}

function sc_ship_register_shard()
{
    return sc_ship_register(
    {
        identity: { key: "ship_shard", name: "Shard", description: "A fast, fragile construct built for precision movement." },
        stats_base:
        {
            hull_max: 75, armour_max: 25, shield_max: 40,
            shield_recharge_delay: 150, shield_recharge_rate: 0.35,
            speed_max: 8, acceleration: 0.55, deceleration: 0.7, turn_speed: 8,
            damage_multiplier: 1, fire_rate_multiplier: 1, cargo_capacity: 12
        },
        collision: { radius: 18 },
        visual: { colour_primary: make_colour_rgb(35, 235, 255), colour_secondary: make_colour_rgb(255, 145, 45), scale: 0.75 },
        hardpoints: { primary: [{ x: 28, y: 0, angle: 0 }], utility: [] },
        starting_loadout: { primary: "weapon_pulse_basic", secondary: undefined }
    });
}

function sc_ship_register_fighter()
{
    return sc_ship_register(
    {
        identity: { key: "ship_fighter", name: "Fighter", description: "A balanced combat construct with dependable defences." },
        stats_base:
        {
            hull_max: 100, armour_max: 60, shield_max: 60,
            shield_recharge_delay: 180, shield_recharge_rate: 0.3,
            speed_max: 6, acceleration: 0.38, deceleration: 0.5, turn_speed: 6,
            damage_multiplier: 1, fire_rate_multiplier: 1, cargo_capacity: 20
        },
        collision: { radius: 26 },
        visual: { colour_primary: make_colour_rgb(35, 165, 255), colour_secondary: make_colour_rgb(255, 135, 35), scale: 1 },
        hardpoints: { primary: [{ x: 36, y: -14, angle: 0 }, { x: 36, y: 14, angle: 0 }], utility: [] },
        starting_loadout: { primary: "weapon_pulse_basic", secondary: undefined }
    });
}

function sc_ship_register_bastion()
{
    return sc_ship_register(
    {
        identity: { key: "ship_bastion", name: "Bastion", description: "A slow heavy construct protected by substantial armour." },
        stats_base:
        {
            hull_max: 160, armour_max: 140, shield_max: 80,
            shield_recharge_delay: 210, shield_recharge_rate: 0.25,
            speed_max: 4.2, acceleration: 0.22, deceleration: 0.32, turn_speed: 3.8,
            damage_multiplier: 1.1, fire_rate_multiplier: 0.9, cargo_capacity: 32
        },
        collision: { radius: 38 },
        visual: { colour_primary: make_colour_rgb(105, 95, 255), colour_secondary: make_colour_rgb(255, 90, 35), scale: 1.25 },
        hardpoints: { primary: [{ x: 45, y: -22, angle: 0 }, { x: 45, y: 22, angle: 0 }], utility: [] },
        starting_loadout: { primary: "weapon_pulse_heavy", secondary: undefined }
    });
}
