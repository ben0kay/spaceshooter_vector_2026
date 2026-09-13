/// @description Returns the readable name of one recorded statistic key.
function sc_inventory_statistics_name_get(_category,_key)
{
    switch (_category)
    {
        case "kills_by_faction":
        {
            var _value = real(_key);

            if (_value >= 0
            && _value < array_length(global.data.factions)
            && !is_undefined(global.data.factions[_value]))
                return string_upper(global.data.factions[_value].identity.name);
        }
        break;

        case "kills_by_enemy":
        {
            if (variable_struct_exists(global.data.enemies,_key))
                return string_upper(
                    variable_struct_get(global.data.enemies,_key).identity.name
                );
        }
        break;

        case "kills_by_class":
        {
            var _value = real(_key);

            switch (_value)
            {
                case EnemyClass.TINY:       return "TINY";
                case EnemyClass.LIGHT:      return "LIGHT";
                case EnemyClass.STANDARD:   return "STANDARD";
                case EnemyClass.HEAVY:      return "HEAVY";
                case EnemyClass.SUPERHEAVY: return "SUPERHEAVY";
                case EnemyClass.CAPITAL:    return "CAPITAL";
                case EnemyClass.TITAN:      return "TITAN";
            }
        }
        break;

        case "kills_by_rank":
        {
            var _value = real(_key);

            switch (_value)
            {
                case EnemyRank.COMMON:   return "COMMON";
                case EnemyRank.VETERAN:  return "VETERAN";
                case EnemyRank.ELITE:    return "ELITE";
                case EnemyRank.CHAMPION: return "CHAMPION";
                case EnemyRank.MINIBOSS: return "MINIBOSS";
                case EnemyRank.BOSS:     return "BOSS";
            }
        }
        break;

        case "kills_by_grade":
            return string_upper(
                sc_item_grade_name_get(real(_key))
            );

        case "resources_collected":
        case "derelict_items_looted":
        {
            if (variable_struct_exists(global.data.items,_key))
                return string_upper(
                    variable_struct_get(global.data.items,_key).identity.name
                );
        }
        break;

        case "asteroids_by_material":
        {
            if (variable_struct_exists(global.data.asteroids,_key))
                return string_upper(
                    variable_struct_get(global.data.asteroids,_key).identity.name
                );
        }
        break;

        case "asteroids_by_size":
        {
            var _value = real(_key);

            switch (_value)
            {
                case AsteroidSize.SMALL:  return "SMALL";
                case AsteroidSize.MEDIUM: return "MEDIUM";
                case AsteroidSize.LARGE:  return "LARGE";
                case AsteroidSize.HUGE:   return "HUGE";
            }
        }
        break;

        case "derelicts_by_key":
        {
            if (variable_struct_exists(global.data.structures,_key))
                return string_upper(
                    variable_struct_get(global.data.structures,_key).identity.name
                );
        }
        break;
    }

    return string_upper(
        string_replace_all(_key,"_"," ")
    );
}

/// @description Returns one category as entries sorted from highest to lowest.
function sc_inventory_statistics_entries_get(_category)
{
    if (!variable_struct_exists(global.profile.statistics,_category))
        return [];

    var _counters = variable_struct_get(global.profile.statistics,_category);
    var _keys = variable_struct_get_names(_counters);
    var _entries = [];

    for (var _i = 0; _i < array_length(_keys); ++_i)
    {
        var _key = _keys[_i];

        array_push(_entries,{
            key: _key,
            value: variable_struct_get(_counters,_key)
        });
    }

    for (var _i = 1; _i < array_length(_entries); ++_i)
    {
        var _entry = _entries[_i];
        var _j = _i - 1;

        while (_j >= 0 && _entries[_j].value < _entry.value)
        {
            _entries[_j + 1] = _entries[_j];
            --_j;
        }

        _entries[_j + 1] = _entry;
    }

    return _entries;
}

/// @description Draws one statistics section title.
function sc_inventory_statistics_heading_draw(_x,_y,_width,_title,_palette)
{
    draw_set_halign(fa_left);
    draw_set_colour(_palette.accent);
    draw_set_alpha(1);
    draw_text(_x,_y,_title);

    draw_set_alpha(0.45);
    draw_line(_x,_y + 23,_x + _width,_y + 23);

    return _y + 36;
}

/// @description Draws one statistic label and counter.
function sc_inventory_statistics_row_draw(_x,_y,_width,_label,_value,_palette)
{
    draw_set_halign(fa_left);
    draw_set_colour(_palette.muted);
    draw_set_alpha(0.9);
    draw_text(_x,_y,_label);

    draw_set_halign(fa_right);
    draw_set_colour(_palette.core);
    draw_set_alpha(1);
    draw_text(_x + _width,_y,string(_value));

    return _y + 25;
}

