/// @description Creates one generic mine from supplied delivery data.
function sc_mine_create(
    _delivery,
    _source,
    _mount_x,
    _mount_y,
    _target_x,
    _target_y,
    _attack_id
)
{
    var _mine_data = _delivery.mine;
    var _mine = instance_create_layer(
        _source.owner_id.x,
        _source.owner_id.y,
        _source.owner_id.layer,
        o_mine,
        {
            mine_create: {
                definition: _mine_data,
                source: _source,
                attack_id: _attack_id
            }
        }
    );

    return instance_exists(_mine);
}

/// @description Initializes one generic mine instance.
function sc_mine_init(_mine, _create)
{
    var _data = _create.definition;
    var _pulse = _data.pulse;
    var _interval = max(1, _data.trigger_check_interval);

    _mine.mine = {
        definition: _data,
        source: _create.source,
        attack_id: _create.attack_id,

        state: MineState.ARMING,
        state_tick: GAME_TICK,
        life_tick: GAME_TICK + _data.life_duration,
        next_trigger_tick: GAME_TICK + (real(_mine.id) mod _interval),

        target_id: noone,
        countdown_end_tick: 0,
        next_bleep_tick: 0,
        bleep_count: 0,

        pulse_tick: GAME_TICK + _pulse.interval,
        pulse_start_tick: -1,
        pulse_angle: random(360),

        detonation_layer: _mine.layer
    };

    _mine.depth = _data.visual.depth;
    _mine.initialized = true;
    return true;
}

/// @description Finds a hostile target for ordinary player or enemy mines.
function sc_mine_target_hostile(_mine)
{
    var _runtime = _mine.mine;
    var _data = _runtime.definition;
    var _source = _runtime.source;
    var _radius = _data.trigger_radius;

    if (_source.faction != Faction.PLAYER)
    {
        var _player = global.player_id;

        if (!instance_exists(_player)
        || point_distance_sqr(_mine.x, _mine.y, _player.x, _player.y)
        > sqr(_radius))
            return noone;

        return _player;
    }

    var _list = ds_list_create();
    var _count = collision_circle_list(
        _mine.x,
        _mine.y,
        _radius,
        o_enemy,
        false,
        true,
        _list,
        false
    );

    var _target = noone;
    var _nearest = sqr(_radius);

    for (var i = 0; i < _count; ++i)
    {
        var _candidate = _list[| i];

        if (!instance_exists(_candidate)
        || !_candidate.initialized
        || _candidate.enemy.state == EnemyState.DEAD)
            continue;

        var _distance = point_distance_sqr(
            _mine.x,
            _mine.y,
            _candidate.x,
            _candidate.y
        );

        if (_distance > _nearest)
            continue;

        _nearest = _distance;
        _target = _candidate;
    }

    ds_list_destroy(_list);
    return _target;
}

/// @description Begins one mine's detonation countdown.
function sc_mine_trigger(_mine, _target)
{
    var _runtime = _mine.mine;
    var _data = _runtime.definition;

    _runtime.state = MineState.TRIGGERED;
    _runtime.state_tick = GAME_TICK;
    _runtime.target_id = _target;
    _runtime.countdown_end_tick = GAME_TICK + _data.countdown_duration;
    _runtime.next_bleep_tick = GAME_TICK;
    _runtime.bleep_count = 0;

    return true;
}

/// @description Plays and schedules one triggered mine warning bleep.
function sc_mine_bleep(_mine)
{
    var _runtime = _mine.mine;
    var _data = _runtime.definition;
    var _bleep = _data.bleep;

    if (GAME_TICK < _runtime.next_bleep_tick)
        return false;

    var _duration = max(1, _data.countdown_duration);
    var _remaining = max(
        0,
        _runtime.countdown_end_tick - GAME_TICK
    );
    var _progress = 1 - (_remaining / _duration);

    var _interval = lerp(
        _bleep.interval_max,
        _bleep.interval_min,
        _progress
    );

    if (_bleep.sound != noone)
    {
        var _audio = audio_play_sound(
            _bleep.sound,
            _bleep.priority,
            false
        );

        audio_sound_pitch(
            _audio,
            lerp(
                _bleep.pitch_min,
                _bleep.pitch_max,
                _progress
            )
        );
    }

    _runtime.next_bleep_tick = GAME_TICK + max(1, round(_interval));
    ++_runtime.bleep_count;
    return true;
}

