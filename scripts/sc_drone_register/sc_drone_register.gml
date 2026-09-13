/*
DRONE DEFINITIONS

Drones share one world object while registered definitions provide their
movement, behaviour, durability, targeting, weapons and visual identity.
*/

/// @description Registers one reusable drone definition.
function sc_drone_register(_definition)
{
    var _key = _definition.identity.key;

    if (variable_struct_exists(global.data.drones,_key))
    {
        show_debug_message(
            "DRONE REGISTRATION ERROR - duplicate key: "
            +_key
        );

        return false;
    }

    variable_struct_set(global.data.drones,_key,_definition);
    return true;
}

/// @description Registers all available drone definitions.
function sc_drone_register_all()
{
    return sc_drone_register_scanner()
        && sc_drone_register_player_point_defence();
}

/// @description Registers the existing derelict scanner drone.
function sc_drone_register_scanner()
{
    var _palette = sc_faction_palette_get(Faction.PLAYER);

    return sc_drone_register({
        identity: {
            key: "drone_scanner",
            name: "Scanner Drone"
        },

        role: DroneRole.SCANNER,

        movement: {
            speed: 8,
            return_speed_multiplier: 1.2
        },

        collision: {
            radius: 13
        },

        defence: {
            armour: 5,
            hull: 15
        },

        visual: {
            radius: 13,
            palette: _palette,

            bake: {
                canvas_size: 64
            },

            draw_script: sc_drone_scanner_body_draw
        },

        behaviour: {
            update_script: sc_drone_scanner_update,
            draw_script: sc_drone_scanner_draw,
            destroy_script: sc_drone_scanner_destroy
        }
    });
}

/// @description Registers the player's point-defence drone.
function sc_drone_register_player_point_defence()
{
    var _palette = sc_faction_palette_get(Faction.PLAYER);

    return sc_drone_register({
        identity: {
            key: "drone_player_point_defence",
            name: "Point Defence Drone"
        },

        role: DroneRole.COMBAT,

        movement: {
            speed: 6,
            return_speed_multiplier: 1.35,
            patrol_radius_min: 120,
            patrol_radius_max: 280,
            reposition_interval_min: 90,
            reposition_interval_max: 180,
            arrival_radius: 18
        },

        collision: {
            radius: 14
        },

        defence: {
            armour: 20,
            hull: 35
        },

        lifetime: {
            duration: 900
        },

        targeting: {
            range: 500,
            scan_interval: 8
        },

        weapon: {
            projectile_key: "projectile_shard_pulse",
            scale: 0.55,
            speed: 34,
            life: 45,
            fire_interval: 10,
            lead_strength: 1,

            damage: {
                amount: 5,
                type: DamageType.KINETIC,
                effect: DamageEffect.NONE
            }
        },

        visual: {
            radius: 14,
            palette: _palette,

            bake: {
                canvas_size: 64
            },

            draw_script: sc_drone_point_defence_body_draw
        },

        behaviour: {
            update_script: sc_drone_point_defence_update,
            draw_script: sc_drone_point_defence_draw,
            destroy_script: undefined
        }
    });
}