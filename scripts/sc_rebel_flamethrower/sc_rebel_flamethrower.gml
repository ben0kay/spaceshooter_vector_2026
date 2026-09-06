/// @description Registers the Rebel Napalm Projector.
function sc_weapon_register_rebel_flamethrower()
{
    var _palette=sc_faction_palette_get(Faction.REBEL);

    return sc_weapon_register({
        identity:{
            key:"weapon_rebel_flamethrower",
            name:"Rebel Napalm Projector"
        },

        delivery:{
            type:AttackDelivery.BEAM,
            scale:1,

            damage:{
                amount:4,
                type:DamageType.THERMAL,
                effect:DamageEffect.BURN,
                effect_chance:0.22
            },

            beam:{
                shape:AttackAreaShape.CONE,

                geometry:{
                    range:430,
                    angle:40
                },

                behaviour:{
                    release_duration:7,
                    tick_interval:6,
                    max_targets:8
                },

                visual:{
                    palette:_palette,
                    draw_script:sc_attack_area_rebel_flamethrower_draw,
                    particles_register_script:sc_rebel_flamethrower_particles_register,
                    particle_script:sc_rebel_flamethrower_particles_emit
                }
            }
        },

        audio:{
            sound:noone,
            volume:0.55,
            pitch_range:0.08
        }
    });
}

/// @description Registers the layered Rebel flamethrower particles.
function sc_rebel_flamethrower_particles_register()
{
    var _p=sc_faction_palette_get(Faction.REBEL);
    var _body=sc_particles_type_create();
    var _core=sc_particles_type_create();
    var _smoke=sc_particles_type_create();
    var _ember=sc_particles_type_create();

    part_type_sprite(_body,s_broad_flame_body,false,false,false);
    part_type_size(_body,0.28,0.52,0.012,0.02);
    part_type_scale(_body,1.15,0.8);
    part_type_colour1(_body,c_white);
    part_type_alpha3(_body,0.92,0.7,0);
    part_type_speed(_body,11,17,-0.1,0);
    part_type_direction(_body,-16,16,0,0);
    part_type_orientation(_body,-8,8,0,2,true);
    part_type_life(_body,19,28);
    part_type_blend(_body,true);

    part_type_sprite(_core,s_bright_flame_core,false,false,false);
    part_type_size(_core,0.24,0.43,0.006,0.014);
    part_type_scale(_core,1.1,0.7);
    part_type_colour1(_core,c_white);
    part_type_alpha3(_core,1,0.78,0);
    part_type_speed(_core,13,19,-0.13,0);
    part_type_direction(_core,-6,6,0,0);
    part_type_orientation(_core,-4,4,0,1,true);
    part_type_life(_core,13,21);
    part_type_blend(_core,true);

    part_type_sprite(_smoke,s_blur,false,false,true);
    part_type_size(_smoke,0.12,0.22,0.012,0.025);
    part_type_colour3(_smoke,_p.hull_mid,_p.hull_dark,_p.void);
    part_type_alpha3(_smoke,0.4,0.28,0);
    part_type_speed(_smoke,2.5,6,-0.04,0);
    part_type_direction(_smoke,0,359,0,0);
    part_type_orientation(_smoke,0,359,0,2,false);
    part_type_life(_smoke,24,40);
    part_type_blend(_smoke,false);

    part_type_sprite(_ember,s_ember,false,false,false);
    part_type_size(_ember,0.35,0.7,-0.01,0.06);
    part_type_colour1(_ember,c_white);
    part_type_alpha3(_ember,1,0.8,0);
    part_type_speed(_ember,12,21,-0.15,0);
    part_type_direction(_ember,-22,22,0,0);
    part_type_orientation(_ember,-15,15,0,4,true);
    part_type_life(_ember,14,24);
    part_type_blend(_ember,true);

    return sc_particles_group_register("rebel_flamethrower",{
        body:_body,
        core:_core,
        smoke:_smoke,
        ember:_ember
    });
}

