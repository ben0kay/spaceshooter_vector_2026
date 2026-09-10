/*
ASTEROID MATERIAL DATA

Materials define appearance, durability and potential resource yield.
Sector definitions will eventually control material spawning frequency.
*/

/// @description Registers one asteroid material definition.
function sc_asteroid_register(_data)
{
    var _key = _data.identity.key;

    if (variable_struct_exists(global.data.asteroids, _key))
    {
        show_debug_message("ASTEROID REGISTRATION ERROR - duplicate key: " + _key);
        return false;
    }

    variable_struct_set(global.data.asteroids, _key, _data);
    return true;
}

/// @description Registers all asteroid materials.
function sc_asteroid_register_all()
{
    return sc_asteroid_register_rock()
        && sc_asteroid_register_carbon()
        && sc_asteroid_register_iron()
        && sc_asteroid_register_copper()
        && sc_asteroid_register_silicon()
        && sc_asteroid_register_quartz()
        && sc_asteroid_register_titanium()
        && sc_asteroid_register_crystal()
        && sc_asteroid_register_ice()
        && sc_asteroid_register_sulfur()
        && sc_asteroid_register_uranium();
}

function sc_asteroid_register_rock()
{
    return sc_asteroid_register({
        identity: { key: "asteroid_rock", name: "Rock Asteroid" },
        item_key: "item_rock",
        stats: { health_multiplier: 0.7, yield_multiplier: 1 },
        palette: {
            void: make_colour_rgb(8, 8, 8), dark: make_colour_rgb(28, 27, 25),
            mid: make_colour_rgb(66, 63, 58), light: make_colour_rgb(126, 120, 110),
            resource: make_colour_rgb(154, 147, 135), glow: make_colour_rgb(83, 78, 70)
        }
    });
}


/// @description Registers carbon-bearing asteroids.
function sc_asteroid_register_carbon()
{
    return sc_asteroid_register({
        identity: { key: "asteroid_carbon", name: "Carbon Asteroid" },
        item_key: "item_carbon",
        stats: { health_multiplier: 0.85, yield_multiplier: 1.2 },
        palette: {
            void: make_colour_rgb(6, 8, 10), dark: make_colour_rgb(18, 22, 25),
            mid: make_colour_rgb(42, 48, 52), light: make_colour_rgb(84, 94, 98),
            resource: make_colour_rgb(128, 150, 158), glow: make_colour_rgb(39, 89, 106)
        }
    });
}

/// @description Registers iron-bearing asteroids.
function sc_asteroid_register_iron()
{
    return sc_asteroid_register({
        identity: { key: "asteroid_iron", name: "Iron Asteroid" },
        item_key: "item_iron",
        stats: { health_multiplier: 1.2, yield_multiplier: 1 },
        palette: {
            void: make_colour_rgb(10, 11, 13), dark: make_colour_rgb(31, 34, 38),
            mid: make_colour_rgb(67, 73, 78), light: make_colour_rgb(129, 139, 145),
            resource: make_colour_rgb(194, 205, 211), glow: make_colour_rgb(83, 116, 133)
        }
    });
}

/// @description Registers copper-bearing asteroids.
function sc_asteroid_register_copper()
{
    return sc_asteroid_register({
        identity: { key: "asteroid_copper", name: "Copper Asteroid" },
        item_key: "item_copper",
        stats: { health_multiplier: 1, yield_multiplier: 1 },
        palette: {
            void: make_colour_rgb(14, 8, 6), dark: make_colour_rgb(43, 25, 19),
            mid: make_colour_rgb(83, 48, 33), light: make_colour_rgb(137, 79, 50),
            resource: make_colour_rgb(229, 132, 66), glow: make_colour_rgb(51, 139, 123)
        }
    });
}

/// @description Registers silicon-bearing asteroids.
function sc_asteroid_register_silicon()
{
    return sc_asteroid_register({
        identity: {
            key: "asteroid_silicon",
            name: "Silicon Asteroid"
        },

        item_key: "item_silicon",

        stats: {
            health_multiplier: 1.05,
            yield_multiplier: 0.9
        },

        palette: {
            void: make_colour_rgb(7, 11, 10),
            dark: make_colour_rgb(24, 35, 31),
            mid: make_colour_rgb(49, 68, 59),
            light: make_colour_rgb(94, 119, 104),
            resource: make_colour_rgb(119, 225, 184),
            glow: make_colour_rgb(41, 155, 112)
        }
    });
}

