/*
DEBUG WEAPON TEST

F2 opens a registry-driven weapon testing panel.
The selected weapon temporarily overrides the player's primary weapon.
The real ship loadout and resources remain unchanged.

Hovering a registered weapon displays its core stats and, where available,
an animated preview of the real baked projectile visual.
*/

/// @description Returns a readable weapon delivery name.
function sc_debug_weapon_delivery_name(_type)
{
    switch (_type)
    {
        case AttackDelivery.PROJECTILE: return "PROJECTILE";
        case AttackDelivery.AREA: return "AREA";
        case AttackDelivery.BEAM: return "BEAM";
        case AttackDelivery.DEPLOYABLE: return "DEPLOYABLE";
    }

    return "UNKNOWN";
}

/// @description Returns a readable damage-type name for the F2 inspector.
function sc_debug_weapon_damage_type_name(_type)
{
    switch (_type)
    {
        case DamageType.KINETIC: return "KINETIC";
        case DamageType.ENERGY: return "ENERGY";
        case DamageType.EXPLOSIVE: return "EXPLOSIVE";
        case DamageType.ELECTRIC: return "ELECTRIC";
        case DamageType.THERMAL: return "THERMAL";
        case DamageType.CORROSIVE: return "CORROSIVE";
    }

    return "UNKNOWN";
}

/// @description Returns a readable projectile-class name for the F2 inspector.
function sc_debug_weapon_projectile_class_name(_class)
{
    switch (_class)
    {
        case ProjectileClass.LIGHT: return "LIGHT";
        case ProjectileClass.REGULAR: return "REGULAR";
        case ProjectileClass.HEAVY: return "HEAVY";
    }

    return "UNKNOWN";
}

/// @description Returns a readable projectile-motion name for the F2 inspector.
function sc_debug_weapon_projectile_motion_name(_motion)
{
    switch (_motion)
    {
        case ProjectileMotion.STANDARD: return "STANDARD";
        case ProjectileMotion.ROCKET: return "ROCKET";
        case ProjectileMotion.CURVE: return "CURVE";
        case ProjectileMotion.STATIONARY: return "STATIONARY";
    }

    return "UNKNOWN";
}

/// @description Returns a readable shot-pattern name for the F2 inspector.
function sc_debug_weapon_shot_pattern_name(_pattern)
{
    switch (_pattern)
    {
        case ShotPattern.SINGLE: return "SINGLE";
        case ShotPattern.SPREAD: return "SPREAD";
        case ShotPattern.RANDOM_CONE: return "RANDOM CONE";
    }

    return "UNKNOWN";
}

/// @description Draws one labelled weapon-inspector stat row.
function sc_debug_weapon_test_stat_draw(_palette,_x,_y,_label,_value)
{
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);

    draw_set_colour(_palette.muted);
    draw_text(_x,_y,_label);

    draw_set_colour(_palette.text);
    draw_text(_x + 154,_y,_value);
}

