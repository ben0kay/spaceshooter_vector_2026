/// @description Creates one generic deployable mine.
function sc_mine_create(_delivery, _source, _x, _y, _direction, _layer)
{
    var _detonation_layer = layer_get_id("Effects_Front");

    if (_detonation_layer == -1)
        _detonation_layer = _layer;

    return instance_create_layer(
        _x,
        _y,
        _layer,
        o_mine,
        {
            mine_create: {
                source: _source,
                direction: _direction,
                detonation_layer: _detonation_layer,
                definition: variable_clone(_delivery.mine),
                explosion: variable_clone(_delivery.explosion)
            }
        }
    );
}

/// @description Initializes one generic mine.
function sc_mine_init(_mine, _create)
{
    var _definition = _create.definition;

    _mine.mine = {
        source: _create.source,
        direction: _create.direction,
        detonation_layer: _create.detonation_layer,

        arming_duration: max(
            1,
            round(_definition.arming_duration)
        ),

        life_duration: max(
            1,
            round(_definition.life_duration)
        ),

        trigger_radius: max(
            1,
            _definition.trigger_radius
        ),

        collision_radius: max(
            1,
            _definition.collision_radius
        ),

        trigger_check_interval: max(
            1,
            round(_definition.trigger_check_interval)
        ),

        countdown_duration: max(
            1,
            round(_definition.countdown_duration)
        ),

        target_script: _definition.target_script,
        bleep: variable_clone(_definition.bleep),
        pulse: variable_clone(_definition.pulse),
        visual: variable_clone(_definition.visual),
        explosion: _create.explosion,

        runtime: {
            state: MineState.ARMING,

            arming_remaining: max(
                1,
                round(_definition.arming_duration)
            ),

            life_remaining: max(
                1,
                round(_definition.life_duration)
            ),

            countdown_remaining: max(
                1,
                round(_definition.countdown_duration)
            ),

            target_id: noone,

            next_trigger_tick: GAME_TICK
                + real(_mine.id)
                mod max(
                    1,
                    round(_definition.trigger_check_interval)
                ),

            next_bleep_tick: GAME_TICK,
            flash: 0,

            pulse_offset: real(_mine.id)
                mod max(
                    1,
                    round(_definition.pulse.interval)
                )
        }
    };

    _mine.depth = _definition.visual.depth;
    _mine.initialized = true;
    return true;
}

/// @description Finds the first valid hostile entity inside a radius.
function sc_mine_target_hostile(_mine, _radius)
{
    var _source = _mine.mine.source;
    var _list = ds_list_create();

    var _count = collision_circle_list(
        _mine.x,
        _mine.y,
        _radius,
        o_entity,
        false,
        true,
        _list,
        false
    );

    var _target = noone;

    for (var _i = 0; _i < _count; ++_i)
    {
        var _candidate = _list[| _i];

        if (!_candidate.initialized
        || _candidate.entity.faction == _source.faction)
            continue;

        if (_candidate.entity.faction != Faction.PLAYER
        && _candidate.enemy.state == EnemyState.DEAD)
            continue;

        _target = _candidate;
        break;
    }

    ds_list_destroy(_list);
    return _target;
}

/// @description Starts one mine's warning countdown.
function sc_mine_trigger(_mine, _target = noone)
{
    var _data = _mine.mine;
    var _runtime = _data.runtime;

    if (_runtime.state == MineState.TRIGGERED
    || _runtime.state == MineState.DETONATED)
        return false;

    _runtime.state = MineState.TRIGGERED;
    _runtime.target_id = _target;
    _runtime.countdown_remaining = _data.countdown_duration;
    _runtime.next_bleep_tick = GAME_TICK;
    _runtime.flash = 1;
    return true;
}

