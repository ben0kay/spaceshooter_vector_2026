/*
TOP HUD BANNER

Shared top-centre presenter for enemy inspection, major alerts and discoveries.
Enemy inspection is implemented first. Other modes can use the same frame later.
*/

/// @description Initializes the shared top-centre HUD banner.
function sc_hud_top_banner_init(_hud)
{
    _hud.top_banner = {
        mode: HudTopBannerMode.NONE,
        target_id: noone,
        alpha: 0,

        forced_target_id: noone,
        next_forced_scan_tick: GAME_TICK,

        message: undefined,
        queue: []
    };

    return true;
}

/// @description Returns whether an enemy may currently appear in the top banner.
function sc_hud_top_banner_enemy_valid(_enemy)
{
    return instance_exists(_enemy)
        && _enemy.initialized
        && _enemy.enemy.state != EnemyState.DEAD;
}

/// @description Returns the closest visible enemy matching one rank.
function sc_hud_top_banner_rank_target_find(_rank)
{
    if (!instance_exists(global.player_id))
        return noone;

    var _selected = noone;
    var _selected_distance_sq = infinity;
    var _count = instance_number(o_enemy);

    for (var _i = 0; _i < _count; _i++)
    {
        var _enemy = instance_find(o_enemy, _i);

        if (!sc_hud_top_banner_enemy_valid(_enemy)
        || _enemy.enemy.identity.rank != _rank
        || !sc_optimization_circle_visible(
            _enemy.x,
            _enemy.y,
            _enemy.enemy.visual.radius,
            24
        ))
            continue;

        var _dx = _enemy.x - global.player_id.x;
        var _dy = _enemy.y - global.player_id.y;
        var _distance_sq = _dx * _dx + _dy * _dy;

        if (_distance_sq >= _selected_distance_sq)
            continue;

        _selected = _enemy;
        _selected_distance_sq = _distance_sq;
    }

    return _selected;
}

/// @description Refreshes the forced boss or miniboss banner target.
function sc_hud_top_banner_forced_target_update(_hud)
{
    var _banner = _hud.top_banner;
    var _config = _hud.data.top_banner;

    if (GAME_TICK < _banner.next_forced_scan_tick
    && sc_hud_top_banner_enemy_valid(_banner.forced_target_id)
    && sc_optimization_circle_visible(
        _banner.forced_target_id.x,
        _banner.forced_target_id.y,
        _banner.forced_target_id.enemy.visual.radius,
        24
    ))
        return _banner.forced_target_id;

    _banner.next_forced_scan_tick =
        GAME_TICK + _config.scan_interval;

    var _target = sc_hud_top_banner_rank_target_find(
        EnemyRank.BOSS
    );

    if (!instance_exists(_target))
    {
        _target = sc_hud_top_banner_rank_target_find(
            EnemyRank.MINIBOSS
        );
    }

    _banner.forced_target_id = _target;
    return _target;
}

/// @description Returns a living enemy underneath or slightly beside the mouse.
function sc_hud_top_banner_hover_target_get(_hud)
{
    if (global.PlayerState != PlayerState.ACTIVE)
        return noone;

    var _enemy = collision_circle(
        mouse_x,
        mouse_y,
        _hud.data.top_banner.hover_padding,
        o_enemy,
        false,
        true
    );

    return sc_hud_top_banner_enemy_valid(_enemy)
        ? _enemy
        : noone;
}

/// @description Selects the highest-priority enemy inspection target.
function sc_hud_top_banner_enemy_target_get(_hud)
{
    var _forced = sc_hud_top_banner_forced_target_update(_hud);

    if (sc_hud_top_banner_enemy_valid(_forced))
        return _forced;

    return sc_hud_top_banner_hover_target_get(_hud);
}

/// @description Updates enemy selection and banner fading.
function sc_hud_top_banner_update(_hud)
{
    var _banner = _hud.top_banner;
    var _config = _hud.data.top_banner;
    var _target = sc_hud_top_banner_enemy_target_get(_hud);

    if (sc_hud_top_banner_enemy_valid(_target))
    {
        _banner.mode = HudTopBannerMode.ENEMY;
        _banner.target_id = _target;
        _banner.alpha = min(
            1,
            _banner.alpha + _config.fade_in_speed
        );

        return;
    }

    _banner.alpha = max(
        0,
        _banner.alpha - _config.fade_out_speed
    );

    if (_banner.alpha <= 0)
    {
        _banner.alpha = 0;
        _banner.mode = HudTopBannerMode.NONE;
        _banner.target_id = noone;
    }
}

