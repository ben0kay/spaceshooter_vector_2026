/// @description Initializes one deployed player mine.
initialized = false;

if (!is_struct(mine_create)
|| !sc_player_mine_init(id, mine_create))
    instance_destroy();