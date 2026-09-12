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
            return sc_projectile_create(
                _delivery.projectile_key,
                _source,
                _delivery,
                _x, _y, _direction,
                _layer
            );

        case AttackDelivery.AREA:
            return sc_attack_area_create(
                _delivery.area,
                _source,
                _delivery.damage,
                _x, _y, _direction,
                _layer,
                _delivery.scale
            );

        case AttackDelivery.BEAM:
            return sc_beam_create(
                _delivery.beam,
                _source,
                _delivery.damage,
                _x, _y, _direction,
                _layer,
                _delivery.scale
            );

        case AttackDelivery.DEPLOYABLE:
            return _delivery.create_script(
                _delivery,
                _source,
                _x, _y, _direction,
                _layer
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

/// @description Returns evenly distributed targets for one projectile volley.
function sc_weapon_volley_targets_even(_owner, _weapon, _x, _y, _direction, _amount)
{
    var _guidance = _weapon.delivery.guidance;
    var _candidates = ds_list_create();

    var _candidate_count = collision_circle_list(
        _x, _y, _guidance.acquire_range,
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
        if (array_length(_targets) >= _amount) break;
    }

    ds_list_destroy(_candidates);

    var _target_count = array_length(_targets);
    if (_target_count <= 0) return [];

    var _assignments = [];

    // Round-robin produces unique targets when enough exist,
    // then distributes extra projectiles evenly.
    for (var _i = 0; _i < _amount; ++_i)
        array_push(_assignments, _targets[_i mod _target_count]);

    return _assignments;
}

/// @description Returns the direction belonging to one projectile inside a shot pattern.
function sc_weapon_shot_direction_get(_shot, _direction, _index)
{
    switch (_shot.pattern)
    {
        case ShotPattern.SPREAD:
        {
            var _step = _shot.amount > 1
                ? _shot.angle_total / (_shot.amount - 1)
                : 0;

            return _direction
                - _shot.angle_total * 0.5
                + _step * _index;
        }

        case ShotPattern.RANDOM_CONE:
            return _direction + random_range(
                -_shot.angle_total * 0.5,
                _shot.angle_total * 0.5
            );
    }

    return _direction;
}

/// @description Gives one guided projectile its preselected volley target.
function sc_weapon_projectile_target_apply(_projectile, _target)
{
    if (!instance_exists(_projectile)
    || !instance_exists(_target))
        return false;

    _projectile.projectile.runtime.target_id = _target;
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

    var _amount = _shot.pattern == ShotPattern.SINGLE
        ? 1
        : max(1, round(_shot.amount));

    var _targets = variable_struct_exists(_shot, "volley_target_script")
        ? _shot.volley_target_script(
            _owner, _weapon,
            _x, _y, _direction,
            _amount
        )
        : [];

    var _first_delivery = noone;

    for (var _i = 0; _i < _amount; ++_i)
    {
        var _shot_direction = sc_weapon_shot_direction_get(
            _shot,
            _direction,
            _i
        );

        var _delivery = sc_weapon_delivery_fire(
            _owner,
            _weapon,
            _source,
            _x,
            _y,
            _shot_direction
        );

        if (_i == 0)
            _first_delivery = _delivery;

        if (_i < array_length(_targets))
            sc_weapon_projectile_target_apply(
                _delivery,
                _targets[_i]
            );
    }

    return _amount == 1
        ? _first_delivery
        : true;
}