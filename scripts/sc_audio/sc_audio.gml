#region CONFIGURATION

/// @description Creates centralized audio tuning values.
function sc_audio_config_create()
{
    return {
        enabled: true,
        master_volume: 1,
        active_maximum: 48,
        cleanup_interval: 8,

        category_volume: [
            1,
            1,
            0.9,
            0.75,
            0.8
        ],

        defaults: {
            priority: 40,
            instance_maximum: 4,
            cooldown: 0,
            falloff_reference: 320,
            falloff_maximum: 1400,
            falloff_factor: 1
        },

        weapon: {
            player_priority: 80,
            world_priority: 45,
            instance_maximum: 6,
            cooldown: 0,
            falloff_reference: 280,
            falloff_maximum: 1200,
            falloff_factor: 1
        }
    };
}

#endregion

#region INITIALIZATION

/// @description Initializes the global audio runtime.
function sc_audio_init()
{
    GCFG.audio = sc_audio_config_create();

    global.audio = {
        initialized: true,
        active: [],
        cooldowns: {},
        paused: false,
        cleanup_tick: 0,
        listener_x: 0,
        listener_y: 0
    };

    audio_listener_position(0,0,0);
    return true;
}

/// @description Stops managed audio and releases its runtime data.
function sc_audio_cleanup()
{
    if (!variable_global_exists("audio")
    || !is_struct(global.audio))
        return;

    var _active = global.audio.active;

    for (var _i = array_length(_active) - 1; _i >= 0; --_i)
    {
        var _handle = _active[_i].handle;

        if (audio_is_playing(_handle))
            audio_stop_sound(_handle);
    }

    global.audio.active = [];
    global.audio.cooldowns = {};
    global.audio.initialized = false;
}

#endregion

#region VALUES

/// @description Returns an optional struct value or its fallback.
function sc_audio_value_get(_data, _name, _fallback)
{
    return is_struct(_data)
    && variable_struct_exists(_data,_name)
        ? variable_struct_get(_data,_name)
        : _fallback;
}

/// @description Returns the final gain belonging to an audio category.
function sc_audio_gain_get(_category, _volume)
{
    var _category_volume = 1;
    var _volumes = GCFG.audio.category_volume;

    if (_category >= 0
    && _category < array_length(_volumes))
        _category_volume = _volumes[_category];

    return clamp(
        _volume
        * _category_volume
        * GCFG.audio.master_volume,
        0,
        1
    );
}

/// @description Returns a randomized pitch using a symmetric range.
function sc_audio_pitch_get(_range)
{
    return max(
        0.01,
        1 + random_range(-abs(_range),abs(_range))
    );
}

#endregion

#region ACTIVE SOUNDS

/// @description Removes finished sound handles from the managed array.
function sc_audio_active_cleanup()
{
    var _active = global.audio.active;

    for (var _i = array_length(_active) - 1; _i >= 0; --_i)
    {
        if (!audio_is_playing(_active[_i].handle))
            array_delete(_active,_i,1);
    }
}

/// @description Counts active sounds sharing one concurrency key.
function sc_audio_active_count(_key)
{
    var _active = global.audio.active;
    var _count = 0;

    for (var _i = 0; _i < array_length(_active); ++_i)
    {
        if (_active[_i].key == _key)
            _count += 1;
    }

    return _count;
}

/// @description Removes the lowest-priority sound when a stronger request needs room.
function sc_audio_voice_reserve(_priority)
{
    var _active = global.audio.active;
    var _maximum = GCFG.audio.active_maximum;

    if (array_length(_active) < _maximum)
        return true;

    var _lowest_index = -1;
    var _lowest_priority = _priority;

    for (var _i = 0; _i < array_length(_active); ++_i)
    {
        if (_active[_i].priority >= _lowest_priority)
            continue;

        _lowest_index = _i;
        _lowest_priority = _active[_i].priority;
    }

    if (_lowest_index < 0)
        return false;

    audio_stop_sound(_active[_lowest_index].handle);
    array_delete(_active,_lowest_index,1);
    return true;
}

/// @description Registers one managed sound handle.
function sc_audio_active_register(_handle, _key, _category, _priority)
{
    array_push(global.audio.active,{
        handle: _handle,
        key: _key,
        category: _category,
        priority: _priority
    });
}

