/// @description Resolves the correct gameplay layer for a weapon delivery.
function sc_weapon_delivery_layer_get(_owner, _delivery_type)
{
    var _fallback = _owner.layer;
    var _faction = _owner.entity.faction;
    var _layer_name = "";

    switch (_delivery_type)
    {
        case AttackDelivery.PROJECTILE:
        case AttackDelivery.BEAM:
            _layer_name = _faction == Faction.PLAYER
                ? "Player_Projectile"
                : "Enemy_Projectile";
        break;

        case AttackDelivery.AREA:
            _layer_name = "Effects_Front";
        break;

        case AttackDelivery.DEPLOYABLE:
            _layer_name = "Effects_Back";
        break;
    }

    if (_layer_name != "")
    {
        var _layer_id = layer_get_id(_layer_name);
        if (_layer_id != -1) return _layer_id;
    }

    return _fallback;
}

/// @description Emits one registered weapon delivery on its correct gameplay layer.
function sc_weapon_delivery_fire(_owner, _weapon, _source, _x, _y, _direction)
{
    var _delivery = _weapon.delivery;
    var _layer = sc_weapon_delivery_layer_get(_owner, _delivery.type);

    switch (_delivery.type)
    {
        case AttackDelivery.PROJECTILE:
        {
            var _projectile = sc_projectile_create(
                _delivery.projectile_key, _source, _delivery,
                _x, _y, _direction, _layer
            );

            // Only guided projectiles receive a guidance activation time.
            if (instance_exists(_projectile) && _delivery.guidance.homing)
            {
                var _delay = variable_struct_exists(_delivery.guidance, "guidance_delay")
                    ? max(0, round(_delivery.guidance.guidance_delay))
                    : 0;

                _projectile.projectile.runtime.guidance_start_tick = GAME_TICK + _delay;
            }

            return _projectile;
        }

        case AttackDelivery.AREA:
            return sc_attack_area_create(
                _delivery.area, _source, _delivery.damage,
                _x, _y, _direction, _layer, _delivery.scale
            );

        case AttackDelivery.BEAM:
            return sc_beam_create(
                _delivery.beam, _source, _delivery.damage,
                _x, _y, _direction, _layer, _delivery.scale
            );

        case AttackDelivery.DEPLOYABLE:
            return _delivery.create_script(
                _delivery, _source,
                _x, _y, _direction, _layer
            );
    }

    return noone;
}

/// @description Applies player zoom spread once when firing an unguided projectile.
function sc_weapon_zoom_accuracy_apply(_owner, _weapon, _direction)
{
    var _config = GCFG.player.zoom_accuracy;
    var _delivery = _weapon.delivery;

    if (!_config.enabled
    || _owner.entity.faction != Faction.PLAYER
    || _delivery.type != AttackDelivery.PROJECTILE
    || _delivery.guidance != 0
    || !instance_exists(global.level.camera))
        return _direction;

    var _zoom = global.level.camera.camera_data.zoom.current;

    if (_zoom <= _config.penalty_start)
        return _direction;

    var _amount = clamp(
        (_zoom - _config.penalty_start)
        / max(0.001, _config.penalty_full - _config.penalty_start),
        0,
        1
    );

    var _spread = _config.spread_max * _amount;

    return _direction + random_range(-_spread, _spread);
}

/// @description Evenly distributes one player projectile volley across nearby enemies.
function sc_weapon_volley_targets_even(_projectiles, _owner, _weapon, _x, _y, _direction)
{
    var _projectile_count = array_length(_projectiles);
    if (_projectile_count <= 0) return false;

    var _guidance = _weapon.delivery.guidance;
    var _range = _guidance.acquire_range;
    var _candidates = ds_list_create();

    // Ordered results prioritize the nearest enemies when there are
    // more valid targets than available projectiles.
    var _candidate_count = collision_circle_list(
        _x, _y, _range,
        o_enemy, false, true,
        _candidates, true
    );

    var _targets = [];

    for (var _i = 0; _i < _candidate_count; ++_i)
    {
        var _target = _candidates[| _i];

        if (!_target.entity.guidance_targetable) continue;
        if (_target.entity.faction == _owner.entity.faction) continue;

        array_push(_targets, _target);

        // Additional targets cannot be used by this volley.
        if (array_length(_targets) >= _projectile_count) break;
    }

    ds_list_destroy(_candidates);

    var _target_count = array_length(_targets);
    if (_target_count <= 0) return false;

    // Round-robin assignment automatically produces:
    // 6 rockets / 6 targets = 1 each
    // 6 rockets / 3 targets = 2 each
    // 6 rockets / 2 targets = 3 each
    for (var _i = 0; _i < _projectile_count; ++_i)
    {
        var _projectile = _projectiles[_i];
        var _target = _targets[_i mod _target_count];

        _projectile.projectile.runtime.target_id = _target;
        _projectile.projectile.runtime.next_target_tick =
            GAME_TICK + max(1, round(_guidance.reacquire_interval));
    }

    return true;
}

/// @description Fires one registered weapon using a generic owner and shot pattern.
function sc_weapon_fire(_owner, _weapon_key, _shot, _x, _y, _direction, _damage_multiplier)
{
    var _weapon = variable_struct_get(global.data.weapons, _weapon_key);
    var _source = {
        owner_id: _owner,
        faction: _owner.entity.faction,
        damage_multiplier: _damage_multiplier
    };

    var _has_volley_script = variable_struct_exists(_shot, "volley_target_script");
    var _projectiles = _has_volley_script ? [] : undefined;

    switch (_shot.pattern)
    {
        case ShotPattern.SINGLE:
            return sc_weapon_delivery_fire(
                _owner, _weapon, _source,
                _x, _y, _direction
            );

        case ShotPattern.SPREAD:
        {
            var _step = _shot.amount > 1
                ? _shot.angle_total / (_shot.amount - 1)
                : 0;

            var _start = _direction - _shot.angle_total * 0.5;

            for (var _i = 0; _i < _shot.amount; ++_i)
            {
                var _delivery = sc_weapon_delivery_fire(
                    _owner, _weapon, _source,
                    _x, _y, _start + _step * _i
                );

                if (_has_volley_script && instance_exists(_delivery))
                    array_push(_projectiles, _delivery);
            }
        }
        break;

        case ShotPattern.RANDOM_CONE:
        {
            var _half_angle = _shot.angle_total * 0.5;

            for (var _i = 0; _i < _shot.amount; ++_i)
            {
                var _delivery = sc_weapon_delivery_fire(
                    _owner, _weapon, _source, _x, _y,
                    _direction + random_range(-_half_angle, _half_angle)
                );

                if (_has_volley_script && instance_exists(_delivery))
                    array_push(_projectiles, _delivery);
            }
        }
        break;

        default:
            return false;
    }

    if (_has_volley_script && array_length(_projectiles) > 0)
        _shot.volley_target_script(
            _projectiles, _owner, _weapon,
            _x, _y, _direction
        );

    return true;
}