/// @description Detonates one generic mine using supplied explosion callbacks.
function sc_mine_detonate(_mine)
{
    var _runtime = _mine.mine;
    var _data = _runtime.definition;
    var _explosion = _data.explosion;
    var _source = _runtime.source;

    if (_runtime.state == MineState.DETONATED)
        return false;

    _runtime.state = MineState.DETONATED;

    sc_attack_area_create(
        _mine.x,
        _mine.y,
        _runtime.detonation_layer,
        _explosion.area,
        _source
    );

    _explosion.particle_script(
        _mine.x,
        _mine.y,
        _data.visual.palette,
        _explosion
    );

    var _shockwave = _explosion.shockwave;

    sc_shockwave_create({
        x: _mine.x,
        y: _mine.y,
        layer: _runtime.detonation_layer,

        radius_start: _shockwave.radius_start,
        radius_end: _shockwave.radius_end,
        duration: _shockwave.duration,

        colour: _data.visual.palette.energy,
        alpha_start: _shockwave.alpha_start,
        alpha_end: _shockwave.alpha_end,
        width_start: _shockwave.width_start,
        width_end: _shockwave.width_end
    });

    instance_destroy(_mine);
    return true;
}

/// @description Updates one generic mine.
function sc_mine_update(_mine)
{
    var _runtime = _mine.mine;
    var _data = _runtime.definition;

    switch (_runtime.state)
    {
        case MineState.ARMING:
        {
            if (GAME_TICK - _runtime.state_tick
            < _data.arming_duration)
                break;

            _runtime.state = MineState.ARMED;
            _runtime.state_tick = GAME_TICK;
            break;
        }

        case MineState.ARMED:
        {
            if (GAME_TICK >= _runtime.life_tick)
            {
                sc_mine_trigger(_mine, noone);
                break;
            }

            if (GAME_TICK >= _runtime.next_trigger_tick)
            {
                _runtime.next_trigger_tick =
                    GAME_TICK + _data.trigger_check_interval;

                var _target = _data.target_script(_mine);

                if (instance_exists(_target))
                    sc_mine_trigger(_mine, _target);
            }

            break;
        }

        case MineState.TRIGGERED:
        {
            sc_mine_bleep(_mine);

            if (GAME_TICK >= _runtime.countdown_end_tick)
                sc_mine_detonate(_mine);

            break;
        }
    }

    var _pulse = _data.pulse;
    var _pulse_interval = _pulse.interval;

    if (_runtime.state == MineState.TRIGGERED)
    {
        _pulse_interval = max(
            _pulse.triggered_interval_min,
            round(
                _pulse.interval
                * _pulse.triggered_interval_scale
            )
        );
    }

    if (GAME_TICK >= _runtime.pulse_tick)
    {
        _runtime.pulse_start_tick = GAME_TICK;
        _runtime.pulse_tick = GAME_TICK + _pulse_interval;
        _runtime.pulse_angle += _pulse.angle_step;
    }
}

/// @description Draws one generic mine through supplied visual callbacks.
function sc_mine_draw(_mine)
{
    var _runtime = _mine.mine;
    var _data = _runtime.definition;
    var _visual = _data.visual;
    var _pulse = _data.pulse;

    if (_runtime.pulse_start_tick >= 0)
    {
        var _elapsed = GAME_TICK - _runtime.pulse_start_tick;

        if (_elapsed <= _pulse.duration)
        {
            _pulse.draw_script(
                _mine.x,
                _mine.y,
                _elapsed,
                _pulse.duration,
                _runtime.pulse_angle,
                _pulse,
                _visual.palette
            );
        }
    }

    _visual.draw_script(_mine, _data);
}