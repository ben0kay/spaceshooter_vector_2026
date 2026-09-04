/// @description Initializes the shared damageable-entity contract and elliptical collision mask.
function sc_entity_init(_entity, _faction, _damage_script, _collision, _guidance_targetable = true)
{
    _entity.entity = {
        faction: _faction,
        damage_script: _damage_script,
        guidance_targetable: _guidance_targetable,

        collision: {
            radius_forward: _collision.radius_forward,
            radius_side: _collision.radius_side
        },

        status: {
            stagger: {
                remaining: 0,
                return_state: 0
            }
        }
    };

    _entity.mask_index = s_collision_circle;
    _entity.image_xscale = _collision.radius_forward / 16;
    _entity.image_yscale = _collision.radius_side / 16;
    _entity.image_angle = _entity.draw_angle;
    return true;
}