/// @description Draws the angular shared top-banner frame.
function sc_hud_top_banner_frame_draw(
    _x,
    _y,
    _width,
    _height,
    _alpha,
    _config,
    _palette
)
{
    var _cut = _config.cut;

    draw_primitive_begin(pr_trianglefan);
    draw_vertex_colour(
        _x + _width * 0.5,
        _y + _height * 0.5,
        _palette.background,
        _alpha * _config.background_alpha
    );

    draw_vertex_colour(_x + _cut, _y, _palette.panel, _alpha);
    draw_vertex_colour(_x + _width - _cut, _y, _palette.panel, _alpha);
    draw_vertex_colour(_x + _width, _y + _cut, _palette.panel, _alpha);
    draw_vertex_colour(_x + _width, _y + _height - _cut, _palette.panel, _alpha);
    draw_vertex_colour(_x + _width - _cut, _y + _height, _palette.panel, _alpha);
    draw_vertex_colour(_x + _cut, _y + _height, _palette.panel, _alpha);
    draw_vertex_colour(_x, _y + _height - _cut, _palette.panel, _alpha);
    draw_vertex_colour(_x, _y + _cut, _palette.panel, _alpha);
    draw_vertex_colour(_x + _cut, _y, _palette.panel, _alpha);
    draw_primitive_end();

    draw_set_colour(_palette.outline);
    draw_set_alpha(_alpha * _config.outline_alpha);

    draw_line_width(_x + _cut, _y, _x + _width - _cut, _y, 2);
    draw_line_width(_x + _width - _cut, _y, _x + _width, _y + _cut, 2);
    draw_line_width(_x + _width, _y + _cut, _x + _width, _y + _height - _cut, 2);
    draw_line_width(_x + _width, _y + _height - _cut, _x + _width - _cut, _y + _height, 2);
    draw_line_width(_x + _width - _cut, _y + _height, _x + _cut, _y + _height, 2);
    draw_line_width(_x + _cut, _y + _height, _x, _y + _height - _cut, 2);
    draw_line_width(_x, _y + _height - _cut, _x, _y + _cut, 2);
    draw_line_width(_x, _y + _cut, _x + _cut, _y, 2);

    draw_set_colour(_palette.accent);
    draw_set_alpha(_alpha * 0.95);
    draw_line_width(_x + 24, _y + 4, _x + 126, _y + 4, 2);
    draw_line_width(_x + _width - 126, _y + 4, _x + _width - 24, _y + 4, 2);
}

/// @description Returns a curved panel width based on the enemy's strongest defence layer.
function sc_hud_top_banner_enemy_width_get(_enemy, _config)
{
    var _defence = _enemy.enemy.defence;
    var _largest = max(
        _defence.shield.maximum,
        _defence.armour.maximum,
        _defence.hull.maximum
    );

    var _capacity = _config.capacity;
    var _minimum_log = log10(_capacity.hp_min);
    var _maximum_log = log10(_capacity.hp_max);
    var _value_log = log10(clamp(_largest, _capacity.hp_min, _capacity.hp_max));
    var _ratio = (_value_log - _minimum_log) / max(0.001, _maximum_log - _minimum_log);

    return round(lerp(
        _capacity.panel_min_width,
        _capacity.panel_max_width,
        _ratio
    ));
}

/// @description Draws one continuous enemy defence bar.
function sc_hud_top_banner_bar_draw(
    _x, _y, _width, _height, _label,
    _current, _maximum, _colour, _alpha, _config, _palette
)
{
    var _ratio = _maximum > 0 ? clamp(_current / _maximum, 0, 1) : 0;
    var _label_width = 72;
    var _value_width = 54;
    var _bar_x = _x + _label_width;
    var _bar_width = _width - _label_width - _value_width;
    var _bar_top = _y + 3;
    var _bar_bottom = _y + _height - 3;
    var _fill_width = _bar_width * _ratio;

    draw_set_halign(fa_left);
    draw_set_valign(fa_middle);
    draw_set_colour(_palette.text);
    draw_set_alpha(_alpha * 0.9);
    draw_text(_x, _y + _height * 0.5, _label);

    draw_set_colour(_palette.panel_light);
    draw_set_alpha(_alpha * _config.empty_alpha);
    draw_rectangle(
        _bar_x,
        _bar_top,
        _bar_x + _bar_width,
        _bar_bottom,
        false
    );

    if (_fill_width > 0)
    {
        draw_set_colour(_colour);
        draw_set_alpha(_alpha * 0.9);
        draw_rectangle(
            _bar_x,
            _bar_top,
            _bar_x + _fill_width,
            _bar_bottom,
            false
        );

        draw_set_colour(_palette.core);
        draw_set_alpha(_alpha * 0.22);
        draw_rectangle(
            _bar_x,
            _bar_top,
            _bar_x + _fill_width,
            _bar_top + 2,
            false
        );
    }

    draw_set_halign(fa_right);
    draw_set_colour(_palette.core);
    draw_set_alpha(_alpha * 0.95);
    draw_text(
        _x + _width,
        _y + _height * 0.5,
        string(round(_ratio * 100)) + "%"
    );
}

