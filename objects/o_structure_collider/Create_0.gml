/// @description Initializes one invisible world-structure collision piece.
var _create = collider_create;

owner_id = _create.owner_id;
part_key = _create.part_key;
collision_shape = _create.shape;

visible = false;
image_alpha = 0;
image_angle = _create.angle;

switch (collision_shape)
{
    case StructureCollisionShape.CIRCLE:
        mask_index = s_collision_circle;
        image_xscale = _create.radius / 16;
        image_yscale = _create.radius / 16;
    break;

    case StructureCollisionShape.RECTANGLE:
        mask_index = s_collision_rectangle;
        image_xscale = _create.width / 32;
        image_yscale = _create.height / 32;
    break;
}