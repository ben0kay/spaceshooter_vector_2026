/// @description Registers the shared shockwave smoke and fragment particles.
function sc_particles_register_shockwave()
{
    var _smoke = sc_particles_type_create();
    var _fragment = sc_particles_type_create();

    if (!part_type_exists(_smoke) || !part_type_exists(_fragment))
    {
        show_debug_message("SHOCKWAVE PARTICLE ERROR - type creation failed");
        return false;
    }

    // Expanding smoke balls deposited around the shockwave ring.
    part_type_sprite(_smoke, s_blur, false, false, true);
    part_type_size(_smoke, 0.28, 0.52, 0.022, 0.03);
    part_type_scale(_smoke, 1, 1);
    part_type_colour2(_smoke, make_colour_rgb(95, 105, 110), make_colour_rgb(25, 30, 35));
    part_type_alpha3(_smoke, 0.52, 0.32, 0);
    part_type_blend(_smoke, false);
    part_type_speed(_smoke, 0.5, 1.5, -0.035, 0);
    part_type_direction(_smoke, 0, 359, 0, 0);
    part_type_orientation(_smoke, 0, 359, 0, 2, false);
    part_type_life(_smoke, 18, 30);

    // Small hot fragments occasionally thrown from the ring.
    part_type_sprite(_fragment, s_particle_exposion_star, false, false, false);
    part_type_size(_fragment, 0.045, 0.09, -0.004, 0.015);
    part_type_colour2(_fragment, c_white, make_colour_rgb(25, 225, 255));
    part_type_alpha3(_fragment, 1, 0.7, 0);
    part_type_blend(_fragment, true);
    part_type_speed(_fragment, 1.5, 4, -0.1, 0);
    part_type_direction(_fragment, 0, 359, 0, 0);
    part_type_orientation(_fragment, -12, 12, 0, 4, true);
    part_type_life(_fragment, 8, 16);

    return sc_particles_group_register("shockwave", {
        smoke: _smoke,
        fragment: _fragment
    });
}

/// @description Creates one cosmetic shockwave from registered visual data.
function sc_shockwave_create(_x, _y, _layer, _definition, _radius)
{
    var _shockwave = instance_create_layer(_x, _y, _layer, o_shockwave, {
        shockwave_create: {
            definition: variable_clone(_definition),
            radius_max: _radius * _definition.radius_scale
        }
    });

    _shockwave.depth = -18;
    return _shockwave;
}

/// @description Initializes one configurable cosmetic shockwave.
function sc_shockwave_init(_shockwave, _create)
{
    var _definition = _create.definition;

    _shockwave.shockwave = {
        radius_current: 0,
        radius_max: max(1, _create.radius_max),
        expansion_response: _definition.expansion_response,
        alpha: 1,
        fade_speed: _definition.fade_speed,
        thickness: _definition.thickness,
        colour: _definition.colour,

        particles: {
            enabled: _definition.particles_enabled,
            interval: max(1, round(_definition.particle_interval)),
            minimum_radius: _definition.particle_min_radius,
            smoke_enabled: _definition.smoke_enabled,
            smoke_amount_max: max(1, round(_definition.smoke_amount_max)),
            smoke_colour: _definition.smoke_colour,
            fragments_enabled: _definition.fragments_enabled,
            fragment_chance: clamp(_definition.fragment_chance, 0, 1),
            fragment_colour: _definition.fragment_colour
        },

        runtime: {
            particle_timer: 0
        }
    };

    _shockwave.initialized = true;
    return true;
}

/// @description Emits smoke and fragments around the expanding shockwave edge.
function sc_shockwave_particles_emit(_shockwave)
{
    var _data = _shockwave.shockwave;
    var _particles = _data.particles;
    var _types = sc_particles_group_get("shockwave");

    if (!is_struct(_types)) return false;

    var _radius_progress = clamp(_data.radius_current / _data.radius_max, 0, 1);
    var _smoke_amount = clamp(ceil(_data.radius_current / 48), 1, _particles.smoke_amount_max);

    if (_particles.smoke_enabled)
    {
        part_type_colour2(_types.smoke, _particles.smoke_colour, merge_colour(_particles.smoke_colour, c_black, 0.7));

        for (var _i = 0; _i < _smoke_amount; _i++)
        {
            var _angle = random(360);
            var _radius = _data.radius_current + random_range(-_data.thickness * 2, _data.thickness * 2);
            var _x = _shockwave.x + lengthdir_x(_radius, _angle);
            var _y = _shockwave.y + lengthdir_y(_radius, _angle);

            part_type_direction(_types.smoke, _angle - 18, _angle + 18, 0, 0);
            part_particles_create(global.particles.impact_system, _x, _y, _types.smoke, 1);
        }
    }

    if (_particles.fragments_enabled && random(1) < _particles.fragment_chance * lerp(0.65, 1, _radius_progress))
    {
        var _angle = random(360);
        var _radius = _data.radius_current + random_range(-_data.thickness, _data.thickness);
        var _x = _shockwave.x + lengthdir_x(_radius, _angle);
        var _y = _shockwave.y + lengthdir_y(_radius, _angle);

        part_type_colour2(_types.fragment, c_white, _particles.fragment_colour);
        part_type_direction(_types.fragment, _angle - 12, _angle + 12, 0, 0);
        part_particles_create(global.particles.impact_system, _x, _y, _types.fragment, 1);
    }

    return true;
}

/// @description Expands, fades and decorates one cosmetic shockwave.
function sc_shockwave_update(_shockwave)
{
    var _data = _shockwave.shockwave;
    var _runtime = _data.runtime;

    _data.radius_current = lerp(_data.radius_current, _data.radius_max, _data.expansion_response);

    if (_data.particles.enabled
    && _data.radius_current >= _data.particles.minimum_radius
    && _data.alpha > 0.15)
    {
        _runtime.particle_timer--;

        if (_runtime.particle_timer <= 0)
        {
            _runtime.particle_timer = _data.particles.interval;
            sc_shockwave_particles_emit(_shockwave);
        }
    }

    _data.alpha = max(0, _data.alpha - _data.fade_speed);

    if (_data.alpha <= 0)
        instance_destroy(_shockwave);
}

/// @description Draws one layered glowing shockwave ring.
function sc_shockwave_draw(_shockwave)
{
    var _data = _shockwave.shockwave;
    var _radius = max(0, _data.radius_current);
    var _thickness = max(1, round(_data.thickness));

    gpu_set_blendmode(bm_add);
    draw_set_colour(_data.colour);

    draw_set_alpha(_data.alpha * 0.1);
    draw_circle(_shockwave.x, _shockwave.y, _radius + _thickness * 3, true);

    draw_set_alpha(_data.alpha * 0.2);
    draw_circle(_shockwave.x, _shockwave.y, _radius + _thickness * 2, true);

    draw_set_alpha(_data.alpha * 0.38);
    draw_circle(_shockwave.x, _shockwave.y, _radius + _thickness, true);

    draw_set_alpha(_data.alpha);

    for (var _i = 0; _i < _thickness; _i++)
        draw_circle(_shockwave.x, _shockwave.y, max(0, _radius - _i), true);

    draw_set_alpha(_data.alpha * 0.28);
    draw_circle(_shockwave.x, _shockwave.y, max(0, _radius - _thickness), true);

    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
    draw_set_colour(c_white);
}