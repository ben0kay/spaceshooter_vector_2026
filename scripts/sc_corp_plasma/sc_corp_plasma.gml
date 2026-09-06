/// @description Registers the Corporation's fast royal-blue plasma bolt.
function sc_projectile_register_corporation_plasma()
{
    var _palette = sc_faction_palette_get(Faction.CORPORATION);

    return sc_projectile_register({
        identity: {
            key: "projectile_corporation_plasma",
            name: "Corporation Plasma Bolt"
        },

        projectile_motion: ProjectileMotion.STANDARD,
        projectile_class: ProjectileClass.REGULAR,

        collision: {
            radius: 5
        },

        visual: {
            radius: 4,
            length: 30,
            palette: _palette,
            draw_script: sc_projectile_corporation_plasma_draw,
            impact_script: sc_projectile_corporation_plasma_impact,
            particles_register_script: sc_projectile_corporation_plasma_particles_register,

            bake: {
                canvas_size: 128,
                frames: 6,
                frame_speed: 2
            }
        }
    });
}

/// @description Registers the Corporation plasma bolt's blue impact particles.
function sc_projectile_corporation_plasma_particles_register()
{
    var _palette = sc_faction_palette_get(Faction.CORPORATION);

    return sc_particles_projectile_impact_register("impact_corporation_plasma", _palette, {
        scale: 1.15,
        spark_amount: 10,
        fragment_amount: 4,
        spark_spread: 65,
        speed_min: 2.5,
        speed_max: 5.5
    });
}

/// @description Emits one Corporation plasma impact.
function sc_projectile_corporation_plasma_impact(_x, _y, _direction, _target, _scale)
{
    return sc_particles_projectile_impact_emit(
        "impact_corporation_plasma",
        _x, _y, _direction, _scale
    );
}

/// @description Draws one narrow high-speed Corporation plasma bolt.
function sc_projectile_corporation_plasma_draw(_x, _y, _angle, _visual, _frame, _frame_count)
{
    var _p = _visual.palette;
    var _r = _visual.radius;
    var _length = _visual.length;
    var _phase = (_frame / _frame_count) * pi * 2;
    var _pulse = 0.88 + sin(_phase) * 0.12;
    var _front_x = _x + lengthdir_x(_r * 1.5, _angle);
    var _front_y = _y + lengthdir_y(_r * 1.5, _angle);
    var _rear_x = _x - lengthdir_x(_length, _angle);
    var _rear_y = _y - lengthdir_y(_length, _angle);
    var _mid_x = _x - lengthdir_x(_length * 0.42, _angle);
    var _mid_y = _y - lengthdir_y(_length * 0.42, _angle);

    draw_set_alpha(0.2);
    draw_set_colour(_p.glow);
    draw_line_width(_rear_x, _rear_y, _front_x, _front_y, _r * 4 * _pulse);

    draw_set_alpha(0.62);
    draw_set_colour(_p.energy);
    draw_line_width(_rear_x, _rear_y, _front_x, _front_y, _r * 1.8 * _pulse);

    draw_set_alpha(1);
    draw_set_colour(_p.core);
    draw_line_width(_mid_x, _mid_y, _front_x, _front_y, max(2, _r * 0.65));

    draw_set_colour(_p.energy);
    draw_circle(_x, _y, _r * 1.15 * _pulse, false);
    draw_set_colour(_p.core);
    draw_circle(_front_x, _front_y, _r * 0.65 * _pulse, false);

    draw_set_alpha(1);
    draw_set_colour(c_white);
}