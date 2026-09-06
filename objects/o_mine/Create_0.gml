/// @description Initializes one generic mine.
initialized = false;

if (!is_struct(mine_create)
|| !sc_mine_init(id, mine_create))
    instance_destroy();