/// @description Draws live faction-coloured enemy information inside the shared banner.
function sc_hud_top_banner_enemy_draw(_hud, _enemy, _x, _y, _width, _alpha)
{
    var _data = _enemy.enemy;
    var _defence = _data.defence;
    var _config = _hud.data.top_banner;
    var _palette = _hud.data.palette;
    var _faction_palette = _data.visual.palette;

    var _shield_colour = _faction_palette.energy;
    var _armour_colour = _faction_palette.accent;
    var _hull_colour = merge_colour(_faction_palette.glow, _faction_palette.accent, 0.4);

    var _current_total = _defence.shield.current
        + _defence.armour.current
        + _defence.hull.current;

    var _maximum_total = _defence.shield.maximum
        + _defence.armour.maximum
        + _defence.hull.maximum;

    var _total_ratio = _maximum_total > 0 ? _current_total / _maximum_total : 0;
    var _bar_x = _x + 22;
    var _bar_width = _width - 44;

    draw_set_valign(fa_middle);
    draw_set_halign(fa_left);
    draw_set_colour(_data.grade.colour);
    draw_set_alpha(_alpha);
    draw_text(_x + 22, _y + 19, string_upper(_data.grade.name));

    draw_set_halign(fa_right);
    draw_set_colour(_palette.text);
    draw_set_alpha(_alpha * 0.9);
    draw_text(_x + _width - 22, _y + 19, string(round(_total_ratio * 100)) + "%");

    sc_hud_top_banner_bar_draw(
        _bar_x, _y + 34, _bar_width, 17, "SHIELD",
        _defence.shield.current, _defence.shield.maximum,
        _shield_colour, _alpha, _config, _palette
    );

    sc_hud_top_banner_bar_draw(
        _bar_x, _y + 55, _bar_width, 17, "ARMOUR",
        _defence.armour.current, _defence.armour.maximum,
        _armour_colour, _alpha, _config, _palette
    );

    sc_hud_top_banner_bar_draw(
        _bar_x, _y + 76, _bar_width, 17, "HULL",
        _defence.hull.current, _defence.hull.maximum,
        _hull_colour, _alpha, _config, _palette
    );
}

/// @description Draws the currently presented top-centre HUD banner.
function sc_hud_top_banner_draw(_hud)
{
    var _banner = _hud.top_banner;
    if (_banner.mode == HudTopBannerMode.NONE || _banner.alpha <= 0) return;

    var _config = _hud.data.top_banner;
    var _palette = _hud.data.palette;
    var _width = _config.width;

    if (_banner.mode == HudTopBannerMode.ENEMY
    && sc_hud_top_banner_enemy_valid(_banner.target_id))
        _width = sc_hud_top_banner_enemy_width_get(_banner.target_id, _config);

    var _x = floor((display_get_gui_width() - _width) * 0.5);
    var _y = floor(_config.y + (1 - _banner.alpha) * -12);

    sc_hud_top_banner_frame_draw(
        _x, _y, _width, _config.height,
        _banner.alpha, _config, _palette
    );

    switch (_banner.mode)
    {
        case HudTopBannerMode.ENEMY:
            if (sc_hud_top_banner_enemy_valid(_banner.target_id))
            {
                sc_hud_top_banner_enemy_draw(
                    _hud, _banner.target_id,
                    _x, _y, _width, _banner.alpha
                );
            }
        break;

        // ALERT and DISCOVERY use the default configured width later.
    }

    draw_set_alpha(1);
    draw_set_colour(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}