/// @description Draws one dynamically populated statistics category.
function sc_inventory_statistics_category_draw(
    _x,_y,_width,_title,_category,_max_rows,_palette
)
{
    _y = sc_inventory_statistics_heading_draw(
        _x,_y,_width,_title,_palette
    );

    var _entries = sc_inventory_statistics_entries_get(_category);
    var _count = array_length(_entries);

    if (_count <= 0)
    {
        draw_set_halign(fa_left);
        draw_set_colour(_palette.muted);
        draw_set_alpha(0.55);
        draw_text(_x,_y,"NO RECORDS");
        return _y + 25;
    }

    var _shown = min(_count,_max_rows);

    for (var _i = 0; _i < _shown; ++_i)
    {
        var _entry = _entries[_i];

        _y = sc_inventory_statistics_row_draw(
            _x,
            _y,
            _width,
            sc_inventory_statistics_name_get(_category,_entry.key),
            _entry.value,
            _palette
        );
    }

    if (_count > _shown)
    {
        draw_set_halign(fa_left);
        draw_set_colour(_palette.muted);
        draw_set_alpha(0.55);
        draw_text(_x,_y,"+ " + string(_count - _shown) + " MORE RECORDS");
        _y += 25;
    }

    return _y;
}

/// @description Draws the persistent player statistics interface.
function sc_inventory_statistics_draw(_hud,_origin_x,_origin_y)
{
    var _data = _hud.data.inventory;
    var _palette = _hud.data.palette;

    var _top = _origin_y + 184;
    var _left = _origin_x + 54;
    var _column_width = 440;
    var _gap = 62;

    var _middle = _left + _column_width + _gap;
    var _right = _middle + _column_width + _gap;

    draw_set_colour(_palette.background);
    draw_set_alpha(0.98);
    draw_rectangle(
        _origin_x + 32,
        _origin_y + 155,
        _origin_x + _data.width - 32,
        _origin_y + _data.height - 24,
        false
    );

    draw_set_colour(_palette.outline);
    draw_set_alpha(0.7);
    draw_rectangle(
        _origin_x + 32,
        _origin_y + 155,
        _origin_x + _data.width - 32,
        _origin_y + _data.height - 24,
        true
    );

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_colour(_palette.core);
    draw_set_alpha(1);
    draw_text(_left,_top,"PERSISTENT OPERATIONS RECORD");

    draw_set_colour(_palette.muted);
    draw_set_alpha(0.65);
    draw_text(
        _left,
        _top + 27,
        "CAREER STATISTICS RECORDED ACROSS COMPLETED OPERATIONS"
    );

    var _y = _top + 68;

    _y = sc_inventory_statistics_heading_draw(
        _left,_y,_column_width,"CAREER SUMMARY",_palette
    );

    _y = sc_inventory_statistics_row_draw(
        _left,_y,_column_width,
        "ENEMIES DESTROYED",
        sc_player_statistics_get("totals","enemies_killed"),
        _palette
    );

    _y = sc_inventory_statistics_row_draw(
        _left,_y,_column_width,
        "GRADED ENEMIES DESTROYED",
        sc_player_statistics_get("totals","graded_enemies_killed"),
        _palette
    );

    _y = sc_inventory_statistics_row_draw(
        _left,_y,_column_width,
        "ASTEROIDS DESTROYED",
        sc_player_statistics_get("totals","asteroids_destroyed"),
        _palette
    );

    _y = sc_inventory_statistics_row_draw(
        _left,_y,_column_width,
        "RESOURCES RECOVERED",
        sc_player_statistics_get("totals","resources_collected"),
        _palette
    );

    _y = sc_inventory_statistics_row_draw(
        _left,_y,_column_width,
        "DERELICTS LOOTED",
        sc_player_statistics_get("totals","derelicts_looted"),
        _palette
    );

    _y = sc_inventory_statistics_row_draw(
        _left,_y,_column_width,
        "DERELICT ITEMS RECOVERED",
        sc_player_statistics_get("totals","derelict_items_looted"),
        _palette
    );

    _y += 28;

    _y = sc_inventory_statistics_category_draw(
        _left,_y,_column_width,
        "KILLS BY FACTION",
        "kills_by_faction",
        6,
        _palette
    );

    _y += 28;

    sc_inventory_statistics_category_draw(
        _left,_y,_column_width,
        "KILLS BY RANK",
        "kills_by_rank",
        6,
        _palette
    );

    _y = _top + 68;

    _y = sc_inventory_statistics_category_draw(
        _middle,_y,_column_width,
        "SHIPS DESTROYED",
        "kills_by_enemy",
        12,
        _palette
    );

    _y += 28;

    sc_inventory_statistics_category_draw(
        _middle,_y,_column_width,
        "KILLS BY SHIP CLASS",
        "kills_by_class",
        7,
        _palette
    );

    _y = _top + 68;

    _y = sc_inventory_statistics_category_draw(
        _right,_y,_column_width,
        "RESOURCES RECOVERED",
        "resources_collected",
        8,
        _palette
    );

    _y += 28;

    _y = sc_inventory_statistics_category_draw(
        _right,_y,_column_width,
        "ASTEROID MATERIALS DESTROYED",
        "asteroids_by_material",
        7,
        _palette
    );

    _y += 28;

    sc_inventory_statistics_category_draw(
        _right,_y,_column_width,
        "DERELICTS EXPLORED",
        "derelicts_by_key",
        5,
        _palette
    );

    draw_set_alpha(1);
    draw_set_colour(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}