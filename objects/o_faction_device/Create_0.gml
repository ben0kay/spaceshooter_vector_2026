/// @description Initializes one registered faction device.
initialized = false;

if (!sc_faction_device_init(id,device_key))
{
    instance_destroy();
    exit;
}