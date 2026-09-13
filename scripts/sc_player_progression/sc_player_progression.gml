/*
PLAYER PROGRESSION

Stores persistent player level, experience and upgrade currency.
Gameplay systems award experience through reusable semantic helpers.
*/

/// @description Creates clean persistent player-progression data.
function sc_player_progression_default()
{
    return {
        level: 1,
        experience: 0,
        data_shards: 0,
        upgrade_ranks: {}
    };
}

/// @description Returns the experience needed to advance from one level.
function sc_player_level_experience_required(_level)
{
    _level = max(1,floor(_level));
    return round(100 * power(_level,1.35));
}

/// @description Returns normalized progress towards the next level.
function sc_player_level_progress_get()
{
    var _progression = global.profile.progression;
    var _required = sc_player_level_experience_required(_progression.level);

    return {
        current: _progression.experience,
        required: _required,
        ratio: clamp(_progression.experience / _required,0,1)
    };
}

/// @description Grants persistent Data Shards directly to the player.
function sc_player_data_shards_grant(_amount)
{
    _amount = max(0,floor(_amount));
    if (_amount <= 0) return false;

    global.profile.progression.data_shards += _amount;
    return true;
}

/// @description Processes one player level increase and its reward.
function sc_player_level_up()
{
    var _progression = global.profile.progression;
    _progression.level++;
    _progression.data_shards++;

    if (instance_exists(global.player_id))
    {
        sc_world_feedback_create(
            global.player_id.x,
            global.player_id.y - 48,
            global.player_id.layer,
            "LEVEL " + string(_progression.level) + "  //  +1 DATA SHARD",
            make_colour_rgb(185,100,255),
            1.25
        );
    }

    // Insert player level-up audio here later.
    // Insert level-up particle burst here later.
    return true;
}

/// @description Grants experience and processes every resulting level.
function sc_player_experience_grant(_amount)
{
    _amount = max(0,round(_amount));
    if (_amount <= 0) return 0;

    var _progression = global.profile.progression;
    var _levels_gained = 0;

    _progression.experience += _amount;

    while (_progression.experience
    >= sc_player_level_experience_required(_progression.level))
    {
        _progression.experience -=
            sc_player_level_experience_required(_progression.level);

        sc_player_level_up();
        _levels_gained++;
    }

    return _levels_gained;
}

/// @description Calculates and grants experience for one player enemy kill.
function sc_player_experience_enemy_grant(_enemy)
{
    var _data = _enemy.enemy;
    var _experience = max(
        1,
        round(_data.identity.threat_value * 10)
    );

    _experience = round(
        _experience
        * _data.grade.reward_multiplier
    );

    sc_player_experience_grant(_experience);

    sc_world_feedback_create(
        _enemy.x,
        _enemy.y + 22,
        _enemy.layer,
        "+" + string(_experience) + " XP",
        make_colour_rgb(180,105,255),
        0.85
    );

    return _experience;
}