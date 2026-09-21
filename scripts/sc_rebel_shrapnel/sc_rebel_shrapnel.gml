/// @description Registers the Mongrel's thick proximity-splitting carrier slug.
function sc_projectile_register_rebel_mongrel_carrier()
{
    var _palette = sc_faction_palette_get(Faction.REBEL);

    return sc_projectile_register({
        identity: {
            key: "projectile_rebel_mongrel_carrier",
            name: "Mongrel Shrapnel Carrier"
        },

        projectile_motion: ProjectileMotion.STANDARD,
        projectile_class: ProjectileClass.HEAVY,

        collision: {
            radius: 9
        },

        proximity: {
            range: 260,
            emissions: [
                sc_projectile_emission_cone_create(
                    "weapon_rebel_shrapnel",
                    6,
                    58,
                    0
                )
            ]
        },

        visual: {
            radius: 8,
            length: 25,
            palette: _palette,
            draw_script: sc_projectile_rebel_mongrel_carrier_draw,
            impact_script: sc_projectile_rebel_slug_impact,

            bake: {
                canvas_size: 96,
                frames: 1,
                frame_speed: 1
            }
        }
    });
}

/// @description Registers one irregular piece released by the Mongrel carrier.
function sc_projectile_register_rebel_shrapnel()
{
    var _palette = sc_faction_palette_get(Faction.REBEL);

    return sc_projectile_register({
        identity: {
            key: "projectile_rebel_shrapnel",
            name: "Mongrel Shrapnel"
        },

        projectile_motion: ProjectileMotion.STANDARD,
        projectile_class: ProjectileClass.REGULAR,

        collision: {
            radius: 4
        },

        visual: {
            radius: 4,
            length: 8,
            palette: _palette,
            draw_script: sc_projectile_rebel_shrapnel_draw,
            impact_script: sc_projectile_rebel_slug_impact,

            bake: {
                canvas_size: 48,
                frames: 4,
                frame_speed: 1000000
            }
        }
    });
}

/// @description Draws the thick scrap shell that carries the shrapnel.
function sc_projectile_rebel_mongrel_carrier_draw(_x, _y, _angle, _visual, _frame, _frame_count)
{
    var _p = _visual.palette;
    var _rear_x = _x - lengthdir_x(_visual.length * 0.6, _angle);
    var _rear_y = _y - lengthdir_y(_visual.length * 0.6, _angle);
    var _front_x = _x + lengthdir_x(_visual.radius, _angle);
    var _front_y = _y + lengthdir_y(_visual.radius, _angle);

    draw_set_colour(_p.hull_dark);
    draw_line_width(_rear_x, _rear_y, _front_x, _front_y, 13);

    draw_set_colour(_p.metal);
    draw_line_width(_rear_x, _rear_y, _front_x, _front_y, 8);

    draw_set_colour(_p.paint);
    draw_line_width(_rear_x, _rear_y, _rear_x + lengthdir_x(5, _angle), _rear_y + lengthdir_y(5, _angle), 3);

    draw_set_colour(_p.core);
    draw_circle(_front_x, _front_y, 3, false);
    draw_set_colour(c_white);
}

/// @description Draws one of four baked jagged scrap shapes.
function sc_projectile_rebel_shrapnel_draw(_x, _y, _angle, _visual, _frame, _frame_count)
{
    var _p = _visual.palette;
    var _turn = _frame * 31;
    var _tip = _angle + _turn;
    var _upper = _tip + 128 + _frame * 6;
    var _lower = _tip - 124 + _frame * 8;
    var _radius = _visual.radius;

    draw_set_colour(_p.hull_dark);
    draw_triangle(
        _x + lengthdir_x(_radius * 2.2, _tip), _y + lengthdir_y(_radius * 2.2, _tip),
        _x + lengthdir_x(_radius * 1.25, _upper), _y + lengthdir_y(_radius * 1.25, _upper),
        _x + lengthdir_x(_radius * 1.4, _lower), _y + lengthdir_y(_radius * 1.4, _lower),
        false
    );

    draw_set_colour(_p.metal);
    draw_line_width(
        _x + lengthdir_x(_radius * 2.2, _tip), _y + lengthdir_y(_radius * 2.2, _tip),
        _x + lengthdir_x(_radius * 1.25, _upper), _y + lengthdir_y(_radius * 1.25, _upper),
        1
    );

    draw_set_colour(c_white);
}