/// @description Draws the real animated baked projectile inside the F2 inspector.
function sc_debug_weapon_test_projectile_preview_draw(
    _projectile_key,
    _x,_y,_width,_height,
    _palette
)
{
    var _projectile = variable_struct_get(
        global.data.projectiles,
        _projectile_key
    );

    var _visual = _projectile.visual;
    var _cache = sc_projectile_visual_cache_get(_projectile_key);
    var _frame_count = array_length(_cache.sprites);
    var _frame = floor(GAME_TICK / _cache.frame_speed) mod _frame_count;
    var _sprite = _cache.sprites[_frame];

    draw_set_alpha(0.7);
    draw_set_colour(_palette.void);
    draw_rectangle(_x,_y,_x + _width,_y + _height,false);

    draw_set_alpha(1);
    draw_set_colour(_palette.outline);
    draw_rectangle(_x,_y,_x + _width,_y + _height,true);

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_colour(_palette.muted);

    draw_text(
        _x + 12,_y + 10,
        "BAKED PROJECTILE // "
        + string_upper(_projectile.identity.name)
    );

    var _radius = _visual.radius;
    var _length = variable_struct_exists(_visual,"length")
        ? _visual.length
        : _radius * 2;

    // Scale from the projectile's actual drawn dimensions rather than its
    // transparent bake canvas so small projectiles remain easy to inspect.
    var _visual_width = max(1,_length + _radius * 2);
    var _visual_height = max(1,_radius * 4);
    var _scale = min(
        (_width - 50) / _visual_width,
        (_height - 62) / _visual_height
    );

    _scale = min(_scale,6);

    var _centre_x = _x + _width * 0.5;
    var _centre_y = _y + 36 + (_height - 36) * 0.5;

    draw_set_alpha(0.08);
    draw_set_colour(_palette.accent);
    draw_line(_centre_x - 22,_centre_y,_centre_x + 22,_centre_y);
    draw_line(_centre_x,_centre_y - 22,_centre_x,_centre_y + 22);

    draw_set_alpha(1);
    draw_set_colour(c_white);

    draw_sprite_ext(
        _sprite,0,
        _centre_x,_centre_y,
        _scale,_scale,
        0,c_white,1
    );
}

/// @description Draws an empty visual-preview box for non-projectile weapons.
function sc_debug_weapon_test_no_preview_draw(
    _delivery_name,
    _x,_y,_width,_height,
    _palette
)
{
    draw_set_alpha(0.7);
    draw_set_colour(_palette.void);
    draw_rectangle(_x,_y,_x + _width,_y + _height,false);

    draw_set_alpha(1);
    draw_set_colour(_palette.outline);
    draw_rectangle(_x,_y,_x + _width,_y + _height,true);

    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);

    draw_set_colour(_palette.muted);
    draw_text(
        _x + _width * 0.5,
        _y + _height * 0.5 - 10,
        _delivery_name + " DELIVERY"
    );

    draw_set_colour(_palette.outline);
    draw_text(
        _x + _width * 0.5,
        _y + _height * 0.5 + 14,
        "NO BAKED PROJECTILE"
    );

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