#endregion

#region COOLDOWNS

/// @description Returns whether an audio request has completed its cooldown.
function sc_audio_cooldown_ready(_key)
{
    if (!variable_struct_exists(global.audio.cooldowns,_key))
        return true;

    return GAME_TICK >= variable_struct_get(
        global.audio.cooldowns,
        _key
    );
}

/// @description Starts an audio request cooldown.
function sc_audio_cooldown_set(_key, _cooldown)
{
    if (_cooldown <= 0)
        return;

    variable_struct_set(
        global.audio.cooldowns,
        _key,
        GAME_TICK + _cooldown
    );
}

#endregion

#region REQUESTS

/// @description Validates concurrency, cooldown and priority for one sound request.
function sc_audio_request_allowed(_sound, _key, _priority, _instance_maximum, _cooldown)
{
    if (!GCFG.audio.enabled
    || _sound == noone
    || !global.audio.initialized)
        return false;

    if (!sc_audio_cooldown_ready(_key))
        return false;

    if (_instance_maximum > 0
    && sc_audio_active_count(_key) >= _instance_maximum)
        return false;

    if (!sc_audio_voice_reserve(_priority))
        return false;

    sc_audio_cooldown_set(_key,_cooldown);
    return true;
}

/// @description Plays one non-positional managed sound.
function sc_audio_play(
    _sound,
    _category = AudioCategory.UI,
    _volume = 1,
    _pitch_range = 0,
    _priority = 50,
    _instance_maximum = 4,
    _cooldown = 0,
    _key = ""
)
{
    if (_sound == noone)
        return -1;

    if (_key == "")
        _key = "sound_" + string(_sound);

    if (!sc_audio_request_allowed(
        _sound,_key,_priority,
        _instance_maximum,_cooldown
    ))
        return -1;

    var _handle = audio_play_sound(
        _sound,
        _priority,
        false
    );

    if (_handle < 0)
        return -1;

    audio_sound_gain(
        _handle,
        sc_audio_gain_get(_category,_volume),
        0
    );

    audio_sound_pitch(
        _handle,
        sc_audio_pitch_get(_pitch_range)
    );

    sc_audio_active_register(
        _handle,
        _key,
        _category,
        _priority
    );

    return _handle;
}

/// @description Plays one culled positional managed sound.
function sc_audio_play_at(
    _sound,
    _x,
    _y,
    _category = AudioCategory.WORLD,
    _volume = 1,
    _pitch_range = 0,
    _priority = 40,
    _instance_maximum = 4,
    _cooldown = 0,
    _falloff_reference = 320,
    _falloff_maximum = 1400,
    _falloff_factor = 1,
    _key = ""
)
{
    if (_sound == noone)
        return -1;

    var _dx = _x - global.audio.listener_x;
    var _dy = _y - global.audio.listener_y;

    if (_dx * _dx + _dy * _dy
    > _falloff_maximum * _falloff_maximum)
        return -1;

    if (_key == "")
        _key = "sound_" + string(_sound);

    if (!sc_audio_request_allowed(
        _sound,_key,_priority,
        _instance_maximum,_cooldown
    ))
        return -1;

    var _handle = audio_play_sound_at(
        _sound,
        _x,_y,0,
        _falloff_reference,
        _falloff_maximum,
        _falloff_factor,
        false,
        _priority
    );

    if (_handle < 0)
        return -1;

    audio_sound_gain(
        _handle,
        sc_audio_gain_get(_category,_volume),
        0
    );

    audio_sound_pitch(
        _handle,
        sc_audio_pitch_get(_pitch_range)
    );

    sc_audio_active_register(
        _handle,
        _key,
        _category,
        _priority
    );

    return _handle;
}

#endregion

#region WEAPONS

