/// @description Creates dormant runtime effect modifiers for an entity or projectile.
function sc_effect_runtime_create()
{
    return {
        movement_scale: 1,
        rotation_scale: 1,
        weapon_scale: 1,
        time_scale: 1
    };
}