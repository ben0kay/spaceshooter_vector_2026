/// @description Initializes one generic environmental field.
initialized = false;

if (!variable_instance_exists(id, "environment_field_create")
|| !is_struct(environment_field_create)
|| !sc_environment_field_init(id, environment_field_create))
{
    show_debug_message("ENVIRONMENT FIELD INSTANCE ERROR");
    instance_destroy();
    exit;
}