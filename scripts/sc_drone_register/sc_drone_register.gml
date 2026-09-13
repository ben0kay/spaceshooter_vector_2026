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

    variable_struct_set(
        global.data.drones,
        _key,
        _definition
    );

    return true;
}

/// @description Registers all available drone definitions.
function sc_drone_register_all()
{
    return sc_drone_register_scanner();
}

/// @description Registers the existing derelict scanner drone.
function sc_drone_register_scanner()
{
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

        behaviour: {
            update_script: sc_drone_scanner_update,
            draw_script: sc_drone_scanner_draw
        }
    });
}