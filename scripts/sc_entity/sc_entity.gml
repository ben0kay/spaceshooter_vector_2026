/// @description Initializes the shared damageable-entity contract and circular collision mask.
function sc_entity_init(_entity, _faction, _damage_script, _collision_radius)
{
    _entity.entity = {
        faction: _faction,
        damage_script: _damage_script
    };

    _entity.mask_index = s_collision_circle;

    var _mask_scale = _collision_radius / 16;
    _entity.image_xscale = _mask_scale;
    _entity.image_yscale = _mask_scale;

    return true;
}