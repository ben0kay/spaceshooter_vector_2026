/*
ASTEROID MODIFIERS

Rare modifiers are layered onto ordinary asteroid materials.
Materials determine composition and base appearance.
Modifiers provide optional stat, behaviour and visual changes.
*/

/// @description Registers one unique asteroid modifier definition.
function sc_asteroid_modifier_register(_data)
{
    var _key = _data.identity.key;

    if (variable_struct_exists(global.data.asteroid_modifiers,_key))
    {
        show_debug_message("ASTEROID MODIFIER REGISTRATION ERROR - duplicate key: "+_key);
        return false;
    }

    variable_struct_set(global.data.asteroid_modifiers,_key,_data);
    return true;
}

/// @description Registers every available rare asteroid modifier.
function sc_asteroid_modifier_register_all()
{
    return sc_asteroid_modifier_register_unstable();
}

/// @description Registers the unstable explosive asteroid modifier.
function sc_asteroid_modifier_register_unstable()
{
    var _config = GCFG.asteroid.modifiers.unstable;

    return sc_asteroid_modifier_register({
        identity: {
            key: "unstable",
            name: "Unstable"
        },

        spawn: {
            weight: 1,
            min_sector_east: 0
        },

        stats: {
            health_multiplier: _config.health_multiplier,
            yield_multiplier: _config.yield_multiplier,
            pickup_launch_multiplier: _config.pickup_launch_multiplier
        },

        behaviour: {
            damage_script: sc_asteroid_modifier_unstable_damage,
            death_script: sc_asteroid_modifier_unstable_death
        },

        visual: {
            enabled: true,
            colour: _config.colour,
            draw_script: sc_asteroid_modifier_unstable_overlay_draw
        }
    });
}

/// @description Rolls one registered modifier without changing the surrounding generation RNG.
function sc_asteroid_modifier_roll(_persistent_id = -1)
{
    var _chance = clamp(GCFG.asteroid.modifiers.rare_chance,0,1);
    if (_chance <= 0) return "";

    var _isolated = _persistent_id >= 0;
    var _previous_seed = 0;

    if (_isolated)
    {
        _previous_seed = random_get_seed();

        var _seed = sc_sector_seed_get(
            global.game.sector.x,
            global.game.sector.y
        );

        _seed = abs((
            _seed
            + (_persistent_id+1)*1103515245
        ) mod 2147483647);

        random_set_seed(max(1,floor(_seed)));
    }

    var _modifier_key = "";

    if (random(1) < _chance)
    {
        var _keys = variable_struct_get_names(global.data.asteroid_modifiers);
        var _pool = [];

        for (var _i = 0; _i < array_length(_keys); ++_i)
        {
            var _definition = variable_struct_get(
                global.data.asteroid_modifiers,
                _keys[_i]
            );

            if (global.game.sector.x < _definition.spawn.min_sector_east
            || _definition.spawn.weight <= 0)
                continue;

            array_push(_pool,{
                key: _definition.identity.key,
                weight: _definition.spawn.weight
            });
        }

        if (array_length(_pool) > 0)
            _modifier_key = sc_asteroid_weighted_choose(_pool).key;
    }

    if (_isolated)
        random_set_seed(_previous_seed);

    return _modifier_key;
}

/// @description Creates independent runtime state for one modifier key.
function sc_asteroid_modifier_runtime_create(_modifier_key)
{
    if (string_length(_modifier_key) <= 0)
        return undefined;

    if (!variable_struct_exists(global.data.asteroid_modifiers,_modifier_key))
    {
        show_debug_message("ASTEROID MODIFIER ERROR - unregistered key: "+_modifier_key);
        return undefined;
    }

    return {
        key: _modifier_key,
        definition: variable_struct_get(
            global.data.asteroid_modifiers,
            _modifier_key
        ),

        triggered: false
    };
}

/// @description Returns the modified pickup launch multiplier.
function sc_asteroid_modifier_pickup_launch_multiplier_get(_asteroid)
{
    var _modifier = _asteroid.asteroid.modifier;

    return is_struct(_modifier)
        ? _modifier.definition.stats.pickup_launch_multiplier
        : 1;
}

/// @description Converts the first damaging hit against an unstable asteroid into lethal damage.
function sc_asteroid_modifier_unstable_damage(_asteroid,_packet,_damage_amount)
{
    var _modifier = _asteroid.asteroid.modifier;

    if (_modifier.triggered || _damage_amount <= 0)
        return _damage_amount;

    _modifier.triggered = true;
    return _asteroid.asteroid.health.current;
}

/// @description Creates the unstable asteroid's neutral radial explosion.
function sc_asteroid_modifier_unstable_death(_asteroid,_packet)
{
    var _data = _asteroid.asteroid;
    var _config = GCFG.asteroid.modifiers.unstable;
    var _size = _data.size;
    var _shockwave = variable_clone(GCFG.asteroid.death.shockwave);

    _shockwave.radius_scale = 1;
    _shockwave.colour = _config.colour;
    _shockwave.fragment_colour = merge_colour(_config.colour,c_white,0.35);
    _shockwave.smoke_colour = merge_colour(_config.colour,c_black,0.75);

    sc_attack_area_create(
        {
            shape: AttackAreaShape.CIRCLE,

            geometry: {
                radius: _config.explosion_radius[_size]
            },

            behaviour: {
                duration: 1,
                tick_interval: 0,
                hit_once: true,
                max_targets: 0,

                falloff_minimum: _config.falloff_minimum,
                falloff_exponent: _config.falloff_exponent,

                occlusion: {
                    asteroids: true
                }
            },

            visual: {
                draw_script: sc_asteroid_modifier_explosion_draw,
                shockwave: _shockwave
            }
        },

        {
            owner_id: _asteroid,
            faction: noone,
            damage_multiplier: 1
        },

        {
            amount: _config.explosion_damage[_size],
            type: DamageType.EXPLOSIVE,
            effect: DamageEffect.NONE,
            knockback_force: _config.explosion_knockback[_size]
        },

        _asteroid.x,
        _asteroid.y,
        _asteroid.draw_angle,
        _asteroid.layer
    );

    return true;
}

