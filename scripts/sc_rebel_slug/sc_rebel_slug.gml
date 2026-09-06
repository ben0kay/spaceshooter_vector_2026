/// @description Registers the Rebel's heavy improvised kinetic slug.
function sc_projectile_register_rebel_slug()
{
    var _palette = sc_faction_palette_get(Faction.REBEL);

    return sc_projectile_register({
        identity: {
            key: "projectile_rebel_slug",
            name: "Rebel Scrap Slug"
        },

        projectile_motion: ProjectileMotion.STANDARD,
        projectile_class: ProjectileClass.REGULAR,

        collision: {
            radius: 5
        },

        visual: {
            radius: 4,
            length: 20,
            palette: _palette,
            draw_script: sc_projectile_rebel_slug_draw,
            impact_script: sc_projectile_rebel_slug_impact,
            particles_register_script: sc_projectile_rebel_slug_particles_register,

            bake: {
                canvas_size: 96,
                frames: 4,
                frame_speed: 2
            }
        }
    });
}

/// @description Registers the Rebel slug's heavy metallic impact.
function sc_projectile_rebel_slug_particles_register()
{
    return sc_particles_projectile_impact_register(
        "impact_rebel_slug",
        sc_faction_palette_get(Faction.REBEL),
        {
            scale: 1.15,
            spark_amount: 9,
            fragment_amount: 6,
            spark_spread: 75,
            speed_min: 2.5,
            speed_max: 6
        }
    );
}

/// @description Emits one Rebel slug impact.
function sc_projectile_rebel_slug_impact(_x, _y, _direction, _target, _scale)
{
    return sc_particles_projectile_impact_emit(
        "impact_rebel_slug",
        _x, _y, _direction, _scale
    );
}

/// @description Draws one large improvised kinetic slug.
function sc_projectile_rebel_slug_draw(_x, _y, _angle, _visual, _frame, _frame_count)
{
    var _p = _visual.palette;
    var _r = _visual.radius;
    var _length = _visual.length;
    var _phase = (_frame/_frame_count)*pi*2;
    var _pulse = 0.85+sin(_phase)*0.15;

    var _front_x = _x+lengthdir_x(_r*1.4,_angle);
    var _front_y = _y+lengthdir_y(_r*1.4,_angle);
    var _rear_x = _x-lengthdir_x(_length,_angle);
    var _rear_y = _y-lengthdir_y(_length,_angle);
    var _body_rear_x = _x-lengthdir_x(_length*0.45,_angle);
    var _body_rear_y = _y-lengthdir_y(_length*0.45,_angle);

    draw_set_alpha(0.2*_pulse);
    draw_set_colour(_p.glow);
    draw_line_width(_rear_x,_rear_y,_front_x,_front_y,_r*3);

    draw_set_alpha(0.7);
    draw_set_colour(_p.energy);
    draw_line_width(_rear_x,_rear_y,_body_rear_x,_body_rear_y,_r);

    draw_set_alpha(1);
    draw_set_colour(_p.hull_dark);
    draw_triangle(
        _front_x,_front_y,
        _body_rear_x+lengthdir_x(_r,_angle+90),_body_rear_y+lengthdir_y(_r,_angle+90),
        _body_rear_x+lengthdir_x(_r,_angle-90),_body_rear_y+lengthdir_y(_r,_angle-90),
        false
    );

    draw_set_colour(_p.metal);
    draw_line_width(_body_rear_x,_body_rear_y,_front_x,_front_y,max(2,_r*0.65));

    draw_set_colour(_p.core);
    draw_circle(_front_x,_front_y,max(1,_r*0.42),false);

    draw_set_alpha(1);
    draw_set_colour(c_white);
}