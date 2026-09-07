/// @description Registers the Corporation rotating alert array.
function sc_faction_device_register_corporation_alert_array()
{
    var _palette = sc_faction_palette_get(Faction.CORPORATION);

    return sc_faction_device_register({
        identity: {
            key: "device_corp_alert_array",
            name: "Corporation Alert Array",
            faction: Faction.CORPORATION
        },

        stats: {
            shield_max: 120,
            armour_max: 180,
            hull_max: 150,
            shield_recharge_delay: 180,
            shield_recharge_rate: 0.4
        },

        collision: {
            radius: 72
        },

        controllers: {
            sensor: {
                start_angle: 0,
                sweep_speed: 0.8,
                detection_width: 1.5,
                detection_radius: 1500,
                alert_radius: 3600,
                alert_cooldown: 300,
                alert_pulse_radius: 320,

                signal: {
                    duration: 180,
                    arc_amount: 12,
                    launch_spacing: 0.08,
                    start_distance: 54,
                    radius_min: 16,
                    radius_max: 62,
                    arc_angle: 120,
                    segments: 12,
                    thickness: 3,
                    alpha: 0.85
                },

                trail_lines: 9,

                trail_lines: 9,
                trail_spacing: 1.8,
                trail_alpha: 0.34,
                sweep_width: 2
            },

            attack: undefined,
            defence: undefined,
            utility: undefined,
            command: undefined
        },

        visual: {
            radius: 72,
            palette: _palette,

            draw: {
                base: sc_faction_device_corporation_alert_base_draw,
                head: sc_faction_device_corporation_alert_head_draw
            },

            bake: {
                base_canvas_size: 192,
                head_canvas_size: 192,
                shield_canvas_size: 224
            }
        }
    });
}

/// @description Draws the stationary Corporation alert-array platform.
function sc_faction_device_corporation_alert_base_draw(_x,_y,_radius,_angle,_visual)
{
    var _p = _visual.palette;

    sc_visual_circle(_x,_y,_radius,_angle,0,0,0.96,_p.outline,false);
    sc_visual_circle(_x,_y,_radius,_angle,0,0,0.88,_p.hull_dark,false);
    sc_visual_circle(_x,_y,_radius,_angle,0,0,0.72,_p.hull_mid,false);
    sc_visual_circle(_x,_y,_radius,_angle,0,0,0.51,_p.void,false);

    for (var _i = 0; _i < 8; ++_i)
    {
        var _direction = _angle + _i * 45;
        var _x1 = _x + lengthdir_x(_radius * 0.73,_direction);
        var _y1 = _y + lengthdir_y(_radius * 0.73,_direction);
        var _x2 = _x + lengthdir_x(_radius * 0.91,_direction);
        var _y2 = _y + lengthdir_y(_radius * 0.91,_direction);

        draw_set_colour(_i mod 2 == 0 ? _p.metal : _p.accent);
        draw_line_width(_x1,_y1,_x2,_y2,4);
    }

    sc_visual_circle(_x,_y,_radius,_angle,0,0,0.29,_p.glow,false);
    sc_visual_circle(_x,_y,_radius,_angle,0,0,0.19,_p.energy,false);
    sc_visual_circle(_x,_y,_radius,_angle,0,0,0.08,_p.core,false);

    draw_set_alpha(1);
    draw_set_colour(c_white);
}

/// @description Draws the separately rotating Corporation sensor head.
function sc_faction_device_corporation_alert_head_draw(_x,_y,_radius,_angle,_visual)
{
    var _p = _visual.palette;

    sc_visual_line(
        _x,_y,_radius,_angle,
        -0.48,0,
        0.58,0,
        14,_p.void
    );

    sc_visual_line(
        _x,_y,_radius,_angle,
        -0.46,0,
        0.56,0,
        8,_p.hull_light
    );

    sc_visual_line(
        _x,_y,_radius,_angle,
        -0.28,0,
        0.68,0,
        3,_p.energy
    );

    sc_visual_quad(
        _x,_y,_radius,_angle,
        0.24,-0.23,
        0.59,-0.12,
        0.59,0.12,
        0.24,0.23,
        _p.hull_mid
    );

    sc_visual_line(
        _x,_y,_radius,_angle,
        0.3,-0.18,
        0.62,0,
        2,_p.core
    );

    sc_visual_line(
        _x,_y,_radius,_angle,
        0.62,0,
        0.3,0.18,
        2,_p.core
    );

    sc_visual_circle(
        _x,_y,_radius,_angle,
        0,0,
        0.17,
        _p.outline,
        false
    );

    sc_visual_circle(
        _x,_y,_radius,_angle,
        0,0,
        0.1,
        _p.core,
        false
    );

    draw_set_alpha(1);
    draw_set_colour(c_white);
}