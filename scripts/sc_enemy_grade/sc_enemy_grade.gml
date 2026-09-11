/// @description Rolls one enemy grade using the configured independent chances.
function sc_enemy_grade_roll()
{
    var _grades = global.config.enemy.grades;
    var _roll = random(1);
    var _total = 0;

    for (
        var _grade = ItemGrade.PROTOTYPE;
        _grade >= ItemGrade.IMPROVED;
        --_grade
    )
    {
        _total += _grades[_grade].chance;

        if (_roll < _total)
            return _grade;
    }

    return ItemGrade.COMMON;
}

/// @description Creates permanent grade data for one enemy instance.
function sc_enemy_grade_create(_base_name)
{
    var _grade = sc_enemy_grade_roll();
    var _config = global.config.enemy.grades[_grade];
    var _graded = _grade != ItemGrade.COMMON;
    var _name = _base_name;

    if (_graded && array_length(_config.names) > 0)
        _name = _config.names[irandom(array_length(_config.names) - 1)];

    return {
        grade: _grade,
        name: _name,
        colour: sc_item_grade_colour_get(_grade),
        graded: _graded,

        defence_multiplier: _config.defence_multiplier,
        damage_multiplier: _config.damage_multiplier,

        glow_alpha: _config.glow_alpha,
        glow_scale: _config.glow_scale,
        glow_phase: random(2 * pi)
    };
}

/// @description Adds permanent grade bonuses before final enemy stats.
function sc_enemy_grade_stats_apply(_enemy)
{
    var _grade = _enemy.enemy.grade;

    if (!_grade.graded)
        return true;

    var _modifiers = _enemy.enemy.stats.modifiers.grade;

    array_push(
        _modifiers,
        {
            stat: "shield_max",
            multiply: _grade.defence_multiplier
        },
        {
            stat: "armour_max",
            multiply: _grade.defence_multiplier
        },
        {
            stat: "hull_max",
            multiply: _grade.defence_multiplier
        },
        {
            stat: "damage_multiplier",
            multiply: _grade.damage_multiplier
        }
    );

    _enemy.enemy.stats.modifiers.grade = _modifiers;
    _enemy.enemy.stats.dirty = true;

    return sc_enemy_stats_recalculate(_enemy);
}

/// @description Draws the faint grade glow behind one graded enemy.
function sc_enemy_grade_glow_draw(_enemy, _draw_x, _draw_y)
{
    var _data = _enemy.enemy;
    var _grade = _data.grade;

    if (!_grade.graded)
        return;

    var _sprite = s_particle_blur_1024;

    if (!sprite_exists(_sprite))
        return;

    var _diameter =
        _data.visual.radius
        * _grade.glow_scale;

    var _scale =
        _diameter
        / sprite_get_width(_sprite);

    var _pulse = 0.9 + sin(
        GAME_TICK * 0.025
        + _grade.glow_phase
    ) * 0.1;

    gpu_set_blendmode(bm_add);

    draw_sprite_ext(
        _sprite,
        0,
        _draw_x,
        _draw_y,
        _scale,
        _scale,
        0,
        _grade.colour,
        _grade.glow_alpha * _pulse
    );

    gpu_set_blendmode(bm_normal);
}

/// @description Draws the permanent grade name above one graded enemy.
function sc_enemy_grade_name_draw(_enemy, _draw_x, _draw_y)
{
    var _data = _enemy.enemy;
    var _grade = _data.grade;


    var _text_y =
        _draw_y
        - _data.visual.radius
        - 15;

    draw_set_halign(fa_center);
    draw_set_valign(fa_bottom);

    draw_set_colour(c_black);
    draw_set_alpha(0.7);
    draw_text(_draw_x + 1, _text_y + 1, _grade.name);

    draw_set_colour(_grade.colour);
    draw_set_alpha(0.92);
    draw_text(_draw_x, _text_y, _grade.name);

    draw_set_alpha(1);
    draw_set_colour(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}