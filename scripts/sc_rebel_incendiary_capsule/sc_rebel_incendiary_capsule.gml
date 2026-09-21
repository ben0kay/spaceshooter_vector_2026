/// @description Registers the reusable Rebel incendiary canister.
function sc_projectile_register_rebel_incendiary_canister()
{
    var _palette = sc_faction_palette_get(Faction.REBEL);

    return sc_projectile_register({
        identity: {
            key: "projectile_rebel_incendiary_canister",
            name: "Rebel Incendiary Canister"
        },

        projectile_motion: ProjectileMotion.STANDARD,
        projectile_class: ProjectileClass.REGULAR,

        collision: {
            radius: 10
        },

        detonation: {
            area: {
                shape: AttackAreaShape.CIRCLE,

                geometry: {
                    radius: 110
                },

                behaviour: {
                    duration: 120,
                    tick_interval: 15,
                    hit_once: false,
                    max_targets: 0,
                    falloff_minimum: 1,
                    falloff_exponent: 1
                },

                visual: {
                    palette: _palette,
                    draw_script: sc_attack_area_rebel_incendiary_fire_draw,
                    particle_script: sc_attack_area_rebel_incendiary_fire_emit
                }
            }
        },

        visual: {
            radius: 10,
            length: 25,
            palette: _palette,
            draw_script: sc_projectile_rebel_incendiary_canister_draw,
            impact_script: sc_projectile_rebel_incendiary_canister_impact,
            particles_register_script: sc_rebel_incendiary_fire_particles_register,

            bake: {
                canvas_size: 72,
                frames: 1,
                frame_speed: 1
            }
        }
    });
}


/// @description Registers particles used across the stationary fire circle.
function sc_rebel_incendiary_fire_particles_register()
{
    var _body = sc_particles_type_create();
    var _core = sc_particles_type_create();
    var _ember = sc_particles_type_create();

    part_type_sprite(_body, s_broad_flame_body, false, false, false);
    part_type_size(_body, 0.24, 0.4, 0.01, 0);
    part_type_colour1(_body, c_white);
    part_type_alpha3(_body, 0.8, 0.65, 0);
    part_type_speed(_body, 0.5, 2, -0.02, 0);
    part_type_direction(_body, 65, 115, 0, 0);
    part_type_orientation(_body, 0, 359, 0, 2, false);
    part_type_life(_body, 15, 24);
    part_type_blend(_body, true);

    part_type_sprite(_core, s_bright_flame_core, false, false, false);
    part_type_size(_core, 0.15, 0.3, 0.008, 0);
    part_type_colour1(_core, c_white);
    part_type_alpha3(_core, 1, 0.7, 0);
    part_type_speed(_core, 1, 3, -0.03, 0);
    part_type_direction(_core, 55, 125, 0, 0);
    part_type_orientation(_core, 0, 359, 0, 2, false);
    part_type_life(_core, 11, 18);
    part_type_blend(_core, true);

    part_type_sprite(_ember, s_ember, false, false, false);
    part_type_size(_ember, 0.3, 0.55, -0.01, 0);
    part_type_colour1(_ember, c_white);
    part_type_alpha3(_ember, 1, 0.7, 0);
    part_type_speed(_ember, 2, 5, -0.05, 0);
    part_type_direction(_ember, 0, 359, 0, 0);
    part_type_orientation(_ember, 0, 359, 0, 3, false);
    part_type_life(_ember, 12, 20);
    part_type_blend(_ember, true);

    return sc_particles_group_register("rebel_incendiary_fire", {
        body: _body,
        core: _core,
        ember: _ember
    });
}

/// @description Distributes flames throughout the full damaging circle.
function sc_attack_area_rebel_incendiary_fire_emit(_area, _data)
{
    var _radius = _data.geometry.radius;
    if (!sc_optimization_circle_visible(_area.x, _area.y, _radius, 64)) return;

    var _particles = sc_particles_group_get("rebel_incendiary_fire");
    if (!is_struct(_particles)) return;

    for (var _i = 0; _i < 3; ++_i)
    {
        var _direction = random(360);
        var _distance = sqrt(random(1)) * _radius * 0.88;
        var _x = _area.x + lengthdir_x(_distance, _direction);
        var _y = _area.y + lengthdir_y(_distance, _direction);

        part_particles_create(global.particles.system, _x, _y, _particles.body, 1);

        if (_i == 0)
            part_particles_create(global.particles.system, _x, _y, _particles.core, 1);
    }

    if (irandom(2) == 0)
    {
        var _direction = random(360);
        var _distance = sqrt(random(1)) * _radius;
        var _x = _area.x + lengthdir_x(_distance, _direction);
        var _y = _area.y + lengthdir_y(_distance, _direction);

        part_particles_create(global.particles.system, _x, _y, _particles.ember, 1);
    }
}

/// @description Draws the persistent fire's faint boundary beneath its flames.
function sc_attack_area_rebel_incendiary_fire_draw(_area, _data)
{
    var _radius = _data.geometry.radius;
    var _alpha = min(1, _data.runtime.life / 18);

    draw_set_colour(make_colour_rgb(210, 70, 20));
    draw_set_alpha(0.1 * _alpha);
    draw_circle(_area.x, _area.y, _radius, false);

    draw_set_colour(make_colour_rgb(255, 155, 55));
    draw_set_alpha(0.32 * _alpha);
    draw_circle(_area.x, _area.y, _radius, true);

    draw_set_alpha(1);
    draw_set_colour(c_white);
}

/// @description Draws one cylindrical canister frame for the projectile bake.
function sc_projectile_rebel_incendiary_canister_draw(_x, _y, _angle, _visual, _frame, _frame_count)
{
    var _r = _visual.radius;

    sc_visual_quad(
        _x, _y, _r, _angle,
        -1.15, -0.55,
        1.15, -0.55,
        1.15, 0.55,
        -1.15, 0.55,
        make_colour_rgb(57, 53, 47)
    );

    sc_visual_quad(
        _x, _y, _r, _angle,
        -0.8, -0.35,
        0.72, -0.35,
        0.72, 0.35,
        -0.8, 0.35,
        make_colour_rgb(155, 112, 68)
    );

    sc_visual_line(
        _x, _y, _r, _angle,
        -0.25, -0.38,
        -0.25, 0.38,
        3,
        make_colour_rgb(235, 151, 47)
    );

    sc_visual_line(
        _x, _y, _r, _angle,
        0.2, -0.38,
        0.2, 0.38,
        3,
        make_colour_rgb(235, 151, 47)
    );

    sc_visual_circle(
        _x, _y, _r, _angle,
        1.15, 0,
        0.47,
        make_colour_rgb(210, 184, 130),
        false
    );
}

/// @description Leaves the visible burst to the fire area created on impact.
function sc_projectile_rebel_incendiary_canister_impact(_x, _y, _direction, _target, _scale)
{
    return true;
}