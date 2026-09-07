/// @description Registers the temporary colossal player starting base.
function sc_world_structure_register_player_base()
{
    return sc_world_structure_register({
        identity: {
            key: "player_starting_base",
            name: "Frontier Haven"
        },

        visual: {
            canvas_width: 2048,
            canvas_height: 1024,

            palette: {
                void: make_colour_rgb(7, 13, 18),
                hull_dark: make_colour_rgb(24, 38, 48),
                hull_mid: make_colour_rgb(62, 82, 94),
                hull_light: make_colour_rgb(139, 162, 170),
                metal: make_colour_rgb(199, 216, 218),
                outline: make_colour_rgb(8, 17, 22),
                accent: make_colour_rgb(19, 133, 156),
                energy: make_colour_rgb(38, 220, 234),
                core: make_colour_rgb(201, 255, 255),
                warning: make_colour_rgb(232, 151, 38)
            },

            draw_script: sc_world_structure_player_base_draw
        },

        collision: {
            broad_radius: 930,

            parts: [
                {
                    key: "central_spine",
                    shape: StructureCollisionShape.RECTANGLE,
                    forward: 0,
                    side: 0,
                    width: 1280,
                    height: 230,
                    angle: 0
                },
                {
                    key: "habitat_upper",
                    shape: StructureCollisionShape.RECTANGLE,
                    forward: -220,
                    side: -245,
                    width: 620,
                    height: 230,
                    angle: 0
                },
                {
                    key: "habitat_lower",
                    shape: StructureCollisionShape.RECTANGLE,
                    forward: -220,
                    side: 245,
                    width: 620,
                    height: 230,
                    angle: 0
                },
                {
                    key: "reactor",
                    shape: StructureCollisionShape.CIRCLE,
                    forward: -620,
                    side: 0,
                    radius: 250,
                    angle: 0
                },
                {
                    key: "command",
                    shape: StructureCollisionShape.CIRCLE,
                    forward: 530,
                    side: 0,
                    radius: 190,
                    angle: 0
                }
            ]
        }
    });
}

/// @description Registers all current world structures.
function sc_world_structure_register_all()
{
    if (!sc_world_structure_register_player_base())
        return false;

    return true;
}

/// @description Draws the temporary colossal player starting base.
function sc_world_structure_player_base_draw(_x, _y, _visual)
{
    var _p = _visual.palette;

    sc_visual_quad(_x, _y, 1, 0,
        -760, -105, 610, -105,
        760, -55, 760, 55,
        _p.outline
    );

    sc_visual_quad(_x, _y, 1, 0,
        -760, -82, 610, -82,
        710, -38, 710, 38,
        _p.hull_mid
    );

    sc_visual_quad(_x, _y, 1, 0,
        -440, -330, 120, -330,
        250, -150, -560, -150,
        _p.outline
    );

    sc_visual_quad(_x, _y, 1, 0,
        -420, -302, 90, -302,
        190, -174, -535, -174,
        _p.hull_dark
    );

    sc_visual_quad(_x, _y, 1, 0,
        -560, 150, 250, 150,
        120, 330, -440, 330,
        _p.outline
    );

    sc_visual_quad(_x, _y, 1, 0,
        -535, 174, 190, 174,
        90, 302, -420, 302,
        _p.hull_dark
    );

    sc_visual_circle(_x, _y, 1, 0, -620, 0, 275, _p.outline, false);
    sc_visual_circle(_x, _y, 1, 0, -620, 0, 238, _p.hull_dark, false);
    sc_visual_circle(_x, _y, 1, 0, -620, 0, 180, _p.hull_mid, false);
    sc_visual_circle(_x, _y, 1, 0, -620, 0, 128, _p.void, false);
    sc_visual_circle(_x, _y, 1, 0, -620, 0, 88, _p.energy, false);
    sc_visual_circle(_x, _y, 1, 0, -620, 0, 52, _p.core, false);

    sc_visual_circle(_x, _y, 1, 0, 530, 0, 215, _p.outline, false);
    sc_visual_circle(_x, _y, 1, 0, 530, 0, 182, _p.hull_mid, false);
    sc_visual_circle(_x, _y, 1, 0, 530, 0, 125, _p.hull_light, false);
    sc_visual_circle(_x, _y, 1, 0, 530, 0, 74, _p.void, false);
    sc_visual_circle(_x, _y, 1, 0, 530, 0, 42, _p.energy, false);

    for (var _side = -1; _side <= 1; _side += 2)
    {
        var _s = _side * 238;

        for (var _i = 0; _i < 5; ++_i)
        {
            var _forward = -350 + _i * 115;

            sc_visual_quad(_x, _y, 1, 0,
                _forward - 42, _s - 54,
                _forward + 42, _s - 54,
                _forward + 42, _s + 54,
                _forward - 42, _s + 54,
                _p.hull_mid
            );

            sc_visual_line(_x, _y, 1, 0,
                _forward - 25, _s,
                _forward + 25, _s,
                7, _p.energy
            );
        }

        sc_visual_line(_x, _y, 1, 0,
            -500, _s - _side * 82,
            140, _s - _side * 82,
            5, _p.hull_light
        );
    }

    for (var _i = 0; _i < 9; ++_i)
    {
        var _forward = -330 + _i * 92;

        sc_visual_line(_x, _y, 1, 0,
            _forward, -72,
            _forward, 72,
            3, _p.outline
        );
    }

    sc_visual_line(_x, _y, 1, 0,
        -330, -38, 335, -38,
        7, _p.accent
    );

    sc_visual_line(_x, _y, 1, 0,
        -330, 38, 335, 38,
        7, _p.energy
    );

    sc_visual_quad(_x, _y, 1, 0,
        690, -135, 900, -90,
        900, 90, 690, 135,
        _p.outline
    );

    sc_visual_quad(_x, _y, 1, 0,
        715, -104, 862, -67,
        862, 67, 715, 104,
        _p.hull_dark
    );

    for (var _side = -1; _side <= 1; _side += 2)
    {
        sc_visual_line(_x, _y, 1, 0,
            730, _side * 62,
            850, _side * 62,
            9, _p.energy
        );

        sc_visual_circle(_x, _y, 1, 0,
            660, _side * 145,
            22, _p.warning, false
        );
    }

    draw_set_alpha(1);
    draw_set_colour(c_white);
}