/// @description Draws the hover inspector for one registered F2 weapon.
function sc_debug_weapon_test_inspector_draw(
    _hud,
    _weapon_key,
    _x,_y,_width,_height
)
{
    var _palette = _hud.data.palette;

    draw_set_alpha(0.88);
    draw_set_colour(_palette.background);
    draw_rectangle(_x,_y,_x + _width,_y + _height,false);

    draw_set_alpha(1);
    draw_set_colour(_palette.outline);
    draw_rectangle(_x,_y,_x + _width,_y + _height,true);

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);

    draw_set_colour(_palette.core);
    draw_text(_x + 18,_y + 16,"WEAPON INSPECTOR");

    if (_weapon_key == "")
    {
        draw_set_colour(_palette.muted);
        draw_text(
            _x + 18,_y + 50,
            "HOVER A WEAPON TO INSPECT"
        );

        draw_set_alpha(0.2);
        draw_set_colour(_palette.outline);
        draw_line(
            _x + 18,_y + 80,
            _x + _width - 18,_y + 80
        );

        draw_set_alpha(1);
        draw_set_colour(_palette.muted);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);

        draw_text(
            _x + _width * 0.5,
            _y + _height * 0.5,
            "REGISTERED WEAPON DATA"
        );

        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        return;
    }

    var _weapon = variable_struct_get(
        global.data.weapons,
        _weapon_key
    );

    var _delivery = _weapon.delivery;
    var _delivery_name = sc_debug_weapon_delivery_name(_delivery.type);

    draw_set_colour(_palette.text);
    draw_text(
        _x + 18,_y + 43,
        string_upper(_weapon.identity.name)
    );

    draw_set_colour(_palette.muted);
    draw_text(
        _x + 18,_y + 66,
        _weapon_key + "  //  " + _delivery_name
    );

    var _preview_x = _x + 18;
    var _preview_y = _y + 94;
    var _preview_width = _width - 36;
    var _preview_height = 155;

    if (_delivery.type == AttackDelivery.PROJECTILE)
    {
        sc_debug_weapon_test_projectile_preview_draw(
            _delivery.projectile_key,
            _preview_x,_preview_y,
            _preview_width,_preview_height,
            _palette
        );
    }
    else
    {
        sc_debug_weapon_test_no_preview_draw(
            _delivery_name,
            _preview_x,_preview_y,
            _preview_width,_preview_height,
            _palette
        );
    }

    var _stat_x = _x + 18;
    var _stat_y = _y + 270;
    var _row = 0;
    var _row_height = 22;

    switch (_delivery.type)
    {
        case AttackDelivery.PROJECTILE:
        {
            var _projectile_data = variable_struct_get(
                global.data.projectiles,
                _delivery.projectile_key
            );

            var _projectile = _delivery.projectile;
            var _damage = _delivery.damage;
            var _guidance = variable_struct_exists(_delivery,"guidance")
                && is_struct(_delivery.guidance)
                ? "GUIDED"
                : "NONE";

            sc_debug_weapon_test_stat_draw(
                _palette,_stat_x,_stat_y + _row++ * _row_height,
                "DAMAGE",
                string(_damage.amount)
                + " // "
                + sc_debug_weapon_damage_type_name(_damage.type)
            );

            sc_debug_weapon_test_stat_draw(
                _palette,_stat_x,_stat_y + _row++ * _row_height,
                "SPEED",
                string(_projectile.speed)
            );

            sc_debug_weapon_test_stat_draw(
                _palette,_stat_x,_stat_y + _row++ * _row_height,
                "LIFETIME",
                string(_projectile.life) + " TICKS"
            );

            sc_debug_weapon_test_stat_draw(
                _palette,_stat_x,_stat_y + _row++ * _row_height,
                "SCALE",
                string(_projectile.scale)
            );

            sc_debug_weapon_test_stat_draw(
                _palette,_stat_x,_stat_y + _row++ * _row_height,
                "GUIDANCE",
                _guidance
            );

            sc_debug_weapon_test_stat_draw(
                _palette,_stat_x,_stat_y + _row++ * _row_height,
                "CLASS",
                sc_debug_weapon_projectile_class_name(
                    _projectile_data.projectile_class
                )
            );

            sc_debug_weapon_test_stat_draw(
                _palette,_stat_x,_stat_y + _row++ * _row_height,
                "MOTION",
                sc_debug_weapon_projectile_motion_name(
                    _projectile_data.projectile_motion
                )
            );
        }
        break;

        case AttackDelivery.BEAM:
{
    var _beam = _delivery.beam;

    if (variable_struct_exists(_delivery,"damage"))
    {
        var _damage = _delivery.damage;

        sc_debug_weapon_test_stat_draw(
            _palette,
            _stat_x,
            _stat_y + _row++ * _row_height,
            "DAMAGE",
            string(_damage.amount)
            + " // "
            + sc_debug_weapon_damage_type_name(_damage.type)
        );
    }

    if (variable_struct_exists(_beam,"geometry"))
    {
        var _geometry = _beam.geometry;

        if (variable_struct_exists(_geometry,"length"))
        {
            sc_debug_weapon_test_stat_draw(
                _palette,
                _stat_x,
                _stat_y + _row++ * _row_height,
                "LENGTH",
                string(_geometry.length)
            );
        }

        if (variable_struct_exists(_geometry,"radius"))
        {
            sc_debug_weapon_test_stat_draw(
                _palette,
                _stat_x,
                _stat_y + _row++ * _row_height,
                "RADIUS",
                string(_geometry.radius)
            );
        }

        if (variable_struct_exists(_geometry,"angle"))
        {
            sc_debug_weapon_test_stat_draw(
                _palette,
                _stat_x,
                _stat_y + _row++ * _row_height,
                "ANGLE",
                string(_geometry.angle)
            );
        }
    }

    if (variable_struct_exists(_beam,"behaviour"))
    {
        var _behaviour = _beam.behaviour;

        if (variable_struct_exists(_behaviour,"tick_interval"))
        {
            sc_debug_weapon_test_stat_draw(
                _palette,
                _stat_x,
                _stat_y + _row++ * _row_height,
                "TICK INTERVAL",
                string(_behaviour.tick_interval)
            );
        }

        if (variable_struct_exists(_behaviour,"growth_speed"))
        {
            sc_debug_weapon_test_stat_draw(
                _palette,
                _stat_x,
                _stat_y + _row++ * _row_height,
                "GROWTH SPEED",
                string(_behaviour.growth_speed)
            );
        }

        if (variable_struct_exists(_behaviour,"release_duration"))
        {
            sc_debug_weapon_test_stat_draw(
                _palette,
                _stat_x,
                _stat_y + _row++ * _row_height,
                "RELEASE",
                string(_behaviour.release_duration) + " TICKS"
            );
        }

        if (variable_struct_exists(_behaviour,"piercing"))
        {
            sc_debug_weapon_test_stat_draw(
                _palette,
                _stat_x,
                _stat_y + _row++ * _row_height,
                "PIERCING",
                _behaviour.piercing ? "YES" : "NO"
            );
        }

        if (variable_struct_exists(_behaviour,"blocks_on_solids"))
        {
            sc_debug_weapon_test_stat_draw(
                _palette,
                _stat_x,
                _stat_y + _row++ * _row_height,
                "BLOCKS ON SOLIDS",
                _behaviour.blocks_on_solids ? "YES" : "NO"
            );
        }

        if (variable_struct_exists(_behaviour,"max_targets"))
        {
            sc_debug_weapon_test_stat_draw(
                _palette,
                _stat_x,
                _stat_y + _row++ * _row_height,
                "MAX TARGETS",
                string(_behaviour.max_targets)
            );
        }
    }
}
break;
        case AttackDelivery.DEPLOYABLE:
        {
            if (variable_struct_exists(_delivery,"mine"))
            {
                var _mine = _delivery.mine;

                sc_debug_weapon_test_stat_draw(
                    _palette,_stat_x,_stat_y + _row++ * _row_height,
                    "ARMING",
                    string(_mine.arming_duration) + " TICKS"
                );

                sc_debug_weapon_test_stat_draw(
                    _palette,_stat_x,_stat_y + _row++ * _row_height,
                    "LIFETIME",
                    string(_mine.life_duration) + " TICKS"
                );

                sc_debug_weapon_test_stat_draw(
                    _palette,_stat_x,_stat_y + _row++ * _row_height,
                    "TRIGGER RADIUS",
                    string(_mine.trigger_radius)
                );

                sc_debug_weapon_test_stat_draw(
                    _palette,_stat_x,_stat_y + _row++ * _row_height,
                    "COLLISION",
                    string(_mine.collision_radius)
                );
            }

            if (variable_struct_exists(_delivery,"explosion"))
            {
                var _explosion = _delivery.explosion;

                sc_debug_weapon_test_stat_draw(
                    _palette,_stat_x,_stat_y + _row++ * _row_height,
                    "EXPLOSION",
                    string(_explosion.damage.amount)
                    + " // "
                    + sc_debug_weapon_damage_type_name(
                        _explosion.damage.type
                    )
                );

                if (variable_struct_exists(_explosion,"area")
                && variable_struct_exists(_explosion.area,"geometry")
                && variable_struct_exists(
                    _explosion.area.geometry,
                    "radius"
                ))
                {
                    sc_debug_weapon_test_stat_draw(
                        _palette,
                        _stat_x,
                        _stat_y + _row++ * _row_height,
                        "BLAST RADIUS",
                        string(_explosion.area.geometry.radius)
                    );
                }
            }
        }
        break;

        case AttackDelivery.AREA:
        {
            if (variable_struct_exists(_delivery,"damage"))
            {
                var _damage = _delivery.damage;

                sc_debug_weapon_test_stat_draw(
                    _palette,_stat_x,_stat_y + _row++ * _row_height,
                    "DAMAGE",
                    string(_damage.amount)
                    + " // "
                    + sc_debug_weapon_damage_type_name(_damage.type)
                );
            }

            if (variable_struct_exists(_delivery,"area"))
            {
                var _area = _delivery.area;

                if (variable_struct_exists(_area,"geometry"))
                {
                    if (variable_struct_exists(_area.geometry,"radius"))
                    {
                        sc_debug_weapon_test_stat_draw(
                            _palette,
                            _stat_x,
                            _stat_y + _row++ * _row_height,
                            "RADIUS",
                            string(_area.geometry.radius)
                        );
                    }

                    if (variable_struct_exists(_area.geometry,"length"))
                    {
                        sc_debug_weapon_test_stat_draw(
                            _palette,
                            _stat_x,
                            _stat_y + _row++ * _row_height,
                            "LENGTH",
                            string(_area.geometry.length)
                        );
                    }
                }

                if (variable_struct_exists(_area,"behaviour")
                && variable_struct_exists(
                    _area.behaviour,
                    "tick_interval"
                ))
                {
                    sc_debug_weapon_test_stat_draw(
                        _palette,
                        _stat_x,
                        _stat_y + _row++ * _row_height,
                        "TICK INTERVAL",
                        string(_area.behaviour.tick_interval)
                    );
                }
            }
        }
        break;
    }

    if (variable_struct_exists(_weapon,"shot"))
    {
        var _shot = _weapon.shot;
        var _shot_text = sc_debug_weapon_shot_pattern_name(_shot.pattern)
            + " x" + string(_shot.amount);

        sc_debug_weapon_test_stat_draw(
            _palette,
            _stat_x,
            _stat_y + _row++ * _row_height,
            "SHOT",
            _shot_text
        );
    }

    if (variable_struct_exists(_weapon,"firing"))
    {
        sc_debug_weapon_test_stat_draw(
            _palette,
            _stat_x,
            _stat_y + _row++ * _row_height,
            "FIRE INTERVAL",
            string(_weapon.firing.interval) + " TICKS"
        );
    }

    if (variable_struct_exists(_weapon,"heat"))
    {
        sc_debug_weapon_test_stat_draw(
            _palette,
            _stat_x,
            _stat_y + _row++ * _row_height,
            "HEAT",
            string(_weapon.heat.amount)
        );
    }

    draw_set_alpha(1);
    draw_set_colour(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

/// @description Creates the wider scrollable F2 weapon-testing interface.
function sc_debug_weapon_test_init(_hud)
{
    var _keys = variable_struct_get_names(global.data.weapons);
    var _weapon_buttons = [];

    var _viewport = {
        x: 34,
        y: 108,
        width: 980,
        height: 510
    };

    var _inspector = {
        x: 1046,
        y: 108,
        width: 500,
        height: 510
    };

    var _columns = 2;
    var _gap_x = 14;
    var _gap_y = 10;
    var _button_width = floor(
        (_viewport.width - _gap_x) / _columns
    );

    var _button_height = 42;
    var _row_step = _button_height + _gap_y;
    var _rows = ceil(array_length(_keys) / _columns);

    for (var _i = 0; _i < array_length(_keys); ++_i)
    {
        var _key = _keys[_i];
        var _weapon = variable_struct_get(global.data.weapons,_key);
        var _column = _i mod _columns;
        var _row = floor(_i / _columns);

        var _label = _weapon.identity.name
            + " // "
            + sc_debug_weapon_delivery_name(_weapon.delivery.type);

        array_push(
            _weapon_buttons,
            sc_gui_button_create(
                _key,
                _column * (_button_width + _gap_x),
                _row * _row_step,
                _button_width,
                _button_height,
                _label,
                GUIButtonStyle.STANDARD
            )
        );
    }

    _hud.debug_weapon_test = {
        open: false,
        width: 1580,
        height: 740,

        viewport: _viewport,
        inspector: _inspector,
        weapon_buttons: _weapon_buttons,
        content_height: max(0,_rows * _row_step - _gap_y),

        scroll: 0,
        scroll_target: 0,
        scroll_speed: _row_step,

        hover_weapon_key: "",

        buttons: {
            restore: sc_gui_button_create(
                "restore",34,665,240,42,
                "RESTORE LOADOUT",
                GUIButtonStyle.PRIMARY
            ),

            close: sc_gui_button_create(
                "close",1512,26,38,38,
                "X",
                GUIButtonStyle.DANGER
            )
        }
    };

    return true;
}

/// @description Disables the debug weapon and restores normal loadout firing.
function sc_player_debug_weapon_disable(_player)
{
    var _debug = _player.combat.debug_weapon;
    if (!_debug.enabled) return false;

    sc_player_continuous_weapon_release(_player);

    _debug.enabled = false;
    _debug.weapon_key = "";
    _debug.shot = undefined;
    _debug.firing = undefined;

    _player.combat.primary.hardpoint_cursor = 0;
    _player.combat.primary.next_fire_tick = GAME_TICK;
    return true;
}

/// @description Selects one registered weapon as the temporary debug primary.
function sc_player_debug_weapon_select(_player,_weapon_key)
{
    if (!variable_struct_exists(global.data.weapons,_weapon_key))
        return false;

    var _weapon = variable_struct_get(
        global.data.weapons,
        _weapon_key
    );

    var _debug = _player.combat.debug_weapon;
    var _interval = 10;
    var _centre_forward = 0.9;

    switch (_weapon.delivery.type)
    {
        case AttackDelivery.AREA:
            _interval = 20;
        break;

        case AttackDelivery.BEAM:
            _interval = 1;
        break;

        case AttackDelivery.DEPLOYABLE:
            _interval = 45;
            _centre_forward = 0;
        break;
    }

    sc_player_continuous_weapon_release(_player);

    _debug.enabled = true;
    _debug.weapon_key = _weapon_key;

    _debug.shot = variable_struct_exists(_weapon,"shot")
        ? variable_clone(_weapon.shot)
        : {
            pattern: ShotPattern.SINGLE,
            amount: 1,
            angle_total: 0
        };

    _debug.firing = variable_struct_exists(_weapon,"firing")
        ? variable_clone(_weapon.firing)
        : {
            mount_mode: WeaponMountMode.CENTRE,
            centre_forward: _centre_forward,
            interval: _interval,
            recoil: 0,
            muzzle_flash_duration: 0
        };

    _player.combat.primary.hardpoint_cursor = 0;
    _player.combat.primary.next_fire_tick = GAME_TICK;

    show_debug_message(
        "DEBUG WEAPON SELECTED - "
        + _weapon.identity.name
    );

    return true;
}

/// @description Opens or closes the F2 weapon-testing interface.
function sc_debug_weapon_test_toggle(_hud)
{
    var _debug = _hud.debug_weapon_test;

    if (_debug.open)
    {
        _debug.open = false;
        global.LevelState = LevelState.PLAYING;
        return true;
    }

    if (global.LevelState != LevelState.PLAYING
    || global.PlayerState != PlayerState.ACTIVE
    || !instance_exists(global.player_id))
        return false;

    _debug.open = true;
    _debug.scroll = 0;
    _debug.scroll_target = 0;
    _debug.hover_weapon_key = "";

    global.LevelState = LevelState.DEBUG;
    return true;
}

/// @description Returns whether a weapon button is fully inside the scroll viewport.
function sc_debug_weapon_test_button_visible(_debug,_button)
{
    var _draw_y = _button.y - _debug.scroll;

    return _draw_y >= 0
        && _draw_y + _button.height <= _debug.viewport.height;
}

/// @description Updates scrolling, hovering and weapon selection in the open F2 interface.
function sc_debug_weapon_test_update(_hud)
{
    var _debug = _hud.debug_weapon_test;
    if (!_debug.open) return;

    var _panel_x = floor(
        (display_get_gui_width() - _debug.width) * 0.5
    );

    var _panel_y = floor(
        (display_get_gui_height() - _debug.height) * 0.5
    );

    var _mouse_x = device_mouse_x_to_gui(0) - _panel_x;
    var _mouse_y = device_mouse_y_to_gui(0) - _panel_y;
    var _pressed = global.input.action.ui_select_pressed;
    var _player = global.player_id;
    var _viewport = _debug.viewport;

    if (sc_gui_button_update(
        _debug.buttons.close,
        _mouse_x,_mouse_y,
        _pressed
    ))
    {
        sc_debug_weapon_test_toggle(_hud);
        return;
    }

    if (sc_gui_button_update(
        _debug.buttons.restore,
        _mouse_x,_mouse_y,
        _pressed
    ))
    {
        sc_player_debug_weapon_disable(_player);
        sc_debug_weapon_test_toggle(_hud);
        return;
    }

    var _mouse_inside = point_in_rectangle(
        _mouse_x,_mouse_y,
        _viewport.x,_viewport.y,
        _viewport.x + _viewport.width,
        _viewport.y + _viewport.height
    );

    if (_mouse_inside)
    {
        var _wheel = mouse_wheel_down() - mouse_wheel_up();

        if (_wheel != 0)
            _debug.scroll_target += _wheel * _debug.scroll_speed;
    }

    var _scroll_max = max(
        0,
        _debug.content_height - _viewport.height
    );

    _debug.scroll_target = clamp(
        _debug.scroll_target,
        0,
        _scroll_max
    );

    _debug.scroll = _debug.scroll_target;
    _debug.hover_weapon_key = "";

    var _list_mouse_x = _mouse_x - _viewport.x;
    var _list_mouse_y = _mouse_y - _viewport.y + _debug.scroll;

    for (
        var _i = 0;
        _i < array_length(_debug.weapon_buttons);
        ++_i
    )
    {
        var _button = _debug.weapon_buttons[_i];

        _button.selected = _player.combat.debug_weapon.enabled
            && _player.combat.debug_weapon.weapon_key == _button.id;

        _button.hovered = false;
        _button.pressed = false;

        if (!_mouse_inside
        || !sc_debug_weapon_test_button_visible(_debug,_button))
            continue;

        var _clicked = sc_gui_button_update(
            _button,
            _list_mouse_x,
            _list_mouse_y,
            _pressed
        );

        if (_button.hovered)
            _debug.hover_weapon_key = _button.id;

        if (_clicked)
        {
            sc_player_debug_weapon_select(
                _player,
                _button.id
            );

            sc_debug_weapon_test_toggle(_hud);
            return;
        }
    }
}

/// @description Draws the wider F2 interface, hover inspector and active override status.
function sc_debug_weapon_test_draw(_hud)
{
    var _debug = _hud.debug_weapon_test;
    var _palette = _hud.data.palette;

    if (!_debug.open)
    {
        if (!instance_exists(global.player_id)
        || !global.player_id.combat.debug_weapon.enabled)
            return;

        var _key = global.player_id.combat.debug_weapon.weapon_key;
        var _weapon = variable_struct_get(
            global.data.weapons,
            _key
        );

        draw_set_alpha(1);
        draw_set_halign(fa_center);
        draw_set_valign(fa_top);
        draw_set_colour(_palette.accent);

        draw_text(
            display_get_gui_width() * 0.5,
            18,
            "DEBUG WEAPON // "
            + string_upper(_weapon.identity.name)
        );

        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        draw_set_colour(c_white);
        return;
    }

    var _viewport = _debug.viewport;
    var _inspector = _debug.inspector;
    var _width = _debug.width;
    var _height = _debug.height;

    var _x = floor(
        (display_get_gui_width() - _width) * 0.5
    );

    var _y = floor(
        (display_get_gui_height() - _height) * 0.5
    );

    draw_set_alpha(0.72);
    draw_set_colour(c_black);
    draw_rectangle(
        0,0,
        display_get_gui_width(),
        display_get_gui_height(),
        false
    );

    draw_set_alpha(0.98);
    draw_set_colour(_palette.background);
    draw_rectangle(
        _x,_y,
        _x + _width,
        _y + _height,
        false
    );

    draw_set_alpha(1);
    draw_set_colour(_palette.outline);
    draw_rectangle(
        _x,_y,
        _x + _width,
        _y + _height,
        true
    );

    draw_set_colour(_palette.accent);
    draw_line_width(
        _x + 24,_y + 78,
        _x + _width - 24,_y + 78,
        2
    );

    draw_line_width(
        _x + 24,_y + 642,
        _x + _width - 24,_y + 642,
        2
    );

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);

    draw_set_colour(_palette.core);
    draw_text(
        _x + 34,
        _y + 27,
        "DEBUG // WEAPON TESTING"
    );

    draw_set_colour(_palette.muted);
    draw_text(
        _x + 34,
        _y + 52,
        "Temporarily fire any registered weapon with unlimited resources"
        + "  //  HOVER TO INSPECT"
    );

    var _list_origin_x = _x + _viewport.x;
    var _list_origin_y = _y + _viewport.y - _debug.scroll;

    for (
        var _i = 0;
        _i < array_length(_debug.weapon_buttons);
        ++_i
    )
    {
        var _button = _debug.weapon_buttons[_i];

        if (sc_debug_weapon_test_button_visible(_debug,_button))
        {
            sc_gui_button_draw(
                _button,
                _list_origin_x,
                _list_origin_y,
                _palette
            );
        }
    }

    var _scroll_max = max(
        0,
        _debug.content_height - _viewport.height
    );

    if (_scroll_max > 0)
    {
        var _track_x = _x
            + _viewport.x
            + _viewport.width
            + 8;

        var _track_y1 = _y + _viewport.y;
        var _track_y2 = _track_y1 + _viewport.height;

        var _handle_height = max(
            44,
            _viewport.height
            * (_viewport.height / _debug.content_height)
        );

        var _handle_y = _track_y1
            + (_debug.scroll / _scroll_max)
            * (_viewport.height - _handle_height);

        draw_set_alpha(0.35);
        draw_set_colour(_palette.outline);

        draw_rectangle(
            _track_x,
            _track_y1,
            _track_x + 6,
            _track_y2,
            false
        );

        draw_set_alpha(1);
        draw_set_colour(_palette.accent);

        draw_rectangle(
            _track_x,
            _handle_y,
            _track_x + 6,
            _handle_y + _handle_height,
            false
        );
    }

    var _inspect_key = _debug.hover_weapon_key;

    // When nothing is hovered, keep the currently active debug weapon visible.
    if (_inspect_key == ""
    && global.player_id.combat.debug_weapon.enabled)
    {
        _inspect_key =
            global.player_id.combat.debug_weapon.weapon_key;
    }

    sc_debug_weapon_test_inspector_draw(
        _hud,
        _inspect_key,
        _x + _inspector.x,
        _y + _inspector.y,
        _inspector.width,
        _inspector.height
    );

    draw_set_halign(fa_left);
    draw_set_valign(fa_middle);
    draw_set_colour(_palette.text);

    draw_text(
        _x + 294,
        _y + 686,
        "REMOVE THE ACTIVE DEBUG WEAPON AND RESTORE THE SHIP LOADOUT"
    );

    sc_gui_button_draw(
        _debug.buttons.restore,
        _x,_y,
        _palette
    );

    sc_gui_button_draw(
        _debug.buttons.close,
        _x,_y,
        _palette
    );

    draw_set_alpha(1);
    draw_set_colour(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}