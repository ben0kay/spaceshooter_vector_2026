/// @description Initializes one generic world resource pickup.
initialized = false;

if (!is_struct(resource_pickup_create)
|| !sc_resource_pickup_init(id, resource_pickup_create))
{
    show_debug_message("RESOURCE PICKUP INITIALIZATION ERROR");
    instance_destroy();
}