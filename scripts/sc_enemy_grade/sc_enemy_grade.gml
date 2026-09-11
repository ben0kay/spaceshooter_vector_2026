/// @description Returns the reusable callsign pool belonging to one grade.
function sc_enemy_grade_name_pool_get(_grade)
{
    static _common = [];

    static _improved = [
        "Ashrunner",
        "Wayfarer",
        "Deadeye",
        "Ember"
    ];

    static _advanced = [
        "Black Talon",
        "Apex",
        "Vanguard",
        "Nightblade"
    ];

    static _superior = [
        "Severance",
        "Requiem",
        "Nemesis",
        "Starreaver"
    ];

    static _prototype = [
        "Eidolon",
        "Terminus",
        "Ascendant",
        "Singularity"
    ];

    switch (_grade)
    {
        case ItemGrade.IMPROVED: return _improved;
        case ItemGrade.ADVANCED: return _advanced;
        case ItemGrade.SUPERIOR: return _superior;
        case ItemGrade.PROTOTYPE: return _prototype;
    }

    return _common;
}

/// @description Returns a reusable Rebel owner pool belonging to one grade.
function sc_enemy_grade_rebel_owner_pool_get(_grade)
{
    static _improved = [
        "Harlan",
        "Mara",
        "Cale",
        "Bren"
    ];

    static _advanced = [
        "Razor",
        "Vex",
        "Kestrel",
        "Rourke"
    ];

    static _superior = [
        "Havoc",
        "Wraith",
        "Mordecai",
        "Calder"
    ];

    static _prototype = [
        "Lazarus",
        "Eidolon",
        "Sovereign",
        "The Architect"
    ];

    switch (_grade)
    {
        case ItemGrade.IMPROVED: return _improved;
        case ItemGrade.ADVANCED: return _advanced;
        case ItemGrade.SUPERIOR: return _superior;
        case ItemGrade.PROTOTYPE: return _prototype;
    }

    return _improved;
}

/// @description Creates a faction-styled name while preserving the real ship name.
function sc_enemy_grade_name_create(_base_name, _faction, _grade)
{
    var _names = sc_enemy_grade_name_pool_get(_grade);
    var _name = _names[irandom(array_length(_names) - 1)];

    switch (_faction)
    {
        case Faction.REBEL:
        {
            var _owners = sc_enemy_grade_rebel_owner_pool_get(_grade);
            var _owner = _owners[irandom(array_length(_owners) - 1)];

            return _owner + "'s " + _base_name;
        }

        case Faction.CORPORATION:
        {
            if (_grade == ItemGrade.PROTOTYPE)
                return "Prototype " + _base_name + " \"" + string_upper(_name) + "\"";

            return _base_name + " \"" + string_upper(_name) + "\"";
        }

        case Faction.SIMULANT:
        {
            if (_grade == ItemGrade.PROTOTYPE)
                return _base_name + " // PROTOTYPE-" + string_upper(_name);

            return _base_name + " // " + string_upper(_name);
        }

        case Faction.AUTOMATED:
        {
            return _base_name
                + " // "
                + string_upper(_name)
                + "-"
                + string(irandom_range(10, 99));
        }

        case Faction.ALIEN:
        {
            return _base_name + " \"" + _name + "\"";
        }
    }

    return _base_name + " \"" + _name + "\"";
}

/// @description Rolls one enemy grade after applying its rank chance multiplier.
function sc_enemy_grade_roll(_rank)
{
    var _grades = global.config.enemy.grades;
    var _rank_multiplier =
        global.config.enemy.grade.rank_chance_multiplier[_rank];

    if (_rank_multiplier <= 0)
        return ItemGrade.COMMON;

    var _roll = random(1);
    var _total = 0;

    for (
        var _grade = ItemGrade.PROTOTYPE;
        _grade >= ItemGrade.IMPROVED;
        --_grade
    )
    {
        _total +=
            _grades[_grade].chance
            * _rank_multiplier;

        if (_roll < _total)
            return _grade;
    }

    return ItemGrade.COMMON;
}

/// @description Creates permanent grade data for one enemy instance.
function sc_enemy_grade_create(_base_name, _faction, _rank)
{
    var _grade = sc_enemy_grade_roll(_rank);
    var _config = global.config.enemy.grades[_grade];
    var _graded = _grade != ItemGrade.COMMON;

    var _name = _graded
        ? sc_enemy_grade_name_create(_base_name, _faction, _grade)
        : _base_name;

    return {
        grade: _grade,
        name: _name,
        colour: sc_item_grade_colour_get(_grade),
        graded: _graded,

        defence_multiplier: _config.defence_multiplier,
        damage_multiplier: _config.damage_multiplier,
        reward_multiplier: _config.reward_multiplier,

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

    var _modifiers =
        _enemy.enemy.stats.modifiers.grade;

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

    _enemy.enemy.stats.modifiers.grade =
        _modifiers;

    _enemy.enemy.stats.dirty = true;

    return sc_enemy_stats_recalculate(_enemy);
}

/// @description Draws the faint grade glow behind one graded enemy.
function sc_enemy_grade_glow_draw(_enemy, _draw_x, _draw_y)
{
    var _data = _enemy.enemy;
    var _grade = _data.grade;
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

/// @description Draws a distance-faded grade name above one graded enemy.
function sc_enemy_grade_name_draw(_enemy, _draw_x, _draw_y)
{
    if (!instance_exists(global.player_id))
        return;

    var _data = _enemy.enemy;
    var _grade = _data.grade;
    var _config = global.config.enemy.grade;

    var _distance = point_distance(
        _enemy.x,
        _enemy.y,
        global.player_id.x,
        global.player_id.y
    );

    if (_distance >= _config.name_distance_max)
        return;

    var _alpha = 1 - clamp(
        (_distance - _config.name_distance_full)
        / (_config.name_distance_max - _config.name_distance_full),
        0,
        1
    );

    var _text_y =
        _draw_y
        - _data.visual.radius
        - 15;

    draw_set_halign(fa_center);
    draw_set_valign(fa_bottom);

    draw_set_colour(c_black);
    draw_set_alpha(0.7 * _alpha);
    draw_text(_draw_x + 1, _text_y + 1, _grade.name);

    draw_set_colour(_grade.colour);
    draw_set_alpha(0.92 * _alpha);
    draw_text(_draw_x, _text_y, _grade.name);

    draw_set_alpha(1);
    draw_set_colour(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}