/// @description Registers titanium-bearing asteroids.
function sc_asteroid_register_titanium()
{
    return sc_asteroid_register({
        identity: { key: "asteroid_titanium", name: "Titanium Asteroid" },
        item_key: "item_titanium",
        stats: { health_multiplier: 1.55, yield_multiplier: 0.7 },
        palette: {
            void: make_colour_rgb(7, 10, 14), dark: make_colour_rgb(22, 31, 42),
            mid: make_colour_rgb(48, 66, 84), light: make_colour_rgb(103, 130, 151),
            resource: make_colour_rgb(188, 225, 243), glow: make_colour_rgb(61, 139, 193)
        }
    });
}

/// @description Registers crystal-bearing asteroids.
function sc_asteroid_register_crystal()
{
    return sc_asteroid_register({
        identity: { key: "asteroid_crystal", name: "Crystal Asteroid" },
        item_key: "item_crystal",
        stats: { health_multiplier: 1.1, yield_multiplier: 0.55 },
        palette: {
            void: make_colour_rgb(9, 7, 15), dark: make_colour_rgb(27, 22, 44),
            mid: make_colour_rgb(56, 46, 82), light: make_colour_rgb(105, 87, 142),
            resource: make_colour_rgb(105, 239, 255), glow: make_colour_rgb(148, 61, 231)
        }
    });
}

/// @description Registers ice asteroids.
function sc_asteroid_register_ice()
{
    return sc_asteroid_register({
        identity: { key: "asteroid_ice", name: "Ice Asteroid" },
        item_key: "item_ice",
        stats: { health_multiplier: 0.65, yield_multiplier: 1.3 },
        palette: {
            void: make_colour_rgb(6, 12, 18), dark: make_colour_rgb(21, 43, 57),
            mid: make_colour_rgb(49, 89, 109), light: make_colour_rgb(121, 179, 197),
            resource: make_colour_rgb(214, 252, 255), glow: make_colour_rgb(45, 188, 229)
        }
    });
}

/// @description Registers sulfur-bearing asteroids.
function sc_asteroid_register_sulfur()
{
    return sc_asteroid_register({
        identity: { key: "asteroid_sulfur", name: "Sulfur Asteroid" },
        item_key: "item_sulfur",
        stats: { health_multiplier: 0.9, yield_multiplier: 0.9 },
        palette: {
            void: make_colour_rgb(13,10,4), dark: make_colour_rgb(43,34,13),
            mid: make_colour_rgb(89,70,23), light: make_colour_rgb(151,119,38),
            resource: make_colour_rgb(214,184,61), glow: make_colour_rgb(255,119,32)
        }
    });
}

/// @description Registers quartz-bearing asteroids.
function sc_asteroid_register_quartz()
{
    return sc_asteroid_register({
        identity: {
            key: "asteroid_quartz",
            name: "Quartz Asteroid"
        },

        item_key: "item_quartz",

        stats: {
            health_multiplier: 1,
            yield_multiplier: 0.85
        },

        palette: {
            void: make_colour_rgb(10,,18),
            dark: make_colour_rgb(35,31,47),
            mid: make_colour_rgb(76,68,96),
            light: make_colour_rgb(155,143,181),
            resource: make_colour_rgb(239,224,255),
            glow: make_colour_rgb(178,112,232)
        }
    });
}

/// @description Registers uranium-bearing asteroids.
function sc_asteroid_register_uranium()
{
    return sc_asteroid_register({
        identity: {
            key: "asteroid_uranium",
            name: "Uranium Asteroid"
        },

        item_key: "item_uranium",

        stats: {
            health_multiplier: 1.3,
            yield_multiplier: 0.55
        },

        palette: {
            void: make_colour_rgb(6,12,5),
            dark: make_colour_rgb(24,35,20),
            mid: make_colour_rgb(53,75,42),
            light: make_colour_rgb(112,137,83),
            resource: make_colour_rgb(194,241,76),
            glow: make_colour_rgb(101,255,48)
        }
    });
}