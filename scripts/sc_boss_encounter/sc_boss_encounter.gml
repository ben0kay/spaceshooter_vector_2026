/// @description Creates runtime data for one scrolling boss encounter.
function sc_boss_encounter_create(_owner)
{
    return {
        owner_id: _owner,
        state: BossEncounterState.WAITING,
        timer: 0,
        background_id: noone,
        wave_ids: [],
        boss_id: noone,

        arena: {
            left: 0, right: 0,
            top: 0, bottom: 0,
            margin_side: 70,
            margin_top: 80,
            margin_bottom: 120
        },

        approach: {
            duration: 180,
            scroll_speed: 4
        },

        boss: {
            key: "enemy_sim_dreadwing"
        }
    };
}

/// @description Starts the encounter after player deployment.
function sc_boss_encounter_begin(_encounter)
{
    var _camera_id = global.level.camera.camera_data.camera_id;
    var _view_x = camera_get_view_x(_camera_id);
    var _view_y = camera_get_view_y(_camera_id);
    var _view_w = camera_get_view_width(_camera_id);
    var _view_h = camera_get_view_height(_camera_id);
    var _arena = _encounter.arena;
    var _player = global.player_id;

    _arena.left = _view_x + _arena.margin_side;
    _arena.right = _view_x + _view_w - _arena.margin_side;
    _arena.top = _view_y + _arena.margin_top;
    _arena.bottom = _view_y + _view_h - _arena.margin_bottom;

    _player.x = (_arena.left + _arena.right) * 0.5;
    _player.y = _arena.bottom - 80;
    _player.movement.velocity_x = 0;
    _player.movement.velocity_y = 0;
    _player.movement.speed = 0;

    _encounter.background_id = instance_find(o_background_boss, 0);

    if (instance_exists(_encounter.background_id))
        _encounter.background_id.boss_background.target_speed = _encounter.approach.scroll_speed;

    _encounter.timer = _encounter.approach.duration;
    _encounter.state = BossEncounterState.APPROACH;

    show_debug_message("BOSS TEST - APPROACH STARTED");
}

/// @description Spawns the short pre-boss enemy wave.
function sc_boss_encounter_wave_spawn(_encounter)
{
    var _arena = _encounter.arena;
    var _centre_x = (_arena.left + _arena.right) * 0.5;
    var _spawn_y = _arena.top + 90;

    _encounter.wave_ids = [
        instance_create_layer(_centre_x - 260, _spawn_y, "Instances", o_enemy, { enemy_key: "enemy_sim_skirmisher" }),
        instance_create_layer(_centre_x, _spawn_y - 50, "Instances", o_enemy, { enemy_key: "enemy_sim_twin_fighter" }),
        instance_create_layer(_centre_x + 260, _spawn_y, "Instances", o_enemy, { enemy_key: "enemy_sim_skirmisher" })
    ];

    if (instance_exists(_encounter.background_id))
        _encounter.background_id.boss_background.target_speed = _encounter.approach.scroll_speed * 0.7;

    _encounter.state = BossEncounterState.WAVE;
    show_debug_message("BOSS TEST - ESCORT WAVE SPAWNED");
}

/// @description Returns whether any tracked encounter enemy remains alive.
function sc_boss_encounter_group_alive(_ids)
{
    for (var _i = 0; _i < array_length(_ids); _i++)
        if (instance_exists(_ids[_i])) return true;

    return false;
}

/// @description Spawns the temporary boss in the upper arena.
function sc_boss_encounter_boss_spawn(_encounter)
{
    var _arena = _encounter.arena;
    var _boss_x = (_arena.left + _arena.right) * 0.5;
    var _boss_y = _arena.top + 150;

    _encounter.boss_id = instance_create_layer(_boss_x, _boss_y, "Instances", o_enemy, {
        enemy_key: _encounter.boss.key
    });

    if (instance_exists(_encounter.background_id))
        _encounter.background_id.boss_background.target_speed = 0.8;

    _encounter.state = BossEncounterState.BOSS;
    show_debug_message("BOSS TEST - BOSS ENTERED");
}

/// @description Updates approach, escort wave, boss and victory flow.
function sc_boss_encounter_update(_encounter)
{
    if (global.LevelState != LevelState.PLAYING || !instance_exists(global.player_id)) return;

    switch (_encounter.state)
    {
        case BossEncounterState.WAITING:
            sc_boss_encounter_begin(_encounter);
        break;

        case BossEncounterState.APPROACH:
            _encounter.timer--;

            if (_encounter.timer <= 0)
                sc_boss_encounter_wave_spawn(_encounter);
        break;

        case BossEncounterState.WAVE:
            if (!sc_boss_encounter_group_alive(_encounter.wave_ids))
                sc_boss_encounter_boss_spawn(_encounter);
        break;

        case BossEncounterState.BOSS:
            if (!instance_exists(_encounter.boss_id))
            {
                if (instance_exists(_encounter.background_id))
                    _encounter.background_id.boss_background.target_speed = 0;

                _encounter.timer = 120;
                _encounter.state = BossEncounterState.VICTORY;
                show_debug_message("BOSS TEST - VICTORY");
            }
        break;

        case BossEncounterState.VICTORY:
            if (_encounter.timer > 0) _encounter.timer--;
        break;
    }
}

/// @description Confines the player collision ellipse inside the visible boss arena.
function sc_boss_encounter_player_confine(_encounter)
{
    if (_encounter.state == BossEncounterState.WAITING || !instance_exists(global.player_id)) return;

    var _player = global.player_id;
    var _movement = _player.movement;
    var _collision = _player.ship.collision;
    var _angle = _player.draw_angle;
    var _cos = dcos(_angle);
    var _sin = dsin(_angle);
    var _extent_x = sqrt(sqr(_collision.radius_forward * _cos) + sqr(_collision.radius_side * _sin));
    var _extent_y = sqrt(sqr(_collision.radius_forward * _sin) + sqr(_collision.radius_side * _cos));
    var _old_x = _player.x;
    var _old_y = _player.y;

    _player.x = clamp(_player.x, _encounter.arena.left + _extent_x, _encounter.arena.right - _extent_x);
    _player.y = clamp(_player.y, _encounter.arena.top + _extent_y, _encounter.arena.bottom - _extent_y);

    if (_player.x != _old_x) _movement.velocity_x = 0;
    if (_player.y != _old_y) _movement.velocity_y = 0;

    _movement.speed = point_distance(0, 0, _movement.velocity_x, _movement.velocity_y);
}

/// @description Draws temporary boss-test status information.
function sc_boss_encounter_draw_gui(_encounter)
{
    if (_encounter.state == BossEncounterState.WAITING) return;

    var _gui_w = display_get_gui_width();
    var _text = "";

    switch (_encounter.state)
    {
        case BossEncounterState.APPROACH: _text = "APPROACHING HOSTILE SIGNAL"; break;
        case BossEncounterState.WAVE: _text = "HOSTILE ESCORTS DETECTED"; break;
        case BossEncounterState.BOSS: _text = "SIMULANT DREADWING"; break;
        case BossEncounterState.VICTORY: _text = _encounter.timer > 0 ? "TARGET DESTROYED" : "VICTORY"; break;
    }

    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
    draw_set_colour(make_colour_rgb(45, 235, 255));
    draw_set_alpha(0.9);
    draw_text(_gui_w * 0.5, 75, _text);

    draw_set_alpha(1);
    draw_set_colour(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}