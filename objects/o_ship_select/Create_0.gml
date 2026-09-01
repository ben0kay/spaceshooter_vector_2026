ship_select = sc_ship_select(id, spawn_x, spawn_y);

if (!is_struct(ship_select))
{
    global.LevelState = LevelState.FAILED;
    instance_destroy();
}