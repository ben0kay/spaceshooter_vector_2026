function sc_enemy_register_all(){
	
	if !(sc_enemy_faction_simulant_all()) return false;
	

}

function sc_enemy_faction_simulant_all(){
	
	if (!sc_faction_register_simulant()) return false;
	if !(sc_enemy_faction_simulant_projectiles()) return false;
	if !(sc_enemy_faction_simulant_weapons()) return false;
	if !(sc_enemy_faction_simulant_ships()) return false;
	
}

function sc_enemy_faction_simulant_projectiles(){

	if (!sc_projectile_register_simulant_pulse()) return false;

}

function sc_enemy_faction_simulant_weapons(){

	if (!sc_weapon_register_simulant_pulse()) return false;
}

function sc_enemy_faction_simulant_ships(){
	
	if (!sc_enemy_register_twin_fighter()) return false;

}