/// @description Emits layered flames along the active Rebel cone.
function sc_rebel_flamethrower_particles_emit(_area,_data)
{
    var _geometry=_data.geometry;
    if (!sc_optimization_circle_visible(_area.x,_area.y,_geometry.range,64)) return;

    var _particles=sc_particles_group_get("rebel_flamethrower");
    if (!is_struct(_particles)) return;

    var _direction=_data.direction;
    var _body_spread=_geometry.angle*0.42;
    var _core_spread=_geometry.angle*0.14;

    part_type_direction(_particles.body,_direction-_body_spread,_direction+_body_spread,0,0);
    part_type_direction(_particles.core,_direction-_core_spread,_direction+_core_spread,0,0);
    part_type_direction(_particles.ember,_direction-_body_spread,_direction+_body_spread,0,0);

    part_particles_create(global.particles.system,_area.x,_area.y,_particles.body,3);
    part_particles_create(global.particles.system,_area.x,_area.y,_particles.core,2);

    if (irandom(1)==0)
        part_particles_create(global.particles.system,_area.x,_area.y,_particles.ember,1);

    if (irandom(3)==0)
    {
        var _smoke_direction=_direction+random_range(-_body_spread,_body_spread);
        var _smoke_distance=random_range(_geometry.range*0.32,_geometry.range*0.62);
        var _smoke_x=_area.x+lengthdir_x(_smoke_distance,_smoke_direction);
        var _smoke_y=_area.y+lengthdir_y(_smoke_distance,_smoke_direction);

        part_particles_create(
            global.particles.system,
            _smoke_x,_smoke_y,
            _particles.smoke,
            1
        );
    }
}

/// @description Draws the faint trustworthy boundary beneath the flame particles.
function sc_attack_area_rebel_flamethrower_draw(_area,_data)
{
    var _p=_data.visual.palette;
    var _geometry=_data.geometry;
    var _runtime=_data.runtime;
    var _alpha=_runtime.release_alpha;
    var _segments=8;
    var _previous_x=_area.x;
    var _previous_y=_area.y;

    gpu_set_blendmode(bm_add);

    draw_set_alpha(0.035*_alpha);
    draw_set_colour(_p.glow);

    for (var _i=0; _i<_segments; ++_i)
    {
        var _direction_a=_data.direction-_geometry.angle*0.5+_geometry.angle*(_i/_segments);
        var _direction_b=_data.direction-_geometry.angle*0.5+_geometry.angle*((_i+1)/_segments);
        var _ax=_area.x+lengthdir_x(_geometry.range,_direction_a);
        var _ay=_area.y+lengthdir_y(_geometry.range,_direction_a);
        var _bx=_area.x+lengthdir_x(_geometry.range,_direction_b);
        var _by=_area.y+lengthdir_y(_geometry.range,_direction_b);

        draw_triangle(_area.x,_area.y,_ax,_ay,_bx,_by,false);
    }

    draw_set_alpha(0.22*_alpha);
    draw_set_colour(_p.energy);

    for (var _i=0; _i<=_segments; ++_i)
    {
        var _direction=_data.direction-_geometry.angle*0.5+_geometry.angle*(_i/_segments);
        var _x=_area.x+lengthdir_x(_geometry.range,_direction);
        var _y=_area.y+lengthdir_y(_geometry.range,_direction);

        if (_i>0)
            draw_line_width(_previous_x,_previous_y,_x,_y,1);

        _previous_x=_x;
        _previous_y=_y;
    }

    draw_set_alpha(0.5*_alpha);
    draw_line_width(
        _area.x,_area.y,
        _area.x+lengthdir_x(_geometry.range,_data.direction-_geometry.angle*0.5),
        _area.y+lengthdir_y(_geometry.range,_data.direction-_geometry.angle*0.5),
        1
    );

    draw_line_width(
        _area.x,_area.y,
        _area.x+lengthdir_x(_geometry.range,_data.direction+_geometry.angle*0.5),
        _area.y+lengthdir_y(_geometry.range,_data.direction+_geometry.angle*0.5),
        1
    );

    draw_set_alpha(1);
    draw_set_colour(c_white);
    gpu_set_blendmode(bm_normal);
}