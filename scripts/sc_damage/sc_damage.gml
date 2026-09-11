

/// @description Returns centralized tuning for one damage type.
function sc_damage_type_config_get(_type)
{
    return GCFG.damage.types[_type];
}

/// @description Returns centralized tuning for one damage effect.
function sc_damage_effect_config_get(_effect)
{
    return GCFG.damage.effects[_effect];
}

/// @description Creates one immutable damage packet when an attack is spawned.
function sc_damage_packet_create(_definition, _source, _projectile = false)
{
    var _type_config = sc_damage_type_config_get(_definition.type);
    var _effect = variable_struct_exists(_definition, "effect")
        ? _definition.effect
        : _type_config.default_effect;

    var _effect_config = sc_damage_effect_config_get(_effect);
    var _critical_config = GCFG.player.critical_hit.projectile.kinetic;

    var _critical_eligible = _projectile
        && _source.faction == Faction.PLAYER
        && _definition.type == DamageType.KINETIC;

    return {
        amount: max(0, _definition.amount),
        type: _definition.type,
        projectile_impact: _projectile,

        knockback_force: variable_struct_exists(_definition, "knockback_force")
            ? max(0, _definition.knockback_force)
            : 0,

        effect: {
            type: _effect,
            chance: variable_struct_exists(_definition, "effect_chance") ? _definition.effect_chance : _effect_config.chance,
            duration: variable_struct_exists(_definition, "effect_duration") ? _definition.effect_duration : _effect_config.duration,
            strength: variable_struct_exists(_definition, "effect_strength") ? _definition.effect_strength : _effect_config.strength,
            tick_interval: variable_struct_exists(_definition, "effect_tick_interval") ? _definition.effect_tick_interval : _effect_config.tick_interval
        },

        extraction: variable_struct_exists(_definition, "extraction")
            ? variable_clone(_definition.extraction)
            : undefined,

        critical_hit: {
            triggered: _critical_eligible && random(1) < _critical_config.chance,
            multiplier: max(1, _critical_config.multiplier),
            armour_enabled: _critical_config.armour_enabled
        },

        source: {
            owner_id: _source.owner_id,
            faction: _source.faction,
            damage_multiplier: _source.damage_multiplier
        }
    };
}

/// @description Returns packet damage before defence-layer matchups.
function sc_damage_packet_amount_get(_packet)
{
    return _packet.amount * _packet.source.damage_multiplier;
}

/// @description Returns a cloned damage packet with scaled damage and knockback.
function sc_damage_packet_scaled(_packet,_scale)
{
    var _result = variable_clone(_packet);
    var _resolved_scale = max(0,_scale);

    _result.amount *= _resolved_scale;
    _result.knockback_force *= _resolved_scale;

    return _result;
}

/// @description Returns the multiplier for a damage type against one defence layer.
function sc_damage_layer_multiplier_get(_type, _layer)
{
    var _config = sc_damage_type_config_get(_type);

    switch (_layer)
    {
        case "shield": return _config.shield_multiplier;
        case "armour": return _config.armour_multiplier;
        case "hull": return _config.hull_multiplier;
    }

    return 1;
}

/// @description Resolves one damage packet through shield, armour and hull.
function sc_damage_resolve(_packet,_shield,_armour,_hull,_armour_hull_multiplier = 1)
{
    var _remaining = sc_damage_packet_amount_get(_packet);
    var _names = ["shield","armour","hull"];
    var _layers = [DefenceLayer.SHIELD,DefenceLayer.ARMOUR,DefenceLayer.HULL];
    var _current = [max(0,_shield),max(0,_armour),max(0,_hull)];
    var _dealt = [0,0,0];
    var _impact_layer = DefenceLayer.NONE;

    for (var _i = 0; _i < 3 && _remaining > 0; ++_i)
    {
        if (_current[_i] <= 0) continue;

        var _multiplier = sc_damage_layer_multiplier_get(_packet.type,_names[_i]);
        if (_i > 0) _multiplier *= _armour_hull_multiplier;

        var _critical_layer = _i == 2
            || (_i == 1 && _packet.critical_hit.armour_enabled);

        if (_packet.critical_hit.triggered && _critical_layer)
            _multiplier *= _packet.critical_hit.multiplier;

        if (_multiplier <= 0)
        {
            _remaining = 0;
            break;
        }

        var _damage = min(_current[_i],_remaining * _multiplier);
        _current[_i] -= _damage;
        _dealt[_i] = _damage;
        _remaining = max(0,_remaining - _damage / _multiplier);

        if (_damage > 0 && _impact_layer == DefenceLayer.NONE)
            _impact_layer = _layers[_i];
    }

    var _critical_applied = _packet.critical_hit.triggered
        && (_dealt[2] > 0
        || (_packet.critical_hit.armour_enabled && _dealt[1] > 0));

    return {
        shield: _current[0],
        armour: _current[1],
        hull: _current[2],
        impact_layer: _impact_layer,
        critical_hit: _critical_applied,
        critical_multiplier: _critical_applied
            ? _packet.critical_hit.multiplier
            : 1,

        dealt: {
            shield: _dealt[0],
            armour: _dealt[1],
            hull: _dealt[2],
            total: _dealt[0] + _dealt[1] + _dealt[2]
        },

        effect: _packet.effect,
        source: _packet.source
    };
}

