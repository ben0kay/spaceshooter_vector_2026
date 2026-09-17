/// @description Bakes layered visuals for supported player ships.
function sc_ship_visual_cache_init()
{
    global.ship_visual_cache = {};
    var _keys = variable_struct_get_names(global.data.ships);

    for (var _i = 0; _i < array_length(_keys); ++_i)
    {
        var _key = _keys[_i];
        var _data = variable_struct_get(
            global.data.ships,
            _key
        );

        var _visual = _data.visual;

        if (!variable_struct_exists(_visual, "draw")
        || !variable_struct_exists(_visual, "bake"))
            continue;

        var _stage_count = _visual.bake.damage_stages;
        var _muzzle_frames = _visual.bake.muzzle_frames;
        var _hardpoint_count = array_length(_data.hardpoints.primary);

        var _cache = {
            hull: array_create(_stage_count, -1),
            armour: array_create(_stage_count, -1),
            wing_hull: array_create(_stage_count, -1),
            wing_armour: array_create(_stage_count, -1),

            core: -1,
            hardpoints: array_create(_hardpoint_count, -1),

            muzzle_flash: array_create(_muzzle_frames, -1),
            shield: -1,
            focus: -1,
            thrust: -1
        };

        for (var _stage = 0;
        _stage < _stage_count;
        ++_stage)
        {
            _cache.hull[_stage] =
                sc_ship_visual_component_bake(
                    _data,
                    "hull",
                    _stage,
                    _visual.bake.body_canvas_size
                );

            _cache.armour[_stage] =
                sc_ship_visual_component_bake(
                    _data,
                    "armour",
                    _stage,
                    _visual.bake.body_canvas_size
                );

            _cache.wing_hull[_stage] =
                sc_ship_visual_component_bake(
                    _data,
                    "wing_hull",
                    _stage,
                    _visual.bake.wing_canvas_size
                );

            _cache.wing_armour[_stage] =
                sc_ship_visual_component_bake(
                    _data,
                    "wing_armour",
                    _stage,
                    _visual.bake.wing_canvas_size
                );
        }

        _cache.core = sc_ship_visual_component_bake(
            _data,
            "core",
            0,
            _visual.bake.core_canvas_size
        );

        for (var _h = 0; _h < _hardpoint_count; ++_h)
        {
            _cache.hardpoints[_h] =
                sc_ship_visual_component_bake(
                    _data,
                    "hardpoint",
                    _h,
                    _visual.bake.hardpoint_canvas_size
                );
        }

        for (var _frame = 0;
        _frame < _muzzle_frames;
        ++_frame)
        {
            _cache.muzzle_flash[_frame] =
                sc_ship_visual_component_bake(
                    _data,
                    "muzzle_flash",
                    _frame,
                    _visual.bake.muzzle_canvas_size
                );
        }

        _cache.shield = sc_ship_visual_component_bake(
            _data,
            "shield",
            0,
            _visual.bake.shield_canvas_size
        );

        _cache.focus = sc_ship_visual_component_bake(
            _data,
            "focus",
            0,
            _visual.bake.focus_canvas_size
        );

        _cache.thrust = sc_ship_visual_component_bake(
            _data,
            "thrust",
            0,
            _visual.bake.thrust_canvas_size
        );

        variable_struct_set(
            global.ship_visual_cache,
            _key,
            _cache
        );

        show_debug_message(
            "SHIP VISUAL CACHE BAKED - "
            + _key
        );
    }

    return true;
}


