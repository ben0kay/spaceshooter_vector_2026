/// @description Registers every Shard weapon and projectile.
function sc_plyr_register_all(){
	
	if !(sc_shard_register_all()) return false;
	if (!sc_ship_register_fighter()) return false; //temp
    if (!sc_ship_register_bastion()) return false; // temp
	    // Register future player chassis families here.
    return true;
}

/// @description Registers the Shard chassis and all Shard combat content.
function sc_shard_register_all()
{
    if (!sc_ship_register_shard()) return false;

    if (!sc_projectile_register_shard_pulse()) return false;
    if (!sc_weapon_register_shard_pulse()) return false;

    if (!sc_weapon_register_minigun()) return false;

    if (!sc_weapon_register_shard_laser()) return false;

    if (!sc_projectile_register_shard_rocket()) return false;
    if (!sc_weapon_register_shard_rocket()) return false;
	
	if (!sc_weapon_register_shard_mining_beam()) return false;

    return true;
}