/// @description Rolls whether one registered damage effect activates.
function sc_damage_effect_triggered(_effect)
{
    if (_effect.type == DamageEffect.NONE) return false;
    return random(1) < _effect.chance;
}

/// @description Applies a damage packet to an interceptable projectile.
function sc_projectile_damage(_projectile, _packet)
{
    if (!instance_exists(_projectile)) return false;

    var _data = _projectile.projectile;
    var _defence = _data.defence;

    if (_data.state != ProjectileState.ACTIVE
    || _data.runtime.destroyed
    || !is_struct(_defence))
        return false;

    var _result = sc_damage_resolve(
        _packet,
        0,
        _defence.armour.current,
        _defence.hull.current
    );

    _defence.armour.current = _result.armour;
    _defence.hull.current = _result.hull;

    if (_result.dealt.total <= 0) return false;

    _data.visual.runtime.hit_alpha = 1;
	
	if (is_struct(_defence.health_bar))
    sc_health_bar_damage_show(_defence.health_bar);

    if (_defence.hull.current <= 0)
    {
        _defence.hull.current = 0;
        _data.runtime.destroyed = true;

        if (_defence.detonate_on_destroy)
            sc_projectile_detonate(_projectile);

        _data.visual.impact_script(
            _projectile.x,
            _projectile.y,
            _data.direction,
            noone,
            _data.scale
        );

        instance_destroy(_projectile);
    }

    return _result;
}

/// @description Returns a player damage packet reduced when its enemy target is off-screen.
function sc_enemy_offscreen_damage_packet_get(_enemy, _packet)
{
    var _config = GCFG.player.offscreen_damage;

    if (!_config.enabled
    || _packet.source.faction != Faction.PLAYER)
        return _packet;

    var _visible = sc_optimization_circle_visible(
        _enemy.x,
        _enemy.y,
        _enemy.enemy.visual.radius,
        _config.margin
    );

    if (_visible)
        return _packet;

    return sc_damage_packet_scaled(
        _packet,
        _config.multiplier
    );
}

/// @description Applies layered enemy damage with off-screen reduction and optional rear damage bonus.
function sc_enemy_damage(_enemy, _packet, _impact = undefined)
{
    var _data = _enemy.enemy;
    if (_data.state == EnemyState.DEAD) return false;

    var _packet_resolve = sc_enemy_offscreen_damage_packet_get(
        _enemy,
        _packet
    );

    var _rear = _data.rear_damage;
    var _rear_angle = false;

    if (_rear.arc > 0 && is_struct(_impact))
    {
        var _dx = _impact.x - _enemy.x;
        var _dy = _impact.y - _enemy.y;

        if (abs(_dx) + abs(_dy) > 0.001)
        {
            var _impact_direction = point_direction(
                _enemy.x,
                _enemy.y,
                _impact.x,
                _impact.y
            );

            var _rear_direction = _enemy.draw_angle + 180;

            _rear_angle = abs(angle_difference(
                _impact_direction,
                _rear_direction
            )) <= _rear.arc * 0.5;
        }
    }

    var _defence = _data.defence;
    var _shield_before = _defence.shield.current;
    var _rear_multiplier = _rear_angle
        ? _rear.multiplier
        : 1;

    var _result = sc_damage_resolve(
        _packet_resolve,
        _defence.shield.current,
        _defence.armour.current,
        _defence.hull.current,
        _rear_multiplier
    );

    _result.rear_hit = _rear_angle
        && (_result.dealt.armour > 0
        || _result.dealt.hull > 0);

    _defence.shield.current = _result.shield;
    _defence.armour.current = _result.armour;
    _defence.hull.current = _result.hull;

    if (_result.dealt.total <= 0)
        return false;

    sc_shield_break_effect_try(
        _enemy,
        _shield_before,
        _result,
        _data.visual.runtime.shield_sprite,
        _data.visual.palette
    );

    if (_result.critical_hit)
    {
        sc_world_feedback_create(
            _enemy.x + random_range(-18, 18),
            _enemy.y - _data.visual.radius * 0.7,
            _enemy.layer,
            "CRITICAL X" + string(_result.critical_multiplier),
            make_colour_rgb(255, 190, 55),
            1.15
        );
    }

    sc_health_bar_damage_show(_enemy.health_bar);

    if (_result.dealt.shield > 0)
        _data.visual.runtime.shield_hit_alpha = 1;

    if (_defence.hull.current <= 0)
    {
        _defence.hull.current = 0;
        _data.state = EnemyState.DEAD;
        sc_enemy_die(_enemy, _packet_resolve);
        return _result;
    }

    if (_data.state == EnemyState.RETREATING
    || _data.state == EnemyState.FLEEING)
    {
        if (_result.effect.type == DamageEffect.STAGGER
        && sc_damage_effect_triggered(_result.effect))
            sc_enemy_stagger_begin(_enemy, _result.effect);

        return _result;
    }

    sc_enemy_engagement_retaliation_try(_enemy, _packet);
    sc_enemy_awareness_damage_try(_enemy, _packet);
    sc_enemy_alert_try(_enemy, _data.doctrine.alert.on_damage);
    sc_enemy_critical_response_try(_enemy, _result);

    if (_result.effect.type == DamageEffect.STAGGER
    && sc_damage_effect_triggered(_result.effect))
        sc_enemy_stagger_begin(_enemy, _result.effect);

    return _result;
}