/// @description Plays one increasingly urgent mine warning bleep.
function sc_mine_bleep(_mine)
{
    var _data = _mine.mine;
    var _runtime = _data.runtime;
    var _bleep = _data.bleep;

    var _progress = 1
        - _runtime.countdown_remaining
        / _data.countdown_duration;

    var _interval = lerp(
        _bleep.interval_start,
        _bleep.interval_end,
        _progress
    );

    if (_bleep.sound != noone)
    {
        var _audio = audio_play_sound(
            _bleep.sound,
            0,
            false
        );

        audio_sound_gain(
            _audio,
            _bleep.volume,
            0
        );

        audio_sound_pitch(
            _audio,
            lerp(
                _bleep.pitch_start,
                _bleep.pitch_end,
                _progress
            )
        );
    }

    _runtime.flash = 1;
    _runtime.next_bleep_tick = GAME_TICK
        + max(1, round(_interval));

    return true;
}

/// @description Detonates one mine through shared area and effect systems.
function sc_mine_detonate(_mine)
{
    var _data = _mine.mine;
    var _runtime = _data.runtime;
    var _explosion = _data.explosion;

    if (_runtime.state == MineState.DETONATED)
        return false;

    _runtime.state = MineState.DETONATED;

    sc_attack_area_create(
        _explosion.area,
        _data.source,
        _explosion.damage,
        _mine.x,
        _mine.y,
        _data.direction,
        _data.detonation_layer,
        _explosion.scale
    );

    _explosion.particle_script(
        _mine.x,
        _mine.y,
        _explosion.scale,
        _data.visual.palette
    );

    instance_destroy(_mine);
    return true;
}

/// @description Updates one mine through collision, arming and detonation.
function sc_mine_update(_mine)
{
    var _data = _mine.mine;
    var _runtime = _data.runtime;

    _runtime.flash = max(
        0,
        _runtime.flash - 0.08
    );

    if (_runtime.state != MineState.DETONATED)
    {
        var _collision_target = _data.target_script(
            _mine,
            _data.collision_radius
        );

        if (instance_exists(_collision_target))
        {
            _runtime.target_id = _collision_target;
            sc_mine_detonate(_mine);
            return;
        }
    }

    switch (_runtime.state)
    {
        case MineState.ARMING:
        {
            _runtime.arming_remaining--;

            if (_runtime.arming_remaining <= 0)
            {
                _runtime.arming_remaining = 0;
                _runtime.state = MineState.ARMED;
                _runtime.flash = 1;
            }

            break;
        }

        case MineState.ARMED:
        {
            _runtime.life_remaining--;

            if (_runtime.life_remaining <= 0)
            {
                _runtime.life_remaining = 0;
                sc_mine_trigger(_mine);
                break;
            }

            if (GAME_TICK < _runtime.next_trigger_tick)
                break;

            _runtime.next_trigger_tick = GAME_TICK
                + _data.trigger_check_interval;

            var _target = _data.target_script(
                _mine,
                _data.trigger_radius
            );

            if (instance_exists(_target))
                sc_mine_trigger(_mine, _target);

            break;
        }

        case MineState.TRIGGERED:
        {
            _runtime.countdown_remaining--;

            if (GAME_TICK >= _runtime.next_bleep_tick)
                sc_mine_bleep(_mine);

            if (_runtime.countdown_remaining <= 0)
                sc_mine_detonate(_mine);

            break;
        }
    }
}

/// @description Draws one generic mine through supplied callbacks.
function sc_mine_draw(_mine)
{
    var _data = _mine.mine;
    var _runtime = _data.runtime;
    var _pulse = _data.pulse;
    var _visual = _data.visual;

    if (_runtime.state != MineState.ARMING)
    {
        var _interval = _runtime.state == MineState.TRIGGERED
            ? max(
                _pulse.triggered_interval_min,
                round(
                    _pulse.interval
                    * _pulse.triggered_interval_scale
                )
            )
            : _pulse.interval;

        var _pulse_tick = (
            GAME_TICK
            + _runtime.pulse_offset
        ) mod _interval;

        _pulse.draw_script(
            _mine.x,
            _mine.y,
            _pulse,
            _pulse_tick / _interval,
            _visual.palette,
            _data.direction
        );
    }

    _visual.draw_script(_mine, _data);
}