/// @description Plays the configured sound belonging to one weapon discharge.
function sc_audio_weapon_play(_owner, _weapon, _x, _y)
{
    if (!variable_struct_exists(_weapon,"audio"))
        return -1;

    var _audio = _weapon.audio;
    var _sound = sc_audio_value_get(_audio,"sound",noone);

    if (_sound == noone)
        return -1;

    var _config = GCFG.audio.weapon;
    var _player = _owner.entity.faction == Faction.PLAYER;
    var _category = _player
        ? AudioCategory.PLAYER
        : AudioCategory.WORLD;

    var _priority = sc_audio_value_get(
        _audio,
        "priority",
        _player
            ? _config.player_priority
            : _config.world_priority
    );

    var _key = variable_struct_exists(_weapon,"identity")
    && variable_struct_exists(_weapon.identity,"key")
        ? "weapon_" + _weapon.identity.key
        : "weapon_" + string(_sound);

    return sc_audio_play_at(
        _sound,
        _x,
        _y,
        _category,
        sc_audio_value_get(_audio,"volume",1),
        sc_audio_value_get(_audio,"pitch_range",0),
        _priority,
        sc_audio_value_get(
            _audio,
            "instance_maximum",
            _config.instance_maximum
        ),
        sc_audio_value_get(
            _audio,
            "cooldown",
            _config.cooldown
        ),
        sc_audio_value_get(
            _audio,
            "falloff_reference",
            _config.falloff_reference
        ),
        sc_audio_value_get(
            _audio,
            "falloff_maximum",
            _config.falloff_maximum
        ),
        sc_audio_value_get(
            _audio,
            "falloff_factor",
            _config.falloff_factor
        ),
        _key
    );
}

/// @description Plays the resolved positional sound belonging to one projectile detonation.
function sc_audio_projectile_detonation_play(_projectile)
{
    var _data = _projectile.projectile;
    var _audio = _data.detonation.audio;

    if (!is_struct(_audio))
        return -1;

    var _sound = sc_audio_value_get(_audio, "sound", noone);

    if (_sound == noone)
        return -1;

    var _config = GCFG.audio.defaults;
    var _volume = sc_audio_value_get(_audio, "volume", 1);

    if (sc_audio_value_get(_audio, "scale_volume", false))
        _volume *= clamp(_data.scale, 0.35, 1.5);

    var _category = _data.source.faction == Faction.PLAYER
        ? AudioCategory.PLAYER
        : AudioCategory.WORLD;

    return sc_audio_play_at(
        _sound,
        _projectile.x,
        _projectile.y,
        _category,
        _volume,
        sc_audio_value_get(_audio, "pitch_range", 0),
        sc_audio_value_get(_audio, "priority", _config.priority),
        sc_audio_value_get(_audio, "instance_maximum", _config.instance_maximum),
        sc_audio_value_get(_audio, "cooldown", _config.cooldown),
        sc_audio_value_get(_audio, "falloff_reference", _config.falloff_reference),
        sc_audio_value_get(_audio, "falloff_maximum", _config.falloff_maximum),
        sc_audio_value_get(_audio, "falloff_factor", _config.falloff_factor),
        "projectile_detonation_" + _data.key
    );
}

#endregion

#region PAUSE

/// @description Pauses or resumes managed gameplay audio.
function sc_audio_pause_set(_paused)
{
    if (_paused == global.audio.paused)
        return;

    global.audio.paused = _paused;

    var _active = global.audio.active;

    for (var _i = 0; _i < array_length(_active); ++_i)
    {
        var _entry = _active[_i];

        if (_entry.category == AudioCategory.UI
        || _entry.category == AudioCategory.MUSIC)
            continue;

        if (_paused)
            audio_pause_sound(_entry.handle);
        else
            audio_resume_sound(_entry.handle);
    }
}

#endregion

#region UPDATE

/// @description Updates the listener, pause state and staggered audio cleanup.
function sc_audio_update()
{
    if (!global.audio.initialized)
        return;

    if (instance_exists(global.player_id))
    {
        global.audio.listener_x = global.player_id.x;
        global.audio.listener_y = global.player_id.y;

        audio_listener_position(
            global.audio.listener_x,
            global.audio.listener_y,
            0
        );
    }

    sc_audio_pause_set(
        global.LevelState == LevelState.PAUSED
    );

    if (global.audio.paused
    || GAME_TICK < global.audio.cleanup_tick)
        return;

    global.audio.cleanup_tick =
        GAME_TICK + GCFG.audio.cleanup_interval;

    sc_audio_active_cleanup();
}

#endregion