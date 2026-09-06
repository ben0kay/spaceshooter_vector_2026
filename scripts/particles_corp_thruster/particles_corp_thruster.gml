/// @description Registers the Corporation enemy-thruster particle family.
function sc_particles_register_corporation_thrust()
{
    var _outer=sc_particles_type_create();
    var _inner=sc_particles_type_create();
    var _ring=sc_particles_type_create();

    if (!part_type_exists(_outer)
    || !part_type_exists(_inner)
    || !part_type_exists(_ring))
    {
        show_debug_message("CORPORATION THRUST PARTICLE ERROR - type creation failed");
        return false;
    }

    // Broad clean blue exhaust layer.
    part_type_sprite(_outer,s_particle_trail_white_beam,false,false,false);
    part_type_colour3(_outer,c_white,make_colour_rgb(80,175,255),make_colour_rgb(20,75,220));
    part_type_alpha3(_outer,0.75,0.46,0);
    part_type_speed(_outer,0.3,0.8,-0.025,0);
    part_type_life(_outer,5,9);
    part_type_orientation(_outer,180,180,0,0,true);
    part_type_blend(_outer,true);

    // Narrow hot white-blue core.
    part_type_sprite(_inner,s_particle_trail_white_beam,false,false,false);
    part_type_colour3(_inner,c_white,make_colour_rgb(190,235,255),make_colour_rgb(50,150,255));
    part_type_alpha3(_inner,1,0.68,0);
    part_type_speed(_inner,0.4,1,-0.03,0);
    part_type_life(_inner,3,6);
    part_type_orientation(_inner,180,180,0,0,true);
    part_type_blend(_inner,true);

    // Ignition ring.
    part_type_sprite(_ring,s_particle_ring_v2,false,false,false);
    part_type_colour2(_ring,c_white,make_colour_rgb(65,160,255));
    part_type_alpha2(_ring,0.9,0);
    part_type_speed(_ring,0,0,0,0);
    part_type_life(_ring,7,11);
    part_type_orientation(_ring,0,359,0,3,false);
    part_type_blend(_ring,true);

    return sc_particles_group_register("corporation_thrust",{
        outer:_outer,
        inner:_inner,
        ring:_ring
    });
}

/// @description Emits a clean Corporation engine ignition burst scaled by ship size, mass and power.
function sc_particles_corporation_thrust_ignition(_x,_y,_direction,_power,_mount_scale,_ship_radius,_mass,_palette)
{
    var _types=sc_particles_group_get("corporation_thrust");

    var _radius_scale=clamp(_ship_radius/52,0.7,2.5);
    var _mass_scale=clamp(_mass,0.5,3);
    var _mass_normal=(_mass_scale-0.5)/2.5;

    // Radius mostly controls overall width. Mass adds length/presence.
    var _scale=_mount_scale*lerp(0.85,_radius_scale,0.65);
    var _length_scale=lerp(0.85,1.35,_mass_normal);
    var _strength=lerp(0.8,1.35,_power);

    var _outer_size=0.56*_scale*_strength*_length_scale;
    var _inner_size=0.32*_scale*_strength*_length_scale;

    part_type_size(
        _types.ring,
        0.22*_scale,
        0.34*_scale,
        0.055*_scale,
        0
    );

    part_type_direction(
        _types.outer,
        _direction-5,
        _direction+5,
        0,
        0
    );

    part_type_size(
        _types.outer,
        _outer_size*0.72,
        _outer_size,
        -0.02*_scale,
        0.008
    );

    part_type_speed(
        _types.outer,
        0.45*_length_scale,
        1.15*_length_scale,
        -0.025,
        0
    );

    part_type_direction(
        _types.inner,
        _direction-2,
        _direction+2,
        0,
        0
    );

    part_type_size(
        _types.inner,
        _inner_size*0.78,
        _inner_size,
        -0.016*_scale,
        0.006
    );

    part_type_speed(
        _types.inner,
        0.55*_length_scale,
        1.35*_length_scale,
        -0.03,
        0
    );

    part_particles_create(global.particles.system,_x,_y,_types.ring,1);
    part_particles_create(global.particles.system,_x,_y,_types.outer,3);
    part_particles_create(global.particles.system,_x,_y,_types.inner,2);

    return true;
}

/// @description Emits clean Corporation blue-white exhaust scaled by ship size, mass and movement power.
function sc_particles_corporation_thrust_emit(_x,_y,_direction,_power,_mount_scale,_ship_radius,_mass,_palette)
{
    var _types=sc_particles_group_get("corporation_thrust");

    var _radius_scale=clamp(_ship_radius/52,0.7,2.5);
    var _mass_scale=clamp(_mass,0.5,3);
    var _mass_normal=(_mass_scale-0.5)/2.5;

    // Larger ships get wider exhaust; heavier ships get longer/heavier exhaust.
    var _scale=_mount_scale*lerp(0.85,_radius_scale,0.65);
    var _length_scale=lerp(0.85,1.35,_mass_normal);
    var _intensity=max(0.25,_power);

    var _outer_size=(0.38+_intensity*0.58)*_scale*_length_scale;
    var _inner_size=(0.19+_intensity*0.34)*_scale*_length_scale;

    var _outer_count=_intensity>0.7?2:1;
    if (_mass_normal>0.6) _outer_count+=1;

    // Broad but very controlled outer plasma trail.
    part_type_direction(
        _types.outer,
        _direction-4,
        _direction+4,
        0,
        0
    );

    part_type_size(
        _types.outer,
        _outer_size*0.78,
        _outer_size,
        -0.018*_scale,
        0.008
    );

    part_type_speed(
        _types.outer,
        0.35*_length_scale,
        0.95*_length_scale,
        -0.025,
        0
    );

    part_type_life(
        _types.outer,
        round(5+3*_mass_normal),
        round(9+5*_mass_normal)
    );

    // Narrow white-hot centre.
    part_type_direction(
        _types.inner,
        _direction-2,
        _direction+2,
        0,
        0
    );

    part_type_size(
        _types.inner,
        _inner_size*0.82,
        _inner_size,
        -0.013*_scale,
        0.006
    );

    part_type_speed(
        _types.inner,
        0.45*_length_scale,
        1.15*_length_scale,
        -0.03,
        0
    );

    part_type_life(
        _types.inner,
        round(3+2*_mass_normal),
        round(6+3*_mass_normal)
    );

    part_particles_create(global.particles.system,_x,_y,_types.outer,_outer_count);
    part_particles_create(global.particles.system,_x,_y,_types.inner,1);

    return true;
}