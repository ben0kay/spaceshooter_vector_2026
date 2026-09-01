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

/// @description Registers the fast silver-aqua Shard chassis.
function sc_ship_register_shard()
{
    return sc_ship_register({
        identity: {
            key: "ship_shard",
            name: "Shard",
            description: "A fast silver-aqua interceptor built for precision movement."
        },

        stats_base: {
            hull_max: 75,
            armour_max: 25,
            shield_max: 40,
            shield_recharge_delay: 150,
            shield_recharge_rate: 0.35,
            speed_max: 8,
            acceleration: 0.55,
            deceleration: 0.7,
            turn_speed: 8,
            damage_multiplier: 1,
            fire_rate_multiplier: 1,
            cargo_capacity: 12
        },

        collision: {
            radius: 18
        },

        visual: {
	    radius: 34,

	    // Compatibility fields used by the current ship-selection preview.
	    scale: 0.75,
	    colour_primary: make_colour_rgb(70, 245, 255),
	    colour_secondary: make_colour_rgb(205, 222, 224),

	    palette: {
	        void: make_colour_rgb(4, 10, 16),
	        hull_dark: make_colour_rgb(25, 36, 43),
	        hull_mid: make_colour_rgb(69, 86, 94),
	        hull_light: make_colour_rgb(142, 165, 172),
	        metal: make_colour_rgb(205, 222, 224),
	        accent: make_colour_rgb(35, 210, 225),
	        energy: make_colour_rgb(70, 245, 255),
	        core: make_colour_rgb(220, 255, 255),
	        glow: make_colour_rgb(25, 135, 160)
	    },

	    draw: {
	        hull: sc_ship_shard_hull_draw,
	        armour: sc_ship_shard_armour_draw,
	        shield: sc_ship_shard_shield_draw,
	        thrust: sc_ship_shard_thrust_draw
	    },

	    bake: {
	        body_canvas_size: 128,
	        shield_canvas_size: 128,
	        thrust_canvas_size: 96,
	        damage_stages: 4
	    }
	},

        hardpoints: {
            primary: [
                {
                    x: 28,
                    y: 0,
                    angle: 0
                }
            ],

            utility: []
        },

        starting_loadout: {
            primary: "weapon_pulse_basic",
            secondary: undefined
        }
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
