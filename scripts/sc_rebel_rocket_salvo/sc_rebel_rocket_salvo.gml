/// @description Registers the guided and explosive Rebel Salvo Rocket projectile.
function sc_projectile_register_rebel_salvo_rocket()
{
    var _palette = sc_faction_palette_get(Faction.REBEL);

    return sc_projectile_register({
        identity: {
            key: "projectile_rebel_salvo_rocket",
            name: "Rebel Salvo Rocket"
        },

        projectile_motion: ProjectileMotion.STANDARD,
        projectile_class: ProjectileClass.REGULAR,

        collision: {
            radius: 8
        },
		
		defence: {
            armour: 0,
            hull: 4,
            detonate_on_destroy: true
        },

        detonation: {
            area: {
                shape: AttackAreaShape.CIRCLE,

                geometry: {
                    radius: 52
                },

                behaviour: {
                    duration: 14,
                    tick_interval: 0,
                    hit_once: true,
                    max_targets: 0,
                    falloff_minimum: 0.45,
                    falloff_exponent: 1
                },

                visual: {
                    palette: _palette,
                    draw_script: sc_attack_area_shard_rocket_explosion_draw,

                    shockwave: {
                        radius_scale: 1.05,
                        expansion_response: 0.24,
                        fade_speed: 0.07,
                        thickness: 3,
                        colour: _palette.energy,

                        particles_enabled: true,
                        particle_interval: 1,
                        particle_min_radius: 6,

                        smoke_enabled: true,
                        smoke_amount_max: 2,
                        smoke_colour: make_colour_rgb(92,75,60),

                        fragments_enabled: true,
                        fragment_chance: 0.35,
                        fragment_colour: _palette.energy
                    }
                }
            }
        },

        visual: {
            radius: 8,
            length: 28,
            palette: _palette,

            draw_script: sc_projectile_rebel_salvo_rocket_draw,
            impact_script: sc_projectile_rebel_salvo_rocket_impact,
            trail_script: sc_projectile_particle_trail_emit,
            particles_register_script: sc_projectile_rebel_salvo_rocket_particles_register,

            particle_trail: {
                group: "trail_rebel_salvo_rocket",
                interval: 1,
                amount: 1,
                rear_scale: 0.32,
                spread: 10,
                size_min: 0.14,
                size_max: 0.24,
                size_growth: 0.004,
                size_wiggle: 0.03
            },

            trail: {
                enabled: true,
                length: 34,
                width: 2.8,
                glow_width: 8,
                alpha: 0.72,
                glow_alpha: 0.18
            },

            bake: {
                canvas_size: 96,
                frames: 6,
                frame_speed: 2
            }
        }
    });
}

/// @description Registers the Rebel Salvo Rocket impact + smoke trail particles.
function sc_projectile_rebel_salvo_rocket_particles_register()
{
    var _palette=sc_faction_palette_get(Faction.REBEL);

    if (!sc_particles_projectile_impact_register(
        "impact_rebel_salvo_rocket",
        _palette,
        {
            scale:1.25,
            spark_amount:10,
            fragment_amount:8,
            spark_spread:130,
            speed_min:2.2,
            speed_max:5.8
        }
    )) return false;

    return sc_particles_projectile_trail_register(
        "trail_rebel_salvo_rocket",
        {
            sprite:s_blur,

            colour_start:make_colour_rgb(255,185,90),
            colour_middle:make_colour_rgb(120,120,120),
            colour_end:make_colour_rgb(70,70,70),

            alpha_start:0.55,
            alpha_middle:0.26,

            speed_min:0.12,
            speed_max:0.55,
            speed_reduce:-0.008,

            life_min:14,
            life_max:24,

            rotation_speed:1.4,
            blend_additive:true
        }
    );
}

/// @description Emits the Rebel Salvo Rocket impact.
function sc_projectile_rebel_salvo_rocket_impact(_x,_y,_direction,_target,_scale)
{
    return sc_particles_projectile_impact_emit(
        "impact_rebel_salvo_rocket",
        _x,
        _y,
        _direction,
        _scale
    );
}

/// @description Draws one baked Rebel Salvo Rocket frame.
function sc_projectile_rebel_salvo_rocket_draw(_x,_y,_angle,_visual,_frame,_frame_count)
{
    var _r=_visual.radius;
    var _phase=(_frame/_frame_count)*pi*2;
    var _flame_pulse=0.88+sin(_phase*2)*0.12;

    // Rear smoke glow.
    gpu_set_blendmode(bm_add);
    draw_set_colour(make_colour_rgb(255,155,60));
    draw_set_alpha(0.18);
    draw_line_width(
        _x+lengthdir_x(-_r*1.8,_angle),_y+lengthdir_y(-_r*1.8,_angle),
        _x+lengthdir_x(_r*0.15,_angle),_y+lengthdir_y(_r*0.15,_angle),
        _r*0.75
    );
    gpu_set_blendmode(bm_normal);

    // Main body.
    sc_visual_quad(
        _x,_y,_r,_angle,
        -0.62,-0.11,
        0.44,-0.09,
        0.44,0.09,
        -0.62,0.11,
        make_colour_rgb(88,72,58)
    );

    // Panel strip.
    sc_visual_quad(
        _x,_y,_r,_angle,
        -0.3,-0.06,
        0.16,-0.05,
        0.16,0.05,
        -0.3,0.06,
        make_colour_rgb(122,104,82)
    );

    // Nose cone.
    sc_visual_triangle(
        _x,_y,_r,_angle,
        0.82,0,
        0.42,0.13,
        0.42,-0.13,
        make_colour_rgb(198,186,168),
        false
    );

    // Fins.
    sc_visual_triangle(
        _x,_y,_r,_angle,
        -0.28,0.1,
        -0.72,0.36,
        -0.54,0.06,
        make_colour_rgb(78,64,52),
        false
    );
    sc_visual_triangle(
        _x,_y,_r,_angle,
        -0.28,-0.1,
        -0.72,-0.36,
        -0.54,-0.06,
        make_colour_rgb(78,64,52),
        false
    );

    // Rear engine ring.
    sc_visual_circle(
        _x,_y,_r,_angle,
        -0.72,0,
        0.12,
        make_colour_rgb(52,42,34),
        false
    );

    // Exhaust flame.
    gpu_set_blendmode(bm_add);
    sc_visual_triangle(
        _x,_y,_r,_angle,
        -1.18,0,
        -0.72,0.12*_flame_pulse,
        -0.72,-0.12*_flame_pulse,
        make_colour_rgb(255,180,70),
        false
    );
    sc_visual_triangle(
        _x,_y,_r,_angle,
        -0.98,0,
        -0.72,0.07*_flame_pulse,
        -0.72,-0.07*_flame_pulse,
        make_colour_rgb(255,235,180),
        false
    );
    gpu_set_blendmode(bm_normal);

    // Tiny warning band.
    sc_visual_line(
        _x,_y,_r,_angle,
        -0.05,-0.09,
        -0.05,0.09,
        2,
        make_colour_rgb(210,150,42)
    );

    draw_set_alpha(1);
    draw_set_colour(c_white);
}