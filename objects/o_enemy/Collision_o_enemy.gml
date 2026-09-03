/// @description Resolves each overlapping enemy pair once.
if (!initialized || !other.initialized) exit;

if (id < other.id)
    sc_enemy_separation_resolve(id, other);