/// @description Applies directional damage through the player's layered defence.
function sc_player_damage(_player, _packet, _impact = undefined)
{
    if (global.PlayerState == PlayerState.DESTROYED) return false;

    var _dash = _player.movement.dash;
    if (global.PlayerState == PlayerState.DASHING && _dash.invulnerable) return false;

    var _defence = _player.defence;
    var _shield_before = _defence.shield.current;
    var _focus = _player.combat.shield_focus;
    var _stats = _player.ship.stats.final;
    var _packet_resolve = _packet;
    var _shield_resolve = _defence.shield.current;

    _focus.protected_impact = false;

    if (_focus.active && is_struct(_impact))
    {
        var _impact_direction = point_direction(_player.x, _player.y, _impact.x, _impact.y);
        var _inside_arc = abs(angle_difference(_impact_direction, _player.draw_angle)) <= _stats.shield_focus_arc * 0.5;

        _focus.impact_direction = _impact_direction;
        _focus.protected_impact = _inside_arc;

        if (_inside_arc)
        {
            _packet_resolve = variable_clone(_packet);
            _packet_resolve.amount *= _stats.shield_focus_damage_multiplier;
        }
        else _shield_resolve = 0;
    }

    var _result = sc_damage_resolve(
        _packet_resolve,
        _shield_resolve,
        _defence.armour.current,
        _defence.hull.current
    );

    if (_focus.active && is_struct(_impact) && !_focus.protected_impact)
    {
        _result.shield = _defence.shield.current;
        _result.shield_focus_bypassed = true;
    }
    else _result.shield_focus_bypassed = false;

    _result.shield_focus_protected = _focus.active && _focus.protected_impact;

    _defence.shield.current = _result.shield;
    _defence.armour.current = _result.armour;
    _defence.hull.current = _result.hull;

    if (_defence.armour.current <= 0)
        _player.inventory.equipment.armour = undefined;

    if (_result.dealt.total <= 0) return false;

    sc_shield_break_effect_try(
        _player,
        _shield_before,
        _result,
        _player.ship.visual.runtime.cache.shield,
        _player.ship.visual.palette
    );

    if (_player.inventory.installation.active)
        sc_player_module_install_cancel(_player);

    _defence.shield.recharge_delay_remaining = _stats.shield_recharge_delay;
    sc_health_bar_damage_show(_player.health_bar);

    if (_result.dealt.shield > 0)
        _player.ship.visual.runtime.shield_hit_alpha = 1;

    if (_defence.hull.current <= 0)
    {
        _defence.hull.current = 0;
        global.PlayerState = PlayerState.DESTROYED;
        sc_player_die(_player, _packet);
    }
    else if (_result.effect.type == DamageEffect.STAGGER && sc_damage_effect_triggered(_result.effect))
        sc_player_stagger_begin(_player, _result.effect);

    return _result;
}

/// @description Applies damage, direct enemy demolition power, resource release and damage stages.
function sc_asteroid_damage(_asteroid, _packet)
{
    var _health = _asteroid.asteroid.health;
    var _damage_amount = sc_damage_packet_amount_get(_packet);

    if (is_struct(_packet.extraction))
        _damage_amount *= _packet.extraction.asteroid_damage_multiplier;

    // Enemy demolition bonuses apply only to direct projectile impacts.
    // Explosion areas, beams and other area attacks receive no bonus.
    if (_packet.projectile_impact
    && _packet.source.faction != Faction.PLAYER
    && _packet.source.faction != noone)
    {
        _damage_amount *=
            GCFG.enemy.asteroid.destroy_damage_multiplier;
    }

    var _damage = min(_health.current, _damage_amount);
    if (_damage <= 0) return false;

    _health.current -= _damage;
    sc_asteroid_yield_damage_add(_asteroid, _packet, _damage);

    var _ratio = _health.current / _health.maximum;

    _health.stage = _ratio <= 0.25
        ? 3
        : (_ratio <= 0.5
            ? 2
            : (_ratio <= 0.75 ? 1 : 0));

    var _result = {
        shield: 0,
        armour: 0,
        hull: _health.current,
        impact_layer: DefenceLayer.HULL,

        dealt: {
            shield: 0,
            armour: 0,
            hull: _damage,
            total: _damage
        },

        effect: _packet.effect,
        source: _packet.source
    };

    if (_health.current <= 0)
    {
        _health.current = 0;
        sc_asteroid_die(_asteroid, _packet);
    }

    return _result;
}