/// @description Bakes one player ship visual component.
function sc_ship_visual_component_bake(
    _data,
    _component,
    _stage,
    _canvas_size
)
{
    var _surface = surface_create(
        _canvas_size,
        _canvas_size
    );

    if (!surface_exists(_surface))
        return -1;

    var _visual = _data.visual;
    var _centre = _canvas_size*0.5;

    surface_set_target(_surface);
    draw_clear_alpha(c_black,0);
    draw_set_alpha(1);
    draw_set_colour(c_white);

    switch (_component)
    {
        case "hull":
            _visual.draw.hull(
                _centre,_centre,
                _visual.radius,0,
                _visual,_stage
            );
        break;

        case "armour":
            _visual.draw.armour(
                _centre,_centre,
                _visual.radius,0,
                _visual,_stage
            );
        break;

        case "wing_hull":
            _visual.draw.wing_hull(
                _centre,_centre,
                _visual.radius,0,
                _visual,_stage
            );
        break;

        case "wing_armour":
            _visual.draw.wing_armour(
                _centre,_centre,
                _visual.radius,0,
                _visual,_stage
            );
        break;

        case "core":
            _visual.draw.core(
                _centre,_centre,
                _visual.radius,0,
                _visual
            );
        break;

        case "hardpoint":
            var _hardpoint =
                _data.hardpoints.primary[_stage];

            _visual.draw.hardpoint(
                _centre,_centre,
                _visual.radius,0,
                _visual,_hardpoint
            );
        break;

        case "muzzle_flash":
            _visual.draw.muzzle_flash(
                _centre,_centre,
                _visual.radius,0,
                _visual,_stage,
                _visual.bake.muzzle_frames
            );
        break;

        case "shield":
            _visual.draw.shield(
                _centre,_centre,
                _visual.radius,0,
                _visual,
                _data.collision
            );
        break;

        case "focus":
            _visual.draw.focus(
                _centre,_centre,
                _visual.radius,0,
                _visual
            );
        break;

        case "thrust":
            _visual.draw.thrust(
                _centre,_centre,
                _visual.radius,0,
                _visual
            );
        break;
    }

    draw_set_alpha(1);
    draw_set_colour(c_white);
    surface_reset_target();

    var _sprite = sprite_create_from_surface(
        _surface,
        0,0,
        _canvas_size,_canvas_size,
        false,false,
        _centre,_centre
    );

    surface_free(_surface);
    return _sprite;
}


/// @description Draws an authored player hardpoint or its primitive fallback.
function sc_ship_hardpoint_dispatch(
    _x,_y,_radius,_angle,
    _visual,_hardpoint
)
{
    if (variable_struct_exists(_visual,"authored")
    && _visual.authored.enabled
    && variable_struct_exists(_hardpoint,"authored"))
    {
        var _authored = _hardpoint.authored;

        if (sprite_exists(_authored.sprite))
        {
            draw_sprite_ext(
                _authored.sprite,0,
                _x,_y,
                _authored.scale,
                _authored.scale,
                _angle,
                c_white,1
            );

            draw_set_alpha(1);
            draw_set_colour(c_white);
            return;
        }
    }

    _hardpoint.draw_script(
        _x,_y,_radius,_angle,
        _visual,0
    );
}


/// @description Deletes all generated player ship sprites.
function sc_ship_visual_cache_destroy()
{
    if (!variable_global_exists(
        "ship_visual_cache"
    ))
        return;

    var _keys = variable_struct_get_names(
        global.ship_visual_cache
    );

    for (var _i = 0;
    _i < array_length(_keys);
    ++_i)
    {
        var _cache = variable_struct_get(
            global.ship_visual_cache,
            _keys[_i]
        );

        for (var _stage = 0;
        _stage < array_length(_cache.hull);
        ++_stage)
        {
            if (sprite_exists(_cache.hull[_stage]))
                sprite_delete(_cache.hull[_stage]);

            if (sprite_exists(_cache.armour[_stage]))
                sprite_delete(_cache.armour[_stage]);

            if (sprite_exists(_cache.wing_hull[_stage]))
                sprite_delete(_cache.wing_hull[_stage]);

            if (sprite_exists(_cache.wing_armour[_stage]))
                sprite_delete(_cache.wing_armour[_stage]);
        }

        for (var _h = 0;
        _h < array_length(_cache.hardpoints);
        ++_h)
        {
            if (sprite_exists(_cache.hardpoints[_h]))
                sprite_delete(_cache.hardpoints[_h]);
        }

        for (var _frame = 0;
        _frame < array_length(_cache.muzzle_flash);
        ++_frame)
        {
            if (sprite_exists(
                _cache.muzzle_flash[_frame]
            ))
            {
                sprite_delete(
                    _cache.muzzle_flash[_frame]
                );
            }
        }

        if (sprite_exists(_cache.core))
            sprite_delete(_cache.core);

        if (sprite_exists(_cache.shield))
            sprite_delete(_cache.shield);

        if (sprite_exists(_cache.focus))
            sprite_delete(_cache.focus);

        if (sprite_exists(_cache.thrust))
            sprite_delete(_cache.thrust);
    }

    global.ship_visual_cache = {};

    show_debug_message(
        "SHIP VISUAL CACHE DESTROYED"
    );
}


/// @description Returns one ship's layered visual cache.
function sc_ship_visual_cache_get(_ship_key)
{
    if (!variable_global_exists("ship_visual_cache")
    || !variable_struct_exists(
        global.ship_visual_cache,
        _ship_key
    ))
        return undefined;

    return variable_struct_get(
        global.ship_visual_cache,
        _ship_key
    );
}