/// @description Leaves the attack-area instance invisible because its shockwave owns the visual.
function sc_asteroid_modifier_explosion_draw(_area,_data)
{
    return;
}

/// @description Draws one unstable fracture overlay for startup baking.
function sc_asteroid_modifier_unstable_overlay_draw(_x,_y,_radius,_variant,_visual)
{
    var _colour = _visual.colour;
    var _angle = _variant*23-18;
    var _x1 = _x+lengthdir_x(_radius*0.58,_angle+180);
    var _y1 = _y+lengthdir_y(_radius*0.58,_angle+180);
    var _x2 = _x+lengthdir_x(_radius*0.12,_angle+8);
    var _y2 = _y+lengthdir_y(_radius*0.12,_angle+8);
    var _x3 = _x+lengthdir_x(_radius*0.57,_angle-4);
    var _y3 = _y+lengthdir_y(_radius*0.57,_angle-4);

    draw_set_colour(_colour);
    draw_set_alpha(0.2);
    draw_line_width(_x1,_y1,_x2,_y2,9);
    draw_line_width(_x2,_y2,_x3,_y3,9);

    draw_set_alpha(0.9);
    draw_line_width(_x1,_y1,_x2,_y2,3);
    draw_line_width(_x2,_y2,_x3,_y3,3);

    var _branch_angle = _angle+68+_variant*7;
    var _branch_x = _x2+lengthdir_x(_radius*0.34,_branch_angle);
    var _branch_y = _y2+lengthdir_y(_radius*0.34,_branch_angle);

    draw_set_alpha(0.18);
    draw_line_width(_x2,_y2,_branch_x,_branch_y,7);

    draw_set_alpha(0.82);
    draw_line_width(_x2,_y2,_branch_x,_branch_y,2);

    draw_set_alpha(0.26);
    draw_circle(_x2,_y2,_radius*0.12,false);

    draw_set_alpha(1);
    draw_circle(_x2,_y2,max(2,_radius*0.025),false);
    draw_set_colour(c_white);
}

/// @description Bakes one transparent asteroid-modifier overlay.
function sc_asteroid_modifier_visual_bake(_definition,_variant)
{
    var _canvas = 256;
    var _centre = _canvas*0.5;
    var _surface = surface_create(_canvas,_canvas);

    if (!surface_exists(_surface))
        return -1;

    surface_set_target(_surface);
    draw_clear_alpha(c_black,0);

    _definition.visual.draw_script(
        _centre,
        _centre,
        108,
        _variant,
        _definition.visual
    );

    surface_reset_target();

    var _sprite = sprite_create_from_surface(
        _surface,
        0,0,
        _canvas,_canvas,
        false,false,
        _centre,_centre
    );

    surface_free(_surface);
    return _sprite;
}

/// @description Bakes every registered modifier overlay and shape.
function sc_asteroid_modifier_visual_cache_init()
{
    if (variable_global_exists("asteroid_modifier_visual_cache"))
        sc_asteroid_modifier_visual_cache_destroy();

    global.asteroid_modifier_visual_cache = {};

    var _keys = variable_struct_get_names(global.data.asteroid_modifiers);

    for (var _k = 0; _k < array_length(_keys); ++_k)
    {
        var _key = _keys[_k];
        var _definition = variable_struct_get(
            global.data.asteroid_modifiers,
            _key
        );

        if (!_definition.visual.enabled)
            continue;

        var _variants = array_create(6,-1);

        for (var _variant = 0; _variant < 6; ++_variant)
        {
            _variants[_variant] = sc_asteroid_modifier_visual_bake(
                _definition,
                _variant
            );

            if (!sprite_exists(_variants[_variant]))
            {
                sc_asteroid_modifier_visual_cache_destroy();
                show_debug_message("ASTEROID MODIFIER BAKE ERROR - "+_key);
                return false;
            }
        }

        variable_struct_set(
            global.asteroid_modifier_visual_cache,
            _key,
            _variants
        );
    }

    show_debug_message("ASTEROID MODIFIER VISUAL CACHE BAKED");
    return true;
}

/// @description Returns one cached modifier overlay.
function sc_asteroid_modifier_visual_cache_get(_key,_variant)
{
    return variable_struct_get(
        global.asteroid_modifier_visual_cache,
        _key
    )[_variant];
}

/// @description Deletes every generated modifier-overlay sprite.
function sc_asteroid_modifier_visual_cache_destroy()
{
    if (!variable_global_exists("asteroid_modifier_visual_cache"))
        return;

    var _keys = variable_struct_get_names(
        global.asteroid_modifier_visual_cache
    );

    for (var _k = 0; _k < array_length(_keys); ++_k)
    {
        var _variants = variable_struct_get(
            global.asteroid_modifier_visual_cache,
            _keys[_k]
        );

        for (var _variant = 0; _variant < array_length(_variants); ++_variant)
            if (sprite_exists(_variants[_variant]))
                sprite_delete(_variants[_variant]);
    }

    global.asteroid_modifier_visual_cache = {};
    show_debug_message("ASTEROID MODIFIER VISUAL CACHE DESTROYED");
}